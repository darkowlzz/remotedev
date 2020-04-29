#!/usr/bin/env bash

set -e

# This script runs pulumi preview on the given stack. It shows the state of the
# machine and plans for any update if pulumi up is run.
# Arguments:
# - $1 : pulumi stack name

source envsetup/vars.sh

STACK_NAME="${1:-$DEFAULT_STACK}"

pulumi preview --stack $STACK_NAME
