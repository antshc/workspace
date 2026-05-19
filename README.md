# workspace

A Docker-based development environment with Node.js, .NET, Python, GitHub CLI, Docker CLI, and GitHub Copilot CLI pre-installed.

## Quick start (runtime)

Pull and run the published image directly:

```bash
docker compose -f docker-compose.runtime.yml run --rm workspace bash
```

## Build from source

Build the base image locally:

```bash
docker compose -f docker-compose.yml build
docker compose -f docker-compose.yml run --rm workspace bash
```

## Testing image

The `testing/` folder extends the base image with the [brain](https://github.com/antshc/brain) CLI and copilot plugins.

Build requires the base image to exist locally first:

```bash
docker build -t workspace:latest ./src
docker build -t workspace-testing ./testing
```

Or use the testing compose file (builds both):

```bash
docker compose -f docker-compose.testing.yml run --rm testing bash
```

## Compose files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Build base image from `./src` |
| `docker-compose.runtime.yml` | Run pre-built `antshc/workspace` from Docker Hub |
| `docker-compose.testing.yml` | Build base + testing image with brain/plugins |

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `COPILOT_MODEL` | `claude-sonnet-4.6` | Model for copilot CLI |
| `COPILOT_EFFORT` | *(unset)* | Inference effort (low, medium, high) |
| `COPILOT_MAX_AUTOPILOT_CONTINUES` | `20` | Max autopilot continuation loop |
| `COPILOT_ADD_DIRS` | *(unset)* | Extra directories (extends defaults) |
| `COPILOT_DENY_TOOLS` | *(unset)* | Comma-separated deny-tool entries |

## Volumes

Uncomment in the compose file as needed:

| Mount | Container path | Purpose |
|-------|---------------|---------|
| `./workspace` | `/root/workspace` | Your project files |
| `./logs/copilot` | `/var/log/copilot` | Copilot debug logs |
| `~/.gitconfig` | `/root/.gitconfig` | Git identity |
| `~/.config/gh` | `/root/.config/gh` | GitHub CLI auth |
| `/var/run/docker.sock` | `/var/run/docker.sock` | Host Docker access |