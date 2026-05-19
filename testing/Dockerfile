FROM antshc/workspace:latest

# Install brain CLI via pipx
RUN pipx install git+https://github.com/antshc/brain.git

# Install copilot plugins
RUN copilot plugin marketplace add antshc/brain
RUN (copilot plugin uninstall ralph@brain >/dev/null 2>&1 || true) && copilot plugin install ralph@brain
RUN (copilot plugin uninstall review@brain >/dev/null 2>&1 || true) && copilot plugin install review@brain
RUN (copilot plugin uninstall wf@brain >/dev/null 2>&1 || true) && copilot plugin install wf@brain
