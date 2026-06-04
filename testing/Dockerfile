FROM workspace:latest

# Install brain CLI via pipx — global install (/opt/pipx), accessible to all users
RUN pipx install git+https://github.com/antshc/brain.git

# Install copilot plugins as the dev user so plugin data lands in /home/dev
USER dev
ENV HOME=/home/dev
RUN copilot plugin marketplace add antshc/brain \
    && (copilot plugin uninstall ralph@brain  >/dev/null 2>&1 || true) && copilot plugin install ralph@brain \
    && (copilot plugin uninstall review@brain >/dev/null 2>&1 || true) && copilot plugin install review@brain \
    && (copilot plugin uninstall wf@brain     >/dev/null 2>&1 || true) && copilot plugin install wf@brain

# Keep root as the default build-time user so the inherited ENTRYPOINT runs as root
# and drops to dev via gosu. When compose sets user: "1000:1000" the entrypoint
# detects non-root and execs directly — no gosu needed.
USER root

CMD ["yolo"]
