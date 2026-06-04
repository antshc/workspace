#!/usr/bin/env bash
# setup.sh — Install copilot brain plugins as the dev user.
# Sourced by entrypoint.sh (runs as root); use gosu to switch to dev
# so plugin data lands in /home/dev.
set -euo pipefail

WORKSPACE_USER="${WORKSPACE_USER:-dev}"

gosu "${WORKSPACE_USER}" bash -c '
  export HOME="/home/'"${WORKSPACE_USER}"'"

  copilot plugin marketplace add antshc/brain
  (copilot plugin uninstall ralph@brain  >/dev/null 2>&1 || true) && copilot plugin install ralph@brain
  (copilot plugin uninstall review@brain >/dev/null 2>&1 || true) && copilot plugin install review@brain
  (copilot plugin uninstall wf@brain     >/dev/null 2>&1 || true) && copilot plugin install wf@brain
'
