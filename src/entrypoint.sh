#!/usr/bin/env bash
set -euo pipefail

INIT_DIR=/etc/workspace/init.d

for script in "$INIT_DIR"/*.sh; do
  [ -f "$script" ] || continue
  # shellcheck source=/dev/null
  source "$script"
done

exec "$@"
