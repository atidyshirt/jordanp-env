#!/bin/sh

docker run -it -v ~/.gitconfig:/etc/gitconfig -v $(pwd):/home/workspace --detach-keys="ctrl-x" atidyshirt/jordanp-env:latest
