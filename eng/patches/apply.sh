#!/usr/bin/env bash
#
# apply.sh [TARGET_DIR]
#
# Applies the patch infrastructure (remove-paths.txt + *.patch) that lives next
# to this script onto a target repo.
#
#   TARGET_DIR  Repo root to modify. Defaults to the current directory.
#
# Paths in remove-paths.txt and the patches are interpreted relative to the target repo root.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(cd "${1:-$PWD}" && pwd)"

# delete all paths mentioned in remove-paths.txt (paths are relative to TARGET_DIR)
removed_any=false
while read -r path; do
    # ignore comments and empty lines
    [[ "$path" =~ ^#.*$ ]] && continue
    [[ -z "$path" ]] && continue

    if [ -e "$TARGET_DIR/$path" ]; then
        echo "Removing $TARGET_DIR/$path"
        git -C "$TARGET_DIR" rm -r --quiet "$path"
        removed_any=true
    else
        echo "Path $TARGET_DIR/$path not found, skipping."
    fi
done < "$SCRIPT_DIR/remove-paths.txt"

# commit the removals so the working tree is clean before applying patches
if [ "$removed_any" = true ]; then
    echo "Committing removed paths"
    git -C "$TARGET_DIR" commit --quiet -m "Remove paths listed in remove-paths.txt"
fi

# apply all git patches in the script's directory in numerical order
for patch in $(find "$SCRIPT_DIR" -name "*.patch" | sort -V); do
    echo "Applying patch $patch"
    git -C "$TARGET_DIR" am "$patch"
done
