#!/usr/bin/env bash

set -e

# Update the system.
apt-get update -y
apt-get upgrade -y

# Install all the dependencies for ignite. Install docker for container tooling.
# This installs containerd as well.
apt-get install -y --no-install-recommends dmsetup openssh-client git binutils \
    docker.io make

# Install CNI binaries.
export CNI_VERSION=v0.8.2
export ARCH=$([ $(uname -m) = "x86_64" ] && echo amd64 || echo arm64)
mkdir -p /opt/cni/bin
curl -sSL https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz | tar -xz -C /opt/cni/bin

# Setup a sudo user.
USERNAME=demouser
# users file contains list of users to be created using newusers command.
USERS_FILE=/tmp/users
# bash profile path.
BASH_PROFILE_SRC=/tmp/bash_profile
BASH_PROFILE=/home/demouser/.bash_profile

if [ -f "$USERS_FILE" ]; then
    echo "creating new users..."
    newusers $USERS_FILE
    adduser $USERNAME sudo
    # Grant docker group access to the user.
    usermod -aG docker $USERNAME
    # Copy bash profile for the user and change the ownership.
    cp $BASH_PROFILE_SRC $BASH_PROFILE
    chown $USERNAME:$USERNAME $BASH_PROFILE
fi
