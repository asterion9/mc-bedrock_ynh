# Testing and Linting This YunoHost App

This repository is a YunoHost app package (`minecraft_bedrock`).  
The recommended workflow is:

1. Static lint (`package_linter`)
2. Integration checks (`package_check`)
3. Manual validation on a real YunoHost host

## 1) Lint (static analysis)

This repository vendors the official YunoHost linter as a git submodule (`tools/package_linter`).

```bash
# from repo root
git submodule update --init --recursive
make lint
```

`make lint` always ensures prerequisites are ready: submodule checkout, virtualenv creation, and dependency installation.

If you only want to prepare the environment:

```bash
make lint-setup
```

What to look for:
- `ERROR` entries must be fixed.
- `WARNING` entries should be reviewed and fixed when relevant.

## 2) Integration tests (install/upgrade/backup/restore/remove)

This repository vendors the official package checker as a submodule (`tools/package_check`) and provides `make check`.

```bash
# from repo root
git submodule update --init --recursive

# Minimal setup prerequisite for host (once):
# - Incus/LXD installed
# - initialized via: lxd init OR incus admin init --minimal

# Run checks on current repo
make check
```

Useful options:

```bash
tools/package_check/package_check.sh --help
make check CHECK_ARGS="-a amd64 -d bookworm -y stable"
make check CHECK_ARGS="-e"   # pause on errors for debugging
```

If `make check` fails with messages like `/usr/bin/env: 'python3\r': No such file or directory` or missing `tests/*.json`, your submodule checkout likely has CRLF endings. Fix with:

```bash
git -C tools/package_check config core.autocrlf false
git -C tools/package_check config core.eol lf
git -C tools/package_check reset --hard HEAD

# verify
file tools/package_check/lib/parse_tests_toml.py
```

Notes for this app:
- It is a non-web app (Minecraft Bedrock server), so package_check will use non-URL install scenarios.
- A `tests.toml` file is present in this repo and currently defines a shallow install-focused test scope.

## 3) Manual validation on a YunoHost server

In addition to automated checks, validate the real service behavior:

```bash
# Fresh install from local directory
sudo yunohost app install . --debug --no-remove-on-failure --force

# Upgrade test from local working tree
sudo yunohost app upgrade minecraft_bedrock -u . --debug
```

Then verify:
- Service status: `sudo yunohost service status minecraft_bedrock`
- Runtime logs: `sudo journalctl -u minecraft_bedrock -n 200 --no-pager`
- UDP port exposed: `19132/udp`
- Backup/restore paths behave as expected (`worlds` kept/restored).

## Official References

- YunoHost docs: Testing your app  
  https://doc.yunohost.org/packaging/test/
- package_linter README  
  https://github.com/YunoHost/package_linter
- package_check README  
  https://github.com/YunoHost/package_check
