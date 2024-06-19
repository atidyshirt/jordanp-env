#!/bin/sh

docker run -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/.gitconfig:/etc/gitconfig \
  -v ~/.ssh:/root/.ssh \
  -v $(pwd):/home/workspace \
  --detach-keys="ctrl-x" \
  atidyshirt/jordanp-env:latest
