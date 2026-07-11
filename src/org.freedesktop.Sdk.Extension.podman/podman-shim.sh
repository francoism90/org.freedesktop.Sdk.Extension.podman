#!/usr/bin/env bash
# Installed as both `podman` and `docker`.
#
# - podman: always runs the real podman binary, or podman-remote when
#   PODMAN_FLATPAK_FORCE_REMOTE is set (non-empty).
# - docker: only overruled (mapped onto podman/podman-remote, same as
#   above) when PODMAN_FLATPAK_OVERRULE_DOCKER is set (non-empty).
#   Otherwise it defers to the next `docker` found on PATH, so a real
#   Docker SDK extension's `docker` keeps working untouched.
#
# argv[0] is preserved via `exec -a` so podman's docker-compat mode
# keeps working when invoked as `docker`.
set -euo pipefail

self="$(readlink -f "$0")"
dir="$(dirname "$self")"
name="$(basename "$0")"

if [ "$name" = "docker" ] && [ -z "${PODMAN_FLATPAK_OVERRULE_DOCKER-}" ]; then
  IFS=':' read -ra path_dirs <<< "$PATH"
  for path_dir in "${path_dirs[@]}"; do
    [ -n "$path_dir" ] || continue
    candidate="$path_dir/podman"
    [ -x "$candidate" ] || continue
    [ "$(readlink -f "$candidate")" != "$self" ] || continue
    exec "$candidate" "$@"
  done
  echo "docker: no other docker found on PATH (set PODMAN_FLATPAK_OVERRULE_DOCKER to use podman instead)" >&2
  exit 127
fi

if [ -n "${PODMAN_FLATPAK_FORCE_REMOTE-}" ]; then
  exec -a "$name" "${dir}/podman-remote" "$@"
fi

exec -a "$name" "${dir}/podman-cli" "$@"
