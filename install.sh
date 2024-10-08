#!/bin/bash

CONTAINER_NAME="env-$(basename $(pwd) | sed 's/[^a-zA-Z0-9]/-/g')"
CONTAINER_ID=$(docker ps -aqf name=$CONTAINER_NAME)

if [[ -z "$CONTAINER_ID" ]]; then
    docker run -it \
      -v /var/run/docker.sock:/var/run/docker.sock:rw,Z \
      -v ~/.gitconfig:/etc/gitconfig:rw,Z \
      -v ~/.ssh/id_rsa:/root/.ssh/id_rsa \
      -v ~/.ssh/id_ed25519:/root/.ssh/id_ed25519 \
      -v ~/.ssh/known_hosts:/root/.ssh/known_hosts \
      -v $(pwd):/home/workspace:rw,Z \
      --privileged=true \
      --detach-keys="ctrl-x" \
      --name $CONTAINER_NAME \
      atidyshirt/jordanp-env:latest
else
    docker start -ai $CONTAINER_NAME
fi
