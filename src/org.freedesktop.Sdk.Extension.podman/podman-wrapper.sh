#!/usr/bin/env bash
# Installed in .../shim/ as both `podman` and `docker`, shadowing the
# real binaries in .../bin/ via PATH order (see append-path in the
# manifest). Redirects to podman-remote when PODMAN_FLATPAK_FORCE_REMOTE
# is set (non-empty), otherwise runs the real podman binary. The invoked
# name (podman or docker) is preserved as argv[0] so podman's
# docker-compat mode keeps working either way.
set -euo pipefail

bindir=/usr/lib/sdk/podman/bin
name="$(basename "$0")"

if [ -n "${PODMAN_FLATPAK_FORCE_REMOTE-}" ]; then
  exec -a "$name" "${bindir}/podman-remote" "$@"
fi

exec -a "$name" "${bindir}/podman" "$@"
