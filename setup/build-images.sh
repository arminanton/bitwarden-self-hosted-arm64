#!/usr/bin/env bash
set -euo pipefail

BITWARDEN_REPO=${BITWARDEN_REPO:-https://github.com/bitwarden/server.git}
BITWARDEN_REF=${BITWARDEN_REF:-main}
TAG=${TAG:-2026.5.0-arm64}
HOST_UID=${HOST_UID:-$(id -u ndsadmin 2>/dev/null || id -u)}
HOST_GID=${HOST_GID:-$(id -g ndsadmin 2>/dev/null || id -g)}
PLATFORM=${PLATFORM:-linux/arm64}

services=(api admin identity sm-api)
for svc in "${services[@]}"; do
  case $svc in
    api)
      SERVICE_PROJECT_PATH=src/Api
      SERVICE_PROJECT_FILE=Api.csproj
      ;;
    admin)
      SERVICE_PROJECT_PATH=src/Admin
      SERVICE_PROJECT_FILE=Admin.csproj
      ;;
    identity)
      SERVICE_PROJECT_PATH=src/Identity
      SERVICE_PROJECT_FILE=Identity.csproj
      ;;
    sm-api)
      SERVICE_PROJECT_PATH=bitwarden_license/src/Commercial.Api
      SERVICE_PROJECT_FILE=Commercial.Api.csproj
      ;;
  esac

  echo "==> Building ${svc} (platform=${PLATFORM})"
  podman build --platform ${PLATFORM} \
    --build-arg BITWARDEN_REPO=${BITWARDEN_REPO} \
    --build-arg BITWARDEN_REF=${BITWARDEN_REF} \
    --build-arg SERVICE_PROJECT_PATH=${SERVICE_PROJECT_PATH} \
    --build-arg SERVICE_PROJECT_FILE=${SERVICE_PROJECT_FILE} \
    --build-arg HOST_UID=${HOST_UID} \
    --build-arg HOST_GID=${HOST_GID} \
    -f setup/Dockerfile.dotnet-service -t localhost/bitwarden/${svc}:${TAG} ..

done

echo "Builds finished. Images tagged as localhost/bitwarden/<service>:${TAG}"
