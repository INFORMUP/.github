# Edge Case & Risk Analysis Integration

**Added**: 2025-01-31
**Agent**: `edge-case-analyzer`
**Phase**: After design review, before test generation

---

## What This Adds

A systematic risk analysis phase that identifies edge cases and failure modes BEFORE tests are written, ensuring comprehensive test coverage of real-world scenarios.

---

## Updated Workflow

### NEW_FEATURE_MAJOR Workflow

```
1. Feature Planning
   ├─> PRD created
   ├─> Design Doc created
   └─> Test Plan created

2. Design Reviews
   ├─> Architecture review
   ├─> Security review
   └─> Cost analysis

3. Edge Case & Risk Analysis ⭐ NEW
   ├─> Enumerate edge cases
   ├─> Identify failure modes
   ├─> Create risk matrix (P0-P4)
   ├─> Generate test requirements
   └─> Output: docs/EDGE-CASE-ANALYSIS-{feature}.md

4. Test Generation (uses edge case analysis)
   ├─> Generate tests for P0 risks (critical)
   ├─> Generate tests for P1 risks (high priority)
   ├─> Generate tests for P2 risks (medium priority)
   └─> Ensure 80%+ coverage + 100% of P0 risks

5. Implementation
   └─> Code with edge cases in mind

6. Verification
   └─> All P0 risk tests must pass
```

---

## When Edge Case Analysis is Required

| Task Type | Required? | Notes |
|-----------|-----------|-------|
| NEW_FEATURE_MAJOR | ✅ Yes | Minimum 10 risks, all P0 must have tests |
| NEW_FEATURE_MINOR | ⚠️  Recommended | Optional but encouraged |
| ENHANCEMENT | ⚠️  If user-facing | Optional, depends on risk |
| REFACTOR | ⚠️  If high-risk | Optional, for complex refactors |
| BUG_FIX | ❌ No | Just need regression test |
| HOTFIX | ❌ No | Focus on fix first |

---

## Risk Prioritization Matrix

### Priority Levels

```
P0 (Critical): High Likelihood + High Severity
  - MUST test before shipping
  - Examples: Empty data crashes app, SQL injection, auth bypass

P1 (High): High/Medium Likelihood + High/Medium Severity
  - SHOULD test before shipping
  - Examples: Performance issues at scale, network timeouts

P2 (Medium): Medium Likelihood + Medium Severity
  - NICE TO test
  - Examples: Edge case UI issues, rare race conditions

P3 (Low): Low Likelihood + Low Severity
  - OPTIONAL to test
  - Examples: Cosmetic issues, very rare scenarios
```

### Example Risk Matrix

For "Survey Analytics Dashboard":

```
P0 - MUST TEST (4 risks)
  • Empty survey results (crashes dashboard)
  • SQL injection in filters
  • XSS in text inputs
  • Invalid survey_id (non-existent)

P1 - SHOULD TEST (8 risks)
  • 10,000+ responses (performance)
  • Concurrent filter updates (race condition)
  • Network timeout during load
  • Invalid date ranges
  • Malformed response data
  • Cache invalidation issues
  • Duplicate responses
  • Partial data load failure

P2 - NICE TO TEST (6 risks)
  • Old browser compatibility
  • Mobile responsive edge cases
  • Timezone edge cases
  • Export format issues
  • Odd data shapes in charts
  • Color accessibility

P3 - OPTIONAL (4 risks)
  • Very slow networks
  • Extremely old data
  • Unicode in rare languages
  • Print layout issues
```

---

## Output Document

### docs/EDGE-CASE-ANALYSIS-{feature}.md

Contains:

1. **Summary**
   - Total risks identified
   - Count by priority (P0/P1/P2/P3)

2. **Risk Matrix**
   - Each risk with:
     - Description
     - Likelihood (High/Medium/Low)
     - Severity (High/Medium/Low)
     - Edge cases
     - Test requirements
     - Acceptance criteria
     - Mitigation strategy

3. **Edge Case Catalog**
   - Input validation edge cases
   - Boundary conditions
   - Failure modes
   - Tables for quick reference

4. **Test Generation Priority**
   - MUST TEST (P0) scenarios
   - SHOULD TEST (P1) scenarios
   - NICE TO TEST (P2) scenarios
   - OPTIONAL (P3+) scenarios

5. **Dependencies for Test-Generator**
   - Specific guidance for unit tests
   - Specific guidance for integration tests
   - Specific guidance for E2E tests

---

## Integration with Test Generator

The test-generator agent reads the edge case analysis and:

1. **Prioritizes test creation**
   - Starts with P0 (critical)
   - Then P1 (high priority)
   - Then P2 if time permits

2. **Generates specific test scenarios**
   ```javascript
   // From edge case analysis: P0 - Empty survey results

   describe('Dashboard with empty survey', () => {
     it('should display empty state when survey has no responses', async () => {
       const survey = await createSurvey({ responses: [] });
       const dashboard = await renderDashboard(survey.id);

       expect(dashboard).toContainText('No responses yet');
       expect(dashboard).not.toHaveErrors();
       expect(dashboard.exportButton).toBeDisabled();
     });

     it('should not crash with null response data', async () => {
       const survey = await createSurvey({ responses: null });
       const dashboard = await renderDashboard(survey.id);

       expect(dashboard).not.toThrow();
     });
   });
   ```

