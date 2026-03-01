#!/bin/bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
upgrade_script="$repo_root/scripts/upgrade"

if [ ! -f "$upgrade_script" ]; then
    echo "Missing upgrade script at $upgrade_script" >&2
    exit 1
fi

backfill_block="$(awk '
    /# BACKFILL SETTINGS FROM EXISTING CONFIG/ { capture=1; next }
    /# Refresh source files to the target version\./ { capture=0 }
    capture { print }
' "$upgrade_script")"

if [ -z "$backfill_block" ]; then
    echo "Could not extract backfill block from scripts/upgrade" >&2
    exit 1
fi

declare -A SETTINGS=()

extract_arg_value() {
    local prefix="$1"
    shift
    local arg
    for arg in "$@"; do
        case "$arg" in
            "$prefix"*)
                echo "${arg#"$prefix"}"
                return 0
                ;;
        esac
    done
    return 1
}

ynh_app_setting_get() {
    local key
    key="$(extract_arg_value "--key=" "$@")"
    printf '%s' "${SETTINGS[$key]-}"
}

ynh_app_setting_set() {
    local key value
    key="$(extract_arg_value "--key=" "$@")"
    value="$(extract_arg_value "--value=" "$@")"
    SETTINGS["$key"]="$value"
}

assert_eq() {
    local expected="$1"
    local actual="$2"
    local label="$3"
    if [ "$expected" != "$actual" ]; then
        echo "Assertion failed for $label" >&2
        echo "Expected: '$expected'" >&2
        echo "Actual  : '$actual'" >&2
        exit 1
    fi
}

run_backfill() {
    local test_install_dir="$1"
    install_dir="$test_install_dir"
    eval "$backfill_block"
}

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

# Case 1: Missing settings are recovered from existing server.properties.
cat > "$tmpdir/server.properties" <<'EOF'
server-name=Recovered Name
gamemode=survival
difficulty=hard
level-seed=abc123
level-name=legacy_world
EOF

SETTINGS=()
run_backfill "$tmpdir"

assert_eq "Recovered Name" "${SETTINGS[server_name]-}" "server_name from server.properties"
assert_eq "survival" "${SETTINGS[gamemode]-}" "gamemode from server.properties"
assert_eq "hard" "${SETTINGS[difficulty]-}" "difficulty from server.properties"
assert_eq "abc123" "${SETTINGS[level_seed]-}" "level_seed from server.properties"
assert_eq "legacy_world" "${SETTINGS[level_name]-}" "level_name from server.properties"

# Case 2: Existing setting has priority over server.properties value.
SETTINGS=()
SETTINGS["server_name"]="Keep Me"
run_backfill "$tmpdir"
assert_eq "Keep Me" "${SETTINGS[server_name]-}" "existing server_name precedence"

echo "PASS: upgrade backfill recovers settings from existing server.properties"
