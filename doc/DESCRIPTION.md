Minecraft Bedrock Server for YunoHost packages the official Bedrock dedicated server as a self-hosted multiplayer service.

This app is a non-web package: it does not expose an HTTP URL/path. Player connections use the Bedrock gameplay port `19132/UDP`.

The package is designed around standard YunoHost app lifecycle operations:

- install and service registration
- upgrades with preserved persistent server data
- backup and restore compatibility through YunoHost

Persistent game and server state is kept across upgrades for the main runtime data set:

- `worlds/`
- `server.properties`
- `allowlist.json`
- `permissions.json`

Current package target:

- architecture: `amd64`
- YunoHost version: `>= 11.2`
