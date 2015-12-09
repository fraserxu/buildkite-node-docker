FROM blueimp/alpine:3.2
MAINTAINER Fraser Xu <xvfeng123@gmail.com>
# BK-TAG: latest

ENV DOCKER_COMPOSE_VERSION=1.4.2 \
    BUILDKITE_AGENT_VERSION=edge \
    BUILDKITE_BUILD_PATH=/buildkite/builds \
    BUILDKITE_HOOKS_PATH=/buildkite/hooks \
    BUILDKITE_BOOTSTRAP_SCRIPT_PATH=/buildkite/bootstrap.sh \
    PATH=$PATH:/buildkite/bin

# ENV VERSION=v0.10.41 CFLAGS="-D__USE_MISC" NPM_VERSION=2
# ENV VERSION=v0.12.9 NPM_VERSION=2
ENV VERSION=v4.2.3 NPM_VERSION=2
# ENV VERSION=v5.1.1 NPM_VERSION=3

# For base builds
# ENV CONFIG_FLAGS="" RM_DIRS=/usr/include
# ENV CONFIG_FLAGS="--fully-static --without-npm" DEL_PKGS="libgcc libstdc++" RM_DIRS=/usr/include

RUN apk add --update curl make gcc g++ python linux-headers paxctl libgcc libstdc++ && \
  curl -sSL https://nodejs.org/dist/${VERSION}/node-${VERSION}.tar.gz | tar -xz && \
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

RUN apk add --update wget bash git perl openssh-client py-pip py-yaml \
    && pip install -U pip docker-compose==${DOCKER_COMPOSE_VERSION} \
    && DESTINATION=/buildkite bash -c "`curl -sL https://raw.githubusercontent.com/buildkite/agent/master/install.sh`" \
    && rm -rf \
      # Clean up any temporary files:
      /tmp/* \
      # Clean up the pip cache:
      /root/.cache \
      # Remove any compiled python files (compile on demand):
      `find / -regex '.*\.py[co]'`


ENTRYPOINT ["buildkite-agent"]
CMD ["start"]
