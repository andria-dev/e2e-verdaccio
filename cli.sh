#!/bin/bash

set -e

help() {
  echo ""
}

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
      if [ $OPTARG = "--help" ]; then

      fi

      VALUE="${OPTARG#*=}" # removes "--arg="
      if [ -z $VALUE ] || [ $VALUE = $OPTARG ]; then
        echo "Invalid option, long args must take a value"
        exit 1
      fi

      case $OPTARG in
        port=?*)
          port=${VALUE?local-registry must take a value}
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

if [ -z $port ]; then
  port="4873"
fi
registry_url="http://localhost:$port"

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
nohup ${package_runner} verdaccio --listen $port &>$tmp_registry_log &
verdaccio_pid=$!

# Wait for `verdaccio` to boot
grep -q 'http address' <(tail -f $tmp_registry_log)

# Login so that we can "publish"
${package_runner} npm-cli-login -u $username -p $password -e $email -r $registry_url

# Unpublish current version
npm unpublish -f --registry $registry_url
# Run publish command
npm publish --registry $registry_url

echo
echo "Running the registry on $registry_url"
read -n 1 -s -r -p "Press any key to exit and close the verdaccio server"
echo

kill -9 $verdaccio_pid
