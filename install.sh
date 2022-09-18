#!/bin/sh

docker pull atidyshirt/jordanp-env:0.4
docker run -it -v $(pwd):/home/ws --detach-keys="ctrl-d" -v ~/.gitconfig:/etc/gitconfig atidyshirt/jordanp-env:0.4 /bin/zsh
