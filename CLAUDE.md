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

### CRITICAL: Follow Required Phase Order

The hybrid model enforces phase order for quality. **You MUST check for required artifacts before proceeding**.

### Required Phases for NEW_FEATURE_MAJOR

```
1. Feature Planning
   → PRD, Design, Test Plan created
   ✅ Proceed when: All docs score 90+

2. Design Review (BLOCKING GATE)
   → Architecture review artifact
   → Security review artifact
   → Cost analysis artifact
   🚫 CANNOT proceed without ALL review artifacts

3. Edge Case Analysis (BLOCKING GATE)
   → Edge case analysis document
   🚫 CANNOT proceed without edge case analysis

4. Test Generation
   → Uses edge case analysis
   → All P0 risks must have tests

5. Implementation
   → Code with tests
```

### How to Enforce

**Before running test-generator or allowing implementation**:

```
CHECK REQUIRED ARTIFACTS:
  [ ] docs/reviews/architecture-{feature}.md exists?
  [ ] docs/reviews/security-{feature}.md exists?
  [ ] docs/reviews/cost-{feature}.md exists? (if major feature)
  [ ] docs/EDGE-CASE-ANALYSIS-{feature}.md exists? (if major feature)

IF ANY MISSING:
  🚫 BLOCK and show:

  "🚫 PHASE GATE BLOCKED

  Missing required artifacts:
    ❌ Architecture review: docs/reviews/architecture-{feature}.md

  You must complete design review before proceeding to testing.

  Run: claude code --agent design-review-coordinator

  This will:
    • Run architecture review
    • Run security review
    • Run cost analysis
    • Create all required review artifacts

  Cannot proceed until all reviews complete."
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
