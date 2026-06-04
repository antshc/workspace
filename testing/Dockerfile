FROM workspace:latest

# Install brain CLI via pipx — global install (/opt/pipx), accessible to all users
RUN pipx install git+https://github.com/antshc/brain.git

# Keep root as the default build-time user so the inherited ENTRYPOINT runs as root
# and drops to dev via gosu. When compose sets user: "1000:1000" the entrypoint
# detects non-root and execs directly — no gosu needed.
USER root

CMD ["yolo"]
