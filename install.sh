#!/bin/sh

docker run -it -v $(pwd):/home/workspace --detach-keys="ctrl-d" -v ~/.gitconfig:/etc/gitconfig atidyshirt/jordanp-env:latest
