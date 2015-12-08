#!/bin/sh

# Setup the isolated docker environment
# if the docker socket has not been bind-mounted:
[ ! -S /var/run/docker.sock ] && dind true