3. **Ensures P0 coverage**
   - All P0 risks MUST have corresponding tests
   - Cannot proceed without P0 test coverage
   - CI fails if P0 tests don't exist

---

## Compliance Impact

### Documentation Score (+5 points if present)

Having edge case analysis adds to documentation score:
- Before: Documentation max 30/30
- With analysis: Documentation 30/30 + bonus consideration

### Test Coverage Score (indirect +10 points)

Better test generation from risk analysis improves:
- Test coverage percentage (hits more edge cases)
- Critical path coverage (all P0 scenarios)
- Overall test quality

### Security Score (+5 points)

Security edge cases identified early:
- SQL injection scenarios
- XSS scenarios
- Auth bypass scenarios
- Data leakage scenarios

**Total Potential Impact**: +15-20 compliance points for thorough analysis

---

## Usage

### Manual Invocation

```bash
# After design review is complete
claude code --agent edge-case-analyzer

# Specify feature context
claude code --agent edge-case-analyzer \
  --context "Feature: survey-analytics-dashboard"
```

### Automatic Trigger

Configured in `.claude-automation-config.json`:

```json
{
  "taskTypes": {
    "NEW_FEATURE_MAJOR": {
      "edgeCaseAnalysis": {
        "required": true,
        "minimumRisksIdentified": 10,
        "requireP0Coverage": true,
        "agent": "edge-case-analyzer"
      }
    }
  }
}
```

Agent automatically runs when:
1. Design doc score ≥90
2. Architecture review complete
3. Security review complete
4. Task type = NEW_FEATURE_MAJOR

---

## Review Process

1. **Agent generates analysis** (`docs/EDGE-CASE-ANALYSIS-{feature}.md`)
2. **Developer reviews**
   - Adds domain-specific edge cases
   - Adjusts likelihood/severity based on experience
   - Adds mitigation strategies
3. **Human reviewer approves** (for major features)
4. **Test generator uses analysis**
5. **Implementation proceeds with edge cases in mind**

---

## Benefits

### Prevents Bugs Before They're Written
- Identify edge cases during design, not production
- Think through failure modes systematically
- Document "what could go wrong"

### Guides Comprehensive Testing
- Test generator has specific scenarios
- Prioritization ensures critical paths covered
- No more "forgot to test empty data"

### Improves Code Quality
- Developers aware of edge cases before coding
- Better error handling from the start
- More defensive programming

### Documents Risk Decisions
- Why certain edge cases have tests
- What trade-offs were made
- Audit trail for compliance

### Saves Time Overall
- 1 hour analysis saves 10 hours debugging
- Catches issues in design, not production
- Reduces back-and-forth in code review

---

## Example: Before vs After

### Before (Without Edge Case Analysis)

```
Developer: "I'll build a survey dashboard"
↓
[Writes code]
↓
[Writes some tests]
↓
Ships to production
↓
💥 Production crashes with empty survey data
↓
Emergency hotfix
↓
💥 Another crash with very large dataset
↓
Another hotfix
```

### After (With Edge Case Analysis)

```
Developer: "I'll build a survey dashboard"
↓
Edge Case Analyzer: "Here are 24 edge cases, 4 are P0 critical"
  - Empty survey data (P0)
  - Very large dataset (P1)
  - Invalid input (P0)
  - Network failures (P1)
↓
Test Generator: "Created tests for all P0 and P1 scenarios"
↓
Developer implements with edge cases in mind
↓
All tests pass (including edge cases)
↓
Ships to production
↓
✅ No crashes, edge cases handled gracefully
```

---

## Configuration Example

```json
{
  "version": "2.0.0",
  "operatingModel": "hybrid",

  "agents": {
    "available": [
      "edge-case-analyzer"
    ]
  },

  "workflow": {
    "phases": [
      {
        "name": "edge-case-analysis",
        "agent": "edge-case-analyzer",
        "after": ["design-review"],
        "before": ["test-generation"],
        "blocking": true
      }
    ]
  },

  "taskTypes": {
    "NEW_FEATURE_MAJOR": {
      "edgeCaseAnalysis": {
        "required": true,
        "minimumRisksIdentified": 10,
        "requireP0Coverage": 100,
        "outputLocation": "docs/EDGE-CASE-ANALYSIS-{feature}.md"
      }
    }
  }
}
```

---

## Success Metrics

Track effectiveness:
- **Prevention Rate**: % of edge cases caught before production
- **Bug Reduction**: Compare bugs before/after adoption
- **Test Quality**: Coverage of real-world scenarios
- **Time Saved**: Reduced debugging and hotfix time

**Expected Results**:
- 60-80% reduction in edge case bugs
- 30% improvement in test coverage quality
- 50% reduction in production hotfixes
- 3-5x ROI (time spent on analysis vs debugging saved)

---

## Related Documentation

- [Edge Case Analyzer Agent](../automation-templates/claude-agents/edge-case-analyzer.md) - Full agent definition
- [Hybrid Operating Model](./HybridOperatingModel.md) - Overall model
- [Test Generator Agent](../automation-templates/claude-agents/test-generator.md) - Uses edge case analysis

---

**Remember**: "An hour of edge case analysis prevents ten hours of production debugging."
