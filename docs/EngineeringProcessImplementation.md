# Engineering Process Implementation Guide

**Parent Document**: [EngineeringOverview.md](./EngineeringOverview.md)

**Purpose**: This document provides detailed, actionable implementation steps for the engineering processes outlined in the Engineering Overview. It includes specific tools, templates, commands, and workflows that engineers should follow.

---

## Table of Contents

1. [Roadmap & Prioritization Implementation](#1-roadmap--prioritization-implementation)
2. [Feature Planning Implementation](#2-feature-planning-implementation)
3. [Design Review Implementation](#3-design-review-implementation)
4. [Code Changes Implementation](#4-code-changes-implementation)
5. [Testing Implementation](#5-testing-implementation)
6. [Commit Process Implementation](#6-commit-process-implementation)
7. [Pull Request Implementation](#7-pull-request-implementation)
8. [Build Process Implementation](#8-build-process-implementation)
9. [Deployment Implementation](#9-deployment-implementation)
10. [Monitoring Implementation](#10-monitoring-implementation)

---

## 1. Roadmap & Prioritization Implementation

### 1.1 Accessing the Roadmap

**Location**: [InformUp Engineering Project](https://github.com/orgs/INFORMUP/projects/1)

### 1.2 Picking Up Work

**For Planned Work**:

1. Navigate to the Engineering Project board
2. Filter items by `Status: Ready` and `Priority: High` or `Priority: Medium`
3. Assign yourself to the item you want to work on
4. Move the item to `Status: In Progress`
5. Link the item to your feature branch (see Feature Planning)

**For Volunteer-Driven Work**:

1. Browse the backlog for items that interest you
2. Comment on the issue to express interest
3. Assign yourself and move to `In Progress`
4. Follow the same process as planned work

**Creating New Work Items**:

```bash
# Use GitHub CLI to create a new issue
gh issue create \
  --title "Feature: [Brief Description]" \
  --body "## Description\n[Detailed description]\n\n## Motivation\n[Why this feature is needed]" \
  --label "feature-request" \
  --project "Engineering"
```

### 1.3 Tracking Time

Update the issue regularly with progress notes:

```markdown
## Progress Log

- 2024-01-15: Initial research and planning (2 hours)
- 2024-01-16: Design review with AI assistant (1 hour)
- 2024-01-17: Implementation start (3 hours)
```

---

## 2. Feature Planning Implementation

### 2.1 When to Create a Feature Plan

Create a feature plan for:
- New features (any size)
- Significant refactors
- New product launches
- Changes affecting multiple systems

Skip for:
- Bug fixes (unless they require significant rework)
- Documentation updates
- Minor UI tweaks

### 2.2 Creating a Feature Branch

```bash
# Update main branch
git checkout main
git pull origin main

# Create feature branch with descriptive name
git checkout -b feature/newsletter-selection-flow

# Push branch to remote
git push -u origin feature/newsletter-selection-flow
```

**Branch Naming Convention**:
- Features: `feature/short-description`
- Bug fixes: `fix/issue-number-short-description`
- Refactors: `refactor/component-name`

### 2.3 Creating the Feature Plan Document

**Location**: Create in repository root as `design-docs/[feature-name].md`

```bash
# Create design docs directory if it doesn't exist
mkdir -p design-docs

# Create feature plan file
touch design-docs/newsletter-selection-flow.md
```

### 2.4 Feature Plan Template

```markdown
# Feature Plan: [Feature Name]

**Author**: [Your Name]
**Date**: [YYYY-MM-DD]
**Status**: Draft | In Review | Approved
**Related Issue**: [Link to GitHub issue]
**Branch**: [Link to feature branch]

## 1. Problem Statement

What problem are we solving? Who is affected?

## 2. Proposed Solution

### 2.1 User Experience

Describe the user-facing changes. Include mockups or wireframes if applicable.

### 2.2 Technical Approach

- What components/services will be created or modified?
- What data models are needed?
- What APIs will be created or changed?

### 2.3 Dependencies

- External services or APIs
- New libraries or frameworks
- Other features or systems

## 3. Implementation Plan

### Phase 1: [Description]
- Task 1
- Task 2

### Phase 2: [Description]
- Task 1
- Task 2

## 4. Testing Strategy

- Unit tests: [What will be tested]
- Integration tests: [What will be tested]
- E2E tests: [What will be tested]
- Manual testing: [What needs manual verification]

## 5. Rollout Plan

- How will this be deployed?
- Are feature flags needed?
- What's the rollback strategy?

## 6. Success Metrics

How will we know this feature is successful?

## 7. Open Questions

- Question 1?
- Question 2?

## 8. AI Assistant Consultation Log

Document key insights from AI assistant during planning.

---

## Design Review Results

[This section will be populated after design review]
```

### 2.5 Using AI to Generate Feature Plan

```bash
# Start interactive session with Claude Code
claude code

# Prompt for feature planning
```

**Prompt Template for AI**:

```
I need to create a feature plan for [feature description].

Context:
- Repository: [repo name]
- Technology stack: [list technologies]
- User need: [describe user need]
- Constraints: [any constraints]

Please help me think through:
1. Is there a standard best practice for this problem?
2. What is the technical complexity (# of API calls, compute requirements, data storage needs)?
3. What are the potential edge cases?
4. What security considerations should I be aware of?
5. What's the estimated cost impact?
6. What dependencies exist?

Generate a comprehensive feature plan using the template in design-docs/template.md
```

### 2.6 Feature Plan Checklist

Before moving to design review, ensure:

- [ ] Problem statement is clear and specific
- [ ] Proposed solution addresses the problem
- [ ] Technical approach is detailed
- [ ] Dependencies are identified
- [ ] Testing strategy is outlined
- [ ] Rollout plan exists
- [ ] AI assistant has reviewed for best practices
- [ ] Open questions are documented

---

## 3. Design Review Implementation

### 3.1 Design Review Types

**Small Features** (< 3 days of work):
- AI review only (interactive session)
- Non-blocking human review (optional)
- Can proceed to implementation immediately

**Medium Features** (3-10 days of work):
- AI review (interactive session)
- One human reviewer required
- Non-blocking (can implement while waiting for feedback)

**Large Features** (> 10 days of work) or **New Products**:
- AI review (interactive session)
- Two human reviewers required
- Blocking (must have approval before implementation)

### 3.2 AI-Assisted Design Review

**Step 1: Architecture Review**

```bash
# Start interactive architecture review
claude code
```

**Prompt for AI Architecture Review**:

```
I need an architecture review for my feature plan.

Feature Plan: design-docs/[feature-name].md

Please review for:

1. **Architecture**:
   - Does the design follow our existing architecture patterns?
   - Are there any architectural anti-patterns?
   - What are the scaling implications?
   - Are there better alternatives?

2. **Code Organization**:
   - What files/modules should be created or modified?
   - Is the separation of concerns appropriate?
   - Are there any missing abstractions?

3. **Integration Points**:
   - How does this integrate with existing systems?
   - Are there any breaking changes?
   - What's the backward compatibility story?

4. **Performance**:
   - What are the performance implications?
   - Are there any bottlenecks?
   - What's the expected load?

Please provide your analysis in markdown format that I can append to the design doc.
```

**Step 2: Security Review**

**Prompt for AI Security Review**:

```
I need a security and data privacy review for my feature plan.

Feature Plan: design-docs/[feature-name].md

Please review for:

1. **Authentication & Authorization**:
   - Who has access to this feature?
   - Are permissions properly enforced?
   - Are there any privilege escalation risks?

2. **Data Privacy**:
   - What user data is collected/processed?
   - Is PII properly handled?
   - Are we GDPR/privacy compliant?
   - What's the data retention policy?

3. **Security Vulnerabilities**:
   - SQL injection risks?
   - XSS vulnerabilities?
   - CSRF protection?
   - Input validation?
   - API security?

4. **Secrets Management**:
   - Are credentials properly secured?
   - Are API keys in environment variables?
   - Is sensitive data encrypted?

Please provide a security assessment in markdown format.
```

**Step 3: Cost Analysis**

**Prompt for AI Cost Analysis**:

```
I need a cost analysis for my feature plan.

Feature Plan: design-docs/[feature-name].md

Current Infrastructure: [describe current setup]

Please analyze:

1. **Compute Costs**:
   - Additional server/lambda costs
   - Expected request volume
   - Compute requirements

2. **Storage Costs**:
   - Database storage
   - File storage
   - Backup costs

3. **Third-Party Services**:
   - API calls to external services
   - New service subscriptions needed

4. **Cost Optimization Opportunities**:
   - Caching strategies
   - Query optimization
   - Batch processing

Provide monthly cost estimates in USD and flag if costs exceed $X/month.
```

### 3.3 Documenting AI Review Results

Create a section in your feature plan document:

```markdown
## Design Review Results

**Date**: [YYYY-MM-DD]
**Reviewer**: Claude AI + [Human Reviewer Names]

### Architecture Review

[Paste AI architecture review results]

**Key Decisions**:
1. Decision 1 and rationale
2. Decision 2 and rationale

**Changes Made to Plan**:
- Change 1
- Change 2

### Security Review

[Paste AI security review results]

**Security Measures Added**:
1. Measure 1
2. Measure 2

### Cost Analysis

[Paste AI cost analysis]

**Estimated Monthly Cost**: $X
**Cost Approval Status**: ✅ Approved / ⏳ Pending / ❌ Needs Revision

### Human Review Comments

**Reviewer 1 ([Name])**:
- Comment 1
- Comment 2

**Reviewer 2 ([Name])**:
- Comment 1
- Comment 2

**Review Status**: ✅ Approved / ⏳ Changes Requested / ❌ Rejected
```

### 3.4 Requesting Human Review

```bash
# Create a PR for the design doc (before implementation)
git checkout feature/newsletter-selection-flow
git add design-docs/newsletter-selection-flow.md
git commit -m "docs: Add feature plan for newsletter selection flow"
git push origin feature/newsletter-selection-flow

# Create draft PR for design review only
gh pr create \
  --draft \
  --title "[Design Review] Newsletter Selection Flow" \
  --body "Design document for review. Implementation will follow after approval.

**Review Focus**:
- Architecture approach
- Security considerations
- Cost implications

**Design Doc**: design-docs/newsletter-selection-flow.md
**Feature Type**: [Small/Medium/Large]
**Reviewers Needed**: [1/2]

cc @reviewer1 @reviewer2"
```

### 3.5 Design Review Approval Criteria

Design is approved when:

- [ ] AI review completed for architecture, security, and cost
- [ ] All security concerns addressed
- [ ] Cost is within acceptable range (< $X/month for standard features)
- [ ] Required number of human approvals received
- [ ] All open questions resolved or documented as acceptable risks
- [ ] Implementation plan is clear and actionable

---

## 4. Code Changes Implementation

### 4.1 Development Environment Setup

```bash
# Ensure you're on the feature branch
git checkout feature/newsletter-selection-flow

# Install dependencies
npm install  # or yarn install

# Set up local environment
cp .env.example .env.local
# Edit .env.local with local configuration

# Start development server
npm run dev
```

### 4.2 Using AI for Implementation

**Starting an Implementation Session**:

```bash
# Start Claude Code in your repository
claude code
```

**Prompt Template for Implementation**:

```
I'm implementing the feature defined in design-docs/[feature-name].md

The design has been reviewed and approved. I need to implement [specific component/feature].

Context:
- Approved design doc: design-docs/[feature-name].md
- Current working branch: feature/[feature-name]
- Tech stack: [list relevant technologies]

Please help me implement this following our approved design. Let's start with [first component/file].
```

### 4.3 Incremental Development Pattern

**Recommended approach**:

1. **Start Small**: Implement the minimum viable component first
2. **Commit Often**: Commit stable states every 30-60 minutes
3. **Test As You Go**: Run tests after each component
4. **Document Changes**: Add inline comments for complex logic

**Example workflow**:

```bash
# Implement data model
# - Create migration
# - Update schema
# - Generate types
git add -A
git commit -m "feat: Add newsletter preference data model"

# Implement API endpoint
# - Create route handler
# - Add validation
# - Write tests
git add -A
git commit -m "feat: Add newsletter preference API endpoint"

# Implement UI component
# - Create component
# - Add styles
# - Write component tests
git add -A
git commit -m "feat: Add newsletter selection UI component"
```

### 4.4 Code Organization Standards

**File Structure** (example for a feature):

```
src/
  features/
    newsletter-selection/
      components/
        NewsletterSelectionForm.tsx
        NewsletterSelectionForm.test.tsx
        NewsletterCheckbox.tsx
      hooks/
        useNewsletterPreferences.ts
        useNewsletterPreferences.test.ts
      api/
        newsletter.ts
        newsletter.test.ts
      types/
        newsletter.types.ts
      utils/
        newsletterValidation.ts
        newsletterValidation.test.ts
      index.ts  # Public API of the feature
```

### 4.5 AI-Assisted Refactoring

If AI goes off track:

```bash
# Reset to last good commit
git log --oneline -10  # Find last good commit
git reset --hard <commit-hash>

# Start fresh with more specific instructions
claude code
```

**Prompt for Course Correction**:

```
The previous implementation didn't match our design. Let me clarify:

Design requirement: [specific requirement from design doc]

What was implemented: [describe what went wrong]

What should be implemented: [describe correct approach]

Please help me implement this correctly.
```

---

## 5. Testing Implementation

### 5.1 Testing Standards

**Coverage Targets**:
- Unit tests: 80% coverage minimum
- Integration tests: Critical paths and API endpoints
- E2E tests: Happy paths for user flows
- Manual testing: Edge cases and UX validation

### 5.2 Test Types by Feature Area

**Backend/API**:
- Unit tests for business logic
- Integration tests for API endpoints
- Database integration tests

**Frontend**:
- Unit tests for utility functions and hooks
- Component tests for UI components
- E2E tests for user flows

### 5.3 Using AI to Generate Tests

**Prompt for Test Generation**:

```
I need comprehensive tests for [file path].

Code to test: [paste code or provide file path]

Please generate:

1. **Unit Tests**:
   - Test all public functions
   - Test edge cases and error conditions
   - Test input validation
   - Use descriptive test names

2. **Test Coverage**:
   - Ensure all branches are covered
   - Include happy path and error cases
   - Test boundary conditions

3. **Test Structure**:
   - Use [Jest/Vitest/etc] syntax
   - Follow AAA pattern (Arrange, Act, Assert)
   - Use meaningful describe blocks
   - Mock external dependencies appropriately

Please write tests that are:
- Human readable
- Maintainable
- Testing behavior, not implementation
- Using our testing conventions
```

### 5.4 Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode (during development)
npm test -- --watch

# Run tests with coverage
npm test -- --coverage

# Run tests for specific file
npm test -- NewsletterSelectionForm.test.tsx

# Run only tests matching pattern
npm test -- --testNamePattern="newsletter"
```

### 5.5 Test Review Checklist

Review generated tests for:

- [ ] Tests are readable and well-named
- [ ] Tests test behavior, not implementation details
- [ ] Edge cases are covered
- [ ] Error conditions are tested
- [ ] Mocks are appropriate and minimal
- [ ] Tests are independent (no shared state)
- [ ] Tests are deterministic (no flaky tests)
- [ ] Coverage meets target (80%+)

### 5.6 Using AI to Audit Tests

**Prompt for Test Audit**:

```
Please audit the tests in [test file path].

Review for:
1. **Coverage**: Are all important code paths tested?
2. **Quality**: Are tests testing the right things?
3. **Maintainability**: Are tests readable and maintainable?
4. **Flakiness**: Are there any potential sources of flaky tests?
5. **Missing Cases**: What edge cases are missing?

Provide specific recommendations for improvement.
```

---

## 6. Commit Process Implementation

### 6.1 Pre-Commit Checklist

Before each commit:

- [ ] Code runs without errors
- [ ] Tests pass locally
- [ ] Linter passes
- [ ] Code is formatted
- [ ] No console.logs or debug code
- [ ] Sensitive data is not committed

### 6.2 Commit Message Convention

**Format**:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples**:

```bash
git commit -m "feat(newsletter): Add newsletter selection UI component"

git commit -m "fix(api): Correct validation for newsletter preferences"

git commit -m "test(newsletter): Add tests for selection form"

git commit -m "docs(newsletter): Update API documentation for preferences endpoint"
```

### 6.3 Git Hooks Setup

**Install Husky for Git Hooks**:

```bash
# Install husky
npm install --save-dev husky

# Initialize husky
npx husky init

# Create pre-commit hook
cat > .husky/pre-commit << 'EOF'
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Run linter
npm run lint

# Run tests
npm test -- --passWithNoTests

# Run type checking (if TypeScript)
npm run type-check

echo "✅ Pre-commit checks passed"
EOF

chmod +x .husky/pre-commit
```

### 6.4 Handling Test Failures

**If tests fail on commit**:

1. **Review the failure**:

```bash
npm test -- --verbose
```

2. **Use AI to diagnose**:

```bash
claude code
```

**Prompt for Test Diagnosis**:

```
My tests are failing with the following error:

[Paste error message]

Test file: [test file path]
Code file: [code file path]

Please help me:
1. Understand what's causing the failure
2. Suggest a fix
3. Explain why the test is failing
```

3. **Fix the issue**:
   - Option A: Fix the code if there's a bug
   - Option B: Update the test if it's incorrect
   - Option C: Update both if design changed

4. **Re-run tests**:

```bash
npm test
```

5. **Commit when tests pass**:

```bash
git add -A
git commit -m "fix: Resolve [issue description]"
```

### 6.5 Commit Frequency

**Recommended cadence**:

- Commit every stable state (every 30-60 minutes)
- Each commit should be a logical unit of work
- If you're unsure, it's better to commit more often
- Use meaningful commit messages

**Example session**:

```bash
# Hour 1: Data model
git commit -m "feat: Add newsletter preference model"

# Hour 2: API endpoint
git commit -m "feat: Add API endpoint for newsletter preferences"

# Hour 3: UI component (part 1)
git commit -m "feat: Add newsletter selection form component"

# Hour 4: UI component (part 2)
git commit -m "feat: Add form validation and error handling"

# Hour 5: Tests
git commit -m "test: Add tests for newsletter selection feature"
```

---

## 7. Pull Request Implementation

### 7.1 Before Creating a PR

**Pre-PR Checklist**:

- [ ] All tests pass
- [ ] Code is linted and formatted
- [ ] Feature works as designed
- [ ] Design doc is updated if implementation differs
- [ ] Tests have 80%+ coverage
- [ ] No debug code or console.logs
- [ ] Documentation is updated
- [ ] Commit messages are clear

### 7.2 Creating a PR

```bash
# Ensure you're up to date with main
git checkout main
git pull origin main
git checkout feature/newsletter-selection-flow
git merge main

# Resolve any conflicts

# Push your branch
git push origin feature/newsletter-selection-flow

# Create PR
gh pr create \
  --title "feat: Newsletter selection flow" \
  --body-file .github/pull_request_template.md
```

### 7.3 PR Description Template

Create `.github/pull_request_template.md`:

```markdown
## Description

Brief description of what this PR does.

## Related Issues

Closes #[issue number]

## Design Document

Link to design document: [design-docs/feature-name.md](./design-docs/feature-name.md)

## Type of Change

- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to break)
- [ ] Refactor (code change that neither fixes a bug nor adds a feature)
- [ ] Documentation update

## Changes Made

- Change 1
- Change 2
- Change 3

## Testing

### Tests Added

- Test 1: Description
- Test 2: Description

### Manual Testing Performed

1. Step 1
2. Step 2
3. Expected result: [describe]
4. Actual result: [describe]

## Screenshots (if applicable)

[Add screenshots for UI changes]

## Checklist

- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have updated the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix/feature works
- [ ] New and existing tests pass locally
- [ ] Test coverage is at least 80%
- [ ] Design document is updated if implementation differs from plan

## Deployment Notes

[Any special deployment considerations]

- [ ] Requires database migration
- [ ] Requires environment variable changes
- [ ] Requires feature flag
- [ ] Requires third-party service configuration

## Rollback Plan

[How to rollback if something goes wrong]

---

**For Reviewers**:

Please review for:
- [ ] Design matches approved design doc
- [ ] Code quality and readability
- [ ] Test coverage and quality
- [ ] Security considerations
- [ ] Performance implications

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 7.4 PR Review Process

**Review Tiers Based on Contributor Type**:

**Tier 1: Core Engineering Team**
- Can merge after 1 approval
- Can approve each other's PRs
- AI review is advisory

**Tier 2: Approved Contributors (Internal to InformUp)**
- Requires 1 core team approval
- Must pass all automated checks
- AI review findings must be addressed

**Tier 3: External Contributors**
- Requires 2 core team approvals
- Must pass all automated checks
- Design review must be completed first
- Cannot merge without human review

### 7.5 Using AI for PR Review

**Prompt for AI PR Review**:

```
Please review my pull request.

PR: [PR URL or description]
Diff: [paste git diff or provide branch name]
Design Doc: design-docs/[feature-name].md

Please review for:

1. **Design Compliance**:
   - Does the implementation match the approved design?
   - Are there any deviations that need documentation?

2. **Code Quality**:
   - Code readability and maintainability
   - Proper error handling
   - Consistent with codebase patterns

3. **Testing**:
   - Are the tests comprehensive?
   - Are edge cases covered?
   - Is test quality high?

4. **Security**:
   - Any security concerns?
   - Input validation present?
   - Authentication/authorization correct?

5. **Performance**:
   - Any performance concerns?
   - Inefficient queries or operations?
   - Caching opportunities?

6. **Documentation**:
   - Are complex areas documented?
   - Is the PR description clear?
   - Are API changes documented?

Please provide specific feedback with line numbers where applicable.
```

### 7.6 Addressing Review Comments

```bash
# Make changes based on feedback
[edit files]

# Commit changes
git add -A
git commit -m "fix: Address PR review feedback

- Implemented suggestion 1
- Fixed issue 2
- Updated documentation per review"

# Push changes
git push origin feature/newsletter-selection-flow

# Comment on PR
gh pr comment [PR-number] --body "Updated based on review feedback. Ready for re-review."
```

### 7.7 PR Approval and Merge

**After approval**:

```bash
# Squash and merge (for feature PRs)
gh pr merge [PR-number] --squash

# Or merge commit (for small fixes)
gh pr merge [PR-number] --merge

# Delete feature branch after merge
git branch -d feature/newsletter-selection-flow
git push origin --delete feature/newsletter-selection-flow
```

---

## 8. Build Process Implementation

### 8.1 CI/CD Pipeline Configuration

**Example GitHub Actions Workflow** (`.github/workflows/ci.yml`):

```yaml
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run type check
        run: npm run type-check

      - name: Run tests
        run: npm test -- --coverage

      - name: Check coverage threshold
        run: |
          COVERAGE=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage $COVERAGE% is below 80% threshold"
            exit 1
          fi

      - name: Upload coverage reports
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json

  build:
    runs-on: ubuntu-latest
    needs: test

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build application
        run: npm run build

      - name: Check build size
        run: |
          SIZE=$(du -sk build | cut -f1)
          if [ $SIZE -gt 5000 ]; then
            echo "Build size ${SIZE}KB exceeds 5MB limit"
            exit 1
          fi

  security:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Run security audit
        run: npm audit --audit-level=moderate

      - name: Check for secrets
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
```

### 8.2 Build Failure Handling

**When a build fails**:

1. **Check the CI logs**:

```bash
# View workflow runs
gh run list

# View specific run
gh run view [run-id]

# View logs
gh run view [run-id] --log
```

2. **Reproduce locally**:

```bash
# Run the same commands as CI
npm ci
npm run lint
npm run type-check
npm test -- --coverage
npm run build
```

3. **Use AI for diagnosis**:

**Prompt for Build Failure Diagnosis**:

```
My build is failing in CI with the following error:

[Paste CI error logs]

Build configuration: [describe build setup]

Please help me:
1. Identify the root cause
2. Suggest a fix
3. Explain how to prevent this in the future

Also check if this is:
- A dependency issue
- A configuration issue
- A code issue
- An environment difference between local and CI
```

4. **Fix and push**:

```bash
[Make fixes]
git add -A
git commit -m "fix: Resolve CI build failure"
git push
```

### 8.3 Build Optimization

**Monitoring build times**:

Create `.github/workflows/build-metrics.yml`:

```yaml
name: Build Metrics

on:
  pull_request:
    branches: [main]

jobs:
  metrics:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Build with timing
        run: |
          START=$(date +%s)
          npm run build
          END=$(date +%s)
          DURATION=$((END - START))
          echo "Build time: ${DURATION}s"

          if [ $DURATION -gt 300 ]; then
            echo "⚠️ Build time exceeds 5 minutes"
          fi
```

---

## 9. Deployment Implementation

### 9.1 Deployment Environments

**Environments**:
1. **Development**: Local development environment
2. **Staging**: Pre-production testing environment
3. **Production**: Live environment

### 9.2 Deployment Process

**To Staging** (automatic on merge to main):

```yaml
# .github/workflows/deploy-staging.yml
name: Deploy to Staging

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: staging

    steps:
      - uses: actions/checkout@v3

      - name: Deploy to staging
        run: |
          # Your deployment script
          npm run deploy:staging
        env:
          DEPLOY_KEY: ${{ secrets.STAGING_DEPLOY_KEY }}

      - name: Run smoke tests
        run: npm run test:smoke -- --env=staging

      - name: Notify on success
        if: success()
        run: |
          gh issue comment ${{ github.event.number }} \
            --body "✅ Deployed to staging: https://staging.informup.org"
```

**To Production** (manual trigger):

```yaml
# .github/workflows/deploy-production.yml
name: Deploy to Production

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to deploy'
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production

    steps:
      - uses: actions/checkout@v3
        with:
          ref: ${{ github.event.inputs.version }}

      - name: Create deployment
        run: |
          gh api repos/${{ github.repository }}/deployments \
            -f ref=${{ github.event.inputs.version }} \
            -f environment=production \
            -f description="Deploy version ${{ github.event.inputs.version }}"

      - name: Deploy to production
        run: npm run deploy:production
        env:
          DEPLOY_KEY: ${{ secrets.PRODUCTION_DEPLOY_KEY }}

      - name: Run smoke tests
        run: npm run test:smoke -- --env=production

      - name: Notify on success
        if: success()
        run: |
          gh issue comment ${{ github.event.number }} \
            --body "🚀 Deployed to production: https://www.informup.org"
```

### 9.3 Pre-Deployment Checklist

- [ ] All tests pass in CI
- [ ] Code review approved
- [ ] Design review approved (for features)
- [ ] Security review completed (for security-sensitive changes)
- [ ] Database migrations tested
- [ ] Environment variables configured
- [ ] Rollback plan documented
- [ ] Stakeholders notified

### 9.4 Database Migrations

**Creating migrations**:

```bash
# Create a new migration
npm run migrate:create -- add_newsletter_preferences

# Run migrations locally
npm run migrate:up

# Test rollback
npm run migrate:down

# Check migration status
npm run migrate:status
```

**Migration Checklist**:

- [ ] Migration is backward compatible
- [ ] Rollback migration exists
- [ ] Migration tested locally
- [ ] Data migration scripts tested on copy of production data
- [ ] Performance impact assessed for large tables
- [ ] Indexes added where needed

### 9.5 Feature Flags

**Implementing feature flags**:

```javascript
// lib/featureFlags.js
export const FeatureFlags = {
  NEWSLETTER_SELECTION: process.env.NEXT_PUBLIC_FEATURE_NEWSLETTER_SELECTION === 'true',
  // Add more flags as needed
};

// Usage in code
import { FeatureFlags } from '@/lib/featureFlags';

if (FeatureFlags.NEWSLETTER_SELECTION) {
  // New feature code
} else {
  // Old code or fallback
}
```

**Environment configuration**:

```bash
# .env.staging
NEXT_PUBLIC_FEATURE_NEWSLETTER_SELECTION=true

# .env.production (initially false)
NEXT_PUBLIC_FEATURE_NEWSLETTER_SELECTION=false
```

### 9.6 Rollback Procedure

**If deployment fails**:

```bash
# Revert to previous version
gh workflow run deploy-production.yml \
  -f version=[previous-version-tag]

# Or revert the merge commit
git revert [merge-commit-hash]
git push origin main

# Notify team
gh issue create \
  --title "INCIDENT: Rollback of [feature]" \
  --body "Rolled back [feature] due to [reason].

Previous version restored: [version]
Impact: [describe impact]
Next steps: [describe]"
```

---

## 10. Monitoring Implementation

### 10.1 Error Monitoring Setup

**Example: Sentry Integration**

```javascript
// lib/sentry.js
import * as Sentry from "@sentry/nextjs";

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  environment: process.env.NEXT_PUBLIC_ENV,
  tracesSampleRate: 1.0,
});

// Usage
try {
  // Code that might throw
} catch (error) {
  Sentry.captureException(error, {
    tags: {
      feature: 'newsletter-selection',
      userId: user.id,
    },
  });
}
```

### 10.2 Automated Error Triage

**AI-Assisted Error Analysis**:

Create `.github/workflows/error-triage.yml`:

```yaml
name: Error Triage

on:
  schedule:
    - cron: '0 */4 * * *'  # Every 4 hours
  workflow_dispatch:

jobs:
  triage:
    runs-on: ubuntu-latest
    steps:
      - name: Fetch recent errors
        id: errors
        run: |
          # Fetch errors from Sentry API
          curl -X GET "https://sentry.io/api/0/organizations/[org]/issues/" \
            -H "Authorization: Bearer ${{ secrets.SENTRY_TOKEN }}" \
            > errors.json

      - name: Analyze with AI
        run: |
          # Use Claude API to analyze errors
          # This is a placeholder - implement based on your setup
          echo "Analyzing errors..."

      - name: Create issues for critical errors
        run: |
          # Parse AI analysis and create GitHub issues
          # for critical/recurring errors
          echo "Creating issues..."
```

### 10.3 Manual Error Investigation with AI

**Prompt for Error Investigation**:

```
I need help investigating a production error.

Error:
[Paste error message and stack trace]

Context:
- Feature: [feature name]
- Environment: [staging/production]
- Timestamp: [when it occurred]
- User impact: [how many users affected]
- Frequency: [how often it's occurring]

Code context:
[Paste relevant code sections]

Please help me:
1. Identify the root cause
2. Assess the severity and user impact
3. Suggest an immediate fix or workaround
4. Recommend a long-term solution
5. Identify if this is related to recent deployments
6. Suggest monitoring improvements to catch this earlier
```

### 10.4 Performance Monitoring

**Example: Core Web Vitals Monitoring**

```javascript
// lib/analytics.js
export function reportWebVitals(metric) {
  // Log to analytics service
  console.log(metric);

  // Send to analytics endpoint
  if (metric.value > threshold[metric.name]) {
    // Alert on poor performance
    fetch('/api/performance-alert', {
      method: 'POST',
      body: JSON.stringify(metric),
    });
  }
}

// pages/_app.js
export { reportWebVitals };
```

### 10.5 Incident Response Process

**When an incident occurs**:

1. **Create incident issue**:

```bash
gh issue create \
  --title "INCIDENT: [Brief Description]" \
  --label "incident" \
  --body "## Incident Details

**Started**: [timestamp]
**Severity**: Critical / High / Medium / Low
**User Impact**: [description]
**Services Affected**: [list services]

## Current Status

[What's happening now]

## Actions Taken

- [timestamp] Action 1
- [timestamp] Action 2

## Investigation

[What we're investigating]

## Updates

[Add updates as comments]"
```

2. **Investigate with AI**:

```bash
claude code
```

Use prompts from section 10.3

3. **Implement fix**:

Follow expedited process:
- Create hotfix branch from production
- Implement fix
- Test quickly but thoroughly
- Deploy directly to production
- Monitor closely

4. **Post-incident review**:

Create post-mortem document:

```markdown
# Post-Incident Review: [Incident Name]

**Date**: [YYYY-MM-DD]
**Duration**: [X hours]
**Severity**: [Critical/High/Medium/Low]

## What Happened

[Brief description]

## Timeline

- [HH:MM] First alert received
- [HH:MM] Investigation started
- [HH:MM] Root cause identified
- [HH:MM] Fix deployed
- [HH:MM] Incident resolved

## Root Cause

[Detailed explanation]

## User Impact

- Number of users affected: [X]
- Services impacted: [list]
- Duration of impact: [X hours]

## What Went Well

- Item 1
- Item 2

## What Could Be Improved

- Item 1
- Item 2

## Action Items

- [ ] Action item 1 (Owner: [name])
- [ ] Action item 2 (Owner: [name])

## Lessons Learned

[Key takeaways]
```

---

## 11. Automation System Implementation

**Motivation**: Automate repetitive tasks and provide AI assistance at every stage of development, while keeping everything running locally on developer machines.

### 11.1 Automation Overview

The InformUp automation system uses Claude Code CLI, git hooks, and file watchers to provide intelligent assistance throughout the development lifecycle.

**Key Benefits**:
- Consistent quality across all developers
- Early issue detection (before PR/CI)
- Reduced cognitive load (don't forget steps)
- Faster onboarding for new developers
- Living documentation (auto-updates)

**See Also**:
- [Getting Started Guide](./GettingStarted.md) - Setup instructions
- [Automation Architecture](./AutomationArchitecture.md) - Technical details

### 11.2 Automation Trigger Matrix

| Event | When | AI Task | Mode | Setup Required |
|-------|------|---------|------|----------------|
| **Branch Creation** | `git checkout -b feature/*` | Generate feature plan template & interactive planning | Interactive | Git hook: `post-checkout` |
| **Design Doc Saved** | Design doc committed | Architecture + Security + Cost review | Interactive | Git hook: `pre-commit` |
| **New File Created** | New `.js/.ts` in `src/` | Generate corresponding test file | Background | File watcher daemon |
| **File Saved** | Code file modified | Update inline documentation | Background | File watcher daemon |
| **Pre-Commit** | Before commit completes | Quick code review + run tests | Blocking | Git hook: `pre-commit` |
| **Post-Commit** | After commit completes | Update changelog, API docs | Background | Git hook: `post-commit` |
| **Pre-Push** | Before push to remote | Full local CI + generate PR description | Interactive | Git hook: `pre-push` |
| **CI Failure** | GitHub Action fails | Diagnose failure, suggest fixes | On-demand | CLI command |
| **Error Logged** | Error appears in logs | Triage and create issues | Scheduled | Cron job (optional) |

### 11.3 Setting Up Automation

#### Quick Setup

```bash
# Navigate to your repository
cd /path/to/your-repo

# Install automation (script in development)
# For now, see docs/GettingStarted.md for manual steps
curl -sSL https://raw.githubusercontent.com/INFORMUP/.github/main/automation-installer/install.sh | bash

# Verify installation
npm run automation:test

# Start file watcher (optional, for background automation)
npm run automation:start &
```

#### Manual Setup (Temporary)

Until the automated installer is complete:

```bash
# 1. Install dependencies
npm install --save-dev husky@^8.0.0 chokidar@^3.5.0

# 2. Initialize Husky
npx husky-init && npm install

# 3. Create directories
mkdir -p scripts/automation design-docs .claude-prompts

# 4. Create configuration file
cat > .claude-automation-config.json << 'EOF'
{
  "version": "1.0.0",
  "enabled": true,
  "repoType": "frontend",
  "triggers": {
    "featurePlanning": { "enabled": true, "mode": "interactive" },
    "designReview": { "enabled": true, "mode": "interactive" },
    "testGeneration": { "enabled": true, "mode": "background" },
    "preCommitReview": { "enabled": true, "quick": true },
    "prGeneration": { "enabled": true, "mode": "interactive" }
  }
}
EOF

# 5. Add npm scripts
npm pkg set scripts.automation:start="node scripts/automation/claude-watcher.js"
npm pkg set scripts.automation:test="echo 'Automation setup verified'"
npm pkg set scripts.local-ci="node scripts/automation/local-ci.js"
```

Full setup instructions: [docs/GettingStarted.md](./GettingStarted.md)

### 11.4 Git Hooks Integration

Git hooks automatically run checks at key points:

#### Pre-Commit Hook

```bash
# .husky/pre-commit
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Run linter
npm run lint --fix

# Run formatter
npm run format

# Run tests
npm test -- --passWithNoTests

# Quick AI code review (if enabled)
if [ -f ".claude-automation-config.json" ]; then
  node scripts/automation/quick-review.js
fi

echo "✅ Pre-commit checks passed"
```

#### Pre-Push Hook

```bash
# .husky/pre-push
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Run full local CI
npm run local-ci

# Generate PR description (interactive)
if git rev-parse --abbrev-ref HEAD | grep -q "feature/"; then
  echo "📝 Generating PR description..."
  node scripts/automation/pr-generator.js --interactive
fi

echo "✅ Pre-push checks passed"
```

#### Post-Checkout Hook (Feature Planning)

```bash
# .husky/post-checkout
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

PREV_HEAD=$1
NEW_HEAD=$2
BRANCH_CHECKOUT=$3

# Only trigger on branch checkout (not file checkout)
if [ "$BRANCH_CHECKOUT" = "1" ]; then
  BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

  # Trigger feature planning for feature branches
  if echo "$BRANCH_NAME" | grep -q "^feature/"; then
    echo "🎨 Starting feature planning for $BRANCH_NAME..."
    node scripts/automation/feature-planning.js --interactive
  fi
fi
```

### 11.5 File Watcher Daemon

The file watcher runs in the background and responds to code changes:

```javascript
// scripts/automation/claude-watcher.js
const chokidar = require('chokidar');
const { execSync, spawn } = require('child_process');
const path = require('path');

class ClaudeWatcher {
  constructor(config) {
    this.config = config;
    this.debounceTimers = new Map();
  }

  start() {
    console.log('🤖 Claude automation watcher started');

    // Watch source files
    const watcher = chokidar.watch('src/**/*.{js,ts,jsx,tsx}', {
      ignored: /node_modules|\.test\.|\.spec\./,
      persistent: true,
      ignoreInitial: true
    });

    watcher
      .on('add', (filepath) => this.onFileAdded(filepath))
      .on('change', (filepath) => this.onFileChanged(filepath));
  }

  onFileAdded(filepath) {
    if (!this.config.triggers.testGeneration?.enabled) return;

    const testFile = this.getTestFilePath(filepath);
    if (!fs.existsSync(testFile)) {
      console.log(`📝 Generating tests for ${filepath}...`);
      this.generateTests(filepath, testFile);
    }
  }

  onFileChanged(filepath) {
    if (!this.config.triggers.docGeneration?.enabled) return;

    // Debounce: wait for 2 seconds of inactivity
    this.debounce(filepath, () => {
      console.log(`📚 Updating docs for ${filepath}...`);
      this.updateDocs(filepath);
    }, 2000);
  }

  generateTests(sourceFile, testFile) {
    // Run in background (non-blocking)
    spawn('claude', [
      'code', 'test', 'generate',
      '--file', sourceFile,
      '--output', testFile
    ], {
      detached: true,
      stdio: 'ignore'
    }).unref();
  }

  updateDocs(filepath) {
    // Update inline documentation
    spawn('claude', [
      'code', 'docs', 'update',
      '--file', filepath,
      '--background'
    ], {
      detached: true,
      stdio: 'ignore'
    }).unref();
  }

  debounce(key, func, wait) {
    if (this.debounceTimers.has(key)) {
      clearTimeout(this.debounceTimers.get(key));
    }
    this.debounceTimers.set(key, setTimeout(() => {
      func();
      this.debounceTimers.delete(key);
    }, wait));
  }

  getTestFilePath(filepath) {
    const ext = path.extname(filepath);
    return filepath.replace(ext, `.test${ext}`);
  }
}

// Start watcher
const config = require('../../.claude-automation-config.json');
const watcher = new ClaudeWatcher(config);
watcher.start();
```

**Running the watcher**:

```bash
# Start in background
npm run automation:start &

# Or use systemd/launchd for always-on
# (configuration examples in docs/AutomationArchitecture.md)

# Check status
ps aux | grep claude-watcher

# View logs
tail -f .claude-automation.log

# Stop
npm run automation:stop
```

### 11.6 Configuration Management

Configuration is managed through `.claude-automation-config.json`:

```json
{
  "version": "1.0.0",
  "enabled": true,
  "repoType": "frontend",

  "triggers": {
    "featurePlanning": {
      "enabled": true,
      "branches": ["feature/*"],
      "mode": "interactive"
    },
    "designReview": {
      "enabled": true,
      "files": ["design-docs/**/*.md"],
      "mode": "interactive"
    },
    "testGeneration": {
      "enabled": true,
      "filePattern": "src/**/*.{js,ts,jsx,tsx}",
      "excludePattern": "**/*.test.*",
      "mode": "background"
    },
    "preCommitReview": {
      "enabled": true,
      "quick": true,
      "failOnIssues": false
    },
    "prGeneration": {
      "enabled": true,
      "mode": "interactive"
    }
  },

  "testing": {
    "command": "npm test",
    "coverageThreshold": 80,
    "coverageCommand": "npm test -- --coverage"
  },

  "build": {
    "command": "npm run build",
    "sizeLimitMB": 5
  },

  "claude": {
    "model": "claude-3-5-sonnet-20241022",
    "timeout": 60000,
    "maxTokens": 4096
  }
}
```

**Customizing per repository**:

1. Edit `.claude-automation-config.json` in your repo
2. Disable specific triggers you don't want
3. Adjust commands for your project structure
4. Set repository-specific thresholds

**Customizing per developer**:

Create `~/.config/claude-automation/config.json` for personal preferences:

```json
{
  "triggers": {
    "testGeneration": {
      "enabled": false  // Disable if you prefer manual test writing
    }
  },
  "notifications": {
    "desktop": true,
    "sound": false
  },
  "verboseLogging": true
}
```

### 11.7 Using Automation in Your Workflow

#### Starting a New Feature

```bash
# Create branch (triggers feature planning)
git checkout -b feature/newsletter-preferences

# Interactive AI session starts automatically
# Answer questions to generate feature plan

# Feature plan template created at:
# design-docs/newsletter-preferences.md
```

#### During Development

```bash
# Create new file
touch src/components/NewsletterForm.tsx

# Test file auto-generated in background
# src/components/NewsletterForm.test.tsx

# Make changes to code
# (docs auto-update on save via file watcher)
```

#### Committing Changes

```bash
# Stage changes
git add src/

# Commit (triggers pre-commit checks)
git commit -m "feat: Add newsletter preferences UI"

# Automatic checks run:
# ✓ Linter
# ✓ Formatter
# ✓ Tests
# ✓ Quick AI review

# Post-commit: docs updated in background
```

#### Creating Pull Request

```bash
# Push (triggers pre-push checks)
git push origin feature/newsletter-preferences

# Full local CI runs:
# ✓ All tests with coverage
# ✓ AI security review
# ✓ AI architecture review
# ✓ Build verification

# Interactive PR description generation
# AI analyzes commits and generates PR description

# Create PR
gh pr create
```

### 11.8 Debugging Automation

#### View Logs

```bash
# View real-time logs
tail -f .claude-automation.log

# Search logs
grep "ERROR" .claude-automation.log

# View verbose output
DEBUG=* npm run automation:start
```

#### Test Individual Components

```bash
# Test git hooks
.husky/pre-commit

# Test file watcher
node scripts/automation/claude-watcher.js --test

# Test PR generator
node scripts/automation/pr-generator.js --dry-run
```

#### Disable Automation Temporarily

```bash
# Skip hooks for one commit
git commit --no-verify -m "message"

# Disable globally
echo 'export CLAUDE_AUTOMATION_ENABLED=false' >> ~/.zshrc

# Disable for repository
echo '{"enabled": false}' > .claude-automation-config.json
```

### 11.9 Troubleshooting Common Issues

**Issue**: Git hooks not running

**Solution**:
```bash
# Make hooks executable
chmod +x .husky/*

# Reinstall Husky
rm -rf .husky
npx husky install
```

**Issue**: File watcher not detecting changes

**Solution**:
```bash
# Check if running
ps aux | grep claude-watcher

# Restart watcher
npm run automation:stop
npm run automation:start
```

**Issue**: Claude Code command not found

**Solution**:
```bash
# Install Claude Code CLI
npm install -g @anthropic/claude-code

# Authenticate
claude auth login

# Verify
claude --version
```

**Issue**: Automation too slow/blocking workflow

**Solution**:
```json
// .claude-automation-config.json
{
  "triggers": {
    "preCommitReview": {
      "quick": true,      // Faster checks
      "failOnIssues": false  // Don't block commits
    },
    "testGeneration": {
      "enabled": false    // Disable background tasks
    }
  }
}
```

**Full troubleshooting guide**: [docs/GettingStarted.md#troubleshooting](./GettingStarted.md#troubleshooting)

### 11.10 Best Practices

**Do**:
- ✅ Run automation locally during development
- ✅ Review AI suggestions before accepting
- ✅ Keep prompts updated and relevant
- ✅ Configure automation for your workflow
- ✅ Report issues and suggest improvements

**Don't**:
- ❌ Blindly accept all AI suggestions
- ❌ Disable automation without understanding impact
- ❌ Commit secrets or sensitive data
- ❌ Skip tests just to make commits faster
- ❌ Forget to update automation regularly

### 11.11 Updating Automation

```bash
# Check current version
cat .claude-automation-config.json | jq '.version'

# Check for updates
curl -sSL https://raw.githubusercontent.com/INFORMUP/.github/main/automation-installer/VERSION

# Update (script in development)
npm run automation:update

# Manual update (current method)
# See docs/GettingStarted.md#updating-automation
```

### 11.12 VS Code Integration

Add tasks for quick AI assistance:

```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "AI: Review Current File",
      "type": "shell",
      "command": "claude code review --file ${file}"
    },
    {
      "label": "AI: Generate Tests",
      "type": "shell",
      "command": "claude code test generate --file ${file}"
    },
    {
      "label": "AI: Explain Code",
      "type": "shell",
      "command": "claude code explain --file ${file} --line ${lineNumber}"
    }
  ]
}
```

Keyboard shortcuts:

```json
// .vscode/keybindings.json
[
  {
    "key": "cmd+shift+r",
    "command": "workbench.action.tasks.runTask",
    "args": "AI: Review Current File"
  },
  {
    "key": "cmd+shift+t",
    "command": "workbench.action.tasks.runTask",
    "args": "AI: Generate Tests"
  }
]
```

---

## Appendix: Quick Reference

### Common Commands

```bash
# Start new feature
git checkout -b feature/[name]
mkdir -p design-docs
touch design-docs/[name].md

# AI assistance
claude code

# Run tests
npm test -- --coverage

# Create PR
gh pr create --draft

# Deploy to staging
git push origin main  # Automatic

# Deploy to production
gh workflow run deploy-production.yml -f version=[tag]

# Check errors
gh issue list --label incident
```

### Approval Matrix

| Feature Size | AI Review | Human Reviewers | Blocking |
|-------------|-----------|-----------------|----------|
| Small       | Required  | 0 (optional)    | No       |
| Medium      | Required  | 1               | No       |
| Large       | Required  | 2               | Yes      |
| New Product | Required  | 2               | Yes      |

### Contact Information

- **Engineering Lead**: [Name] - [email/slack]
- **Security Contact**: [Name] - [email/slack]
- **DevOps Contact**: [Name] - [email/slack]

### Useful Links

- [Engineering Project Board](https://github.com/orgs/INFORMUP/projects/1)
- [Design Docs Repository](./design-docs/)
- [CI/CD Dashboard](https://github.com/INFORMUP/[repo]/actions)
- [Error Monitoring](https://sentry.io/organizations/informup/)
- [Documentation](./docs/)

---

**Document Version**: 1.0
**Last Updated**: [Date]
**Next Review**: [Date + 3 months]
