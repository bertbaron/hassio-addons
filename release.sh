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

# --- Precondition checks ---

CURRENT_BRANCH="$(git -C "$SCRIPT_DIR" rev-parse --abbrev-ref HEAD)"
if [[ "$CURRENT_BRANCH" != "develop" ]]; then
    echo "Error: must be on the 'develop' branch (currently on '$CURRENT_BRANCH')"
    exit 1
fi

if ! git -C "$SCRIPT_DIR" diff --quiet || ! git -C "$SCRIPT_DIR" diff --cached --quiet; then
    echo "Error: working tree is not clean. Commit or stash your changes first."
    exit 1
fi

# Check CHANGELOG has a ## <version> heading at the top (after the comment line)
if ! grep -qE "^## $VERSION$" "$CHANGELOG"; then
    echo "Error: CHANGELOG.md does not contain a '## $VERSION' section."
    echo "Add a changelog entry for $VERSION before releasing."
    exit 1
fi

# Check the first version heading in the changelog IS this version (not an older one)
FIRST_VERSION=$(grep -Em1 "^## [0-9]" "$CHANGELOG" | sed 's/## //')
if [[ "$FIRST_VERSION" != "$VERSION" ]]; then
    echo "Error: the first version in CHANGELOG.md is '$FIRST_VERSION', expected '$VERSION'."
    echo "Make sure the $VERSION section is at the top of the changelog."
    exit 1
fi

echo "==> Releasing version $VERSION"

# --- Step 1: Update config.yaml on develop ---
sed -i '' "s/^version: .*/version: \"$VERSION\"/" "$CONFIG"
# Also restore the add-on name to the non-edge version for main
sed -i '' 's/^name: Logspout addon (edge)/name: Logspout addon/' "$CONFIG"

git -C "$SCRIPT_DIR" add "$CONFIG"
git -C "$SCRIPT_DIR" commit -m "chore: prepare release $VERSION

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

echo "==> Merging develop into main"
git -C "$SCRIPT_DIR" checkout main
git -C "$SCRIPT_DIR" merge develop --no-ff -m "chore: release $VERSION

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

echo "==> Pushing main (triggers CI release build)"
git -C "$SCRIPT_DIR" push origin main

# --- Step 2: Restore develop to edge state ---
echo "==> Restoring develop to edge state"
git -C "$SCRIPT_DIR" checkout develop

sed -i '' "s/^version: .*/version: \"edge\"/" "$CONFIG"
sed -i '' 's/^name: Logspout addon$/name: Logspout addon (edge)/' "$CONFIG"

git -C "$SCRIPT_DIR" add "$CONFIG"
git -C "$SCRIPT_DIR" commit -m "chore: back to edge after release $VERSION

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

echo "==> Pushing develop"
git -C "$SCRIPT_DIR" push origin develop

echo ""
echo "✅ Released $VERSION!"
echo "   - main pushed → CI will publish ghcr.io/bertbaron/{arch}-addon-logspout:$VERSION"
echo "   - develop restored to edge state"
echo ""
echo "Next steps:"
echo "  - Monitor the CI build: https://github.com/bertbaron/hassio-addons/actions"
echo "  - Tag the release on GitHub if desired: git tag v$VERSION && git push origin v$VERSION"
