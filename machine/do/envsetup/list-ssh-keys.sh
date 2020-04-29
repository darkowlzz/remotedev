#!/usr/bin/env bash

set -e

# This script lists of all the ssh keys in a digitalocean account.

curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" "https://api.digitalocean.com/v2/account/keys?page=2"
