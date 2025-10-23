# Migration Guide: Script-Based to Agent-Based Automation

**Target Audience**: Repositories currently using InformUp automation scripts
**Migration Time**: ~30-45 minutes per repository
**Difficulty**: Medium
**Version**: 1.0.0

---

## Table of Contents

1. [Overview](#overview)
2. [What's Changing](#whats-changing)
3. [Prerequisites](#prerequisites)
4. [Migration Steps](#migration-steps)
5. [Verification](#verification)
6. [Rollback Plan](#rollback-plan)
7. [Troubleshooting](#troubleshooting)
8. [FAQ](#faq)

---

## Overview

### Why Migrate?

The agent-based architecture offers significant improvements:

**Benefits**:
- **Simpler**: Agents replace complex Node.js scripts
- **Native**: Uses Claude Code's built-in agent system
- **Maintainable**: Agent definitions are markdown, not JavaScript
- **Powerful**: Agents have access to all Claude Code tools
- **Composable**: Agents can invoke other agents
- **Versioned**: Agent definitions tracked in git

**Performance**:
- Same or better performance
- Reduced maintenance burden
- Easier to customize

---

## What's Changing

### Architecture Comparison

#### Before: Script-Based

```
Git Hook
    ↓
Node.js Script (feature-planning.js)
    ↓
Spawn Claude CLI Process
    ↓
Load Prompt from .md file
    ↓
Execute
```

#### After: Agent-Based

```
Git Hook
    ↓
Claude Code Agent Invocation
    ↓
Agent Definition (.md file with instructions)
    ↓
Execute with tools
```

### File Changes

| Component | Before | After |
|-----------|--------|-------|
| Feature Planning | `scripts/automation/feature-planning.js` | `.claude/agents/feature-planner.md` |
| Code Review | `scripts/automation/quick-review.js` | `.claude/agents/code-reviewer.md` |
| PR Generation | `scripts/automation/pr-generator.js` | `.claude/agents/pr-generator.md` |
| Local CI | `scripts/automation/local-ci.js` | `.claude/agents/local-ci.md` |
| Prompts | `automation-templates/prompts/*.md` | Embedded in agents |
| File Watcher | `scripts/automation/claude-watcher.js` | Simplified watcher invoking agents |

---

## Prerequisites

### Required

- [x] Claude Code CLI installed (`claude --version`)
- [x] Authenticated with Claude (`claude auth status`)
- [x] Git repository with existing automation
- [x] Backup of current configuration
- [x] Node.js 18+ (for temporary coexistence)

### Recommended

- [x] Clean working directory (`git status`)
- [x] All current hooks working
- [x] Test in a feature branch first

---

## Migration Steps

### Step 1: Backup Current Setup (5 min)

```bash
# Navigate to repository
cd /path/to/your-repo

# Create backup branch
git checkout -b backup/pre-agent-migration

# Commit current state
git add -A
git commit -m "backup: Pre-agent migration snapshot"

# Create backup of automation files
mkdir -p .backup/automation
cp -r .husky/ .backup/automation/
cp -r scripts/automation/ .backup/automation/
cp .claude-automation-config.json .backup/automation/

echo "✅ Backup created at .backup/automation/"
```

### Step 2: Install Agent Definitions (10 min)

```bash
# Create .claude/agents directory
mkdir -p .claude/agents

# Copy agent definitions from .github repo
GITHUB_REPO="/path/to/.github"  # Adjust path

cp -r $GITHUB_REPO/automation-templates/claude-agents/*.md .claude/agents/

# Verify agents installed
ls .claude/agents/
# Should see:
# - feature-planner.md
# - code-reviewer.md
# - pr-generator.md
# - architecture-reviewer.md
# - security-auditor.md
# - cost-analyzer.md
# - test-generator.md
# - local-ci.md
# - build-diagnostician.md
# - error-investigator.md
# - documentation.md
# - README.md

echo "✅ Agents installed"
```

### Step 3: Update Git Hooks (10 min)

Update each git hook to use agents instead of scripts.

#### Update `.husky/post-checkout`

**Before**:
```bash
#!/usr/bin/env sh
# ... existing script logic ...
node scripts/automation/feature-planning.js "$FEATURE_NAME" --interactive
```

**After**:
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Only trigger on branch checkout
if [ "$BRANCH_CHECKOUT" != "1" ]; then
  exit 0
fi

# Get current branch name
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

# Skip main/master/develop
if [ "$BRANCH_NAME" = "main" ] || [ "$BRANCH_NAME" = "master" ]; then
  exit 0
fi

# Load config
CONFIG_FILE=".claude-automation-config.json"
ENABLED=$(node -p "try { require('./$CONFIG_FILE').triggers.featurePlanning.enabled } catch(e) { 'true' }")

if [ "$ENABLED" != "true" ]; then
  exit 0
fi

# Check for feature branch pattern
if echo "$BRANCH_NAME" | grep -qE "^(feature|fix|enhancement)/"; then
  echo "🎨 New feature branch detected: $BRANCH_NAME"
  echo "Starting feature planning..."

  # Invoke agent
  claude code --agent feature-planner
fi

exit 0
```

#### Update `.husky/pre-commit`

**Before**:
```bash
#!/usr/bin/env sh
# ... existing script ...
node scripts/automation/quick-review.js
```

**After**:
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Load config
CONFIG_FILE=".claude-automation-config.json"
ENABLED=$(node -p "try { require('./$CONFIG_FILE').triggers.preCommitReview.enabled } catch(e) { 'true' }")

if [ "$ENABLED" != "true" ]; then
  exit 0
fi

echo "🔍 Running code review..."

# Invoke agent with timeout
timeout 30s claude code --agent code-reviewer

EXIT_CODE=$?

if [ $EXIT_CODE -eq 124 ]; then
  echo "⚠️  Code review timed out, proceeding with commit"
  exit 0
elif [ $EXIT_CODE -ne 0 ]; then
  echo "❌ Code review found critical issues"
  exit $EXIT_CODE
fi

echo "✅ Pre-commit checks passed"
exit 0
```

#### Update `.husky/pre-push`

**Before**:
```bash
#!/usr/bin/env sh
# ... existing script ...
node scripts/automation/local-ci.js
node scripts/automation/pr-generator.js
```

**After**:
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Load config
CONFIG_FILE=".claude-automation-config.json"
CI_ENABLED=$(node -p "try { require('./$CONFIG_FILE').triggers.prePushChecks.enabled } catch(e) { 'true' }")
PR_ENABLED=$(node -p "try { require('./$CONFIG_FILE').triggers.prGeneration.enabled } catch(e) { 'true' }")

# Run local CI
if [ "$CI_ENABLED" = "true" ]; then
  echo "🚀 Running local CI pipeline..."

  claude code --agent local-ci

  if [ $? -ne 0 ]; then
    echo "❌ Local CI failed. Fix issues before pushing."
    echo "Or skip checks with: git push --no-verify"
    exit 1
  fi
fi

# Generate PR description
if [ "$PR_ENABLED" = "true" ]; then
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  if [[ "$CURRENT_BRANCH" == feature/* ]]; then
    echo ""
    echo "📝 Would you like to generate a PR description? (y/n)"
    read -t 10 ANSWER || ANSWER="n"

    if [ "$ANSWER" = "y" ]; then
      claude code --agent pr-generator
    fi
  fi
fi

echo "✅ Pre-push checks complete"
exit 0
```

### Step 4: Update File Watcher (Optional, 5 min)

If using file watcher for background automation:

**Create new watcher**: `scripts/automation/agent-watcher.js`

```javascript
#!/usr/bin/env node
/**
 * Agent-Based File Watcher
 * Invokes Claude agents on file changes
 */

const chokidar = require('chokidar');
const { spawn } = require('child_process');
const path = require('path');

class AgentWatcher {
  constructor() {
    this.config = require('../../.claude-automation-config.json');
  }

  start() {
    console.log('🤖 Agent watcher started');

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
    if (!require('fs').existsSync(testFile)) {
      console.log(`📝 Generating tests for ${filepath}...`);
      this.invokeAgent('test-generator', ['--file', filepath]);
    }
  }

  onFileChanged(filepath) {
    if (!this.config.triggers.docGeneration?.enabled) return;

    // Debounce doc updates
    clearTimeout(this.docTimeout);
    this.docTimeout = setTimeout(() => {
      console.log(`📚 Updating docs for ${filepath}...`);
      this.invokeAgent('documentation', ['--file', filepath]);
    }, 2000);
  }

  invokeAgent(agentName, args = []) {
    spawn('claude', ['code', '--agent', agentName, ...args], {
      detached: true,
      stdio: 'ignore'
    }).unref();
  }

  getTestFilePath(filepath) {
    const ext = path.extname(filepath);
    return filepath.replace(ext, `.test${ext}`);
  }
}

// Start watcher
const watcher = new AgentWatcher();
watcher.start();
```

**Update package.json**:
```json
{
  "scripts": {
    "automation:start": "node scripts/automation/agent-watcher.js",
    "automation:stop": "pkill -f agent-watcher.js"
  }
}
```

### Step 5: Update Configuration (5 min)

Update `.claude-automation-config.json` to reference agents:

```json
{
  "version": "2.0.0",
  "source": "github.com/INFORMUP/.github",
  "enabled": true,
  "repoType": "frontend",

  "agents": {
    "directory": ".claude/agents",
    "available": [
      "feature-planner",
      "code-reviewer",
      "pr-generator",
      "architecture-reviewer",
      "security-auditor",
      "cost-analyzer",
      "test-generator",
      "local-ci",
      "build-diagnostician",
      "error-investigator",
      "documentation"
    ]
  },

  "triggers": {
    "featurePlanning": {
      "enabled": true,
      "agent": "feature-planner",
      "branches": ["feature/*", "fix/*", "enhancement/*"],
      "mode": "interactive"
    },
    "designReview": {
      "enabled": true,
      "agents": ["architecture-reviewer", "security-auditor", "cost-analyzer"],
      "mode": "interactive"
    },
    "testGeneration": {
      "enabled": true,
      "agent": "test-generator",
      "mode": "background"
    },
    "preCommitReview": {
      "enabled": true,
      "agent": "code-reviewer",
      "quick": true,
      "failOnIssues": false,
      "mode": "blocking",
      "timeout": 30000
    },
    "prePushChecks": {
      "enabled": true,
      "agent": "local-ci",
      "mode": "blocking"
    },
    "prGeneration": {
      "enabled": true,
      "agent": "pr-generator",
      "mode": "interactive"
    },
    "docGeneration": {
      "enabled": false,
      "agent": "documentation",
      "mode": "background"
    }
  },

  "testing": {
    "command": "npm test",
    "coverageCommand": "npm test -- --coverage",
    "coverageThreshold": 80
  },

  "build": {
    "command": "npm run build",
    "sizeLimitMB": 5
  }
}
```

### Step 6: Clean Up Old Scripts (Optional, 5 min)

Once migration is complete and tested:

```bash
# Move old scripts to archive
mkdir -p .archive/old-automation
mv scripts/automation/*.js .archive/old-automation/

# Keep the new watcher
mv .archive/old-automation/agent-watcher.js scripts/automation/

# Remove old prompts directory (now embedded in agents)
mv automation-templates/prompts .archive/old-automation/

echo "✅ Old scripts archived"
```

---

## Verification

### Test Each Agent

#### 1. Feature Planner

```bash
# Create test branch
git checkout -b feature/test-agent-migration

# Agent should trigger automatically
# Verify you see: "🎨 New feature branch detected"
```

#### 2. Code Reviewer

```bash
# Make a change with a console.log
echo "console.log('test');" >> src/test.ts
git add src/test.ts
git commit -m "test: Verify code reviewer"

# Agent should warn about console.log
# Verify you see: "⚠️ Code review found 1 issue"
```

#### 3. Local CI

```bash
# Push changes
git push origin feature/test-agent-migration

# Agent should run CI pipeline
# Verify you see: "🚀 Running local CI pipeline..."
```

#### 4. Manual Agents

```bash
# Test manual invocation
claude code --agent architecture-reviewer
claude code --agent security-auditor
claude code --agent test-generator --file src/test.ts
claude code --agent build-diagnostician
```

### Verification Checklist

- [ ] Feature Planner triggers on feature branch creation
- [ ] Code Reviewer runs on `git commit`
- [ ] Local CI runs on `git push`
- [ ] PR Generator offers to create PR
- [ ] Manual agents can be invoked
- [ ] Agents can access files and run commands
- [ ] Configuration is respected (enabled/disabled)
- [ ] No errors in hook execution

---

## Rollback Plan

If migration fails or causes issues:

### Quick Rollback

```bash
# Restore from backup
git checkout backup/pre-agent-migration

# Copy back old automation
cp -r .backup/automation/.husky/ ./
cp -r .backup/automation/scripts/ ./
cp .backup/automation/.claude-automation-config.json ./

# Verify hooks work
.husky/pre-commit

echo "✅ Rolled back to script-based automation"
```

### Selective Rollback

Keep agents but revert problematic hooks:

```bash
# Revert specific hook
git checkout backup/pre-agent-migration -- .husky/pre-commit

# Or manually restore old behavior in hook
```

---

## Troubleshooting

### Issue: Agent not found

**Error**: `Agent 'feature-planner' not found`

**Solution**:
```bash
# Verify agents are installed
ls .claude/agents/

# If missing, reinstall
cp automation-templates/claude-agents/*.md .claude/agents/
```

### Issue: Hook doesn't trigger agent

**Error**: Hook runs but agent doesn't execute

**Solution**:
```bash
# Check Claude Code is installed
claude --version

# Check authentication
claude auth status

# Verify hook is executable
chmod +x .husky/*

# Check hook script for syntax errors
bash -n .husky/post-checkout
```

### Issue: Agent times out

**Error**: `Code review timed out`

**Solution**:
```bash
# Increase timeout in hook
# Change: timeout 30s
# To: timeout 60s

# Or disable in config
# "enabled": false
```

### Issue: Configuration not loading

**Error**: Config not being read

**Solution**:
```bash
# Verify config syntax
jq '.' .claude-automation-config.json

# Check Node.js can read it
node -p "require('./.claude-automation-config.json').triggers"
```

---

## FAQ

### Q: Can I run both systems in parallel during migration?

**A**: Yes! Keep old scripts in place while testing agents. Remove scripts once confident.

### Q: Do I need to migrate all agents at once?

**A**: No. Migrate incrementally:
1. Start with Feature Planner
2. Add Code Reviewer
3. Add remaining agents over time

### Q: What if I've customized the old scripts?

**A**: Customize agent definitions instead:
1. Copy agent to `.claude/agents/`
2. Edit markdown to match your customizations
3. Test thoroughly

### Q: Can I still use the old prompts?

**A**: Agent definitions replace prompts. Migrate prompt content into agent instructions.

### Q: How do I update agents?

**A**: Pull latest from `.github` repo:
```bash
cp /path/to/.github/automation-templates/claude-agents/*.md .claude/agents/
```

### Q: What if Claude Code isn't installed?

**A**: Agents require Claude Code. Install first:
```bash
npm install -g @anthropic/claude-code
claude auth login
```

---

## Next Steps

After successful migration:

1. **Remove backup branch**
   ```bash
   git branch -D backup/pre-agent-migration
   ```

2. **Update team documentation**
   - Notify team of new agent-based system
   - Share this migration guide
   - Update onboarding docs

3. **Customize agents**
   - Adjust agent definitions for your workflow
   - Add repository-specific instructions
   - Share customizations with team

4. **Monitor and iterate**
   - Collect feedback from team
   - Adjust agent behavior as needed
   - Report issues to InformUp engineering

---

## Support

**Questions or Issues**:
- GitHub Issues: [Create an issue](https://github.com/INFORMUP/.github/issues)
- Slack: #engineering
- Email: engineering@informup.org

**Documentation**:
- [Agent README](../automation-templates/claude-agents/README.md)
- [Automation Architecture](./AutomationArchitecture.md)
- [Engineering Process](./EngineeringProcessImplementation.md)

---

**Migration Guide Version**: 1.0.0
**Last Updated**: 2025-01-22
**Maintained By**: InformUp Engineering Team
