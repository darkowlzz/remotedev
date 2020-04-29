#!/usr/bin/env bash

set -e

# This script destroys any existing resources created by pulumi in a given
# stack.
# Arguments:
# - $1 : pulumi stack name

source envsetup/vars.sh

STACK_NAME="${1:-$DEFAULT_STACK}"

# Check if the stack exists before attempting a delete.
if $(pulumi stack ls -j | grep -q "$STACK_NAME"); then
    pulumi destroy -y --skip-preview --stack $STACK_NAME
else
    echo "$STACK_NAME stack not found..."
fi
