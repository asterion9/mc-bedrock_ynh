# Minecraft Bedrock YunoHost: LLM Quick Guide

## Scope
- App id: `minecraft_bedrock`
- Main files: `manifest.toml`, `tests.toml`, `scripts/{install,remove,backup,restore,upgrade,_common.sh}`
- Non-web app: no URL/path functional check.

## Critical Invariants
- Install provisions runtime files with `ynh_setup_source` (required).
- Persistent worlds live in `data_dir/worlds`; app dir exposes `worlds` as a symlink.
- Migration must preserve existing worlds; do not delete/reinitialize user data.
- IPv4 and IPv6 use the same configured port for this app.
- User-facing docs must clearly show the effective server port.

## Lifecycle Rules (Do Not Regress)
- `restore` is its own transition, not “install + copy”.
- Avoid restore checks that fail only because install dir exists in restore context.
- If backup restored a path, do not recreate/reset it unconditionally.
- Backup must include both data and critical runtime config files.
- In restore, use `ynh_restore_file ... --not_mandatory` where archived paths may be absent.

## Service Handling
- Prefer direct `ynh_systemd_action` start/stop.
- Avoid log-line wait loops; they are brittle in package_check containers and can hang tests.

## Test Workflow (package_check)
- Pre-reqs:
```bash
git submodule update --init --recursive
incus admin init --minimal   # or lxd init
```
- Run:
```bash
make check
```
- Fast debug:
```bash
make check CHECK_ARGS="-e"
```
- Always report:
  - exit code
  - failing phase + first actionable error
  - `tools/package_check/full_log_0.log`

## Known Environment Traps
- Incus socket access denied: user not in `incus-admin` or stale login session.
- CRLF in checker submodule:
```bash
git -C tools/package_check config core.autocrlf false
git -C tools/package_check config core.eol lf
git -C tools/package_check reset --hard HEAD
```
