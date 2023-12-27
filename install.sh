#! /bin/sh

# exit if a command fails
set -eo pipefail

apk update
apk add openssl aws-cli
apk add mongodb-tools

# cleanup
rm -rf /var/cache/apk/*
