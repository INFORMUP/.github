# Phase Completion Commit Guidelines

**Version**: 2.0.0
**Rule**: Commit after each workflow phase completes

---

## Why Commit After Each Phase?

**Benefits**:
1. **Clear Audit Trail**: Git history shows workflow progression
2. **Rollback Points**: Can revert to any phase if needed
3. **Prevents Loss**: Work is saved incrementally
4. **Easier Review**: One phase per commit is easier to review
5. **Progress Tracking**: See exactly where feature is in workflow
6. **Parallel Work**: Multiple people can work on different phases

**Example Git History**:
```
* docs: Update documentation for survey-dashboard
* feat: Implement survey-dashboard
* test: Add tests for survey-dashboard
* docs: Add edge case analysis for survey-dashboard
* docs: Add design reviews for survey-dashboard
* docs: Add feature planning for survey-dashboard
```

Clean, readable, shows progression! ✅

---

## Phase Commit Requirements

### 1. Feature Planning Phase

**Trigger**: PRD + Design Doc + Test Plan all created

**Commit**:
```bash
git add docs/PRD-{feature}.md \
        docs/DESIGN-{feature}.md \
        docs/TEST-PLAN-{feature}.md

git commit -m "docs: Add feature planning for {feature}

Created PRD, design doc, and test plan.

🎯 TASK: NEW_FEATURE_MAJOR | PHASE: Planning | ENFORCEMENT: strict

📊 PHASE COMPLIANCE: 92/100 ✅

PHASE ARTIFACTS:
  📄 PRD: docs/PRD-{feature}.md (score: 93/100)
  📄 Design: docs/DESIGN-{feature}.md (score: 95/100)
  📄 Test Plan: docs/TEST-PLAN-{feature}.md (score: 88/100)

GATE STATUS: OPEN - Ready for design review

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### 2. Design Review Phase

**Trigger**: All design reviews complete (architecture + security + cost)

**Commit**:
```bash
git add docs/reviews/

git commit -m "docs: Add design reviews for {feature}

Completed architecture, security, and cost reviews.

🎯 TASK: NEW_FEATURE_MAJOR | PHASE: Design Review | ENFORCEMENT: strict

📊 PHASE COMPLIANCE: 100/100 ✅

PHASE ARTIFACTS:
  📄 Architecture Review: docs/reviews/architecture-{feature}.md (APPROVED)
  📄 Security Review: docs/reviews/security-{feature}.md (APPROVED)
  📄 Cost Analysis: docs/reviews/cost-{feature}.md (APPROVED - \$45/month)

REVIEW SUMMARY:
  • 0 critical issues
  • 2 recommendations (caching, rate limiting)
  • Estimated cost: \$45/month ✅

GATE STATUS: OPEN - Ready for edge case analysis

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### 3. Edge Case Analysis Phase

**Trigger**: Edge case analysis document created

**Commit**:
```bash
git add docs/EDGE-CASE-ANALYSIS-{feature}.md

git commit -m "docs: Add edge case analysis for {feature}

Identified edge cases and failure modes, prioritized by risk.

🎯 TASK: NEW_FEATURE_MAJOR | PHASE: Edge Case Analysis | ENFORCEMENT: strict

📊 PHASE COMPLIANCE: 100/100 ✅

PHASE ARTIFACTS:
  📄 Edge Case Analysis: docs/EDGE-CASE-ANALYSIS-{feature}.md

RISK SUMMARY:
  • P0 Critical: 4 risks (must test)
  • P1 High: 6 risks (should test)
  • P2 Medium: 5 risks (nice to test)
  • P3 Low: 3 risks (optional)
  • Total: 18 edge cases identified

GATE STATUS: OPEN - Ready for test generation

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### 4. Test Generation Phase

**Trigger**: All tests generated for the feature

**Commit**:
```bash
git add src/**/*.test.* tests/

git commit -m "test: Add tests for {feature}

Generated comprehensive test suite covering all edge cases.

🎯 TASK: NEW_FEATURE_MAJOR | PHASE: Test Generation | ENFORCEMENT: strict

📊 PHASE COMPLIANCE: 100/100 ✅

PHASE ARTIFACTS:
  📄 Unit Tests: src/components/SurveyDashboard.test.tsx
  📄 Integration Tests: tests/integration/survey-api.test.ts
  📄 E2E Tests: tests/e2e/survey-dashboard.spec.ts

TEST SUMMARY:
  • Coverage: 92% (target: 80%) ✅
  • P0 risks covered: 4/4 ✅
  • P1 risks covered: 6/6 ✅
  • Total test cases: 47

GATE STATUS: OPEN - Ready for implementation (TDD: tests written first)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### 5. Implementation Phase

**Trigger**: Feature code implementation complete

