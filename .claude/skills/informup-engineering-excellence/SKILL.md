---
name: informup-engineering-excellence
description: Hybrid engineering operating model combining AI agent automation with strict quality enforcement for InformUp development. Uses specialized Claude agents to enforce rigorous software engineering practices throughout the development lifecycle.
---

# InformUp Engineering Excellence Model

This skill combines the best of agent-based automation with strict process enforcement to ensure high-quality software development while maximizing developer productivity.

## MANDATORY WORKFLOW

Every engineering task follows these enforced phases:

### Phase 1: Requirements & Design (BLOCKING)

**Agent**: `feature-planner-enforced`

Before ANY code is written, you MUST complete:

1. **Product Requirements Document**
   ```markdown
   Location: docs/PRD-{feature-name}.md
   Required Sections:
   - Problem Statement
   - User Stories (minimum 3)
   - Success Criteria (measurable)
   - Non-functional Requirements
   ```

2. **Technical Design Document**
   ```markdown
   Location: docs/DESIGN-{feature-name}.md
   Required Sections:
   - Architecture Overview
   - Component Interfaces
   - Data Models
   - API Contracts
   - Technology Rationale
   ```

3. **Test Plan**
   ```markdown
   Location: docs/TEST-PLAN-{feature-name}.md
   Required Sections:
   - Unit Test Strategy (80% minimum)
   - Integration Test Scenarios
   - Edge Cases
   - Performance Benchmarks
   ```

**Enforcement**: Cannot proceed without all three documents scored >90% complete.

### Phase 2: Test-First Development (BLOCKING)

**Agent**: `tdd-enforcer`

Write tests BEFORE implementation:

1. **Create Failing Tests**
   - Write unit tests that fail
   - Cover all acceptance criteria
   - Include edge cases

2. **Verify Red State**
   - All new tests must fail initially
   - Commit tests before implementation

3. **Coverage Target**
   - New code must have >80% coverage
   - Critical paths require 100%

**Enforcement**: Implementation commits blocked without prior test commits.

### Phase 3: Implementation

**Agent**: `code-reviewer-strict`

While coding, enforce:

#### Code Quality Standards
- Functions: ≤20 lines
- Cyclomatic complexity: ≤10
- Clear variable naming
- Comprehensive error handling
- Input validation on all boundaries

#### InformUp Specific
- Volunteer-friendly code (well-commented)
- Mission-aligned features only
- Resource-conscious (nonprofit budget)
- Accessibility standards (civic engagement)

### Phase 4: Continuous Quality Checks

**Agents**: Multiple specialized reviewers

#### On Every Commit
- `code-reviewer-strict`: Style and standards
- `security-auditor`: No secrets, secure patterns
- `test-generator`: Maintain coverage

#### Before PR
- `compliance-validator`: Full process audit
- `local-ci`: All tests pass
- `documentation`: Docs updated

#### Blocking Criteria
```yaml
Compliance Score Required: 90/100
Coverage Required: 80%
Security Issues Allowed: 0
Performance Regression Allowed: 0%
```

## AGENT DEFINITIONS

### Core Enforcement Agents

#### 1. Workflow Guardrails (Proactive)
```bash
# Prevents process violations before they happen
# Monitors git operations and blocks inappropriate actions

Responsibilities:
- Prevent commits without tests
- Block pushing without review
- Ensure phase order compliance
- Alert on process violations
```

#### 2. Feature Planner Enforced
```bash
# Interactive planning with mandatory outputs

Workflow:
1. Understand requirements thoroughly
2. Generate ALL required documents
3. Validate document completeness
4. Score and report compliance
5. Block proceeding if score <90%
```

#### 3. TDD Enforcer
```bash
# Ensures test-driven development

Checks:
- Tests exist for new code
- Tests written before implementation
- Tests actually test the requirements
- Coverage meets targets
```

#### 4. Compliance Validator
```bash
# Final gate before PR

Validates:
- All documents present and complete
- Process phases followed in order
- Quality metrics achieved
- No security/performance issues
```

## CONFIGURATION

### Project Setup

Create `.claude/config.json`:

```json
{
  "skill": "informup-engineering-excellence",
  "enforcement": "strict",
  "organization": "InformUp",
  
  "phases": {
    "requirements": {
      "blocking": true,
      "documents": ["PRD", "DESIGN", "TEST-PLAN"],
      "minScore": 90
    },
    "testing": {
      "blocking": true,
      "approach": "TDD",
      "coverage": 80
    },
    "implementation": {
      "maxFunctionLines": 20,
      "maxComplexity": 10,
      "linting": "strict"
    }
  },
  
  "agents": {
    "auto_invoke": true,
    "blocking_gates": true,
    "available": [
      "workflow-guardrails",
      "feature-planner-enforced",
      "tdd-enforcer",
      "code-reviewer-strict",
      "security-auditor",
      "cost-analyzer",
      "test-generator",
      "local-ci",
      "compliance-validator",
      "documentation",
      "pr-generator",
      "error-investigator"
    ]
  },
  
  "context": {
    "organization": "InformUp",
    "type": "nonprofit",
    "mission": "Increase civic engagement",
    "constraints": ["limited budget", "volunteer contributors"],
    "priorities": ["accessibility", "maintainability", "mission alignment"]
  }
}
```

