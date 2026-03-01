# LLM Guide: Testing This App With YunoHost package_check

This document is written for an LLM/coding agent to run and interpret `package_check` reliably for this repository.

## Scope

Use this when validating package lifecycle behavior (`install`, `remove`, `reinstall`, `upgrade`, `backup/restore`, multi-instance when enabled).

Repository-specific context:

- App id: `minecraft_bedrock`
- Non-web app (no URL/path test target)
- Test config file: `tests.toml`
- Checker location: `tools/package_check` (git submodule)

## Preconditions

1. Ensure submodules are available:

```bash
git submodule update --init --recursive
```

2. Host must provide LXD or Incus and be initialized:

```bash
incus admin init --minimal
# OR
lxd init
```

3. User running checks must have daemon access (`incus-admin`/`lxd` group) and an active login session with that membership.

## Standard Command

From repository root:

```bash
make check
```

Equivalent direct invocation:

```bash
tools/package_check/package_check.sh .
```

Useful variants:

```bash
make check CHECK_ARGS="-a amd64 -d bookworm -y stable"
make check CHECK_ARGS="-e"   # pause on errors
```

## LLM Execution Policy

1. Run `make check` first.
2. If it fails, surface:
- failing test phase name
- first actionable error
- log file path
3. Do not claim success unless command exit code is `0`.
4. Always report the summary path printed by package_check (for example `tools/package_check/full_log_0.log`).

## Interpreting Results

`package_check` includes a linter phase and integration phases.

- Linter failures are packaging metadata/script/documentation issues.
- Integration failures are runtime lifecycle issues in containerized YunoHost.

For this app, expect non-web install scenarios (not URL/path functional checks).

## Multi-instance Testing

`install.multi` runs only when manifest has:

```toml
[integration]
multi_instance = true
```

If `multi_instance = false`, package_check will not run multi-instance test flow.

To include/exclude tests, edit `tests.toml` in repo root.

Common test IDs:

- `install.root`
- `install.subdir`
- `install.nourl`
- `install.multi`
- `backup_restore`
- `upgrade`
- `change_url`

## Fast Debug Loop

1. Re-run with stop-on-error:

```bash
make check CHECK_ARGS="-e"
```

2. Inspect generated logs:

- `tools/package_check/full_log_0.log`
- `tools/package_check/results_0.json`

3. Fix issue, rerun full `make check`.

## Common Environment Issues

### Incus socket permission error

Symptom:

- cannot talk to `/var/lib/incus/unix.socket`

Resolution:

- add user to `incus-admin`
- open a new login session
- verify with `id` and `incus list`

### CRLF submodule issue

Symptom:

- `/usr/bin/env: 'python3\r': No such file or directory`
- missing checker files despite checkout

Resolution:

```bash
git -C tools/package_check config core.autocrlf false
git -C tools/package_check config core.eol lf
git -C tools/package_check reset --hard HEAD
```

## Completion Criteria

Report test completion only when all are true:

1. `make check` exits `0`
2. package_check summary shows success for intended test set
3. log path is provided in result summary
