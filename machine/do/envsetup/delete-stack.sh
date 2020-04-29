#!/usr/bin/env bash

set -e

# This script deletes a given pulumi stack if it exists.
# Arguments:
# - $1 : pulumi stack name

source envsetup/vars.sh

STACK_NAME="${1:-$DEFAULT_STACK}"

if $(pulumi stack ls -j | grep -q "$STACK_NAME"); then
    echo "Deleting stack $STACK_NAME..."
    pulumi stack rm $STACK_NAME -y -f
else
    echo "$STACK_NAME stack not found..."
fi
