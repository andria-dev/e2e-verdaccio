#!/bin/bash

set -e

local_registry=${LOCAL_REGISTRY_URL:-"http://0.0.0.0:4873"}

# Start local registry
tmp_registry_log=`mktemp`
bash -c "nohup verdaccio &>$tmp_registry_log &"

# Wait for `verdaccio` to boot
grep -q 'http address' <(tail -f $tmp_registry_log)

# Login so that we can "publish"
bash -c "npx npm-cli-login -u test -p test -e test@test.com -r $local_registry"


# Unpublish current version
bash -c "npm unpublish -f --registry $local_registry"
# Run publish command
bash -c "npm publish --registry $local_registry"

read -n 1 -s -r -p "Press any key to exit and close the verdaccio server"
