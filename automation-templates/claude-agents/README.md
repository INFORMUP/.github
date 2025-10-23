# Claude Agents for InformUp Engineering Workflow

**Version**: 1.0.0
**Last Updated**: 2025-01-22

---

## Overview

This directory contains 11 specialized Claude Code agents that automate and assist with every phase of InformUp's engineering workflow. Each agent is a self-contained expert with specific tools and responsibilities.

## Agent Architecture

### What are Claude Agents?

Claude agents are specialized AI assistants with:
- **Defined roles**: Clear responsibilities and expertise
- **Specific tools**: Access to relevant commands and operations
- **Focused prompts**: Detailed instructions for their domain
- **Workflow integration**: Triggered at appropriate stages

### Benefits of Agent-Based Automation

- **Specialized**: Each agent is an expert in its domain
- **Maintainable**: Agent definitions are version-controlled markdown files
- **Composable**: Agents can invoke other agents
- **Native**: Uses Claude Code's built-in agent system
- **Simpler**: Replaces complex Node.js scripts with agent definitions

---

## Engineering Workflow Mapping

### Phase 1: Feature Planning

**Agent**: [feature-planner.md](./feature-planner.md)

**Trigger**: `post-checkout` hook on feature branches

**Workflow**:
```
Developer creates feature branch
        ↓
post-checkout hook detects feature/* branch
        ↓
Invokes Feature Planner Agent
        ↓
Agent asks questions interactively
        ↓
Generates design document in design-docs/
```

**Replaces**: `scripts/automation/feature-planning.js`

---

### Phase 2: Design Review

**Agents**:
- [architecture-reviewer.md](./architecture-reviewer.md)
- [security-auditor.md](./security-auditor.md)
- [cost-analyzer.md](./cost-analyzer.md)

**Trigger**: Design doc commit, manual invocation

**Workflow**:
```
Developer commits design doc
        ↓
pre-commit hook invokes review agents
        ↓
Architecture Reviewer: Analyzes design patterns
Security Auditor: Identifies security risks
Cost Analyzer: Estimates resource costs
        ↓
Agents append reviews to design doc
        ↓
Developer addresses feedback
```

**Replaces**: `automation-templates/prompts/architecture-review.md`, `security-review.md`, etc.

---

### Phase 3: Code Development

**Agent**: [test-generator.md](./test-generator.md)

**Trigger**: File watcher on new code files

**Workflow**:
```
Developer creates new file: src/feature.ts
        ↓
File watcher detects creation
        ↓
Invokes Test Generator Agent
        ↓
Agent reads source code
        ↓
Generates test file: src/feature.test.ts
        ↓
Developer reviews and adjusts tests
```

**Replaces**: Test generation logic in `claude-watcher.js`

---

### Phase 4: Pre-Commit Review

**Agent**: [code-reviewer.md](./code-reviewer.md)

**Trigger**: `pre-commit` hook

**Workflow**:
```
Developer runs: git commit
        ↓
pre-commit hook invokes Code Reviewer Agent
        ↓
Agent reviews staged changes in <30 seconds
        ↓
Checks for: secrets, security issues, bugs, debug code
        ↓
If critical issues: Block commit
If warnings: Allow but warn
If clean: Proceed
```

**Replaces**: `scripts/automation/quick-review.js`

---

### Phase 5: Pull Request Creation

**Agents**:
- [local-ci.md](./local-ci.md)
- [pr-generator.md](./pr-generator.md)

**Trigger**: `pre-push` hook

**Workflow**:
```
Developer runs: git push
        ↓
pre-push hook invokes Local CI Agent
        ↓
Runs: lint, type-check, tests, build, security
        ↓
If failed: Block push, show errors
If passed: Continue
        ↓
Invokes PR Generator Agent
        ↓
Analyzes git history and changes
        ↓
Generates PR description
        ↓
Optionally creates PR via gh CLI
```

**Replaces**: `scripts/automation/local-ci.js`, `pr-generator.js`

---

### Phase 6: Build & Deployment

**Agent**: [build-diagnostician.md](./build-diagnostician.md)

**Trigger**: Manual invocation after build failures

**Workflow**:
```
Build fails in CI or locally
        ↓
Developer invokes Build Diagnostician
        ↓
Agent analyzes error logs
        ↓
Identifies root cause
        ↓
Provides step-by-step fix
        ↓
Developer applies fix
```

**Replaces**: Build failure analysis prompts

---

### Phase 7: Production Monitoring

**Agent**: [error-investigator.md](./error-investigator.md)

