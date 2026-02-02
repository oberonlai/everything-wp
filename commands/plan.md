---
description: Create implementation plan using 4-layer task breakdown. WAIT for user CONFIRM before touching any code.
invokes_agent: planner
---

# Plan Command

Create a comprehensive implementation plan before writing any code.

## When to Use

- Starting a new feature
- Making architectural changes
- Working on complex refactoring
- Requirements are unclear

## Syntax

```bash
# Basic usage
/plan Build a booking system

# With skill reference (loads API documentation)
/plan @wc-api Build custom checkout flow
/plan @stripe-api @ecpay-api Build payment gateway
```

## Output

Plan is saved to `spec/[feature-name].md` for future reference.

## Related

- Agent: `@everything-wp/agents/planner.md`
- Skills: `@everything-wp/skills/`
