#!/usr/bin/env bash
# Usage: ./release.sh <version>
# Example: ./release.sh 1.11.0
#
# Merges the develop branch into main as a release:
#  1. Validates preconditions (branch, clean tree, CHANGELOG)
#  2. Sets version in config.yaml, commits on develop
#  3. Merges develop → main, pushes main (triggers CI release build)
#  4. Restores develop to edge state, pushes develop

set -euo pipefail

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.11.0"
    exit 1
fi

# Validate semver-ish format
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: version must be in X.Y.Z format, got: $VERSION"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$SCRIPT_DIR/logspout/config.yaml"
CHANGELOG="$SCRIPT_DIR/logspout/CHANGELOG.md"
EDGE_SUFFIX=" (edge)"

die() {
    echo "Error: $*" >&2
    exit 1
}

get_yaml_value() {
    local key="$1"
    local line

    line="$(grep -E "^${key}:" "$CONFIG" | head -n1 || true)"
    [[ -n "$line" ]] || die "missing '$key' in $CONFIG"

    printf '%s\n' "$line" | sed -E "s/^${key}:[[:space:]]*//; s/^\"(.*)\"$/\1/"
}

set_yaml_value() {
    local key="$1"
    local value="$2"
    local quote="${3:-false}"
    local rendered_value="$value"
    local tmp_file

    if [[ "$quote" == "true" ]]; then
        rendered_value="\"$value\""
    fi

    tmp_file="$(mktemp "${TMPDIR:-/tmp}/release-config.XXXXXX")"

    if ! awk -v key="$key" -v value="$rendered_value" '
        BEGIN { updated = 0 }
        $0 ~ ("^" key ":") {
            print key ": " value
            updated = 1
            next
        }
        { print }
        END {
            if (!updated) {
                exit 1
            }
        }
    ' "$CONFIG" > "$tmp_file"; then
        rm -f "$tmp_file"
        die "failed to update '$key' in $CONFIG"
    fi

    mv "$tmp_file" "$CONFIG"
}

assert_yaml_value() {
    local key="$1"
    local expected="$2"
    local actual

    actual="$(get_yaml_value "$key")"
    [[ "$actual" == "$expected" ]] || die "expected '$key' to be '$expected', got '$actual'"
}

# --- Precondition checks ---

CURRENT_BRANCH="$(git -C "$SCRIPT_DIR" rev-parse --abbrev-ref HEAD)"
if [[ "$CURRENT_BRANCH" != "develop" ]]; then
    die "must be on the 'develop' branch (currently on '$CURRENT_BRANCH')"
fi

if [[ -n "$(git -C "$SCRIPT_DIR" status --short --untracked-files=normal)" ]]; then
    die "working tree is not clean. Commit, stash, or remove your changes first."
fi

# Check CHANGELOG has a ## <version> heading at the top (after the comment line)
if ! grep -qE "^## $VERSION$" "$CHANGELOG"; then
    die "CHANGELOG.md does not contain a '## $VERSION' section.
Add a changelog entry for $VERSION before releasing."
fi

# Check the first version heading in the changelog IS this version (not an older one)
FIRST_VERSION=$(grep -Em1 "^## [0-9]" "$CHANGELOG" | sed 's/## //')
if [[ "$FIRST_VERSION" != "$VERSION" ]]; then
    die "the first version in CHANGELOG.md is '$FIRST_VERSION', expected '$VERSION'.
Make sure the $VERSION section is at the top of the changelog."
fi

echo "==> Verifying local branches are up to date"
git -C "$SCRIPT_DIR" fetch origin main develop

LOCAL_DEVELOP="$(git -C "$SCRIPT_DIR" rev-parse develop)"
REMOTE_DEVELOP="$(git -C "$SCRIPT_DIR" rev-parse origin/develop)"
[[ "$LOCAL_DEVELOP" == "$REMOTE_DEVELOP" ]] || die "local develop is not in sync with origin/develop. Pull or push develop before releasing."

LOCAL_MAIN="$(git -C "$SCRIPT_DIR" rev-parse main)"
REMOTE_MAIN="$(git -C "$SCRIPT_DIR" rev-parse origin/main)"
[[ "$LOCAL_MAIN" == "$REMOTE_MAIN" ]] || die "local main is not in sync with origin/main. Pull or push main before releasing."

CURRENT_VERSION="$(get_yaml_value version)"
[[ "$CURRENT_VERSION" == "edge" ]] || die "expected develop config version to be 'edge', got '$CURRENT_VERSION'"

EDGE_NAME="$(get_yaml_value name)"
[[ "$EDGE_NAME" == *"$EDGE_SUFFIX" ]] || die "expected develop config name to end with '$EDGE_SUFFIX', got '$EDGE_NAME'"

RELEASE_NAME="${EDGE_NAME%"$EDGE_SUFFIX"}"
[[ -n "$RELEASE_NAME" && "$RELEASE_NAME" != "$EDGE_NAME" ]] || die "failed to derive the release add-on name from '$EDGE_NAME'"

echo "==> Releasing version $VERSION"

# --- Step 1: Update config.yaml on develop ---
set_yaml_value version "$VERSION" true
set_yaml_value name "$RELEASE_NAME"
assert_yaml_value version "$VERSION"
assert_yaml_value name "$RELEASE_NAME"

git -C "$SCRIPT_DIR" add "$CONFIG"
git -C "$SCRIPT_DIR" commit -m "chore: prepare release $VERSION

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

echo "==> Merging develop into main"
git -C "$SCRIPT_DIR" checkout main
# Use -X theirs so that when main and develop have diverged (develop is source of truth),
# conflicts are resolved by preferring develop's content.
git -C "$SCRIPT_DIR" merge develop --no-ff -X theirs -m "chore: release $VERSION

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

echo "==> Pushing main (triggers CI release build)"
git -C "$SCRIPT_DIR" push origin main

# --- Step 2: Restore develop to edge state ---
echo "==> Restoring develop to edge state"
git -C "$SCRIPT_DIR" checkout develop

set_yaml_value version "edge" true
set_yaml_value name "$EDGE_NAME"
assert_yaml_value version "edge"
assert_yaml_value name "$EDGE_NAME"

git -C "$SCRIPT_DIR" add "$CONFIG"
git -C "$SCRIPT_DIR" commit -m "chore: back to edge after release $VERSION

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

echo "==> Pushing develop"
git -C "$SCRIPT_DIR" push origin develop

echo ""
echo "✅ Released $VERSION!"
echo "   - main pushed → CI will publish ghcr.io/bertbaron/logspout:$VERSION"
echo "   - develop restored to edge state"
echo ""
echo "Next steps:"
echo "  - Monitor the CI build: https://github.com/bertbaron/hassio-addons/actions"
echo "  - Tag the release on GitHub if desired: git tag v$VERSION && git push origin v$VERSION"
