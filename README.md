# Charm in LXC

This project provides a method to build a Linux Container (LXC) with
a Juju Charm development environment including all the related tools. The
system container can be used for isolation and portability across other hosts.

## Who should use this project?

This project contains a procedure to build the system container with Juju
inside it. This project is useful to people who want to use Juju but want to
isolate the program to a system container, or developers who want to build
Juju charms and want the tools isolated to the container.

If you simply want to run Juju, pull this repository and build the container.
This project requires LXD so you must have that installed on your machine.

## Install prerequisites

Install LXD using the package manager for your distribution.

```Shell
sudo apt-get install lxd
```
Then either log out and log in again to get the user's group membership
refreshed, or use a command to add yourself to the "lxd" group immediately:

```Shell
newgrp lxd
```

Check out [linuxcontainers.org](https://linuxcontainers.org/lxd/) for more
information on LXD and how to use it.

## Download

Clone the repository from github:

```Shell
git clone https://github.com/mbruzek/charm-container.git
cd charm-container
```

## Run

To build your own Juju container run the build script, then you are
able to use the container.

```Shell
./build.sh
```
or
```Shell
make build
```

Now that the container is build and running, you can get a shell inside it
with:

```Shell
lxc exec charm-container -- /bin/bash -c 'cd /home/ubuntu/ && su ubuntu'
```
or
```Shell
make bash
```

## Remove

If you no longer want the container or if the build failed, remove the build
artifacts by running the following commands:  

```Shell
./clean.sh
```
or
```Shell
make clean
```
