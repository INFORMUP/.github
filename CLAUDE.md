# Claude Instructions for InformUp Engineering

**CRITICAL**: You MUST use the InformUp Hybrid Operating Model skill for ALL engineering tasks.

---

## Skill to Use

**Skill**: `informup-engineering-excellence` (located in `.claude/skills/informup-engineering-excellence/SKILL.md`)

**When**: For EVERY engineering task (features, bugs, refactors, docs, etc.)

**Purpose**: Enforces transparent standards with task classification, compliance scoring, and document linking.

---

## Quick Reference

The skill provides:
- **Task Classification**: Automatically classifies work into 9 types (NEW_FEATURE_MAJOR, BUG_FIX, etc.)
- **Standards Display**: Shows applicable standards for the task type
- **Compliance Scoring**: Calculates 0-100 score with breakdown
- **Document Linking**: Includes artifacts for human review
- **Improvement Guidance**: Shows how to increase compliance

**Report Format** (concise, technical):
```
🎯 TASK: [TYPE] | ENFORCEMENT: [level] | THRESHOLD: [XX]

📊 COMPLIANCE: [XX]/100 [STATUS]
  Documentation  [XX]/30
  Code Quality   [XX]/25
  Test Coverage  [XX]/25
  Security       [XX]/10
  Performance    [XX]/10

ARTIFACTS:
  📄 [Doc]: [path]
```

---

## Repository Context

**Organization**: InformUp
**Type**: Nonprofit newsroom
**Mission**: Dramatically increase local civic participation
**Constraints**: Limited budget, volunteer contributors
**Priorities**: Mission alignment, accessibility, maintainability

---

## Configuration

**Enforcement Level**: medium (set in `.claude-automation-config.json`)
**Minimum Score**: 80
**Security Issues**: Always blocking

---

## Important Rules

1. **Always invoke the skill** for engineering work
2. **Include compliance report** in all commits and PRs
3. **Link to artifacts** for human review
4. **Use concise format** (no verbose output)

---

## Anti-Reversion Protection

### CRITICAL: Never Revert Without Explicit Confirmation

**BEFORE removing, reverting, or significantly changing:**
- Previous features or functionality
- Configuration decisions
- Architecture choices
- Standards or requirements
- User customizations
- Design decisions from previous sessions

**YOU MUST ASK FIRST**:
```
⚠️  REVERSION DETECTED

Proposed change would remove/modify: [X]

Previous decision: [What was decided before]
Impact: [What will be affected]

Do you want to proceed?
  [1] Yes, revert this
  [2] No, keep it
  [3] Modify instead
```

### Decision Log

Track major decisions in `.claude/decisions.md` for context across sessions:

**Log format**:
```markdown
## [YYYY-MM-DD] - [Decision]
**Context**: [Why]
**Decision**: [What]
**Impact**: [Who/what affected]
```

**Check this log** before suggesting reversions.

### Examples

**BAD**:
```
User: "Reports are verbose"
Claude: [Removes reporting without asking]
```

**GOOD**:
```
User: "Reports are verbose"
Claude: "I can reduce verbosity. Current reports include:
  - Task classification
  - Compliance scores
  - Standards display

Options:
  1. Make concise (keep all info, reduce formatting)
  2. Remove some sections (which?)
  3. Make configurable

What would you prefer?"
```

---

For detailed documentation, see:
- `docs/HybridOperatingModel.md` - Full specification
- `docs/HybridModelQuickReference.md` - Quick reference guide
- `.claude/skills/informup-engineering-excellence/SKILL.md` - Skill definition
