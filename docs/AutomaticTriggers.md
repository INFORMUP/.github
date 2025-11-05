# Automatic Triggers - What Runs When

**Version**: 2.0.0
**Operating Model**: Hybrid with Automatic Enforcement

---

## Overview

The Hybrid Operating Model uses **git hooks** to automatically trigger agents at the right time. This ensures reviews happen without requiring manual invocation.

---

## Complete Trigger Map

### On Branch Creation (`post-checkout` hook)

**Trigger**: `git checkout -b <branch-name>`

**Runs**:
- ✅ `feature-planner` agent (interactive)

**When**:
- Branch matches pattern: `feature/*`, `fix/*`, `enhancement/*`
- Not on main/master/develop branches

**What It Does**:
1. Detects new feature branch
2. Prompts to start feature planning
3. Helps create PRD + Design + Test Plan (if major)
4. Or creates design doc template

**Example**:
```bash
$ git checkout -b feature/survey-dashboard

🎨 New branch detected: feature/survey-dashboard

Would you like to start AI-assisted feature planning?
  1) Yes, start interactive planning
  2) Create template only
  3) Skip for now
```

---

### On Design Doc Commit (`post-commit` hook) ⭐ NEW

**Trigger**: Committing ANY design document

**Detects**:
- `docs/DESIGN-*.md`
- `docs/PRD-*.md`
- `design-docs/*.md`

**Runs**:
- ✅ `design-review-coordinator` agent (BLOCKING - interactive)

**What It Does**:
1. Detects design doc in commit
2. Automatically runs design-review-coordinator
3. Coordinator orchestrates:
   - `architecture-reviewer` (parallel)
   - `security-auditor` (parallel)
   - `cost-analyzer` (parallel, if major feature)
4. Creates review artifacts in `docs/reviews/`
5. Reports gate status

**Task Types**:
- ✅ **ALL** task types with design docs (not just major features!)
- NEW_FEATURE_MAJOR → architecture + security + cost
- NEW_FEATURE_MINOR → architecture + security
- ENHANCEMENT → architecture + security (if applicable)
- REFACTOR → architecture

**Example**:
```bash
$ git add docs/DESIGN-survey-dashboard.md
$ git commit -m "docs: Add design for survey dashboard"

📋 Design document detected in commit

Running design review coordinator...
(architecture, security, cost analysis)

[Reviews run in parallel - takes ~5 minutes]

✅ Design reviews complete!

Review artifacts created in docs/reviews/
  📄 architecture-survey-dashboard.md
  📄 security-survey-dashboard.md
  📄 cost-survey-dashboard.md

Next phase: Edge case analysis or test generation
```

**Important**: This is **BLOCKING** - you must interact with the reviews.

---

### On Code Commit (`pre-commit` hook)

**Trigger**: `git commit` (any commit with code changes)

**Runs**:
1. ✅ Linter
2. ✅ Formatter
3. ✅ Tests
4. ✅ Type checker (if TypeScript)
5. ✅ `code-reviewer` agent (quick mode, 30s timeout)

**What It Does**:
- Checks code quality before commit
- Runs quick AI review of staged changes
- Fails commit if critical issues found (configurable)

**Example**:
```bash
$ git commit -m "feat: Add dashboard component"

🔍 Running pre-commit checks...
  ✓ Linter passed
  ✓ Formatting OK
  ✓ Tests passed
  ✓ Type check passed
  🤖 Quick AI review...
  ✓ AI review passed

✅ All pre-commit checks passed
```

---

### On Push (`pre-push` hook)

**Trigger**: `git push`

**Runs**:
- ✅ `local-ci` agent (if enabled)
- ✅ `pr-generator` agent (if enabled and pushing to create PR)

**What It Does**:
- Runs full CI pipeline locally
- Generates PR description with compliance report
- Final gate check before push

**Example**:
```bash
$ git push origin feature/survey-dashboard

🚀 Running local CI...
  ✓ All tests pass (92% coverage)
  ✓ Build successful
  ✓ All phase gates passed

📝 Generating PR description...
  ✓ PR description created with compliance report

✅ Ready to push
```

---

## Summary: Automatic vs Manual

### Automatic (Via Git Hooks)

**Always Run Automatically**:
1. ✅ Feature planning (on new branch) - `post-checkout`
2. ✅ **Design reviews (on design doc commit)** - `post-commit` ⭐ **RUNS FOR ALL TASKS**
3. ✅ Code review (on every commit) - `pre-commit`
4. ✅ Local CI (on push) - `pre-push`
5. ✅ PR generation (on push) - `pre-push`

