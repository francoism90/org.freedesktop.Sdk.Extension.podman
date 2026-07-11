#!/usr/bin/env bash
# Installed as `podman`. Redirects to podman-remote when
# PODMAN_FLATPAK_FORCE_REMOTE is set (non-empty), otherwise runs the
# real podman binary (podman-cli).
set -euo pipefail

dir="$(dirname "$(readlink -f "$0")")"

if [ -n "${PODMAN_FLATPAK_FORCE_REMOTE-}" ]; then
  exec "${dir}/podman-remote" "$@"
fi

exec "${dir}/podman-cli" "$@"