**Commit**:
```bash
git add src/

git commit -m "feat: Implement {feature}

Implements survey analytics dashboard with all planned features.

🎯 TASK: NEW_FEATURE_MAJOR | PHASE: Implementation | ENFORCEMENT: strict

📊 COMPLIANCE: 94/100 ✅ EXCELLENT

  Documentation  30/30  ✅
  Code Quality   24/25  ✅ (1 function at 21 lines, will refactor)
  Test Coverage  25/25  ✅ 92% coverage
  Security       10/10  ✅ All inputs validated
  Performance     5/10  ⚠️  Initial implementation, optimization planned

PHASE GATES:
  ✅ Design Review
  ✅ Edge Case Analysis
  ✅ Test Generation
  ✅ Implementation

ARTIFACTS:
  📄 All planning docs: docs/*
  📄 All review docs: docs/reviews/*
  📄 All tests: tests/*
  📄 Implementation: src/components/SurveyDashboard.tsx

NEXT: Performance optimization, then PR

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### 6. Documentation Update Phase

**Trigger**: README, API docs, CHANGELOG updated

**Commit**:
```bash
git add README.md docs/ CHANGELOG.md

git commit -m "docs: Update documentation for {feature}

Updated README, API docs, and CHANGELOG for survey dashboard.

🎯 TASK: NEW_FEATURE_MAJOR | PHASE: Documentation | ENFORCEMENT: strict

📊 PHASE COMPLIANCE: 100/100 ✅

PHASE ARTIFACTS:
  📄 README: README.md (updated)
  📄 API Docs: docs/API.md (new endpoints)
  📄 Changelog: CHANGELOG.md (v1.2.0 entry)

GATE STATUS: COMPLETE - Ready for PR

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Git History Example

**Good phase-based history**:
```
95a0859 docs: Update documentation for survey-dashboard
a3f2b1c feat: Implement survey-dashboard
8d9e4f2 test: Add tests for survey-dashboard
7c8b3a1 docs: Add edge case analysis for survey-dashboard
6b7a2f0 docs: Add design reviews for survey-dashboard
5a6b1e9 docs: Add feature planning for survey-dashboard
```

**Each commit**:
- Represents one complete phase
- Has all artifacts for that phase
- Includes phase compliance report
- Shows gate status
- Can be reviewed independently

---

## Benefits

### For Developers

- **Save Work**: Each phase committed = work saved
- **Clear Progress**: Git log shows where you are
- **Easy Rollback**: Can go back to any phase
- **Organized**: One concern per commit

### For Reviewers

- **Phased Review**: Can review planning before implementation
- **Clear Context**: Each commit has phase context
- **Audit Trail**: Can see all decisions
- **Better Feedback**: Review design before code is written

### For Teams

- **Parallel Work**: Different people can work on different phases
- **Knowledge Transfer**: Git history tells the story
- **Quality Gates**: Can't skip ahead in git history
- **Accountability**: Clear who did what when

---

## Enforcement

### Claude Must Prompt After Each Phase

**After completing a phase**:
```
Claude: "✅ {Phase Name} complete!

ARTIFACTS CREATED:
  📄 {artifact 1}
  📄 {artifact 2}

These should be committed now to mark phase completion.

Shall I create the commit? (Recommended)
  [1] Yes, commit with phase report
  [2] No, I'll commit manually
  [3] Add more to this phase first"
```

**If user chooses [1]**:
```
Claude: [Creates commit with proper phase format]

"✅ Committed with phase completion report

Next phase: {next phase name}
Gate status: {OPEN|BLOCKED}

Ready to proceed?"
```

---

## Special Cases

### Combining Phases

**Q**: Can I commit multiple phases together?

**A**: Not recommended, but acceptable if:
- Phases are very small
- Done in one sitting
- Clear in commit message

**Better**: Separate commits for clarity

### Forgetting to Commit

**Q**: What if I move to next phase without committing previous?

**A**: Claude should detect and warn:
```
⚠️  PHASE COMMIT MISSING

You completed: Design Review
But did not commit artifacts:
  • docs/reviews/architecture-{feature}.md
  • docs/reviews/security-{feature}.md

Should we commit these now before proceeding?
```

### Amending Phase Commits

**Q**: Can I amend a phase commit?

**A**: Yes, if:
- Same phase, just refinements
- Haven't moved to next phase yet
- Use `git commit --amend`

---

## Configuration

Enable in `.claude-automation-config.json`:

```json
{
  "workflow": {
    "commitAfterPhaseCompletion": true,
    "gates": {
      "design-review": {
        "commitRequired": true
      },
      "edge-case-analysis": {
        "commitRequired": true
      },
      "test-generation": {
        "commitRequired": true
      }
    }
  }
}
```

---

## Summary

**Rule**: Commit after each phase completion

**Why**: Clear history, rollback points, audit trail, prevents loss

**Format**: Phase-specific commit message with compliance report

**Enforcement**: Claude prompts to commit after each phase

This creates a clean, traceable workflow in git history! ✅
