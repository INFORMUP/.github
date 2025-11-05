# Claude Instructions for InformUp Engineering

**Use the `informup-engineering-excellence` skill for ALL engineering tasks.**

---

## Core Rules

1. **Use the skill** - `.claude/skills/informup-engineering-excellence/SKILL.md`
2. **Follow phase order** - Design doc → Reviews → Edge cases → Tests → Code
3. **Commit after each phase** - Clear audit trail
4. **Use workspace** - `.claude_workspace/` for temporary files
5. **Never revert without asking** - Check `.claude/decisions.md` first
6. **Clear context when task complete** - Run `/clear` after merge

---

## Automatic Triggers

**Git hooks run agents automatically**:
- New branch → feature-planner
- Design doc commit → design-review-coordinator ⭐
- Code commit → code-reviewer
- Push → local-ci + pr-generator

---

## Phase Gates (Enforced)

**Before proceeding, verify artifacts exist**:

```
Design Review Gate:
  ✅ docs/reviews/architecture-{feature}.md
  ✅ docs/reviews/security-{feature}.md
  ✅ docs/reviews/cost-{feature}.md (if major)

Edge Case Gate (major features):
  ✅ docs/EDGE-CASE-ANALYSIS-{feature}.md
```

**Block if missing** - Run coordinator to create.

---

## Report Format

```
🎯 TASK: [TYPE] | ENFORCEMENT: [level] | THRESHOLD: [XX]

📊 COMPLIANCE: [XX]/100 [STATUS]
  Documentation  [XX]/30
  Code Quality   [XX]/25
  Test Coverage  [XX]/25
  Security       [XX]/10
  Performance    [XX]/10

PHASE GATES:
  [✅|❌] Design Review
  [✅|❌] Edge Case Analysis
  [✅|❌] Test Generation

ARTIFACTS:
  📄 [Type]: [path]
```

---

## InformUp Context

**Mission**: Increase local civic participation
**Constraints**: Limited budget, volunteer contributors
**Priorities**: Mission alignment, maintainability, accessibility

---

## Key Agents

```bash
claude code --agent design-review-coordinator  # After design doc
claude code --agent edge-case-analyzer         # After reviews
claude code --agent test-generator             # After edge cases
claude code --agent workflow-guardrails        # Check compliance
```

---

**Docs**: `docs/HybridOperatingModel.md` | **Quick Ref**: `docs/HybridModelQuickReference.md`
