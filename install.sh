#!/bin/sh

docker run -it -v $(pwd):/home/ws --detach-keys="ctrl-d" -v ~/.gitconfig:/etc/gitconfig jordanp-env
