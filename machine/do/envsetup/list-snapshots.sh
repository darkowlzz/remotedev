#!/usr/bin/env bash

set -e

# This script lists all the digitalocean snapshots in an account.

curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" "https://api.digitalocean.com/v2/snapshots"
