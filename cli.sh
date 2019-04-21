#!/bin/bash

set -e

# Set local_registry variable with fallback
local_registry=${LOCAL_REGISTRY_URL:-"http://0.0.0.0:4873"}

# Set package_manager to env variable
# Fallback to detecting package lock files
if [ ! -z $PACKAGE_MANAGER ]; then
  package_manager=$PACKAGE_MANAGER
elif [ -f pnpm-lock.yaml ]; then
  package_manager="pnpm"
elif [ -f yarn.lock ]; then
  package_manager="yarn"
elif [ -f package-lock.json ]; then
  package_manager="npm"
else
  echo "Please specify a package manager with the environment variable: PACKAGE_MANAGER."
  echo "Or create a pnpm-lock.yaml, yarn.lock, or package-lock.json and the correct package manager will be used"
fi

# Start local registry
tmp_registry_log=`mktemp`
bash -c "nohup verdaccio &>$tmp_registry_log &"

# Wait for `verdaccio` to boot
grep -q 'http address' <(tail -f $tmp_registry_log)

# Login so that we can "publish"
bash -c "${} npm-cli-login -u test -p test -e test@test.com -r $local_registry"


# Unpublish current version
bash -c "pnpm unpublish -f --registry $local_registry"
# Run pnpm publish command
bash -c "pnpm publish --registry $local_registry"

read -n 1 -s -r -p "Press any key to exit and close the verdaccio server"
