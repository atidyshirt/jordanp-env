#!/bin/sh

TIMESTAMP="$(date +'%d-%m-%Y')"
docker build github.com/atidyshirt/jordanp-env
docker run --rm --network=host --name jordanp-env-${TIMESTAMP} -v `pwd`:`pwd` -w `pwd` -v /var/run/docker.sock:/var/run/docker.sock -it ubuntu /bin/bash
