#!/bin/sh

docker run -it -v ~/.gitconfig:/etc/gitconfig -v ~/.ssh:/root/.ssh -v $(pwd):/home/workspace --detach-keys="ctrl-x" atidyshirt/jordanp-env:latest
