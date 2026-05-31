#!/bin/sh
set -euo pipefail

# entrypoint: create/adjust appuser with HOST_UID/HOST_GID and drop privileges
# If HOST_UID/GID are provided at runtime they will be used; otherwise image-built user is used.

HOST_UID=${HOST_UID:-}
HOST_GID=${HOST_GID:-}

if [ -n "$HOST_UID" ] && [ -n "$HOST_GID" ]; then
  # ensure group exists
  if ! getent group "$HOST_GID" >/dev/null 2>&1; then
    addgroup -g "$HOST_GID" appgroup || true
  fi

  # if appuser exists, check ids; otherwise create
  if id appuser >/dev/null 2>&1; then
    CURRENT_UID=$(id -u appuser)
    CURRENT_GID=$(id -g appuser)
    if [ "$CURRENT_UID" != "$HOST_UID" ] || [ "$CURRENT_GID" != "$HOST_GID" ]; then
      # remove and recreate user to match host ids
      deluser appuser || true
      adduser -D -u "$HOST_UID" -G appgroup -s /bin/sh appuser || true
    fi
  else
    adduser -D -u "$HOST_UID" -G appgroup -s /bin/sh appuser || true
  fi

  # ensure ownership of application and workspace mounts
  chown -R "$HOST_UID":"$HOST_GID" /app || true
  chown -R "$HOST_UID":"$HOST_GID" /workspace || true

  # exec the requested command as the non-root user
  exec su-exec appuser "$@"
else
  # no host UID/GID set — just run the command
  exec "$@"
fi
