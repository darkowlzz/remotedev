#!/usr/bin/env bash

set -e

# This script fetches the machine IP from pulumi and creates a ssh session with
# the machine.

source envsetup/vars.sh

# Construct the local source path and destination path.
original_source=$(yq r $CONFIG_FILE_IN_CONTAINER source)
source_base_dir=$(basename $original_source)
dest_dir=$(yq r $CONFIG_FILE_IN_CONTAINER destination)
target_dir="$dest_dir/$source_base_dir"

# Get the configured owner name to work as in remote.
owner=$(yq r $CONFIG_FILE_IN_CONTAINER owner)

# Get the machine IP.
pulumi_stack=$(yq r $CONFIG_FILE_IN_CONTAINER pulumi.stack)
IP=$(pulumi stack output ip --stack $pulumi_stack)

# Enable ssh access to the given owner on remote by copying the authorized keys
# to the user's account.
owner_ssh_dir="/home/$owner/.ssh"
ssh root@$IP "mkdir -p $owner_ssh_dir; cp -r /root/.ssh/* $owner_ssh_dir; chown -R $owner $owner_ssh_dir"
# Create the target dir as the owner.
ssh $owner@$IP "mkdir -p $target_dir"

# SSH into the target dir.
echo "Loggin as $owner at $target_dir"
ssh -t $owner@$IP "cd $target_dir; bash"
