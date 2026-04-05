#!/bin/bash

IMAGE_NAME="${IMAGE_NAME:-ghcr.io/atidyshirt/jordanp-env}"
IMAGE_VERSION="${IMAGE_VERSION:-latest}"

WORKSPACE="$(pwd -P)"
CONTAINER_NAME="env-$(basename "$WORKSPACE" | sed 's/[^a-zA-Z0-9]/-/g')"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_args=(
  -it
  --detach-keys="ctrl-x"
  -e "JORDANP_WORKSPACE=${WORKSPACE}"
  -e "XDG_CONFIG_HOME=/root/.config"
  -w "${WORKSPACE}"
  -v /var/run/docker.sock:/var/run/docker.sock:rw,Z
  -v "${HOME}/.gitconfig:/etc/gitconfig:rw,Z"
  -v "${WORKSPACE}:${WORKSPACE}:rw,Z"
  --privileged=true
  --name "$CONTAINER_NAME"
)

if ! docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
  docker run "${run_args[@]}" "${IMAGE_NAME}:${IMAGE_VERSION}"
else
  docker start -ai "$CONTAINER_NAME"
fi
