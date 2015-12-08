# Alpine Linux Dockerfile

FROM blueimp/alpine:3.2

MAINTAINER Fraser Xu <xvfeng123@gmail.com>

ENV VERSION=v0.10.41 CFLAGS="-D__USE_MISC" NPM_VERSION=2
# ENV VERSION=v0.12.9 NPM_VERSION=2
# ENV VERSION=v4.2.3 NPM_VERSION=2
# ENV VERSION=v5.1.1 NPM_VERSION=3

# For base builds
ENV CONFIG_FLAGS="--without-npm" RM_DIRS=/usr/include
# ENV CONFIG_FLAGS="--fully-static --without-npm" DEL_PKGS="libgcc libstdc++" RM_DIRS=/usr/include

# Install dependencies:
RUN apk add --update \
    curl \
    make \
    gcc \
    g++ \
    python \
    linux-headers \
    paxctl \
    libgcc \
    libstdc++ \
    openssl \
    # Install the docker package for its dependencies (git, iptables, xz):
    docker \
    # Install bash for the dind setup script:
    bash \
    # Install py-pip as requirement to install docker-compose:
    py-pip \
    # Install the openssh-client (used by CI agents like buildkite):
    openssh-client \
  # Override the packaged docker (1.6.2) with docker 1.7.1:
  && curl https://get.docker.com/builds/Linux/x86_64/docker-1.7.1 > \
    /usr/bin/docker && chmod 755 /usr/bin/docker \
  # Install docker-compose (and upgrade pip):
  && pip install --upgrade \
    pip \
    docker-compose==1.5.2 \
  # Clean up obsolete files:
  && rm -rf \
    # Clean up any temporary files:
    /tmp/* \
    # Clean up the pip cache:
    /root/.cache \
    /var/cache/apk/* \
    # Remove any compiled python files (compile on demand):
    `find / -regex '.*\.py[co]'`

# Install the dind (docker-in-docker) setup script:
RUN wget -O /usr/local/bin/dind \
  https://raw.githubusercontent.com/docker/docker/v1.7.1/hack/dind && \
  chmod 755 /usr/local/bin/dind

# Install Nodejs
RUN curl -sSL https://nodejs.org/dist/${VERSION}/node-${VERSION}.tar.gz | tar -xz && \
  cd /node-${VERSION} && \
  ./configure --prefix=/usr ${CONFIG_FLAGS} && \
  make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  make install && \
  paxctl -cm /usr/bin/node && \
  cd / && \
  if [ -x /usr/bin/npm ]; then \
    npm install -g npm@${NPM_VERSION} && \
    find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
  fi && \
  apk del curl make gcc g++ python linux-headers paxctl ${DEL_PKGS} && \
  rm -rf /etc/ssl /node-${VERSION} ${RM_DIRS} \
    /usr/share/man /tmp/* /var/cache/apk/* /root/.npm /root/.node-gyp \
    /usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html

CMD ["bash"]
