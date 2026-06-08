#!/usr/bin/env bash
#
# validate.sh
#
# Validates that the patch infrastructure in this directory (apply.sh,
# remove-files.txt and the *.patch files) reproduces the current repo when
# applied on top of the pristine upstream source referenced by the root
# cgmanifest.json.
#
# It does this by:
#   1. Reading the upstream repositoryUrl + commitHash from cgmanifest.json.
#   2. Cloning that repo at that exact commit into a temp folder.
#   3. Running apply.sh against the clone
#   4. Diffing the patched clone against the current repo.
#   5. Printing any differences found.
#
# Exit code is 0 when there are no differences, 1 otherwise.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CGMANIFEST="$REPO_ROOT/cgmanifest.json"

if [ ! -f "$CGMANIFEST" ]; then
    echo "error: cannot find cgmanifest.json at $CGMANIFEST" >&2
    exit 1
fi

# --- 1. Parse repositoryUrl + commitHash from cgmanifest.json ----------------

read_manifest() {
    # $1 = key under the git component (repositoryUrl | commitHash)
    python3 -c "import json,sys; print(json.load(open('$CGMANIFEST'))['registrations'][0]['component']['git']['$1'])"
}

REPO_URL="$(read_manifest repositoryUrl)"
COMMIT_HASH="$(read_manifest commitHash)"

if [ -z "$REPO_URL" ] || [ -z "$COMMIT_HASH" ]; then
    echo "error: could not read repositoryUrl/commitHash from cgmanifest.json" >&2
    exit 1
fi

echo "Upstream repo:   $REPO_URL"
echo "Upstream commit: $COMMIT_HASH"

# --- 2. Clone upstream at the pinned commit into a temp folder ---------------

TMP_DIR="$(mktemp -d)"
CLONE_DIR="$TMP_DIR/upstream"

cleanup() {
    local exit_code=$?
    if [ "$exit_code" -eq 0 ]; then
        rm -rf "$TMP_DIR"
    else
        echo "Leaving temp directory for inspection: $TMP_DIR" >&2
    fi
}
trap cleanup EXIT

echo "Cloning into $CLONE_DIR ..."
git clone --quiet --reference "$REPO_ROOT" --dissociate "$REPO_URL" "$CLONE_DIR"
git -C "$CLONE_DIR" checkout --quiet "$COMMIT_HASH"

# --- 3. Run the patch infrastructure against the clone -----------------------

echo "Running apply.sh against the clone ..."
bash "$SCRIPT_DIR/apply.sh" "$CLONE_DIR"

# --- 4. Diff the patched clone against the current repo ----------------------
#
# Exclude paths listed in ignore-paths.txt and remove-paths.txt
EXCLUDES=()
while read -r path; do
    # ignore comments and empty lines
    [[ "$path" =~ ^#.*$ ]] && continue
    [[ -z "$path" ]] && continue

    EXCLUDES+=("--exclude=$path")
done < <(cat "$SCRIPT_DIR/ignore-paths.txt" "$SCRIPT_DIR/remove-paths.txt")

echo
echo "Differences between current repo and patched upstream:"
echo "------------------------------------------------------"

DIFF_OUTPUT="$(diff -ru "${EXCLUDES[@]}" "$REPO_ROOT" "$CLONE_DIR" || true)"

# Rewrite the temp path to something readable.
DIFF_OUTPUT="${DIFF_OUTPUT//$CLONE_DIR/<patched-upstream>}"
DIFF_OUTPUT="${DIFF_OUTPUT//$REPO_ROOT/<current-repo>}"

if [ -z "$DIFF_OUTPUT" ]; then
    echo "(none) - the patches reproduce the current repo exactly."
    exit 0
else
    echo "$DIFF_OUTPUT"
    exit 1
fi
