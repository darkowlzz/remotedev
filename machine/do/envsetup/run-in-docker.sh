#!/usr/bin/env bash

set -e

# This script helps run all the operations within a container, using mounted
# paths for keeping persistent data, like the pulumi state and credentials.
# Arguments:
# - $1 : container image to run the scripts in
# - $2 : path of the script to run
# - $3 : any argument to the script

source envsetup/vars.sh
source secrets.sh

CONTAINER_IMAGE="${1:-$DEFAULT_CONTAINER_IMAGE}"
SCRIPT=$2
SCRIPT_ARG=$3

echo "Using container image: $CONTAINER_IMAGE"

docker run --rm -ti \
    -e PULUMI_CONFIG_PASSPHRASE="$PULUMI_CONFIG_PASSPHRASE" \
    -e DIGITALOCEAN_TOKEN="$DIGITALOCEAN_TOKEN" \
    -w /do \
    -v "$(pwd)":/do \
    -v "$PULUMI_STACKS_DIR":/root/.pulumi/stacks \
    -v "$PULUMI_CREDENTIALS_FILE":/root/.pulumi/credentials.json \
    -v "$SSH_KEY_DIR":/root/.ssh \
    "$CONTAINER_IMAGE" \
    -c "bash $SCRIPT $SCRIPT_ARG"
