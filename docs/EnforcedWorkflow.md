# Enforced Workflow - How Phase Gates Work

**Version**: 2.0.0
**Operating Model**: Hybrid with Phase Gate Enforcement

---

## Overview

The Hybrid Operating Model now **enforces** workflow phases through artifact checking and blocking gates. You cannot skip ahead without completing required steps and producing required artifacts.

---

## Complete Enforced Workflow

### NEW_FEATURE_MAJOR (Strict Enforcement)

```
┌─────────────────────────────────────────────────────────────┐
│ 1. FEATURE PLANNING                                         │
├─────────────────────────────────────────────────────────────┤
│ Agent: feature-planner                                      │
│ Creates:                                                    │
│   • docs/PRD-{feature}.md (score ≥90)                       │
│   • docs/DESIGN-{feature}.md (score ≥90)                    │
│   • docs/TEST-PLAN-{feature}.md (score ≥90)                 │
│                                                             │
│ ✅ GATE: All docs exist with score ≥90                      │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. DESIGN REVIEW (BLOCKING GATE) ⭐                         │
├─────────────────────────────────────────────────────────────┤
│ Agent: design-review-coordinator                            │
│ Orchestrates:                                               │
│   • architecture-reviewer (parallel)                        │
│   • security-auditor (parallel)                             │
│   • cost-analyzer (parallel)                                │
│                                                             │
│ Creates:                                                    │
│   • docs/reviews/architecture-{feature}.md                  │
│   • docs/reviews/security-{feature}.md                      │
│   • docs/reviews/cost-{feature}.md                          │
│                                                             │
│ Checks:                                                     │
│   [ ] All review artifacts exist                            │
│   [ ] No BLOCKED status                                     │
│   [ ] Critical issues addressed                             │
│                                                             │
│ ✅ GATE: All reviews APPROVED                               │
│ 🚫 BLOCKS: If any review missing or BLOCKED                 │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. EDGE CASE & RISK ANALYSIS (BLOCKING GATE) ⭐             │
├─────────────────────────────────────────────────────────────┤
│ Agent: edge-case-analyzer                                   │
│ Creates:                                                    │
│   • docs/EDGE-CASE-ANALYSIS-{feature}.md                    │
│                                                             │
│ Contains:                                                   │
│   • 10+ edge cases identified                               │
│   • Risk matrix (P0-P4)                                     │
│   • Test requirements for each risk                         │
│   • P0 risks must have mitigation                           │
│                                                             │
│ ✅ GATE: Edge case analysis complete                        │
│ 🚫 BLOCKS: If <10 risks or no P0 mitigation                 │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. TEST GENERATION                                          │
├─────────────────────────────────────────────────────────────┤
│ Agent: test-generator                                       │
│ Uses:                                                       │
│   • Edge case analysis                                      │
│   • Design reviews                                          │
│   • Test plan                                               │
│                                                             │
│ Creates:                                                    │
│   • Unit tests (P0 + P1 risks)                              │
│   • Integration tests (P0 + P1 risks)                       │
│   • E2E tests (P0 critical paths)                           │
│                                                             │
│ Ensures:                                                    │
│   • All P0 risks have tests                                 │
│   • 80%+ coverage                                           │
│   • TDD approach (tests before code)                        │
│                                                             │
│ ✅ GATE: All P0 tests exist, coverage ≥80%                  │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. IMPLEMENTATION                                           │
├─────────────────────────────────────────────────────────────┤
│ Developer implements with:                                  │
│   • Design doc guidance                                     │
│   • Review recommendations in mind                          │
│   • Edge cases known upfront                                │
│   • Tests already written (TDD)                             │
│                                                             │
│ Pre-commit: code-reviewer agent checks each commit          │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. FINAL COMPLIANCE CHECK                                   │
├─────────────────────────────────────────────────────────────┤
│ Agent: workflow-guardrails (pre-push)                       │
│ Verifies:                                                   │
│   [ ] All phase gates passed                                │
│   [ ] All artifacts exist                                   │
│   [ ] Compliance score ≥90                                  │
│   [ ] All P0 tests passing                                  │
│   [ ] No security issues                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## How Blocking Works

### Artifact Checking

**Before allowing progression, Claude checks**:

```python
def can_proceed_to_testing(feature):
    # Check design review gate
    required_reviews = [
        f"docs/reviews/architecture-{feature}.md",
        f"docs/reviews/security-{feature}.md",
        f"docs/reviews/cost-{feature}.md"
    ]

    for review_path in required_reviews:
        if not file_exists(review_path):
            return False, f"Missing: {review_path}"

        if has_critical_issues(review_path):
            return False, f"Critical issues in: {review_path}"

    # Check edge case analysis gate
    edge_case_path = f"docs/EDGE-CASE-ANALYSIS-{feature}.md"
    if not file_exists(edge_case_path):
        return False, f"Missing: {edge_case_path}"

    return True, "All gates passed"
```

### Block Message

**If user tries to skip ahead**:

```
🚫 PHASE GATE BLOCKED

