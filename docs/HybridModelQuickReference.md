# Hybrid Operating Model - Quick Reference

**Version**: 2.0.0
**For**: Developers using the hybrid model

---

## At a Glance

### What's Different?

Every agent interaction now shows:
1. **Task Classification** - What type of work is this?
2. **Applicable Standards** - What standards apply and why?
3. **Compliance Score** - How are you doing? (0-100)
4. **Improvement Path** - How to increase your score

### Example Agent Output

```
🎯 Task: NEW_FEATURE_MAJOR
📋 Standards: PRD + Design + Test Plan + 80% coverage + TDD
📊 Compliance: 78/100 ⚠️ (need 80+)
🔧 Fix: +3 tests, split 1 function → 85/100 ✅
```

---

## Task Types

| Type | When | Docs | Tests | Enforcement |
|------|------|------|-------|-------------|
| **NEW_FEATURE_MAJOR** | >500 LOC, user-facing | PRD + Design + Tests | 80%, TDD | Strict |
| **NEW_FEATURE_MINOR** | <500 LOC | Design | 80% | Medium |
| **ENHANCEMENT** | Improve existing | Update design | Maintain | Medium |
| **BUG_FIX** | Fix bug | Issue desc | +Regression | Soft |
| **HOTFIX** | Production emergency | Post-hoc OK | Regression | Expedited |
| **REFACTOR** | Restructure | Plan | Maintain+ | Medium |
| **DOCS** | Documentation only | Self-doc | None | Soft |
| **CHORE** | Deps, config | Notes | If applicable | Soft |
| **EXPERIMENT** | POC, learning | Notes | Optional | Minimal |

### How to Choose

- **Major feature** = New user-facing capability, >500 lines, complex
- **Minor feature** = Small addition, <500 lines
- **Enhancement** = Improve existing feature
- **Bug fix** = Repair broken functionality
- **Hotfix** = Production down/critical security issue
- **Refactor** = Improve code structure, no behavior change
- **Docs** = README, comments, etc.
- **Chore** = Dependencies, tooling, configuration
- **Experiment** = Trying something out, learning

**Branch naming helps**:
```bash
feature/*    → NEW_FEATURE (size determines major/minor)
fix/*        → BUG_FIX
hotfix/*     → HOTFIX
refactor/*   → REFACTOR
docs/*       → DOCS
chore/*      → CHORE
experiment/* → EXPERIMENT
```

---

## Compliance Scoring

### How It Works

Every task gets scored **0-100**:

```
Documentation:  30 points
Code Quality:   25 points
Test Coverage:  25 points
Security:       10 points
Performance:    10 points
──────────────────────────
Total:         100 points
```

### Score Meanings

| Score | Rating | What It Means |
|-------|--------|---------------|
| 90-100 | ✅ EXCELLENT | Ship it! |
| 80-89 | ✅ GOOD | Good to go, minor improvements suggested |
| 70-79 | ⚠️ ADEQUATE | Has issues, should address before merging |
| <70 | ❌ NEEDS WORK | Blocked (if enforcement is medium/strict) |

### Example Score Display

```
📊 CURRENT COMPLIANCE: 78/100 ⚠️

Documentation:    25/30  ✅ Good
Code Quality:     18/25  ⚠️  2 functions too long
Test Coverage:    18/25  ⚠️  73% (need 80%)
Security:         10/10  ✅ Perfect
Performance:       7/10  ⚠️  1 memory leak

STATUS: Below threshold (need 80+)

QUICK WINS TO 85/100:
  1. Split processData() → +5 pts [15 min]
  2. Add edge case tests → +3 pts [20 min]
  3. Fix memory leak → +4 pts [10 min]
     ─────────────────────────────────────
     +12 pts → 90/100 ✅ (45 min total)
```

---

## Enforcement Levels

Your repo is configured with an enforcement level (check `.claude-automation-config.json`):

### Minimal (Experiments)
- Shows standards and scores
- **Never blocks**
- Education only

### Soft (Default for Bug Fixes, Docs, Chores)
- Shows standards and scores
- **Blocks only for security issues**
- Warns for quality issues

### Medium (Default for Features, Refactors)
- Shows standards and scores
- **Blocks if score <80**
- Overrides allowed with justification

### Strict (Major Features)
- Shows standards and scores
- **Blocks if score <90**
- Overrides require approval

