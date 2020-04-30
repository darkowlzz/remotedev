#!/usr/bin/env bash

set -e

# This script syncs source dirs into .sync/ dir, excluding .git dir and the
# content of .gitignore.

source envsetup/vars.sh

# YQ runs in a container. Pass config file path in the container.
source_dir=$($YQ r $CONFIG_FILE_IN_CONTAINER source)
base_dir=$(basename $source_dir)

# Ensure sync directory exists.
mkdir -p "$PWD/.sync"

# Copy the source into the local sync dir.
local_copy="$PWD/.sync/$base_dir"
pushd $source_dir
    echo "Copying $source_dir into local sync dir $local_copy..."
    rsync -avzq --exclude .git/ --exclude .gitignore . $local_copy
popd
