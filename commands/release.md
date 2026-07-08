---
description: Release a new plugin version — sync version numbers across all files, commit, tag, and push to trigger the release workflow
required_skills:
  - wp-backend
---

# Release Command

Automates the error-prone pre-tag release routine: bump the version **in every file that carries it**, commit, tag, and push. The pushed tag triggers `release-workflow.yml` (set up by `/init-plugin`), which runs tests, builds the distribution ZIP, and publishes a GitHub Release.

This command exists because version syncing is a mechanical-consistency problem, not a knowledge problem — the version lives in 3–5 places and missing one breaks the release (e.g. WordPress shows the old version, `Stable tag` mismatch on wp.org).

## Syntax

```bash
/release            # Suggest bump type from commits since last tag, confirm with user
/release 1.4.0      # Release an explicit version
/release --patch    # Force patch bump (also: --minor, --major)
```

## When to Use

- After `/verify` passes and the release branch is merged
- Any time you would otherwise hand-edit version numbers before tagging

## How It Works

### Step 1: Preflight

All must pass before anything is modified:

1. **Clean working tree** — `git status --porcelain` must be empty. Abort otherwise; never mix release bumps with unrelated changes.
2. **On the default branch** and up to date with remote (`git pull` first).
3. **Determine the new version**:
   - Explicit argument → use it.
   - Otherwise inspect `git log <last-tag>..HEAD --oneline`: any `feat` → minor, only `fix`/`chore`/`docs` → patch, breaking change noted → major.
   - **Always show the suggested version and the commit list, and wait for user confirmation.**
4. **Tag must not exist** — abort if `git tag -l v<version>` matches.
5. Recommend running `/verify` first if it hasn't been run on this HEAD (do not force it).

### Step 2: Locate Every Version Carrier

Search the project for all files that carry the version. Typical carriers:

| File | Field |
|------|-------|
| Main plugin file (`<plugin-slug>.php`) | `Version:` header |
| Main plugin file | version constant, e.g. `define( 'MYPLUGIN_VERSION', '…' )` |
| `readme.txt` | `Stable tag:` |
| `package.json` | `version` (if present) |
| `composer.json` | `version` (only if the field exists — do not add it) |

Use `Grep` for the **current** version string across the repo to catch project-specific carriers this table misses (docblocks, config files). Print the full list of files to be touched before editing.

### Step 3: Bump

1. Update every carrier found in Step 2 to the new version.
2. Add a changelog entry to `readme.txt` under `== Changelog ==` (derive bullets from the commit list in Step 1; let the user edit before committing).
3. Re-`Grep` the old version string to confirm zero remaining occurrences (ignore historical changelog entries and lockfiles).

### Step 4: Commit, Tag, Push

```bash
git add <bumped files>
git commit -m "chore(release): bump version to <X.Y.Z>"
git tag v<X.Y.Z>
git push && git push origin v<X.Y.Z>
```

**Ask once before pushing** — the push is the point of no return that triggers CI. After pushing, print the Actions URL so the user can watch the release build.

### Step 5: Post-release Check

- Confirm the workflow run started (`gh run list --limit 1`).
- If the workflow fails, do NOT delete/re-push the tag automatically — report the failure and let the human decide.

## Example Interaction

```
User: /release

Claude:
Commits since v1.2.0:
- feat(export): CSV export for bookings
- fix(list-table): pagination offset

Suggested version: 1.3.0 (minor — contains feat)
Version carriers found:
- my-plugin.php        (Version header + MYPLUGIN_VERSION constant)
- readme.txt           (Stable tag + changelog entry)
- package.json         (version)

Proceed with 1.3.0? [Y/n]

User: Y

Claude:
✅ 3 files bumped, 0 stale occurrences of 1.2.0 remain
✅ Committed: chore(release): bump version to 1.3.0
✅ Tagged v1.3.0
Push commit + tag to trigger release workflow? [Y/n]

User: Y

Claude:
🚀 Pushed. Release build: https://github.com/acme/my-plugin/actions/runs/…
```

## What `/release` Does NOT Do

- Does **not** run the quality gate — run `/verify` first
- Does **not** deploy to wp.org SVN — the GitHub Release ZIP is the artifact; SVN deploy stays manual (or in your own CI)
- Does **not** create the release workflow — that's `/init-plugin`

## Related Commands

- `/verify` — full quality gate, run before releasing
- `/submit-review` — wp.org compliance check before first submission
- `/init-plugin` — sets up the `release-workflow.yml` this command triggers
