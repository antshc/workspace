# 55-copilot-config.sh — Write $COPILOT_HOME/config.json with trustedFolders at runtime.
# Sourced by entrypoint.sh (runs as root).
#
# Reads COPILOT_ADD_DIRS (same var used by copilot-alias.sh for --add-dir flags).
# COPILOT_ADD_DIRS extends COPILOT_DEFAULT_ADD_DIRS — never replaces them.

_COPILOT_HOME="${COPILOT_HOME:-/root/.copilot}"
_DEFAULT_DIRS="${COPILOT_DEFAULT_ADD_DIRS:-/root/workspace,/root/workspace.worktrees,/root/.copilot}"

if [[ -n "${COPILOT_ADD_DIRS:-}" ]]; then
  _ALL_DIRS="${_DEFAULT_DIRS},${COPILOT_ADD_DIRS}"
else
  _ALL_DIRS="${_DEFAULT_DIRS}"
fi

mkdir -p "$_COPILOT_HOME"

tr ',' '\n' <<< "$_ALL_DIRS" \
  | jq -Rs '[split("\n")[] | gsub("^\\s+|\\s+$";"") | select(length > 0)] | {trustedFolders: .}' \
  > "$_COPILOT_HOME/config.json"

chmod 600 "$_COPILOT_HOME/config.json"

unset _COPILOT_HOME _DEFAULT_DIRS _ALL_DIRS
