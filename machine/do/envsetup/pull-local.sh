#!/usr/bin/env bash

set -e

# This script copies the files in sync directory, to the original source
# directory. The source for this copying is the directory under .sync and the
# destination is the source in the config. This is the second part of the pull
# operation after copying files from remote to the sync directory.

source envsetup/vars.sh

# YQ runs in a container. Pass config file path in the container.
original_source=$($YQ r $CONFIG_FILE_IN_CONTAINER source)
destination=$(dirname $original_source)
# Derive the sync directory name from the source path.
dest_base_dir=$(basename $original_source)
source="$PWD/.sync/$dest_base_dir"

# Sync the file, nothing to exclude since files in .sync already have files
# after exclusion in the initial sync.
echo "Copying $source into $destination..."
rsync -avzh "$source" "$destination"
