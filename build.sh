#!/bin/bash

# Create a new container with a Juju charm development environement installed.

set -ex

if [ -z "$1" ]; then
  CODENAME=$(lsb_release -cs)
else
  CODENAME=$1
fi
if [ -z "$2" ]; then
  USER=ubuntu
else
  USER=$2
fi
ARCHITECTURE=$(dpkg --print-architecture)

CONTAINER_NAME=charm-container
IMAGE_REPO_NAME=lxd-image-repository

# Add the linuxcontainers image repository.
lxc remote add $IMAGE_REPO_NAME images.linuxcontainers.org
# Pull a clean ubuntu image from the image repository.
lxc launch $IMAGE_REPO_NAME:ubuntu/${CODENAME}/${ARCHITECTURE} ${CONTAINER_NAME}
# Remove the linuxcontainers image repository.
lxc remote remove $IMAGE_REPO_NAME
# Sleep a few seconds to allow the network to start up.
sleep 2
# List the lxc image that was just created.
lxc list
# The LXC images already have an ubuntu user, create any other users.
if [ "${USER}" != "ubuntu" ]; then
  lxc exec ${CONTAINER_NAME} -- useradd -m ${USER} -s /bin/bash
fi
# Push the setup file to the container.
lxc file push setup-juju-2.sh ${CONTAINER_NAME}/home/${USER}/
# Run the file to setup Juju-2 inside the container as root.
lxc exec ${CONTAINER_NAME} -- /home/${USER}/setup-juju-2.sh ${USER}
# Remove the file when complete.
lxc exec ${CONTAINER_NAME} -- rm /home/${USER}/setup-juju-2.sh
# JUJU_REPOSITORY is the location to look for charms.
if [ -z "${JUJU_REPOSITORY}" ]; then
  echo "No JUJU_REPOSITORY found, please enter your charm directory: "
  read JUJU_REPOSITORY
fi

function map_directory() {
  # Map a directory in lxc from source ($1) to destination ($2) as name ($3)
  local SOURCE=$1
  local DESTINATION=$2
  local NAME=$3
  # Can only map a directory that exists on the host.
  if [ -d "${SOURCE}" ]; then
    lxc config device add ${CONTAINER_NAME} ${NAME} disk \
    source=${SOURCE} path=${DESTINATION}
  else
    echo "Warning: ${SOURCE} does not exist, could not map ${NAME}"
  fi
}

# Map the charm directories to this container.
map_directory "${JUJU_REPOSITORY}/precise" /home/${USER}/charms/precise precise
map_directory "${JUJU_REPOSITORY}/trusty" /home/${USER}/charms/trusty trusty
map_directory "${JUJU_REPOSITORY}/xenial" /home/${USER}/charms/xenial xenial
# Map JUJU_DATA from the host environment.
map_directory "${JUJU_DATA}" /home/${USER}/.local/share/juju juju-data
# Map INTERFACE_PATH from the host environment.
map_directory "${INTERFACE_PATH}" /home/${USER}/interfaces interfaces
# Map LAYER_PATH from the host environment.
map_directory "${LAYER_PATH}" /home/${USER}/layers layers

echo "Build completed successfully, you can now use ${CONTAINER_NAME}"
