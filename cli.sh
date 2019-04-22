#!/bin/bash

set -e

while getopts ":u:p:e:-:" opt; do
  case $opt in
    u)
      username=$OPTARG
      echo $username
      exit
    ;;
    p)
      password=$OPTARG
    ;;
    e)
      email=$OPTARG
    ;;
    -)
      VALUE="${OPTARG#*=}" # removes "--arg="
      if [ -z $VALUE ] || [ $VALUE = $OPTARG ]; then
        echo "Invalid option, long args must take a value"
        exit 1
      fi

      case $OPTARG in
        registry-url=?*)
          local_registry=${VALUE?local-registry must take a value}
        ;;
        package-runner=?*)
          package_runner=${VALUE?package-runner must take a value}
        ;;
      esac
    ;;
    \?)
      echo "Invalid option -$OPTARG"
      exit 1
    ;;
  esac
done

if [ -z $local_registry ]; then
  local_registry="http://localhost:4873"
fi

if [ -z $username ]; then
  username="test"
fi

if [ -z $password ]; then
  password="test"
fi

if [ -z $email ]; then
  email="test@test.com"
fi

if [ -z $package_runner ]; then
  if [ -f pnpm-lock.yaml ]; then
    package_runner="pnpx"
  else
    package_runner="npx"
  fi
fi

# Start local registry
tmp_registry_log=`mktemp`
bash -c "nohup verdaccio &>$tmp_registry_log &"

# Wait for `verdaccio` to boot
grep -q 'http address' <(tail -f $tmp_registry_log)

# Login so that we can "publish"
bash -c "${package_runner} npm-cli-login -u $username -p $password -e $email -r $local_registry"

# Unpublish current version
bash -c "npm unpublish -f --registry $local_registry"
# Run publish command
bash -c "npm publish --registry $local_registry"

echo
echo "Running the registry on http://localhost:4873"
read -n 1 -s -r -p "Press any key to exit and close the verdaccio server"
echo