### Git Hooks Setup

Install enforcement hooks:

```bash
#!/bin/bash
# .husky/pre-commit

# Block commits without tests
if ! claude code --agent tdd-enforcer --check; then
  echo "❌ TDD Check Failed: Write tests first!"
  exit 1
fi

# Strict code review
if ! claude code --agent code-reviewer-strict --auto; then
  echo "❌ Code standards not met"
  exit 1
fi

echo "✅ Pre-commit checks passed"
```

```bash
#!/bin/bash
# .husky/pre-push

# Full compliance check
if ! claude code --agent compliance-validator --score; then
  echo "❌ Compliance score too low (required: 90%)"
  exit 1
fi

# Local CI
if ! claude code --agent local-ci --full; then
  echo "❌ Tests or build failed"
  exit 1
fi

echo "✅ Ready to push"
```

## USAGE PATTERNS

### Starting New Feature

```bash
# 1. Create feature branch
git checkout -b feature/user-survey-improvements

# 2. Auto-invoke planner (via post-checkout hook)
# Agent guides you through requirements

# 3. Write tests first
claude code --agent tdd-enforcer --generate-tests

# 4. Implement with continuous review
# Code reviewer runs on save via file watcher

# 5. Check compliance before PR
claude code --agent compliance-validator --report
```

### Manual Agent Invocation

```bash
# Get guidance
claude code --agent workflow-guardrails

# Plan feature interactively
claude code --agent feature-planner-enforced

# Generate tests for existing code
claude code --agent test-generator --target src/components/Survey.js

# Security review
claude code --agent security-auditor --deep-scan

# Check everything
claude code --agent compliance-validator --full-audit
```

## ENFORCEMENT MECHANISMS

### 1. Blocking Gates

Cannot proceed past gates without meeting criteria:

| Gate | Requirement | Enforced By |
|------|-------------|------------|
| Pre-Implementation | Docs complete | feature-planner-enforced |
| Pre-Commit | Tests exist | tdd-enforcer |
| Pre-Push | 90% compliance | compliance-validator |
| Pre-Merge | Human approval | GitHub + reviewer |

### 2. Continuous Monitoring

File watchers run agents automatically:

```javascript
// .claude/watchers.config.js
module.exports = {
  watchers: [
    {
      pattern: 'src/**/*.js',
      onChange: ['code-reviewer-strict', 'test-generator']
    },
    {
      pattern: 'docs/**/*.md',
      onChange: ['documentation']
    }
  ]
}
```

### 3. Compliance Scoring

Every commit gets scored:

```
Compliance Report for commit a1b2c3d
=====================================
Requirements Documentation: 95/100 ✅
Test Coverage: 82% ✅
Code Quality: 88/100 ✅
Security Scan: PASS ✅
Performance: No regression ✅

Overall Score: 91/100 ✅ PASSING

Areas for Improvement:
- Function 'processData' is 22 lines (limit: 20)
- Missing test for edge case in Survey.validate()
```

## REPORTING & METRICS

### Dashboard Integration

Compliance metrics are tracked and visualized:

```javascript
// Automated metrics collection
{
  "repository": "informup-website",
  "week": "2024-W04",
  "metrics": {
    "avgComplianceScore": 92,
    "testCoverage": 84,
    "deploymentsBlocked": 2,
    "securityIssuesPrevented": 5,
    "volunteerContributions": 12,
    "avgReviewTime": "45 minutes"
  }
}
```

### Regular Audits

Weekly automated audits:

```bash
# Run every Monday
claude code --agent compliance-validator --weekly-audit --repo all
```

## CUSTOMIZATION FOR YOUR CONTEXT

### For InformUp Repos

Each repository can have specific overrides:

```json
// informup-website/.claude/overrides.json
{
  "context": {
    "type": "public-facing",
    "additionalRequirements": ["WCAG 2.1 AA compliance", "mobile-first"]
  }
}
```

### For Different Contributor Types

```json
// .claude/contributor-rules.json
{
  "volunteers": {
    "extraGuidance": true,
    "requireMentor": true,
    "simplifiedProcess": false  // Still follow full process
  },
  "nonTechnical": {
    "requireReview": true,
    "blockedActions": ["security-critical", "database-changes"],
    "allowedAgents": ["feature-planner", "documentation"]
  }
}
```

## ROLLBACK & RECOVERY

If enforcement is too strict:

```bash
# Temporary override (requires justification)
SKIP_ENFORCEMENT=true git commit -m "EMERGENCY: [justification]"

# Will trigger immediate review flag
```

## SUCCESS METRICS

Track improvement over time:

- **Bug Reduction**: Target 50% decrease
- **Security Issues**: Target zero tolerance
- **Coverage**: Maintain >80% always
- **Volunteer Success**: >90% successful first PRs
- **Mission Alignment**: 100% features support civic engagement

## REMEMBER

This model exists to:
1. **Protect** against breaking production
2. **Empower** volunteers to contribute confidently  
3. **Ensure** quality without slowing development
4. **Support** InformUp's mission

The AI agents are here to help, not hinder. They enforce standards so humans can focus on creativity and impact.

---

*"Move fast and don't break things" - Made possible by moving thoughtfully with AI assistance.*