### Expedited (Hotfixes)
- Fix first, comply after
- Documentation can be post-hoc (24h deadline)
- **Security still enforced**

---

## Common Scenarios

### "I want to start a major feature"

```bash
git checkout -b feature/user-dashboard
```

Agent will:
1. ✅ Classify as NEW_FEATURE_MAJOR
2. ✅ Show required docs: PRD + Design + Test Plan
3. ✅ Guide you through planning
4. ✅ Help create required documents
5. ✅ Score each document (need 90+)

**What you need**: ~1-2 hours for planning

### "I need to fix a quick bug"

```bash
git checkout -b fix/validation-error
```

Agent will:
1. ✅ Classify as BUG_FIX
2. ✅ Relaxed standards (soft enforcement)
3. ✅ Need: Issue description + regression test
4. ✅ Function size limit relaxed (30 lines vs 20)

**What you need**: ~15-30 minutes

### "Production is down!"

```bash
git checkout -b hotfix/critical-data-leak
```

Agent will:
1. ✅ Classify as HOTFIX
2. ✅ Expedited mode (fix first!)
3. ✅ Security still enforced (it's a data leak)
4. ✅ Docs can follow within 24h

**What you need**: Fix ASAP, document after

### "I'm just experimenting"

```bash
git checkout -b experiment/new-approach
```

Agent will:
1. ✅ Classify as EXPERIMENT
2. ✅ Minimal enforcement
3. ✅ Just asks for experiment notes
4. ✅ Tests optional

**What you need**: Minimal, just capture learnings

---

## Agent Commands

### Automatic Triggers

Agents run automatically via git hooks:

```bash
git checkout -b feature/new-thing  → feature-planner
git commit                         → code-reviewer
git push                           → local-ci, pr-generator
```

### Manual Invocation

```bash
# Get workflow guidance
claude code --agent workflow-guardrails

# Check current compliance
claude code --agent workflow-guardrails --check-compliance

# Plan a feature
claude code --agent feature-planner

# Review code
claude code --agent code-reviewer

# Generate tests
claude code --agent test-generator

# Check security
claude code --agent security-auditor
```

---

## Overrides & Exceptions

### When You Need to Override

Sometimes you have a good reason to not meet standards.

**Valid Reasons**:
- Urgent hotfix (docs can follow)
- Experimental code (not production-bound)
- External constraints (third-party code)
- Refactoring in progress (will fix in next commit)

### How to Override

```bash
# Most configs allow overrides with justification
# Agent will ask: "Why are you overriding?"
# Provide clear reason:

"This is a hotfix for production down.
Will add full tests and docs within 24h.
Tracking in issue #123."
```

This override is **logged** and will be reviewed.

### When Overrides Are Blocked

For major features with strict enforcement:
- Security issues: **Never allowed**
- Quality <90: **Requires approval**
- Missing critical docs: **Requires approval**

---

## Tips & Tricks

### Tip 1: Use Task Classification to Your Advantage

If you're doing quick work:
```bash
git checkout -b fix/typo  # Classified as BUG_FIX → soft standards
```

Not:
```bash
git checkout -b feature/typo  # Would be classified as FEATURE → strict
```

### Tip 2: Check Compliance Early

```bash
# See your score before committing
claude code --agent workflow-guardrails --check-compliance
```

### Tip 3: Ask for Help Improving Score

```
Agent: "Your compliance is 72/100"
You: "What's the fastest way to 80?"
Agent: "Add 2 tests → 80/100 in ~20 minutes"
```

### Tip 4: Use Experiments for POCs

```bash
git checkout -b experiment/try-new-library
# Minimal standards, fast iteration
# Convert to feature/* branch if it works
```

### Tip 5: Leverage Auto-Generated Tests

```bash
# Agent can generate test scaffolding
claude code --agent test-generator --file src/new-feature.js
# Review and refine the generated tests
```

---

## Understanding Agent Output

### Task Classification Block

```
🎯 TASK CLASSIFICATION
Detected Task: NEW_FEATURE_MAJOR
Reason:
  - Branch pattern: feature/*
  - Estimated scope: 800-1200 lines
  - User-facing: Yes
  - Data handling: User survey data
```

**Meaning**: Agent tells you how it classified your work and why.
**Action**: Confirm or correct if wrong.

### Applicable Standards Block

```
📋 APPLICABLE STANDARDS FOR NEW_FEATURE_MAJOR

Documentation:
  ✅ PRD required (score 90+)
  ✅ Design Doc required (score 90+)
  ✅ Test Plan required (score 90+)

Testing:
  ✅ 80% minimum coverage
  ✅ TDD required
  ✅ Types: Unit + Integration + E2E
```

**Meaning**: These are the standards for THIS task type.
**Action**: Understand what's expected.

### Compliance Score Block

```
📊 CURRENT COMPLIANCE: 78/100 ⚠️

Documentation:    25/30  ✅
Code Quality:     18/25  ⚠️
Test Coverage:    18/25  ⚠️
Security:         10/10  ✅
Performance:       7/10  ⚠️

STATUS: Below threshold (need 80+)
```

**Meaning**: Your current score and breakdown.
**Action**: Identify areas to improve.

### Improvement Path Block

```
🔧 TO IMPROVE FROM 78 → 85

Quick Wins:
  1. Split processData() → +5 pts [15 min]
  2. Add tests for edge cases → +3 pts [20 min]
     ──────────────────────────────────────
     +8 pts → 86/100 ✅ (35 min)
```

**Meaning**: Specific, actionable steps to improve.
**Action**: Pick the highest impact items.

---

## FAQ

**Q: What if I disagree with the task classification?**

A: Tell the agent! It will ask for confirmation. If you say "this is actually a minor feature, not major," it will adjust standards.

**Q: Can I change standards for my repository?**

A: Yes! Edit `.claude-automation-config.json` and adjust standards for each task type.

**Q: What if I don't have time to meet all standards?**

A: Depends on enforcement level:
- **Soft**: You'll get warnings but can proceed
- **Medium**: You can override with justification
- **Strict**: You need approval or must meet standards

**Q: How do I increase enforcement over time?**

A: Edit `.claude-automation-config.json`:
```json
{
  "standards": {
    "enforcement": "strict"  // Was "soft" or "medium"
  }
}
```

**Q: Why am I seeing scores now? I didn't before.**

A: This is the hybrid model (v2.0). It adds transparency through scoring. You can see exactly how your work measures up.

**Q: Can I disable scoring?**

A: Yes, but not recommended. Edit config:
```json
{
  "compliance": {
    "displayFormat": {
      "showScore": false
    }
  }
}
```

---

## Cheat Sheet

### Branch Naming → Task Type

```
feature/xyz      → NEW_FEATURE (major/minor based on size)
fix/xyz          → BUG_FIX
hotfix/xyz       → HOTFIX
refactor/xyz     → REFACTOR
docs/xyz         → DOCS
chore/xyz        → CHORE
experiment/xyz   → EXPERIMENT
```

### Task Type → Standards

```
NEW_FEATURE_MAJOR:  PRD + Design + Tests | 80% | TDD | Strict
NEW_FEATURE_MINOR:  Design | 80% | Medium
BUG_FIX:            Issue | Maintain + regression | Soft
HOTFIX:             Post-hoc OK | Regression | Expedited
REFACTOR:           Plan | Maintain+ | Medium
EXPERIMENT:         Notes | Optional | Minimal
```

### Score → Status

```
90-100:  ✅ Excellent - Ship it!
80-89:   ✅ Good - Ready to go
70-79:   ⚠️  Adequate - Fix issues
<70:     ❌ Blocked - Needs work
```

### Enforcement → Behavior

```
Minimal:    Never blocks, education only
Soft:       Blocks security only
Medium:     Blocks <80, overrides OK
Strict:     Blocks <90, approval needed
Expedited:  Fix first, comply after
```

---

## Getting Help

### From Agents

```bash
# General guidance
claude code --agent workflow-guardrails

# Specific to task
claude code --agent feature-planner        # For planning
claude code --agent code-reviewer          # For review
claude code --agent test-generator         # For tests
```

### From Documentation

- **Full Spec**: `docs/HybridOperatingModel.md`
- **Implementation Guide**: `HYBRID_MODEL_IMPLEMENTATION.md`
- **Agent Details**: `automation-templates/claude-agents/README.md`

### From Team

- **Slack**: #engineering channel
- **Email**: engineering@informup.org
- **Issues**: GitHub issues for questions/problems

---

**Remember**: The goal is transparent, measurable standards with intelligent guidance. Agents help you understand what's expected and how to meet those expectations. You're always in control.

---

*Quick Reference for InformUp Hybrid Operating Model v2.0*
