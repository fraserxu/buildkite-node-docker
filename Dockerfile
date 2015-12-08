# Alpine Linux Dockerfile

FROM alpine:3.2

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
    libstd++ \
    openssl \
    # Install the docker package for its dependencies (git, iptables, xz):
    docker \
    # Install bash for the dind setup script:
    bash \
    # Install the openssh-client (used by CI agents like buildkite):
    openssh-client \
  # Override the packaged docker (1.6.2) with docker 1.7.1:
  && curl https://get.docker.com/builds/Linux/x86_64/docker-1.7.1 > \
    /usr/bin/docker && chmod 755 /usr/bin/docker \
    # Clean up obsolete files:
  && rm -rf \
    # Clean up any temporary files:
    /tmp/* \
    # Clean up the pip cache:
    /root/.cache \
    /var/cache/apk/*

# Install the entrypoint wrapper script:
RUN printf '%s\n' '#!/bin/sh' \
  'for file in /usr/local/etc/entrypoint.d/*; do "$file"; done; exec "$@"' > \
  /usr/local/bin/entrypoint && chmod 755 /usr/local/bin/entrypoint

# Create the entrypoint init scripts directory:
RUN mkdir -p /usr/local/etc/entrypoint.d

# Install the envconfig script:
RUN wget -O /usr/local/bin/envconfig \
  https://raw.githubusercontent.com/blueimp/container-tools/1.7.0/bin/envconfig.sh && \
  chmod 755 /usr/local/bin/envconfig

# Create an empty envconfig configuration file:
RUN touch /usr/local/etc/envconfig.conf

# Add envconfig as entrypoint init script:
RUN ln -s /usr/local/bin/envconfig /usr/local/etc/entrypoint.d/20-envconfig.sh

# Install superd - a supervisor daemon for multi-process docker containers:
RUN wget -O /usr/local/bin/superd \
  https://raw.githubusercontent.com/blueimp/container-tools/1.7.0/bin/superd.sh && \
  chmod 755 /usr/local/bin/superd

# Create an empty superd configuration file:
RUN touch /usr/local/etc/superd.conf

# Install log - a script to execute a given command and log the output:
RUN wget -O /usr/local/bin/log \
  https://raw.githubusercontent.com/blueimp/container-tools/1.7.0/bin/log.sh && \
  chmod 755 /usr/local/bin/log

# Install gosu - a tool to execute a command as another user:
RUN wget -O /usr/local/bin/gosu \
  https://github.com/tianon/gosu/releases/download/1.5/gosu-amd64 && \
  chmod 755 /usr/local/bin/gosu

ENTRYPOINT ["entrypoint"]

# Install the dind (docker-in-docker) setup script:
RUN wget -O /usr/local/bin/dind \
  https://raw.githubusercontent.com/docker/docker/v1.7.1/hack/dind && \
  chmod 755 /usr/local/bin/dind

# Add the superd configuration file:
COPY superd.conf /usr/local/etc/

# Add the entrypoint init scripts:
COPY entrypoint.d /usr/local/etc/entrypoint.d

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

CMD ["sh"]
