#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# create wg0.conf for Wireguard
if [[ -z "${1+x}" ]] ; then
    echo "No file name for Wireguard config was provided."
    exit 1
fi

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# create config superfolder
mkdir -p "${SCRIPT_PATH}/config"
mkdir -p "${SCRIPT_PATH}/config/wireguard"
WIREGUARD_DEFAULTS="${SCRIPT_PATH}/wireguard"
WIREGUARD_CONFIG_PATH="${SCRIPT_PATH}/config/wireguard"
cp "${WIREGUARD_DEFAULTS}/${1}.conf" "${WIREGUARD_CONFIG_PATH}/wg0.conf"
chmod -R go-rwx "${SCRIPT_PATH}/config"

# copy .env file template into real .env
cp "${SCRIPT_PATH}/env.template" "${SCRIPT_PATH}/.env"

# configuring .env for user & group ids => https://docs.linuxserver.io/general/understanding-puid-and-pgid
{
    echo
    echo "# gid & uid"
    echo "uid=$(id -u)"
    echo "gid=$(id -g)"
} >> "${SCRIPT_PATH}/.env"

# create nextcloud config folder
NEXTCLOUD_DEFAULTS="${SCRIPT_PATH}/nextcloud"
NEXTCLOUD_CONFIG_PATH="${SCRIPT_PATH}/config/nextcloud/www/nextcloud/config"
mkdir -p "${NEXTCLOUD_CONFIG_PATH}"
cp "${NEXTCLOUD_DEFAULTS}/config.php" "${NEXTCLOUD_CONFIG_PATH}/config.php"
cp "${NEXTCLOUD_DEFAULTS}/autoconfig.php" "${NEXTCLOUD_CONFIG_PATH}/autoconfig.php"

./additional_config.bash "${NEXTCLOUD_CONFIG_PATH}"