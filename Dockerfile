ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION}

ARG UBUNTU_CODENAME=noble
ARG NODE_MAJOR=24
ARG DOTNET_SDK_8_VERSION=8.0.419
ARG DOTNET_SDK_10_VERSION=10.0.105

ENV DEBIAN_FRONTEND=noninteractive
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_NOLOGO=1

# Install base packages, add all third-party repos, then install repo packages —
# single update/clean cycle
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl wget git jq ca-certificates gnupg unzip bash openssh-client \
        iproute2 net-tools lsof netcat-openbsd \
        python3 python3-pip python3-venv \
        libicu74 libssl3t64 \
        iputils-ping \
    # Node repo
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
        > /etc/apt/sources.list.d/nodesource.list \
    # GitHub CLI repo
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    # Docker CLI repo (client only — connects to host daemon via mounted socket)
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME} stable" \
        | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    # Refresh index once for all new repos, then install
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs gh docker-ce-cli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install specific .NET SDK versions via the official dotnet-install script.
# Installing to /usr/lib/dotnet ensures SDKs appear under /usr/lib/dotnet/sdk.
RUN curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh \
    && chmod +x /tmp/dotnet-install.sh \
    && /tmp/dotnet-install.sh --version ${DOTNET_SDK_8_VERSION} --install-dir /usr/lib/dotnet \
    && /tmp/dotnet-install.sh --version ${DOTNET_SDK_10_VERSION} --install-dir /usr/lib/dotnet \
    && ln -s /usr/lib/dotnet/dotnet /usr/local/bin/dotnet \
    && rm /tmp/dotnet-install.sh \
    && dotnet tool install --tool-path /usr/local/bin csharp-ls --version 0.16.0.0 \
    && curl -fsSL https://gh.io/copilot-install | bash

# Create private global Python venv
RUN mkdir -p /root/.venvs \
    && python3 -m venv /root/.venvs/global \
    && /root/.venvs/global/bin/python -m pip install --upgrade --no-cache-dir pip setuptools wheel pipx

# Copy copilot wrapper
COPY copilot-alias.sh /usr/local/bin/copilot-alias.sh
RUN chmod +x /usr/local/bin/copilot-alias.sh \
    && ln -s /usr/local/bin/copilot-alias.sh /usr/local/bin/copiloty \
    && mkdir -p /root/workspace /var/log/copilot

ENV COPILOT_DEFAULT_ADD_DIRS=/root/workspace,/root/workspace.worktrees,/root/.copilot
ENV DOTNET_ROOT=/usr/lib/dotnet
ENV PATH=/root/.local/bin:/root/.venvs/global/bin:$PATH
ENV PIPX_HOME=/root/.local/pipx
ENV PIPX_BIN_DIR=/root/.local/bin
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /root/workspace

CMD ["copiloty"]
