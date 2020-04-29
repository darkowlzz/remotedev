#!/usr/bin/env bash

set -e

# This script fetches the machine IP from pulumi and creates a ssh session with
# the machine.

source envsetup/vars.sh

STACK_NAME="${1:-$DEFAULT_STACK}"

IP=$(pulumi stack output ip --stack $STACK_NAME)
echo "Connecting to $IP"
# Default user for digitalocean machine images is root.
ssh root@$IP
