FROM lscr.io/linuxserver/nextcloud:latest

# pinging the nextloud instance will eventually trigger the installation process until ultimately returning a login page
HEALTHCHECK             \
    --interval=2m       \
    --retries=10        \
    --start-period=10m  \
    --timeout=5s        \
    CMD curl --insecure --fail "https://localhost:443/login" || exit 1