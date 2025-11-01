# Hybrid Engineering Operating Model

**Version**: 2.0.0
**Last Updated**: 2025-01-31
**Status**: Active

---

## Overview

InformUp's Hybrid Engineering Operating Model combines the best of two approaches:

1. **Agent-Based Automation** (current strength) - AI-native, interactive, educational guidance
2. **Standards-Based Enforcement** (new addition) - Measurable quality standards with transparent decision-making

### Core Philosophy

**"Transparent Standards, Intelligent Guidance"**

- Agents explicitly state what task type you're working on
- Clear standards are shown for each task type
- Agents use judgment to classify work and recommend appropriate standards
- Enforcement is configurable (warn → soft → strict)
- Education over gatekeeping

---

## Key Innovation: Task-Aware Standards

### The Problem We Solved

**Before**: Agents ran without clearly stating why or what standards applied
**After**: Every agent interaction starts with transparent task classification

### How It Works

```
Developer action → Agent activates → Determines task type → Shows applicable standards → Provides guidance
```

**Example**:
```
🎯 Task Classification
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Detected Task Type: NEW FEATURE (major)
Complexity: High (estimated 500+ lines)
Impact: User-facing

📋 Applicable Standards for this task:
  ✅ Documentation: PRD + Design Doc + Test Plan required
  ✅ Test Coverage: 80% minimum
  ✅ Code Quality: Functions ≤20 lines, complexity ≤10
  ✅ Security Review: Required (user data involved)
  ✅ Design Review: Required (human review needed)

Current Compliance: 0/100 (not started yet)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Task Classification System

### Task Types

Every piece of work is classified into one of these types, each with different standards:

| Task Type | Description | Documentation | Tests | Review | Enforcement |
|-----------|-------------|---------------|-------|--------|-------------|
| **NEW_FEATURE_MAJOR** | User-facing feature, >500 LOC | PRD + Design + Test Plan | 80% + TDD | Human + AI | Strict |
| **NEW_FEATURE_MINOR** | Small feature, <500 LOC | Design Doc | 80% | AI + Optional Human | Medium |
| **ENHANCEMENT** | Improvement to existing feature | Updated Design Doc | Maintain coverage | AI | Medium |
| **BUG_FIX** | Non-critical bug repair | Issue description | Test for bug + maintain coverage | AI | Soft |
| **HOTFIX** | Critical production issue | Incident report | Regression test | Human (post-fix) | Expedited |
| **REFACTOR** | Code improvement, no behavior change | Refactor plan | Maintain/improve coverage | AI | Medium |
| **DOCS** | Documentation only | N/A | N/A | Light | Soft |
| **CHORE** | Dependencies, config, tooling | Change notes | If applicable | Light | Soft |
| **EXPERIMENT** | Proof of concept, R&D | Experiment notes | Optional | Optional | Minimal |

### How Tasks Are Classified

Agents use multiple signals to determine task type:

1. **Branch Name**: `feature/*`, `fix/*`, `hotfix/*`, `refactor/*`, `docs/*`, `chore/*`, `experiment/*`
2. **Change Analysis**: Lines changed, files affected, complexity
3. **User Confirmation**: Agents ask if classification seems wrong
4. **Context**: Linked issues, PR descriptions, commit messages

**Example Classification Logic**:
```
Branch: feature/user-survey-dashboard
Files: 23 files, 1,247 lines added
User Data: Yes (survey responses)
→ Classification: NEW_FEATURE_MAJOR
```

---

## Standards Framework

### Documentation Standards

#### NEW_FEATURE_MAJOR
**Required**:
- Product Requirements Document (PRD) - `docs/PRD-{feature}.md`
- Technical Design Document - `docs/DESIGN-{feature}.md`
- Test Plan - `docs/TEST-PLAN-{feature}.md`

**Scoring**: Each document scored 0-100, minimum 90/100 to proceed

#### NEW_FEATURE_MINOR
**Required**:
- Design Document - `design-docs/{feature}.md`

**Scoring**: Minimum 85/100

#### ENHANCEMENT, REFACTOR
**Required**:
- Updated design doc or refactor plan
- Explanation of why change is needed

#### BUG_FIX, HOTFIX
**Required**:
- Issue description with repro steps
- Root cause analysis (for hotfixes)

### Code Quality Standards

#### All Features & Refactors
```yaml
Functions:
  max_lines: 20
  max_complexity: 10

Naming:
  clear: required
  consistent: required

Error Handling:
  all_inputs_validated: required
  comprehensive: required

Security:
  no_hardcoded_secrets: blocking
  input_sanitization: required
```

#### Bug Fixes & Hotfixes
```yaml
# Relaxed standards for urgent fixes
Functions:
  max_lines: 30  # Slightly relaxed
  max_complexity: 12

Focus:
  - Fix the immediate issue
  - Add regression test
  - Plan proper refactor if needed
```

### Testing Standards

#### Test Coverage Targets

| Task Type | Minimum Coverage | TDD Required | Test Types |
|-----------|-----------------|--------------|------------|
| NEW_FEATURE_MAJOR | 80% | Yes | Unit + Integration + E2E |
| NEW_FEATURE_MINOR | 80% | Recommended | Unit + Integration |
| ENHANCEMENT | Maintain current | No | Unit |
| BUG_FIX | +5% (test for bug) | No | Regression + Unit |
| HOTFIX | Regression test only | No | Regression |
| REFACTOR | Maintain or improve | No | All existing |

#### TDD Enforcement

**When TDD is Required** (NEW_FEATURE_MAJOR):
- Tests must be committed BEFORE implementation
- Tests must fail initially (red state verified)
- Implementation makes tests pass (green state)
- Code is refactored (refactor state)

**When TDD is Recommended** (NEW_FEATURE_MINOR):
- Encouraged but not blocking
- Agent offers to generate test scaffolding
- Compliance score higher with TDD

**When TDD is Optional**:
- BUG_FIX: Write test that reproduces bug, then fix
- HOTFIX: Fix first, test after (but required)
- REFACTOR: Tests already exist
- CHORE: Tests if applicable

---

## Compliance Scoring

### How Scoring Works

Every task gets a compliance score: **0-100**

Scoring breakdown:
```
Documentation:     30 points
Code Quality:      25 points
Test Coverage:     25 points
Security:          10 points
Performance:       10 points
────────────────────────────
Total:            100 points
```

### Scoring Thresholds

| Score | Rating | Action |
|-------|--------|--------|
| 90-100 | ✅ EXCELLENT | Pass - ready to ship |
| 80-89 | ⚠️  GOOD | Pass with recommendations |
| 70-79 | ⚠️  ADEQUATE | Warning - address issues |
| <70 | ❌ NEEDS WORK | Blocked (if strict enforcement) |

### Enforcement Modes

Configure in `.claude-automation-config.json`:

```json
{
  "standards": {
    "enforcement": "medium",  // minimal | soft | medium | strict
    "minimumScore": 80,
    "failOnSecurityIssues": true,
    "allowOverride": true
  }
}
```

**Enforcement Levels**:

- **Minimal** (experiments, learning): Scoring shown, no blocking, education focus
- **Soft** (default): Warnings for <80, blocking only for security
- **Medium** (recommended): Blocking for <80, overrides allowed with justification
- **Strict** (production-critical): Blocking for <90, overrides require approval

---

## Enhanced Agent Behavior

### All Agents Now Include

1. **Task Classification Header**
   ```
   🎯 Task: NEW_FEATURE_MAJOR
   📊 Current Compliance: 65/100
   ⚠️  Status: Below threshold (need 80+)
   ```

2. **Applicable Standards Display**
   ```
   📋 Standards for this task:
   ✅ Documentation: Required
   ✅ Test Coverage: 80% minimum
   ⚠️  Code Quality: 2 functions exceed 20 lines
   ```

3. **Transparent Decision Explanations**
   ```
   💡 Why these standards apply:

   This is a NEW_FEATURE_MAJOR because:
   - User-facing functionality (survey dashboard)
   - >500 lines of code (estimated)
   - Handles user data (requires security review)

   If this classification seems wrong, let me know!
   ```

4. **Actionable Guidance**
   ```
   🔧 To improve compliance to 85/100:

   High Impact (quick wins):
   - Split processData() function (22 lines → max 20)
   - Add test for edge case: empty survey responses

   Medium Impact:
   - Complete "Security Considerations" section in design doc

   This would raise your score from 65 → 85
   ```

### Agent-Specific Enhancements

#### Feature Planner (Enhanced)
```markdown
NOW INCLUDES:
- Task type classification upfront
- Standards display based on task type
- Compliance scoring as doc is created
- Warning if starting major feature without proper planning

EXAMPLE OUTPUT:
"I see you're starting a NEW_FEATURE_MAJOR (survey dashboard).
This requires PRD + Design + Test Plan (90+ score each).
Let's work through these together..."
```

#### Code Reviewer (Enhanced)
```markdown
NOW INCLUDES:
- Standards check based on task type
- Compliance scoring of current changes
- Specific fixes to improve score
- Different strictness based on task type

EXAMPLE OUTPUT:
"Reviewing ENHANCEMENT changes...
Current compliance: 78/100 ⚠️

Issues:
- [Function Length] processResults() is 23 lines (max: 20)
  Fix: Extract validation logic to validateResults()
  Impact: +5 points → 83/100 ✅"
```

#### Workflow Guardrails (Enhanced)
```markdown
NOW INCLUDES:
- Task classification on every major action
- Standards appropriate to task type
- Clear explanation of WHY standards matter
- Options with tradeoff explanations

EXAMPLE OUTPUT:
"🚧 Working on main branch

Detected: REFACTOR task on main branch
Standards: Refactors should be in feature branches

WHY: Refactors can introduce bugs. Feature branches provide:
- Safe testing environment
- Easy rollback if issues arise
- Better code review process

RECOMMENDATION: Move to feature branch
ALTERNATIVE: Proceed on main (acceptable if: small, well-tested)

Your choice?"
```

---

## Configuration Schema

### .claude-automation-config.json

```json
{
  "version": "2.0.0",
  "operatingModel": "hybrid",

  "taskClassification": {
    "autoDetect": true,
    "allowUserOverride": true,
    "requireConfirmation": true
  },

  "standards": {
    "enforcement": "medium",
    "minimumScore": 80,
    "failOnSecurity Issues": true,
    "allowOverride": true,
    "overrideRequiresJustification": true
  },

  "taskTypes": {
    "NEW_FEATURE_MAJOR": {
      "documentation": {
        "required": ["PRD", "DESIGN", "TEST_PLAN"],
        "minimumScore": 90
      },
      "testing": {
        "minimumCoverage": 80,
        "tddRequired": true,
        "types": ["unit", "integration", "e2e"]
      },
      "codeQuality": {
        "maxFunctionLines": 20,
        "maxComplexity": 10
      },
      "review": {
        "aiRequired": true,
        "humanRequired": true
      },
      "enforcement": "strict"
    },

    "BUG_FIX": {
      "documentation": {
        "required": ["issue_description"],
        "minimumScore": 70
      },
      "testing": {
        "minimumCoverage": "maintain",
        "regressionTestRequired": true
      },
      "codeQuality": {
        "maxFunctionLines": 30,
        "maxComplexity": 12
      },
      "enforcement": "soft"
    },

    "HOTFIX": {
      "documentation": {
        "required": ["incident_report"],
        "canBePostHoc": true
      },
      "testing": {
        "regressionTestRequired": true
      },
      "review": {
        "humanRequired": true,
        "timing": "post-deployment"
      },
      "enforcement": "expedited"
    },

    "EXPERIMENT": {
      "documentation": {
        "required": ["experiment_notes"]
      },
      "testing": {
        "optional": true
      },
      "enforcement": "minimal"
    }
  },

  "compliance": {
    "scoring": {
      "documentation": 30,
      "codeQuality": 25,
      "testCoverage": 25,
      "security": 10,
      "performance": 10
    },
    "thresholds": {
      "excellent": 90,
      "good": 80,
      "adequate": 70,
      "needsWork": 0
    }
  },

  "agents": {
    "allAgentsShowStandards": true,
    "allAgentsShowCompliance": true,
    "allAgentsExplainDecisions": true
  }
}
```

---

## Migration Guide

### From v1.0 (Pure Agent-Based) → v2.0 (Hybrid)

#### What's New

1. **Task Classification**: Agents now classify your work and show applicable standards
2. **Compliance Scoring**: Every task gets scored 0-100
3. **Transparent Decision-Making**: Agents explain WHY standards apply
4. **Configurable Enforcement**: Choose your strictness level
5. **Task-Specific Standards**: Different standards for different work types

#### What Stays the Same

- ✅ Same 12 agents
- ✅ Interactive, educational approach
- ✅ Git hooks and file watchers
- ✅ InformUp-specific context
- ✅ Agent-based architecture

#### What Changes

- 📊 Agents now show compliance scores
- 🎯 Agents classify task types
- 📋 Standards are explicitly displayed
- ⚙️  Enforcement is configurable
- 💡 More transparency in decision-making

#### Migration Steps

1. **Update configuration**:
   ```bash
   # Backup old config
   cp .claude-automation-config.json .claude-automation-config.v1.json

   # Install new config with defaults
   ./automation-installer/install.sh --upgrade
   ```

2. **Choose enforcement level**:
   Edit `.claude-automation-config.json`:
   ```json
   {
     "standards": {
       "enforcement": "soft"  // Start soft, increase later
     }
   }
   ```

3. **Test with one feature**:
   ```bash
   git checkout -b feature/test-hybrid-model
   # Agent will show new classification and standards display
   ```

4. **Adjust settings** based on team feedback

5. **Gradually increase enforcement** as team adapts:
   ```
   Week 1-2: "soft" (warnings only)
   Week 3-4: "medium" (blocking at 80+)
   Week 5+: "strict" (blocking at 90+ for major features)
   ```

---

## Benefits of the Hybrid Model

### For Developers

- **Clarity**: Always know what standards apply and why
- **Flexibility**: Different standards for different work
- **Learning**: Understand best practices through transparent explanations
- **Control**: Choose enforcement level that works for you
- **Guidance**: Agents help improve compliance with specific suggestions

### For InformUp

- **Quality**: Measurable standards without slowing development
- **Transparency**: Clear decision-making process
- **Adaptability**: Configure enforcement per repository or task type
- **Mission Alignment**: Standards support nonprofit constraints
- **Volunteer-Friendly**: Educational approach helps all skill levels

### For the Codebase

- **Consistency**: Standards applied appropriately to each task type
- **Maintainability**: Clear documentation and quality requirements
- **Security**: Security standards enforced based on risk
- **Testability**: Coverage targets based on task criticality
- **Sustainability**: Long-term maintainability built in

---

## Examples in Practice

### Example 1: Starting a Major Feature

```
$ git checkout -b feature/survey-analytics-dashboard

🎯 Task Classification
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Detected Task Type: NEW_FEATURE_MAJOR
Reason:
  - Branch pattern: feature/*
  - Estimated scope: 800-1200 lines
  - User-facing: Yes
  - Data handling: User survey data

📋 Applicable Standards:
  Documentation:
    ✅ PRD required (score: 90+)
    ✅ Design Doc required (score: 90+)
    ✅ Test Plan required (score: 90+)

  Testing:
    ✅ 80% coverage minimum
    ✅ TDD required
    ✅ Types: Unit + Integration + E2E

  Code Quality:
    ✅ Functions ≤20 lines
    ✅ Complexity ≤10

  Review:
    ✅ AI review required
    ✅ Human review required

Current Compliance: 0/100 (not started)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Let's start by creating your planning documents. First question:

What specific problem does this analytics dashboard solve?
```

### Example 2: Quick Bug Fix

```
$ git checkout -b fix/empty-survey-crash

🎯 Task Classification
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Detected Task Type: BUG_FIX
Reason:
  - Branch pattern: fix/*
  - Likely scope: <100 lines
  - Urgency: Normal

📋 Applicable Standards:
  Documentation:
    ✅ Issue description with repro steps

  Testing:
    ✅ Regression test for the bug
    ✅ Maintain current coverage (currently 82%)

  Code Quality:
    ✅ Functions ≤30 lines (slightly relaxed)
    ✅ Complexity ≤12 (slightly relaxed)

  Review:
    ✅ AI review required
    ⚪ Human review optional

Current Compliance: N/A (not yet implemented)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 Pro Tip: Write a test that reproduces the crash first!

Ready to start? What's the bug you're fixing?
```

### Example 3: Hotfix in Production

```
$ git checkout -b hotfix/data-leak-patch

🎯 Task Classification
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Detected Task Type: HOTFIX
Reason:
  - Branch pattern: hotfix/*
  - CRITICAL: Production issue

📋 Applicable Standards (EXPEDITED MODE):
  Documentation:
    ⚠️  Incident report (can be added post-fix)

  Testing:
    ✅ Regression test required

  Security:
    🚨 Security review REQUIRED (this is a data leak!)

  Review:
    ✅ Human review REQUIRED (post-deployment acceptable)

Enforcement: EXPEDITED
  - Fix the issue first
  - Tests can follow immediately after
  - Documentation within 24 hours
  - Full review post-deployment

🚨 SECURITY ALERT: Data leak detected. Prioritizing fix.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

What's the nature of the data leak? I'll help you patch it safely.
```

---

## Success Metrics

Track these metrics to measure the hybrid model's effectiveness:

### Compliance Metrics
- Average compliance score by task type
- % of tasks meeting minimum thresholds
- Time to reach compliance
- Override frequency and reasons

### Quality Metrics
- Production bugs per release
- Security issues detected pre-deployment
- Test coverage trends
- Code review cycle time

### Developer Experience Metrics
- Time to first contribution (volunteers)
- Developer satisfaction with standards
- Enforcement override requests
- Agent interaction quality ratings

### Organizational Metrics
- Mission alignment of features
- Resource efficiency (volunteer time)
- Technical debt accumulation rate
- Deployment confidence

---

## FAQ

**Q: What if the task classification is wrong?**
A: Agents always ask for confirmation. You can override and the agent will adjust standards accordingly.

**Q: Can I skip standards for experiments?**
A: Yes! Mark your branch as `experiment/*` and enforcement is minimal. But you'll still get helpful guidance.

**Q: What if I disagree with a standard?**
A: Standards are configurable per repository. Propose changes via PR to `.claude-automation-config.json`.

**Q: Can I temporarily lower enforcement?**
A: Yes, if configured with `"allowOverride": true`, you can override with justification. This is logged for review.

**Q: How do I increase enforcement over time?**
A: Gradually change the `enforcement` level in config: minimal → soft → medium → strict

**Q: Do all task types require the same documentation?**
A: No! Each task type has appropriate documentation requirements. Bug fixes just need issue descriptions, major features need PRD + Design + Test Plan.

---

## Related Documentation

- [Engineering Overview](./EngineeringOverview.md) - High-level principles
- [Implementation Guide](./EngineeringProcessImplementation.md) - Detailed workflows
- [Automation Architecture](./AutomationArchitecture.md) - Technical architecture
- [Agent README](../automation-templates/claude-agents/README.md) - Agent details

---

**Maintained by**: InformUp Engineering Team
**Version**: 2.0.0
**License**: MIT
