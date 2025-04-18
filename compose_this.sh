#!/usr/bin/env bash
set -euxo pipefail
# This script wraps docker compose with the required arguments for this project.

# The root of this compose project, fetched via git
compose_root="$(git rev-parse --show-toplevel)"
compose_flags=(
    --project-name "$(basename ${PWD})"
  --file "${compose_root}/compose.yaml"
  --file "${compose_root}/compose.override.yaml"
  --env-file "${compose_root}/compose.env"
)
cd "${compose_root}"
exec docker compose "${compose_flags[@]}" "$@"
