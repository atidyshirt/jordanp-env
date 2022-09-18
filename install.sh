#!/bin/sh

docker run -it -v $(pwd):/home/ws --detach-keys="ctrl-d" -v ~/.gitconfig:/etc/gitconfig atidyshirt/jordanp-env:0.3 /bin/zsh
