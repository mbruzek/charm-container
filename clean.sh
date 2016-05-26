#!/bin/bash

set -ex

CONTAINER_NAME=charm-container
IMAGE_REPO_NAME=lxd-image-repository

lxc stop ${CONTAINER_NAME} || true
lxc delete ${CONTAINER_NAME} || true
lxc remote remove ${IMAGE_REPO_NAME} || true
rm -f build_output.txt
