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

## Decision Making Process

### CRITICAL: Solution Evaluation (Never "Quick Fix")

**Before implementing ANY solution**:

1. **Enumerate Approaches** (3-5 options)
   ```
   PROBLEM: [Description]

   POSSIBLE SOLUTIONS:
   1. [Approach 1] - [brief description]
   2. [Approach 2] - [brief description]
   3. [Approach 3] - [brief description]
   4. [Approach 4] - [brief description]
   ```

2. **Evaluate Against Context**
   ```
   EVALUATION CRITERIA:
   • Application goal alignment
   • Architecture consistency
   • Long-term maintainability
   • Volunteer-friendly
   • Mission alignment (InformUp civic engagement)

   ANALYSIS:
   Approach 1: [pros/cons vs criteria]
   Approach 2: [pros/cons vs criteria]
   ...

   RECOMMENDATION: [Best approach and why]
   ```

3. **Present to User**
   - Show all options with tradeoffs
   - Recommend best approach with rationale
   - User chooses (or confirms recommendation)

**NEVER**:
- ❌ Choose "quick fix" or hack
- ❌ Implement without evaluating alternatives
- ❌ Skip evaluation for "simple" problems
- ❌ Assume first solution is best

**ALWAYS**:
- ✅ Consider multiple approaches
- ✅ Evaluate against architecture
- ✅ Think long-term maintainability
- ✅ Choose proper solution over fast solution

---

## Engineering Philosophy

### Iterative/Evolutionary Design (Not Waterfall)

**CRITICAL**: Start small, validate, then expand.

**Approach**:
```
1. Build minimal atomic component
   → Confirm it works

2. Add next piece of functionality
   → Confirm it works

3. Integrate pieces
   → Confirm they work together

4. Repeat until complete
```

**Example** (Survey Dashboard):
```
❌ WATERFALL (Don't do this):
  Design entire dashboard → Build all components → Test everything → Ship

✅ ITERATIVE (Do this):
  1. Build data fetching (atomic) → Test → Commit
  2. Add basic chart display → Test → Commit
  3. Add filtering → Test → Commit
  4. Add export → Test → Commit
  5. Polish UI → Test → Commit
```

**Principles**:
- **Start atomic**: Smallest useful piece first
- **Validate early**: Test each piece before next
- **Commit often**: Each atomic piece gets committed
- **Trust evolution**: System will evolve organically
- **No big bang**: Never build everything then test

**NEVER**:
- ❌ Build entire feature then test
- ❌ Design whole system upfront
- ❌ Wait for "complete" before validating
- ❌ Big bang integration

**ALWAYS**:
- ✅ Decompose into atomic components
- ✅ Build smallest piece first
- ✅ Validate before adding more
- ✅ Commit working increments
- ✅ Trust iterative process

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