**Trigger**: Manual invocation, scheduled monitoring

**Workflow**:
```
Production error occurs
        ↓
Error logged to Sentry/monitoring
        ↓
Developer invokes Error Investigator
        ↓
Agent analyzes error, logs, context
        ↓
Identifies root cause and impact
        ↓
Recommends fix and prevention
```

**Replaces**: Error investigation prompts

---

### Continuous: Documentation

**Agent**: [documentation.md](./documentation.md)

**Trigger**: File watcher, post-commit

**Workflow**:
```
Developer changes code
        ↓
File watcher detects change
        ↓
Documentation Agent analyzes changes
        ↓
Updates inline docs, README, API docs
        ↓
Updates CHANGELOG.md
        ↓
Commits documentation updates
```

**Replaces**: Doc generation in `claude-watcher.js`

---

## Agent Directory

| Agent | Role | Trigger | Mode | Replaces |
|-------|------|---------|------|----------|
| **feature-planner** | Interactive feature planning | post-checkout | Interactive | feature-planning.js |
| **architecture-reviewer** | Design architecture review | Design review | Interactive | architecture-review.md |
| **security-auditor** | Security & privacy review | Design review | Blocking | security-review.md |
| **cost-analyzer** | Resource cost estimation | Design review | Background | Cost analysis prompts |
| **test-generator** | Generate test suites | File watcher | Background | Test gen in watcher |
| **code-reviewer** | Quick code review | pre-commit | Blocking | quick-review.js |
| **pr-generator** | Generate PR descriptions | pre-push | Interactive | pr-generator.js |
| **local-ci** | Full local CI pipeline | pre-push | Blocking | local-ci.js |
| **build-diagnostician** | Diagnose build failures | Manual | Interactive | Build failure prompts |
| **error-investigator** | Investigate prod errors | Manual/scheduled | Interactive | Error investigation prompts |
| **documentation** | Maintain documentation | File watcher/post-commit | Background | Doc gen in watcher |

---

## Usage Guide

### Automatic Invocation

Agents are automatically invoked by git hooks and file watchers:

```bash
# Feature Planning - automatic on new feature branch
git checkout -b feature/new-feature
# → Feature Planner agent runs automatically

# Code Review - automatic on commit
git commit -m "feat: Add new feature"
# → Code Reviewer agent runs automatically

# Local CI & PR Generation - automatic on push
git push origin feature/new-feature
# → Local CI agent runs, then PR Generator
```

### Manual Invocation

Invoke agents directly when needed:

```bash
# Architecture review
claude code --agent architecture-reviewer

# Security audit
claude code --agent security-auditor

# Cost analysis
claude code --agent cost-analyzer

# Generate tests
claude code --agent test-generator --file src/feature.ts

# Diagnose build failure
claude code --agent build-diagnostician

# Investigate error
claude code --agent error-investigator

# Update documentation
claude code --agent documentation --file src/feature.ts
```

### Passing Context

Provide context to agents:

```bash
# Pass file context
claude code --agent test-generator --file src/api/users.ts

# Pass error context
claude code --agent error-investigator --context "$(cat error.log)"

# Pass git diff
claude code --agent code-reviewer --context "$(git diff --cached)"
```

---

## Configuration

### Enabling/Disabling Agents

Configure in `.claude-automation-config.json`:

```json
{
  "triggers": {
    "featurePlanning": {
      "enabled": true,
      "mode": "interactive"
    },
    "preCommitReview": {
      "enabled": true,
      "quick": true,
      "failOnIssues": false
    },
    "testGeneration": {
      "enabled": true,
      "mode": "background"
    }
  }
}
```

### Customizing Agent Behavior

Create local overrides in `.claude/agents/`:

```bash
# Copy agent to local directory
cp automation-templates/claude-agents/feature-planner.md .claude/agents/

# Edit to customize
code .claude/agents/feature-planner.md
```

Local agents take precedence over templates.

---

## Development Workflow with Agents

### Typical Feature Development Flow

1. **Start Feature**
   ```bash
   git checkout -b feature/newsletter-preferences
   ```
   → Feature Planner helps create design doc

2. **Design Review**
   ```bash
   git add design-docs/newsletter-preferences.md
   git commit -m "docs: Add feature plan"
   ```
   → Architecture, Security, and Cost agents review design

3. **Write Code**
   ```bash
   # Create src/api/newsletter.ts
   ```
   → Test Generator creates src/api/newsletter.test.ts

4. **Commit Changes**
   ```bash
   git add src/
   git commit -m "feat: Add newsletter API"
   ```
   → Code Reviewer checks for issues

