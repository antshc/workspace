#!/usr/bin/env bash
set -euo pipefail

INIT_DIR=/etc/workspace/init.d

for script in "$INIT_DIR"/*.sh; do
  [ -f "$script" ] || continue
  # shellcheck source=/dev/null
  source "$script"
done

# Optional setup script — mount a shell script to /etc/sandbox/setup.sh to run
# custom steps at startup (after init.d, before the main command).
if [ -f /etc/sandbox/setup.sh ]; then
  bash /etc/sandbox/setup.sh
fi

exec "$@"
