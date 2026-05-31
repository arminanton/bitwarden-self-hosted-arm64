#!/usr/bin/env bash
set -euo pipefail

# Start the stack using podman-compose / podman compose
# Ensure HOST_UID and HOST_GID are exported so build/runtime use proper UIDs
export HOST_UID=${HOST_UID:-$(id -u ndsadmin 2>/dev/null || id -u)}
export HOST_GID=${HOST_GID:-$(id -g ndsadmin 2>/dev/null || id -g)}
export BITWARDEN_REPO=${BITWARDEN_REPO:-https://github.com/bitwarden/server.git}
export BITWARDEN_REF=${BITWARDEN_REF:-main}
export TAG=${TAG:-2026.5.0-arm64}

cd "$(dirname "$0")"
# prefer podman compose if available
if command -v podman >/dev/null 2>&1 && podman --version >/dev/null 2>&1; then
  podman compose up -d --build
else
  docker compose up -d --build
fi

echo "Started containers (use 'podman ps' or 'podman logs <name>' to inspect)"
