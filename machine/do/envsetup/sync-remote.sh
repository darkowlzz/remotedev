#!/usr/bin/env bash

set -e

# This script logs into the remote machine, ensures that rsync can be run with
# the configured owner user by copying the ssh authorized keys from root to the
# configured user's account. It then logs in as the configured user and creates
# the destination directory. Runs rsync to sync the local files to destination.

source envsetup/vars.sh

# Construct the local source path and destination path.
original_source=$(yq r $CONFIG_FILE_IN_CONTAINER source)
source_base_dir=$(basename $original_source)
source_dir="$PWD/.sync/$source_base_dir"
dest_dir=$(yq r $CONFIG_FILE_IN_CONTAINER destination)

# Get the configured owner name to rsync to remote.
owner=$(yq r $CONFIG_FILE_IN_CONTAINER owner)

# Get the machine IP.
pulumi_stack=$(yq r $CONFIG_FILE_IN_CONTAINER pulumi.stack)
IP=$(pulumi stack output ip --stack $pulumi_stack)

# Enable rsync to the given owner on remote by copying the authorized keys to
# the user's account.
owner_ssh_dir="/home/$owner/.ssh"
ssh root@$IP "mkdir -p $owner_ssh_dir; cp -r /root/.ssh/* $owner_ssh_dir; chown -R $owner $owner_ssh_dir"
# Create the destination dir as the owner.
ssh $owner@$IP "mkdir -p $dest_dir"

echo "Syncing $source_base_dir to $IP:$dest_dir..."
rsync -avzh $source_dir $owner@$IP:$dest_dir
echo "Sync complete."