**Conditional (If Enabled in Config)**:
- Documentation updates (on source code commits)

### Manual (User Invokes)

**Run When Needed**:
- `edge-case-analyzer` - After design reviews, before tests
- `test-generator` - After edge case analysis
- `architecture-reviewer` - Manual deep dive
- `security-auditor` - Manual deep dive
- `cost-analyzer` - Manual deep dive
- `build-diagnostician` - When build fails
- `error-investigator` - When investigating errors
- `workflow-guardrails` - Manual workflow check

---

## Key Point: Design Reviews Run for ALL Tasks

### Answer to Question 2

**Design reviews run for**:
- ✅ NEW_FEATURE_MAJOR (architecture + security + cost)
- ✅ NEW_FEATURE_MINOR (architecture + security)
- ✅ ENHANCEMENT with design doc (architecture + security)
- ✅ REFACTOR with plan (architecture)
- ✅ **ANY commit containing a design doc** (universal rule)

**NOT limited to major features!**

**What varies by task type**:
- **Which reviews run** (major features get cost analysis, minor don't)
- **Enforcement strictness** (major = strict, minor = medium)
- **Additional requirements** (major needs edge case analysis, minor doesn't)

**But the trigger is universal**: Design doc commit → Reviews run automatically

---

## Hook Installation

### Yes, Install Script Sets Up Hooks

The installer:
1. ✅ Installs husky
2. ✅ Copies hook templates from `automation-templates/husky/` to `.husky/`
3. ✅ Makes hooks executable (`chmod +x`)
4. ✅ Hooks activate immediately after first commit

**Hooks Installed**:
- `.husky/post-checkout` - Feature planning trigger
- `.husky/post-commit` - **Design review trigger** ⭐ (now includes this!)
- `.husky/pre-commit` - Code quality + review
- `.husky/pre-push` - CI + PR generation
- `.husky/commit-msg` - Commit message validation

---

## Workflow Example (Automatic)

```bash
# 1. Create branch
$ git checkout -b feature/survey-dashboard
🎨 New branch detected!
[feature-planner runs automatically]

# 2. Create design doc
$ vim docs/DESIGN-survey-dashboard.md
$ git add docs/DESIGN-survey-dashboard.md
$ git commit -m "docs: Add design for survey dashboard"

📋 Design document detected!
[design-review-coordinator runs AUTOMATICALLY] ⭐
[Creates: architecture + security + cost reviews]
✓ Review artifacts created

# 3. Continue with edge case analysis (manual)
$ claude code --agent edge-case-analyzer
[Creates edge case analysis]
$ git commit -m "docs: Add edge case analysis..."

# 4. Generate tests (manual)
$ claude code --agent test-generator
[Creates tests from edge cases]
$ git commit -m "test: Add tests..."

# 5. Implement
$ vim src/components/SurveyDashboard.tsx
$ git commit -m "feat: Implement dashboard"
[code-reviewer runs automatically via pre-commit]

# 6. Push
$ git push origin feature/survey-dashboard
[local-ci runs automatically via pre-push]
[pr-generator runs automatically]
```

**Automatic steps**: Branch creation, design review, code review, CI, PR
**Manual steps**: Edge case analysis, test generation

---

## Configuration

Control what runs automatically in `.claude-automation-config.json`:

```json
{
  "triggers": {
    "featurePlanning": {
      "enabled": true  // post-checkout
    },
    "designReview": {
      "enabled": true,  // post-commit (NEW!)
      "automatic": true
    },
    "preCommitReview": {
      "enabled": true  // pre-commit
    },
    "prePushChecks": {
      "enabled": true  // pre-push
    }
  }
}
```

---

## Summary - Answers to Your Questions

### Q1: Does install script set up hooks for design reviews?

**A**: ✅ **YES** (now it does!)

The install script:
- Copies `post-commit` hook (now includes design review trigger)
- Copies all other hooks (pre-commit, pre-push, post-checkout)
- Makes them executable
- They activate automatically

### Q2: Does this only run for major features?

**A**: ❌ **NO** - Runs for **ANY task with a design doc**

**Universal rule**: Design doc commit → Design reviews run

**What varies by task type**:
- NEW_FEATURE_MAJOR → Gets all reviews (architecture + security + cost)
- NEW_FEATURE_MINOR → Gets architecture + security
- Others → Gets appropriate subset

**But the trigger is universal**: ANY design doc triggers reviews.

---

**The gap is now closed!** Design reviews happen automatically when design docs are committed, for all task types. ✅
