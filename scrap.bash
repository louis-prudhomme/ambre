#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

docker-compose down
if [[ ! -f "${SCRIPT_PATH}/.env" ]] ; then
    echo ".env does not exist, yet is necessary to clean up."
    exit 1
fi

# empty data path
DATA_PATH=$(sed -n "s/^data_path=\(.*\)/\1/p" < "${SCRIPT_PATH}/.env" | head -n 1)
echo "Emptying ${DATA_PATH}"
rm -rf "${DATA_PATH}/shared"
rm -rf "${DATA_PATH}/transmission-watch"

# remove images
echo "Removing images"
docker-compose rm -f

# empty autogenerated files
echo "Removing generated files"
rm -f "${SCRIPT_PATH}/.env" || echo ".env was already deleted"
rm -rf "${SCRIPT_PATH}/config" || echo "config/ was already deleted"
