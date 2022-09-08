#!/bin/sh

docker run -it -v $(pwd):/home/ws -v ~/.gitconfig:/etc/gitconfig atidyshirt:jordanp-env /bin/zsh
