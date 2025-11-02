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

PHASE GATES: (for features)
  [✅|❌] Design Review (architecture, security, cost)
  [✅|❌] Edge Case Analysis
  [✅|❌] Test Generation

ARTIFACTS:
  📄 [Doc]: [path]
  📄 [Review]: [path]
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

## Workflow Phase Enforcement

### CRITICAL: Design Reviews Required for ANY Design Doc

**Universal Rule**: If a design document is created or committed, design reviews MUST be run.

**Trigger**: ANY of these files committed:
- `docs/DESIGN-*.md`
- `docs/PRD-*.md`
- `design-docs/*.md`

**Action**: Automatically run design-review-coordinator to create review artifacts.

### Required Workflow

```
DESIGN DOC COMMITTED
        ↓
DESIGN REVIEW COORDINATOR (AUTOMATIC)
  ├─> Architecture Review → docs/reviews/architecture-{feature}.md
  ├─> Security Review → docs/reviews/security-{feature}.md
  └─> Cost Analysis → docs/reviews/cost-{feature}.md (if major)
        ↓
GATE CHECK: All review artifacts exist?
  ✅ Yes → May proceed to next phase
  ❌ No → BLOCKED until reviews complete
```

### Phase Order by Task Type

**NEW_FEATURE_MAJOR**:
```
Planning → Design Review (GATE) → Edge Case (GATE) → Tests → Code
```

**NEW_FEATURE_MINOR**:
```
Planning → Design Review (GATE) → Tests → Code
```

**ENHANCEMENT** (if has design doc):
```
Planning → Design Review (GATE) → Tests → Code
```

**REFACTOR** (if has refactor plan):
```
Planning → Architecture Review (GATE) → Tests → Code
```

### How to Enforce

**STEP 1: Detect Design Doc Commit**

When user commits any design document:

```bash
# These patterns trigger design review:
git add docs/DESIGN-*.md
git add docs/PRD-*.md
git add design-docs/*.md

# Claude MUST run design-review-coordinator
```

**STEP 2: Check for Review Artifacts**

Before allowing progression to testing or implementation:

```
CHECK REQUIRED ARTIFACTS:

For ANY design doc:
  [ ] docs/reviews/architecture-{feature}.md exists?
  [ ] docs/reviews/security-{feature}.md exists?

For major features (additionally):
  [ ] docs/reviews/cost-{feature}.md exists?
  [ ] docs/EDGE-CASE-ANALYSIS-{feature}.md exists?

IF ANY MISSING:
  🚫 BLOCK with:

  "🚫 DESIGN REVIEW REQUIRED

  Design doc detected: {path}
  Missing review artifacts:
    ❌ docs/reviews/architecture-{feature}.md
    ❌ docs/reviews/security-{feature}.md

  ANY design doc requires design reviews.

  Run: claude code --agent design-review-coordinator

  This creates required review artifacts in ~5 minutes."
```

**STEP 3: Verify Before Each Phase**

```python
# Before test generation
if has_design_doc() and not all_reviews_complete():
    block("Design reviews required")

# Before implementation
if has_design_doc() and not all_reviews_complete():
    block("Design reviews required")

# Before PR
if has_design_doc() and not all_reviews_complete():
    block("Design reviews required")
```

### Design Review Coordinator

**Use this agent to orchestrate reviews**:

```bash
# After design doc is created
claude code --agent design-review-coordinator
```

**This agent will**:
1. Check for design doc
2. Run all required reviews (architecture, security, cost)
3. Create review artifacts in docs/reviews/
4. Report status (APPROVED / BLOCKED / APPROVED WITH CONDITIONS)
5. Only open gate if all reviews pass

