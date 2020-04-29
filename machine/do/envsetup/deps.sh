#!/usr/bin/env bash

set -e

# This script installs all the dependencies for setting up an environment.
# - generate ssh keys to be used with the provisioned machine and upload the key
#   to digitalocean
# - create pulumi stacks dir and credentials file
# - create a machine config file based on the sample config with populated
#   attributes

source envsetup/vars.sh
source secrets.sh

# Generate a new ssh key.
if [ ! -d "$SSH_KEY_DIR" ]; then
    echo "Creating ssh key dir $SSH_KEY_DIR..."
    mkdir -p $SSH_KEY_DIR
fi

# If both the private and public keys don't exist, generate.
if [ ! -f "$PRIVATE_KEY_FILE" ] && [ ! -f "$PUBLIC_KEY_FILE" ]; then
    # keyname is the name of the ssh key.
    keyname="remotedev-$RANDOM"

    echo "Generating ssh key..."
    ssh-keygen -t rsa -b 4096 -C "$keyname@example.com" -f .ssh/id_rsa

    # Upload the public key to digital ocean.
    pubkey=$(cat $PUBLIC_KEY_FILE)
    # Create a ssh key data file to be posted to the DO API.
    # Refer: https://stackoverflow.com/questions/38860529/create-json-using-jq-from-pipe-separated-keys-and-values-in-bash
    $JQ --arg key0 'name' --arg value0 "$keyname" --arg key1 'public_key' --arg value1 "$pubkey" '. | .[$key0]=$value0 | .[$key1]=$value1' <<<'{}' > "$TEMP_DO_SSH_KEY_FILE"
    # Save the new key create response in a file. This can be used for deleting
    # the key later by using the key ID or fingerprint in the file.
    echo "Creating a new digitalocean ssh key with the generated ssh key..."
    curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" -d "@$TEMP_DO_SSH_KEY_FILE" "https://api.digitalocean.com/v2/account/keys" > "$TEMP_DO_SSH_KEY_DETAILS"
    rm "$TEMP_DO_SSH_KEY_FILE"
else
    echo " ✓ ssh key found."

    # Check again for the existence of both the private and public key. If
    # either one is missing, fail and request for manual cleanup.

    if [ ! -f "$PRIVATE_KEY_FILE" ]; then
        echo " ⚠️  private key $PRIVATE_KEY_FILE not found"
        echo "Partial ssh keys found. Please cleanup $SSH_KEY_DIR manually and run again."
        exit 1
    fi

    if [ ! -f "$PUBLIC_KEY_FILE" ]; then
        echo " ⚠️  private key $PUBLIC_KEY_FILE not found"
        echo "Partial ssh keys found. Please cleanup $SSH_KEY_DIR manually and run again."
        exit 1
    fi
fi

# Create a local .pulumi directory with content that needs to be persistent. The
# pulumi container includes the pulumi plugins installed in .pulumi/plugins
# directory. Create local stacks and credentials.

# Create local pulumi stacks directory.
if [ ! -d "$PULUMI_STACKS_DIR" ]; then
    echo "Creating local pulumi stacks directory $PULUMI_STACKS_DIR..."
    mkdir -p $PULUMI_STACKS_DIR
else
    echo " ✓ local pulumi stacks found."
fi

# Create local pulumi credentials file with valid json content.
if [ ! -f "$PULUMI_CREDENTIALS_FILE" ]; then
    echo "Creating pulumi credentials file $PULUMI_CREDENTIALS_FILE..."
    echo "{}" > $PULUMI_CREDENTIALS_FILE
else
    echo " ✓ pulumi credentials file found."
fi

# Copy the sample configuration file and populate with the generated data above.
if [ ! -f $CONFIG_FILE ]; then
    echo "Creating a new config file from the sample config and updating it..."
    cp "$SAMPLE_CONFIG_FILE" "$CONFIG_FILE"
fi
# Get the ssh key ID and add it in the config file.
pubkeyid=$(cat $TEMP_DO_SSH_KEY_DETAILS | $JQ .ssh_key.id)
# cat $CONFIG_FILE | $YQ w - sshKeys[+] "$pubkeyid" > "$CONFIG_FILE"
$YQ w -i $(basename $CONFIG_FILE) sshKeys[+] "$pubkeyid"

