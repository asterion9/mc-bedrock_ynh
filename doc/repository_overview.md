# Minecraft Bedrock YunoHost App Definition Overview

## Capabilities

This repository defines a YunoHost app package (`minecraft_bedrock`) that deploys and manages a Minecraft Bedrock dedicated server on YunoHost.

- Installs Minecraft Bedrock server binaries from the upstream official Linux ZIP source declared in `manifest.toml`.
- Supports `amd64` architecture on YunoHost `>= 11.2`.
- Exposes the Bedrock server UDP port (default `19132`) as a YunoHost exposed port resource.
- Creates and runs a dedicated system user for the service.
- Installs files into a managed app install directory.
- Configures and registers a systemd service to run `bedrock_server` at boot.
- Preserves important data during upgrades (`worlds`, `allowlist.json`, `permissions.json`, `server.properties`).
- Provides lifecycle actions through YunoHost scripts:
- `install`: deploy server binaries and configuration.
- `upgrade`: stop service, refresh binaries, keep persistent data, restart service.
- `remove`: stop service and remove systemd integration.
- `backup`: stop service, back up world data, restart service.
- `restore`: stop service, restore world data, restart service.
- Integrates a minimal config panel entry in YunoHost admin UI.

## Files Responsibilities

- `manifest.toml`: App metadata, compatibility constraints, version, source download URL/SHA256, and YunoHost resources (ports, system user, install dir, permissions).
- `conf/systemd.service`: systemd unit template used by YunoHost to run the Bedrock server service as the app user in the app install directory.
- `conf/server.properties`: template/default Minecraft server configuration copied into the install dir at installation.
- `conf/config_panel.toml`: minimal YunoHost config panel declaration (title + description).
- `scripts/_common.sh`: shared helper functions used by lifecycle scripts (mainly start/stop logic with log matching).
- `scripts/install`: installation workflow (source setup, config deployment, service registration/configuration).
- `scripts/upgrade`: upgrade workflow (stop server, deploy new source, preserve data, restart).
- `scripts/remove`: uninstall workflow (stop server and remove systemd config).
- `scripts/backup`: backup workflow for persistent world data.
- `scripts/restore`: restoration workflow for persistent world data.
- `LICENSE`: project license text.
- `.github/`: repository automation/CI metadata (if workflows or templates are added there).
- `doc/`: documentation folder for repository docs (this file is stored here).
