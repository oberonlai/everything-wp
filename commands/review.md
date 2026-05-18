---
description: Senior-engineer code review on the current diff — Security, Performance, Simplification, Test coverage gap, and i18n.
required_skills:
  - wp-backend
invokes_agent: code-reviewer
---

# Review Command

This command runs a diff-scoped code review with a senior WordPress engineer's perspective. Use it **after `/todo` finishes** and **before `/verify`** to catch issues that automated tools miss.

## What This Command Does

Reviews only files changed since the last commit and reports findings in five areas:

1. **Security** — nonce, sanitization, capability, SQL prepare, output escaping, file ops
2. **Performance** — N+1 queries, missing cache, hook overload, autoload bombing
3. **Simplification** — duplication, dead code, debug residue, reinventing WP core
4. **Test Coverage Gap** — new behavior without a corresponding test
5. **i18n** — hardcoded strings, missing text domain, dynamic `__($var)`, escape + i18n combos

## When to Use

| Stage                             | Run                                          |
|-----------------------------------|----------------------------------------------|
| After `/todo` completes           | `/review` ← this command                     |
| Before opening a PR / release     | `/verify` (full project quality gate)        |
| Before submitting to wp.org       | `/submit-review` (wp.org compliance check)   |

`/review` is **read-only** — it reports, it does not modify code. You decide what to fix.

## How It Works

### Scope

Diff-only. The agent runs:

```bash
git diff --name-only HEAD -- 'src/**/*.php' 'tests/**/*.php'
```

Then reads each changed file in full (context matters for security/perf review) and runs the 5-area checklist.

### Severity

Every finding is tagged:

- 🔴 **Must fix** — security hole, data loss, broken behavior. Blocks PR.
- 🟡 **Should fix** — real problem (perf, missing i18n, bad WP idiom, test gap). Fix soon.
- 🔵 **Nice to have** — style, readability, micro-optimization. Author's call.

### Output

Per-finding format:

```
🔴 src/Admin/Settings.php:45 — Nonce verification missing
   Code: `$value = $_POST['settings'];`
   Issue: POST handler accepts user input without nonce check.
   Suggested fix:
     $nonce = ( isset( $_POST['nonce'] ) ) ? sanitize_text_field( wp_unslash( $_POST['nonce'] ) ) : '';
     if ( ! wp_verify_nonce( $nonce, 'save_settings' ) ) { wp_die(); }
```

Plus a summary table at the end and an explicit `Recommendation` line.

## Example Interaction

```
User: /review

Claude:
═══════════════════════════════════════════════════
                Code Review Report
═══════════════════════════════════════════════════

📂 Files reviewed: 3 files
📊 Findings: 🔴 1 Must · 🟡 4 Should · 🔵 2 Nice

───────────────────────────────────────────────────
Security
───────────────────────────────────────────────────

🔴 src/Admin/Settings.php:45 — Nonce verification missing
   ...

───────────────────────────────────────────────────
Performance
───────────────────────────────────────────────────
No issues found in this area.

───────────────────────────────────────────────────
Simplification
───────────────────────────────────────────────────

🔵 src/Service/Booking.php:120 — Duplicated date formatting (3 sites)
   ...

(... continues for Test Coverage Gap and i18n)

Recommendation:
- Fix the 🔴 nonce issue before /verify or PR
- 🟡 i18n findings can be bulk-addressed with /wp-i18n
```

## What `/review` Does NOT Do

- Does **not** modify code — review only, never edits
- Does **not** run tests / lint / PHPStan — that's `/verify`
- Does **not** check wp.org submission rules — that's `/submit-review`
- Does **not** review legacy code outside the current diff — focused on what you just changed

## Related Commands

- `/todo spec/<feature>/<file>.md [--tdd]` — implement from spec (run this first)
- `/verify` — full-project quality gate (run after `/review` fixes)
- `/submit-review` — wp.org submission compliance check (run before uploading to plugin directory)

## Related Agent

This command invokes the `code-reviewer` agent.
Located at: `@everything-wp/agents/code-reviewer.md`