Attempting to: Generate tests
Current phase: Design review incomplete

MISSING ARTIFACTS:
  ❌ docs/reviews/architecture-survey-dashboard.md
  ❌ docs/reviews/security-survey-dashboard.md
  ❌ docs/reviews/cost-survey-dashboard.md

Required workflow:
  1. Create design doc ✅ (you've done this)
  2. Run design reviews ❌ (you're here - must do this)
  3. Edge case analysis ⏸️  (blocked until reviews complete)
  4. Generate tests ⏸️  (blocked)

TO PROCEED:
  Run: claude code --agent design-review-coordinator

This will:
  • Run all required reviews in parallel (~5 minutes)
  • Create review artifacts in docs/reviews/
  • Open the gate if reviews pass
  • Let you know if any issues need addressing
```

---

## Automatic vs Manual Coordination

### Automatic Coordination (Recommended)

**Use git hooks to trigger coordination**:

```bash
# .husky/post-commit (when design doc committed)
#!/bin/bash

# Check if design doc was just committed
if git diff-tree --name-only HEAD | grep -q "docs/DESIGN-"; then
  echo "🔍 Design doc committed - running design reviews..."
  claude code --agent design-review-coordinator
fi
```

### Manual Coordination

**Developer manually runs**:

```bash
# After creating design doc
claude code --agent design-review-coordinator
```

---

## Review Artifact Format

### docs/reviews/architecture-{feature}.md

```markdown
# Architecture Review: {Feature}

**Reviewer**: Claude (architecture-reviewer agent)
**Date**: {date}
**Design Doc**: docs/DESIGN-{feature}.md
**Status**: [APPROVED | APPROVED WITH CONDITIONS | BLOCKED]

## Summary
[High-level assessment]

## Critical Issues
[Any blocking issues - must be empty for APPROVED]

## Recommendations
- [Recommendation 1]
- [Recommendation 2]

## Detailed Analysis
[Component-by-component review]

## Compliance Impact
Architecture Score: [XX]/100
```

### docs/reviews/security-{feature}.md

```markdown
# Security Review: {Feature}

**Reviewer**: Claude (security-auditor agent)
**Date**: {date}
**Status**: [APPROVED | APPROVED WITH CONDITIONS | BLOCKED]

## Summary
[Security assessment]

## Critical Issues
[Any security vulnerabilities - must be empty for APPROVED]

## Recommendations
- [Security hardening suggestions]

## Security Checklist
- [ ] Input validation
- [ ] Authentication/Authorization
- [ ] Data encryption
- [ ] Secret management
- [...]

## Compliance Impact
Security Score: [XX]/100
```

### docs/reviews/cost-{feature}.md

```markdown
# Cost Analysis: {Feature}

**Analyzer**: Claude (cost-analyzer agent)
**Date**: {date}
**Status**: [APPROVED | WARNING | CRITICAL]

## Estimated Monthly Costs

| Resource | Usage | Cost |
|----------|-------|------|
| [Resource] | [Amount] | $[XX] |
| **Total** | | **$[XX]** |

## Status
- ✅ APPROVED: <$100/month
- ⚠️ WARNING: $100-$500/month (review required)
- 🚨 CRITICAL: >$500/month (redesign recommended)

## Cost Optimization Recommendations
[If cost is high]
```

---

## Compliance Reporting with Gates

### Updated Compliance Report Format

```
🎯 TASK: NEW_FEATURE_MAJOR | ENFORCEMENT: strict | THRESHOLD: 90

📊 COMPLIANCE: 85/100 ✅ GOOD

  Documentation  30/30  ✅
  Code Quality   23/25  ✅
  Test Coverage  24/25  ✅
  Security       10/10  ✅
  Performance     8/10  ⚠️

PHASE GATES:
  ✅ Design Review (architecture, security, cost) - COMPLETE
  ✅ Edge Case Analysis - COMPLETE
  ⏸️  Test Generation - IN PROGRESS

ARTIFACTS:
  📄 PRD: docs/PRD-survey-dashboard.md
  📄 Design: docs/DESIGN-survey-dashboard.md
  📄 Test Plan: docs/TEST-PLAN-survey-dashboard.md
  📄 Architecture Review: docs/reviews/architecture-survey-dashboard.md
  📄 Security Review: docs/reviews/security-survey-dashboard.md
  📄 Cost Analysis: docs/reviews/cost-survey-dashboard.md
  📄 Edge Case Analysis: docs/EDGE-CASE-ANALYSIS-survey-dashboard.md
```

**Phase gate status**:
- ✅ Complete (gate passed, may proceed)
- ⏸️  In progress (working on this phase)
- ❌ Blocked (missing artifacts or critical issues)
- ⚪ Not started (future phase)

---

## Benefits

### Prevents Skipping Steps

**Before** (without enforcement):
```
Developer: Creates design doc
Developer: "Let me start coding!"
[Skips all reviews]
💥 Ships code with security issues
```

**After** (with enforcement):
```
Developer: Creates design doc
Claude: "🚫 Cannot start testing - design reviews required"
Developer: Runs design-review-coordinator
Claude: Creates architecture + security + cost reviews
Claude: "✅ All reviews approved - may proceed"
Developer: Continues to edge case analysis
```

### Creates Complete Audit Trail

**For every feature, you have**:
- docs/PRD-{feature}.md
- docs/DESIGN-{feature}.md
- docs/TEST-PLAN-{feature}.md
- docs/reviews/architecture-{feature}.md ⭐
- docs/reviews/security-{feature}.md ⭐
- docs/reviews/cost-{feature}.md ⭐
- docs/EDGE-CASE-ANALYSIS-{feature}.md ⭐

**Human reviewers can see**:
- What was designed
- What reviews happened
- What issues were found
- What risks were identified
- What tests were planned

### Ensures Quality Gates

**Cannot ship without**:
- ✅ Architecture validated
- ✅ Security reviewed
- ✅ Costs estimated
- ✅ Edge cases identified
- ✅ Tests for all P0 risks
- ✅ Compliance score ≥90

---

## Configuration

### Enable Phase Gate Enforcement

In `.claude-automation-config.json`:

```json
{
  "workflow": {
    "enforcePhaseOrder": true,
    "requiredPhases": {
      "NEW_FEATURE_MAJOR": [
        "feature-planning",
        "design-review",      // ⭐ Enforced
        "edge-case-analysis", // ⭐ Enforced
        "test-generation",
        "implementation",
        "code-review"
      ]
    },
    "gates": {
      "design-review": {
        "requires": ["design-doc-complete"],
        "enables": ["edge-case-analysis", "test-generation"]
      }
    }
  }
}
```

### Disable for Specific Task Types

```json
{
  "taskTypes": {
    "EXPERIMENT": {
      "designReview": {
        "required": false  // No gates for experiments
      }
    }
  }
}
```

---

## Checking Gate Status

### Manual Check

```bash
# Check if all gates are passed
claude code --agent design-review-coordinator --status
```

**Output**:
```
🎯 GATE STATUS: survey-dashboard

FEATURE PLANNING: ✅ COMPLETE
  • PRD: ✅
  • Design: ✅
  • Test Plan: ✅

DESIGN REVIEW: ✅ COMPLETE
  • Architecture Review: ✅ APPROVED
  • Security Review: ✅ APPROVED
  • Cost Analysis: ✅ APPROVED ($45/month)

EDGE CASE ANALYSIS: ❌ NOT STARTED
  Required: docs/EDGE-CASE-ANALYSIS-survey-dashboard.md
  Status: Missing

TEST GENERATION: ⏸️ BLOCKED (waiting for edge case analysis)

IMPLEMENTATION: ⏸️ BLOCKED (waiting for tests)

NEXT ACTION: Run edge-case-analyzer agent
```

### In Compliance Reports

All compliance reports now include phase gate status.

---

## Troubleshooting

### "Gate blocked but I want to skip"

**Q**: Can I skip design review for a quick feature?

**A**: If it's truly quick, classify as:
- **EXPERIMENT** (no gates)
- **BUG_FIX** (lighter gates)

Not as NEW_FEATURE.

### "Review found issues - what now?"

**Q**: Security review found an issue. How do I proceed?

**A**:
1. Update design doc to address issue
2. Re-run design-review-coordinator
3. Once APPROVED, gate opens

### "I already did reviews manually"

**Q**: I already reviewed the design myself. Can I skip?

**A**: No, but you can create the review artifacts manually:
```bash
# Create docs/reviews/architecture-{feature}.md
# Document your review findings
# Then gate will pass
```

### "This is too much for a small change"

**Q**: I just want to add a button. Do I need all this?

**A**: No! Classify correctly:
- Small UI change = **ENHANCEMENT** (lighter requirements)
- New user flow = **NEW_FEATURE_MINOR** (medium requirements)
- Major new capability = **NEW_FEATURE_MAJOR** (full requirements)

---

## Success Metrics

Track gate effectiveness:
- **Gate Compliance**: % of features that pass all gates
- **Issues Caught**: Count of issues found in design review vs production
- **Time Saved**: Reduced debugging from catching issues early
- **Quality**: Reduction in production bugs

**Expected Results**:
- 80% of security issues caught in design review (not production)
- 70% of architecture issues caught before implementation
- 90% cost estimates accurate (no surprise bills)
- 60% reduction in edge case bugs

---

## Summary

**Phase gates ensure**:
1. Design is reviewed before implementation
2. Review artifacts exist for human review
3. Edge cases are identified systematically
4. Tests cover real risks (not just happy path)
5. Quality is built in, not bolted on

**You cannot skip ahead** - but if you classify your work correctly, you get right-sized requirements.

---

**Related Documentation**:
- [Design Review Coordinator Agent](../automation-templates/claude-agents/design-review-coordinator.md)
- [Edge Case Analyzer Agent](../automation-templates/claude-agents/edge-case-analyzer.md)
- [Hybrid Operating Model](./HybridOperatingModel.md)
