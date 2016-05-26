#!/bin/bash

# This script runs on the LXC image as root to install and configure Juju-2.
# When a user is passed as an argument, the user must already be created.

set -ex

# When there are not enough arguments default to the ubuntu user.
if [ "$#" -lt 1 ]; then
  USER=ubuntu
else
  USER=$1
fi

apt-get update -qq --fix-missing
# Install tools like add-apt-repository
apt-get install -qy software-properties-common
# The stable ppa is required for charm-tools.
apt-add-repository -y ppa:juju/stable
# Add the devel ppa to get the latest juju.
apt-add-repository -y ppa:juju/devel
apt-get update -qq --fix-missing

INSTALL_PACKAGES=(juju-2.0 \
  build-essential \
  byobu \
  charm \
  charm-tools \
  cython \
  git \
  make \
  openssh-client \
  python-dev \
  python-flake8 \
  python-pip \
  python-virtualenv \
  rsync \
  unzip \
  tree \
  vim \
  virtualenvwrapper)

apt-get -qy install ${INSTALL_PACKAGES[*]}

HOME=/home/${USER}
# Set up the Juju environment variables for the user.
RC=${HOME}/.bashrc
# JUJU_DATA is the path to Juju's configuration files.
echo "export JUJU_DATA=${HOME}/.local/share/juju" >> $RC
# JUJU_REPOSITORY is the directory to look for charms.
echo "export JUJU_REPOSITORY=${HOME}/charms" >> $RC
# INTERFACE_PATH is the directory for charm reactive interfaces.
echo "export INTERFACE_PATH=${HOME}/interfaces" >> $RC
# LAYER_PATH is the directory for charm reactive layers.
echo "export LAYER_PATH=${HOME}/layers" >> $RC
JUJU_VERSION=$(juju version)
echo "echo 'welcome to ${JUJU_VERSION}'" >> $RC
# Create the JUJU_DATA directory.
mkdir -p ${HOME}/.local/share/juju
# Create the Juju charm directories so they can be mounted in other steps.
mkdir -p ${HOME}/charms
mkdir ${HOME}/charms/precise
mkdir ${HOME}/charms/trusty
mkdir ${HOME}/charms/xenial
mkdir ${HOME}/layers
mkdir ${HOME}/interfaces
mkdir ${HOME}/builds

chown -R ${USER}:${USER} ${HOME}

# Remove uneeded packages.
REMOVE_PACKAGES=(cython gcc)

apt-get remove -qy ${REMOVE_PACKAGES[*]}

apt-get autoremove -qy
apt-get autoclean -qy
apt-get clean -qy
