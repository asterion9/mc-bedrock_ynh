# Admin Information

This page contains operational information for administrators of the `minecraft_bedrock` app.

## Network

- Default gameplay port: `19132/UDP`
- External access depends on the full network path (host firewall, router/NAT, upstream filtering).

## Data and Configuration

Main persistent data under the app install directory:

- `worlds/`: world saves
- `server.properties`: server settings
- `allowlist.json`: allowlist entries
- `permissions.json`: operator/permission entries

## Lifecycle Behavior

- YunoHost backups include persistent server data.
- Restore reinstates persistent server data from backup.
- App upgrades preserve worlds and main JSON/property configuration files.

## Runtime Diagnostics

- Service state: `sudo yunohost service status minecraft_bedrock`
- Recent service logs: `sudo journalctl -u minecraft_bedrock -n 200 --no-pager`

## Common Incident Context

- External join failures are often network path issues for `19132/UDP`.
- Join failures can also stem from Bedrock client/server version mismatch.
- Access/operator behavior is determined by `allowlist.json` and `permissions.json`.
