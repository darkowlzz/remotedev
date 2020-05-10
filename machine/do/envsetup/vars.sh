#!/usr/bin/env bash

set -e

# This file contains the common variables that are used across all the scripts
# in this directory.

SETUP_DIR="$PWD/envsetup"
BIN_DIR="$SETUP_DIR/bin"
JQ_BIN="$BIN_DIR/jq"
PULUMI_STACKS_DIR="$PWD/.pulumi/stacks"
PULUMI_CREDENTIALS_FILE="$PWD/.pulumi/credentials.json"
SSH_KEY_DIR="$PWD/.ssh"
PRIVATE_KEY_FILE="$SSH_KEY_DIR/id_rsa"
PUBLIC_KEY_FILE="$SSH_KEY_DIR/id_rsa.pub"
SAMPLE_CONFIG_FILE="$PWD/config.sample.yaml"
CONFIG_FILE="$PWD/config.yaml"
CONFIG_FILE_IN_CONTAINER="config.yaml"

TEMP_DO_SSH_KEY_FILE="$PWD/.temp-do-ssh-key.json"
TEMP_DO_SSH_KEY_DETAILS="$PWD/.temp-do-ssh-key-details.json"

DEFAULT_STACK="remotedev"
DEFAULT_CONTAINER_IMAGE="darkowlzz/remotedev:v0.0.2"

JQ='docker run --rm -i imega/jq -c'
YQ='docker run --rm -v '${PWD}':/workdir mikefarah/yq yq'
