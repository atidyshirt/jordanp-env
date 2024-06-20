#!/bin/sh

CONTAINER_NAME="env-$(basename $(pwd) | sed 's/[^a-zA-Z0-9]/-/g')"
CONTAINER_ID=$(docker ps -aqf name=$CONTAINER_NAME)

if [[ -z "$CONTAINER_ID" ]]; then
    docker run -it \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v ~/.gitconfig:/etc/gitconfig \
      -v ~/.ssh:/root/.ssh \
      -v $(pwd):/home/workspace \
      --detach-keys="ctrl-x" \
      --name $CONTAINER_NAME \
      atidyshirt/jordanp-env:latest
else
    docker start -ai $CONTAINER_NAME
fi