**Example output**:
```
🎯 DESIGN REVIEW STATUS: survey-dashboard

REVIEWS COMPLETED:
  ✅ Architecture: APPROVED (docs/reviews/architecture-survey-dashboard.md)
  ✅ Security: APPROVED (docs/reviews/security-survey-dashboard.md)
  ✅ Cost: APPROVED (docs/reviews/cost-survey-dashboard.md)

GATE: OPEN - You may proceed to edge case analysis

ARTIFACTS:
  📄 Architecture: docs/reviews/architecture-survey-dashboard.md
  📄 Security: docs/reviews/security-survey-dashboard.md
  📄 Cost: docs/reviews/cost-survey-dashboard.md
```

---

## Important Rules

1. **Always invoke the skill** for engineering work
2. **Include compliance report** in all commits and PRs
3. **Link to artifacts** for human review
4. **Use concise format** (no verbose output)
5. **Keep repository clean** - use workspace for temporary files
6. **Commit after each phase completion** - create workflow checkpoints

---

## Phase Completion Commits

### CRITICAL: Commit After Each Phase

**Rule**: When a workflow phase completes, commit the artifacts immediately.

**Why**:
- Creates clear audit trail
- Provides rollback points
- Shows workflow progression in git history
- Prevents loss of work
- Makes review easier (one phase per commit)

### Required Commits

**After each of these phases**:

```
1. Feature Planning Complete
   Commit: "docs: Add feature planning for {feature}"
   Files:
     • docs/PRD-{feature}.md
     • docs/DESIGN-{feature}.md
     • docs/TEST-PLAN-{feature}.md

2. Design Review Complete
   Commit: "docs: Add design reviews for {feature}"
   Files:
     • docs/reviews/architecture-{feature}.md
     • docs/reviews/security-{feature}.md
     • docs/reviews/cost-{feature}.md (if applicable)

3. Edge Case Analysis Complete
   Commit: "docs: Add edge case analysis for {feature}"
   Files:
     • docs/EDGE-CASE-ANALYSIS-{feature}.md

4. Test Generation Complete
   Commit: "test: Add tests for {feature}"
   Files:
     • All test files generated

5. Implementation Complete
   Commit: "feat: Implement {feature}"
   Files:
     • Source code
     • Updated tests (if needed)

6. Documentation Updates
   Commit: "docs: Update documentation for {feature}"
   Files:
     • README updates
     • API docs
     • CHANGELOG
```

### Commit Message Format for Phase Completion

```
<type>: <phase description>

<what was completed in this phase>

🎯 TASK: <TASK_TYPE> | PHASE: <PHASE_NAME> | ENFORCEMENT: <level>

📊 PHASE COMPLIANCE: <XX>/100

PHASE ARTIFACTS:
  📄 <artifact>: <path>
  📄 <artifact>: <path>

GATE STATUS: <OPEN|BLOCKED>

<compliance report if relevant>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example Phase Commits

**Planning Phase**:
```
docs: Add feature planning for survey-dashboard

Created PRD, design doc, and test plan for survey analytics dashboard.

🎯 TASK: NEW_FEATURE_MAJOR | PHASE: Planning | ENFORCEMENT: strict

📊 PHASE COMPLIANCE: 92/100 ✅

PHASE ARTIFACTS:
  📄 PRD: docs/PRD-survey-dashboard.md (score: 93/100)
  📄 Design: docs/DESIGN-survey-dashboard.md (score: 95/100)
  📄 Test Plan: docs/TEST-PLAN-survey-dashboard.md (score: 88/100)

GATE STATUS: OPEN - Ready for design review

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Design Review Phase**:
```
docs: Add design reviews for survey-dashboard

Completed architecture, security, and cost analysis reviews.

🎯 TASK: NEW_FEATURE_MAJOR | PHASE: Design Review | ENFORCEMENT: strict

📊 PHASE COMPLIANCE: 100/100 ✅

PHASE ARTIFACTS:
  📄 Architecture Review: docs/reviews/architecture-survey-dashboard.md (APPROVED)
  📄 Security Review: docs/reviews/security-survey-dashboard.md (APPROVED)
  📄 Cost Analysis: docs/reviews/cost-survey-dashboard.md (APPROVED - $45/month)

REVIEW SUMMARY:
  • 0 critical issues
  • 2 recommendations (caching, rate limiting)
  • Estimated cost: $45/month ✅

GATE STATUS: OPEN - Ready for edge case analysis

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Edge Case Analysis Phase**:
```
docs: Add edge case analysis for survey-dashboard