5. **Push & Create PR**
   ```bash
   git push origin feature/newsletter-preferences
   ```
   → Local CI runs full tests
   → PR Generator creates PR description

6. **Handle Build Failures** (if any)
   ```bash
   claude code --agent build-diagnostician
   ```
   → Diagnoses and suggests fixes

7. **Monitor Production**
   ```bash
   # If errors occur
   claude code --agent error-investigator
   ```
   → Investigates and recommends fixes

---

## Integration Points

### Git Hooks

Agents integrate with git hooks in `.husky/`:

```bash
.husky/
├── post-checkout    → feature-planner
├── pre-commit       → code-reviewer
├── post-commit      → documentation
└── pre-push         → local-ci, pr-generator
```

### File Watcher

Background agents run via file watcher:

```bash
# Start watcher
npm run automation:start

# Watches for:
# - New files → test-generator
# - File changes → documentation
```

### Manual Commands

Add npm scripts for easy access:

```json
{
  "scripts": {
    "agent:plan": "claude code --agent feature-planner",
    "agent:review-arch": "claude code --agent architecture-reviewer",
    "agent:review-security": "claude code --agent security-auditor",
    "agent:cost": "claude code --agent cost-analyzer",
    "agent:tests": "claude code --agent test-generator",
    "agent:diagnose": "claude code --agent build-diagnostician",
    "agent:investigate": "claude code --agent error-investigator"
  }
}
```

---

## Migration from Scripts

### Before (Script-Based)

```bash
# .husky/post-checkout
node scripts/automation/feature-planning.js "$FEATURE_NAME" --interactive
```

### After (Agent-Based)

```bash
# .husky/post-checkout
claude code --agent feature-planner
```

### Benefits

- **Simpler**: One command instead of Node.js script
- **Native**: Uses Claude Code's agent system
- **Maintainable**: Agent definition in markdown, not JavaScript
- **Powerful**: Agents have access to all Claude Code tools
- **Composable**: Agents can invoke other agents

---

## Troubleshooting

### Agent Not Found

```bash
Error: Agent 'feature-planner' not found
```

**Solution**: Ensure agents are installed in `.claude/agents/`

```bash
# Check if agents exist
ls .claude/agents/

# If not, run installer
./automation-installer/install.sh
```

### Agent Fails to Execute

```bash
Error: Agent execution failed
```

**Solution**: Check Claude Code installation

```bash
# Verify Claude Code is installed
claude --version

# Verify authentication
claude auth status
```

### Hook Not Triggering Agent

**Solution**: Check hook permissions and configuration

```bash
# Make hooks executable
chmod +x .husky/*

# Verify config enables trigger
cat .claude-automation-config.json | jq '.triggers.featurePlanning.enabled'
```

---

## Best Practices

### Do

- ✅ Review agent output before accepting changes
- ✅ Customize agents for your repository's needs
- ✅ Keep agent definitions in version control
- ✅ Update agents when workflow changes
- ✅ Use agents interactively for important decisions

### Don't

- ❌ Blindly accept all agent suggestions
- ❌ Skip manual review of critical changes
- ❌ Disable security agents without good reason
- ❌ Forget to update agents when tools change
- ❌ Rely solely on agents for quality (human review still matters)

---

## Contributing

### Adding New Agents

1. Create agent definition in `automation-templates/claude-agents/{name}.md`
2. Follow existing agent format and structure
3. Document trigger, mode, and workflow
4. Test thoroughly
5. Update this README
6. Submit PR

### Improving Existing Agents

1. Edit agent definition
2. Test changes
3. Update version number
4. Document changes in CHANGELOG
5. Submit PR

---

## Version History

### v1.0.0 (2025-01-22)

Initial release with 11 agents:
- Feature Planner
- Architecture Reviewer
- Security Auditor
- Cost Analyzer
- Test Generator
- Code Reviewer
- PR Generator
- Local CI
- Build Diagnostician
- Error Investigator
- Documentation

---

## Related Documentation

- [Engineering Overview](../../docs/EngineeringOverview.md)
- [Engineering Process Implementation](../../docs/EngineeringProcessImplementation.md)
- [Automation Architecture](../../docs/AutomationArchitecture.md)
- [Getting Started](../../docs/GettingStarted.md)

---

## Support

**Questions or Issues**:
- GitHub Issues: [Create an issue](https://github.com/INFORMUP/.github/issues)
- Slack: #engineering
- Email: engineering@informup.org

---

**Maintained by**: InformUp Engineering Team
**License**: MIT
