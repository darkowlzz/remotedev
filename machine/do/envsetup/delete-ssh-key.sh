#!/usr/bin/env bash

set -e

# This script deletes the ssh key from digital ocean and any temporary file
# containing the key details.

source envsetup/vars.sh
source secrets.sh

pubkeyid=$(cat $TEMP_DO_SSH_KEY_DETAILS | $JQ .ssh_key.id)
echo "Deleting digitalocean ssh key ID: $pubkeyid"
curl -X DELETE -H "Content-Type: application/json" -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" "https://api.digitalocean.com/v2/account/keys/$pubkeyid"
rm $TEMP_DO_SSH_KEY_DETAILS
