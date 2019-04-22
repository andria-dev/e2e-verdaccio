#!/bin/bash

set -e

local_registry=${LOCAL_REGISTRY_URL:-"http://localhost:4873"}
if [ ! -z $PACKAGE_RUNNER ]; then
  package_runner=$PACKAGE_RUNNER
elif [ -f pnpm-lock.yaml ]; then
  package_runner="pnpx"
else
  package_runner="npx"
fi

# Start local registry
tmp_registry_log=`mktemp`
bash -c "nohup verdaccio &>$tmp_registry_log &"

# Wait for `verdaccio` to boot
grep -q 'http address' <(tail -f $tmp_registry_log)

# Login so that we can "publish"
bash -c "${package_runner} npm-cli-login -u test -p test -e test@test.com -r $local_registry"

# Unpublish current version
bash -c "npm unpublish -f --registry $local_registry"
# Run publish command
bash -c "npm publish --registry $local_registry"

echo
echo "Running the registry on http://localhost:4873"
read -n 1 -s -r -p "Press any key to exit and close the verdaccio server"
echo