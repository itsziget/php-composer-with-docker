#!/usr/bin/env bash

set -eu -o pipefail

version="$1"

local_download_path=~/".docker/cli-plugins/docker-compose-v$version"
local_final_path=~/".docker/cli-plugins/docker-compose"

arch="$(arch | sed 's/arm64/aarch64/')"
os="$(uname -s | tr '[:upper]' '[:lower]')"

remote_url="https://github.com/docker/compose/releases/download/v$version/docker-compose-$os-$arch"

if [[ ! -e "$local_download_path" ]]; then
  mkdir -p "$(dirname "$local_download_path")"
  curl --fail -L -o "$local_download_path" "$remote_url"
  chmod +x "$local_download_path"
fi

mkdir -p "$(dirname "$local_final_path")"
if [[ -e "$local_final_path" ]]; then
  # Apparently, copying over an existing file breaks docker compose on MacOS  
  unlink "$local_final_path"
fi
cp "$local_download_path" "$local_final_path"
chmod +x "$local_final_path" # in case something went wrong when it was downloaded

echo "Switched to: "
docker compose version

# pre-requisites for checking that we're running in container
if [ -f /proc/self/cgroup ] && [ -n "$(command -v getent)" ]; then
    # checks if we're running in container...
    if awk -F: '/cpu/ && $3 ~ /^\/$/{ c=1 } END { exit c }' /proc/self/cgroup; then
        # Check whether there is a passwd entry for the container UID
        myuid="$(id -u)"
        mygid="$(id -g)"
        # turn off -e for getent because it will return error code in anonymous uid case
        set +e
        uidentry="$(getent passwd "$myuid")"
        set -e

        # If there is no passwd entry for the container UID, attempt to create one
        if [ -z "$uidentry" ] ; then
            if [ -w /etc/passwd ] ; then
                echo "zeppelin:x:$myuid:$mygid:anonymous uid:$Z_HOME:/bin/false" >> /etc/passwd
            else
                echo "Container ENTRYPOINT failed to add passwd entry for anonymous UID"
            fi
        fi
    fi
fi
