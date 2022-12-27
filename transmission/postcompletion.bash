#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
TRANSMISSION_USR=$(sed -n "s/^transmission_usr=\(.*\)/\1/p" < "${SCRIPT_PATH}/../.env" | head -n 1)

docker exec -ti nextcloud /bin/bash -c "occ files:scan --path=${TRANSMISSION_USR}"