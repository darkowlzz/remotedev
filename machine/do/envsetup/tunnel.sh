#!/usr/bin/env bash

set -e

source envsetup/vars.sh

STACK_NAME="${1:-$DEFAULT_STACK}"

SOCKS5_PORT="8123"

IP=$(pulumi stack output ip --stack $STACK_NAME)
echo "Creating SOCKS5 proxy tunnel to $IP at port $SOCKS5_PORT ..."

# NOTE: This script runs in a container. But creating a SOCKS5 tunnel from
# container, even with host network, doesn't work. Create a script that can be
# run from the host to create SOCKS5 tunnel.

# Default user for digitalocean machine images is root.
echo "ssh -i .ssh/id_rsa -D $SOCKS5_PORT -C -q -N root@$IP" > .tunnel.sh
