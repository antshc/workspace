# workspace

## Testing image

The `testing/` folder contains a Dockerfile that extends `antshc/workspace` with the [brain](https://github.com/antshc/brain) CLI and copilot plugins pre-installed.

**Build:**

```bash
docker build -t workspace-testing ./testing
```

**Run:**

```bash
docker run --rm -it \
  -e COPILOT_GITHUB_TOKEN=<your-token> \
  workspace-testing
```

Or use docker compose:

```bash
docker compose -f docker-compose.testing.yml up
```