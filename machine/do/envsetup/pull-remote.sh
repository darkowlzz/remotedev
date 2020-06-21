#!/usr/bin/env bash

set -e

# This script logs into the remote machine, ensures that rsync can be run with
# the configured owner user by copying the ssh authorized keys from root to the
# configured user's account. It then runs rsync to sync the remote source with
# a local destination.

source envsetup/vars.sh

# YQ runs in a container. Pass config file path in the container.
original_source=$(yq r $CONFIG_FILE_IN_CONTAINER source)
source_base_dir=$(basename $original_source)
original_dest=$(yq r $CONFIG_FILE_IN_CONTAINER destination)

remote_source_dir="$original_dest/$source_base_dir"
local_dest="$PWD/.sync/"

# Get the configured owner name to rsync to remote.
owner=$(yq r $CONFIG_FILE_IN_CONTAINER owner)

# Get the machine IP.
pulumi_stack=$(yq r $CONFIG_FILE_IN_CONTAINER pulumi.stack)
IP=$(pulumi stack output ip --stack $pulumi_stack)

# Enable rsync to the given owner on remote by copying the authorized keys to
# the user's account.
owner_ssh_dir="/home/$owner/.ssh"
ssh root@$IP "mkdir -p $owner_ssh_dir; cp -r /root/.ssh/* $owner_ssh_dir; chown -R $owner $owner_ssh_dir"

remote_source="$owner@$IP:$remote_source_dir"

exclude_file="$local_dest/$source_base_dir/.gitignore"

echo "Syncing $remote_source to $local_dest"
# Exclude the files in gitignore. Since rsync accepts relative paths to exclude
# files, use the gitignore in the sync dir instead of the gitignore in the
# remote repo.
rsync -avzh --exclude-from "$exclude_file" $remote_source $local_dest
#rsync -avzh --exclude .git/ --exclude-from .gitignore $remote_source $local_dest
echo "Sync complete."
