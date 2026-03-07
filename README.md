# Minecraft Bedrock YunoHost App (`minecraft_bedrock`)

## Overview

This repository contains a YunoHost app package that deploys and manages a Minecraft Bedrock dedicated server.

Core capabilities:

- installs Bedrock server binaries from the upstream Linux ZIP defined in `manifest.toml`
- targets `amd64` on YunoHost `>= 11.2`
- exposes default Bedrock port `19132/UDP`
- manages a dedicated system user and install directory
- registers the service to run through YunoHost/systemd lifecycle
- preserves persistent server data during upgrades (`worlds`, `allowlist.json`, `permissions.json`, `server.properties`)

## Repository Structure

- `manifest.toml`: app metadata, version, compatibility, source URL/checksum, resources
- `conf/systemd.service`: service unit template
- `conf/server.properties`: default server configuration template
- `conf/config_panel.toml`: YunoHost config panel metadata
- `scripts/_common.sh`: shared script helpers
- `scripts/install`: install workflow
- `scripts/upgrade`: upgrade workflow with data preservation
- `scripts/remove`: uninstall workflow
- `scripts/backup`: backup workflow
- `scripts/restore`: restore workflow
- `tests.toml`: package_check test selection
- `doc/DESCRIPTION.md`: catalog-facing long app description
- `doc/ADMIN.md`: admin-facing operational documentation
- `tools/package_linter/`: YunoHost package linter submodule
- `tools/package_check/`: YunoHost package integration checker submodule

## App Lifecycle Behavior

Implemented YunoHost actions:

- `install`: provision source, config, and service
- `upgrade`: stop service, deploy updated source, keep persistent data, restart
- `remove`: stop service and remove integration
- `backup`: snapshot persistent data
- `restore`: restore persistent data and restart service

## Development Workflow

Recommended validation sequence:

1. static lint (`make lint`)
2. integration checks (`make check`)
3. manual validation on a YunoHost host

### Lint

```bash
git submodule update --init --recursive
make lint
```

`make lint` handles submodule/venv/dependencies automatically.

Optional setup-only step:

```bash
make lint-setup
```

### Integration Checks

Host prerequisites (one-time):

- Incus or LXD installed
- initialized with `incus admin init --minimal` or `lxd init`

Run checks:

```bash
git submodule update --init --recursive
make check
```

Useful variants:

```bash
tools/package_check/package_check.sh --help
make check CHECK_ARGS="-a amd64 -d bookworm -y stable"
make check CHECK_ARGS="-e"
```

CRLF submodule recovery (if needed):

```bash
git -C tools/package_check config core.autocrlf false
git -C tools/package_check config core.eol lf
git -C tools/package_check reset --hard HEAD
file tools/package_check/lib/parse_tests_toml.py
```

### Manual Validation

```bash
sudo yunohost app install . --debug --no-remove-on-failure --force
sudo yunohost app upgrade minecraft_bedrock -u . --debug
```

Quick checks:

- `sudo yunohost service status minecraft_bedrock`
- `sudo journalctl -u minecraft_bedrock -n 200 --no-pager`
- UDP port `19132` exposed and reachable
- backup/restore preserves `worlds` and config files

## Definition of Done

A task is considered done when:

1. Code and docs changes are committed in this repository.
2. Static checks pass (`make lint`).
3. Package checks run successfully (`make check`) with no blocking errors.

## References

- YunoHost packaging tests: https://doc.yunohost.org/packaging/test/
- package_linter: https://github.com/YunoHost/package_linter
- package_check: https://github.com/YunoHost/package_check
