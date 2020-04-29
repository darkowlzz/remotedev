#!/usr/bin/env bash

set -e

# This script provisions the resources in a given stack using pulumi, skipping
# any interactive options and previews. If the pulumi stack doesn't exists, it
# creates the stack.
# Arguments:
# - $1 : pulumi stack name

source envsetup/vars.sh

STACK_NAME="${1:-$DEFAULT_STACK}"

# Ensure the pulumi state is saved locally.
pulumi login --local

# Create a new stack if needed.
if ! $(pulumi stack ls -j | grep -q "$STACK_NAME"); then
    echo "$STACK_NAME not found, creating a new stack..."
    pulumi stack init $STACK_NAME
fi

pulumi up -y --skip-preview --stack $STACK_NAME
