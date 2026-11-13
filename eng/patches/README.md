# Patch infrastructure

This directory holds the changes that turn the pristine upstream
repo source into the form used by this repository.
Keeping the modifications as standalone patches makes it easy
to re-create the repo on top of a new upstream commit and to audit exactly what
diverges from upstream.

The upstream repository URL and the exact commit the patches apply to are pinned
in the root [cgmanifest.json](../../cgmanifest.json).

## Contents

| File | Purpose |
| --- | --- |
| `*.patch` | `git am`-style patches applied in numerical order on top of upstream. |
| `remove-paths.txt` | Paths deleted from the upstream tree |
| `ignore-paths.txt` | Paths excluded from the `validate.sh` diff script (repo-specific dotnet files that have no upstream equivalent, e.g. `eng/`). |
| `validate.sh` | Verifies the patches reproduce the current repo from pristine upstream. |

## Usage

### Apply the patches to a clean tree

Run the following against the root of a clean target tree. The steps first remove every
path listed in `remove-paths.txt`, then apply each `*.patch` in order with
`git am`.

```bash
TARGET_DIR="/path/to/target"   # repo root to modify

./apply.sh "$TARGET_DIR"
```

### Validate that the patches still reproduce the repo

```bash
./validate.sh
```

This clones the upstream repo at the commit pinned in `cgmanifest.json`, applies
the patch infrastructure to the clone, and diffs the result against the current
repo.
It exits `0` when there are no differences and `1` otherwise.

## Updating to a new upstream commit

1. Update `repositoryUrl` / `commitHash` in [cgmanifest.json](../../cgmanifest.json).
2. Re-apply the patches onto the new upstream and resolve any conflicts.
3. Regenerate the `*.patch` files from the resolved commits if necessary.
4. Run `./validate.sh` to confirm everything reproduces cleanly.