Identified 18 edge cases and failure modes, prioritized P0-P3.

🎯 TASK: NEW_FEATURE_MAJOR | PHASE: Edge Case Analysis | ENFORCEMENT: strict

📊 PHASE COMPLIANCE: 100/100 ✅

PHASE ARTIFACTS:
  📄 Edge Case Analysis: docs/EDGE-CASE-ANALYSIS-survey-dashboard.md

RISK SUMMARY:
  • P0 Critical: 4 risks (must test)
  • P1 High: 6 risks (should test)
  • P2 Medium: 5 risks (nice to test)
  • P3 Low: 3 risks (optional)

GATE STATUS: OPEN - Ready for test generation

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Enforcement

**When phase completes, Claude MUST**:
1. Prompt to commit artifacts
2. Generate commit message with phase completion format
3. Show gate status (what's next)

**Example**:
```
Claude: "✅ Design review complete!

All review artifacts created:
  📄 docs/reviews/architecture-survey-dashboard.md
  📄 docs/reviews/security-survey-dashboard.md
  📄 docs/reviews/cost-survey-dashboard.md

NEXT: Commit these artifacts to mark phase completion.

Suggested commit:
  git add docs/reviews/
  git commit -m 'docs: Add design reviews for survey-dashboard...'

Shall I create this commit?"
```

---

## Workspace Management

### CRITICAL: Keep Repository Clean

**Use the workspace directory for ALL temporary/intermediate files**:

**Workspace Location**: `.claude_workspace/`

**What Goes in Workspace**:
- ✅ Intermediate drafts and working documents
- ✅ Checklists and task lists
- ✅ Temporary scripts and tools
- ✅ Analysis outputs and reports (before final)
- ✅ Generated files for review
- ✅ Scratch files and notes
- ✅ AI-generated content pending review
- ✅ Test data and fixtures (temporary)
- ✅ Build artifacts (temporary)

**What Goes in Repository** (NOT workspace):
- ✅ Final documentation (docs/, design-docs/)
- ✅ Source code (src/, lib/, etc.)
- ✅ Tests (tests/, __tests__/, *.test.*)
- ✅ Configuration files (package.json, tsconfig.json, etc.)
- ✅ Git hooks (.husky/)
- ✅ Claude agents (.claude/agents/)
- ✅ Claude skills (.claude/skills/)
- ✅ Decision log (.claude/decisions.md)
- ✅ README and core docs

### Workspace Structure

```
.claude_workspace/
├── drafts/              # Document drafts before final version
├── analysis/            # Edge case analysis, reviews in progress
├── checklists/          # Task checklists, todo lists
├── scripts/             # Temporary scripts
└── notes/               # Session notes, scratch work
```

### Example Usage

**Creating a draft design doc**:
```
❌ BAD: Write to docs/DESIGN-feature.md immediately
✅ GOOD: Write to .claude_workspace/drafts/DESIGN-feature.md first
         → Review with user
         → Move to docs/DESIGN-feature.md when approved
```

**Running edge case analysis**:
```
❌ BAD: Create docs/EDGE-CASE-ANALYSIS-feature.md immediately
✅ GOOD: Create .claude_workspace/analysis/edge-cases-feature.md first
         → Review with user
         → Move to docs/EDGE-CASE-ANALYSIS-feature.md when approved
```

**Creating temporary checklists**:
```
❌ BAD: Create TODO.md in repo root
✅ GOOD: Create .claude_workspace/checklists/feature-tasks.md
         → Never commit to repo
```

### Cleanup

**During work**:
- Keep workspace organized in subdirectories
- Delete obsolete files when done

**When feature complete**:
- Move finalized docs from workspace → repo
- Delete temporary files
- Keep only reference materials if needed

**Workspace is gitignored**: Files here won't be committed accidentally

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
