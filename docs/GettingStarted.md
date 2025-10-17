# Getting Started with InformUp Engineering Automation

**Welcome!** This guide will help you set up and use InformUp's AI-powered engineering automation system in your repository.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Setup (5 Minutes)](#quick-setup-5-minutes)
3. [Detailed Installation](#detailed-installation)
4. [Configuration](#configuration)
5. [Customization](#customization)
6. [Updating Automation](#updating-automation)
7. [Troubleshooting](#troubleshooting)
8. [FAQ](#faq)
9. [Next Steps](#next-steps)

---

## Prerequisites

Before installing the automation system, ensure you have:

### Required

- **Git** (2.0+)
  ```bash
  git --version
  ```

- **Node.js** (18.0+) and npm
  ```bash
  node --version
  npm --version
  ```

- **Claude Code CLI** installed and authenticated
  ```bash
  # Install Claude Code
  npm install -g @anthropic/claude-code

  # Authenticate (first time only)
  claude auth login

  # Verify installation
  claude --version
  ```

- **GitHub CLI** (for PR management)
  ```bash
  # Install gh
  brew install gh  # macOS
  # or follow https://cli.github.com/

  # Authenticate
  gh auth login
  ```

### Recommended

- **VS Code** with recommended extensions
- **macOS, Linux, or WSL2** (Windows users should use WSL2)

### Permissions

- Write access to the repository you're setting up
- Member of the INFORMUP GitHub organization

---

## Quick Setup (5 Minutes)

For experienced developers who want to get started immediately:

```bash
# 1. Navigate to your repository
cd /path/to/your-repo

# 2. Run the installer (coming soon)
curl -sSL https://raw.githubusercontent.com/INFORMUP/.github/main/automation-installer/install.sh | bash

# 3. Start the file watcher (optional, for automatic AI assistance)
npm run automation:start &

# 4. Start coding!
git checkout -b feature/my-new-feature
```

**Note**: The installer script is currently in development. For now, follow the [Detailed Installation](#detailed-installation) steps below.

---

## Detailed Installation

### Step 1: Verify Prerequisites

```bash
# Check all prerequisites
claude --version    # Should show Claude Code version
gh --version        # Should show GitHub CLI version
node --version      # Should be 18.0 or higher
```

### Step 2: Clone or Navigate to Your Repository

```bash
# For new repositories
gh repo clone INFORMUP/your-repo-name
cd your-repo-name

# For existing repositories
cd /path/to/your-repo
git pull origin main
```

### Step 3: Install Automation (Manual Method - Temporary)

Until the automated installer is ready, follow these manual steps:

```bash
# 1. Install dependencies
npm install --save-dev husky@^8.0.0 chokidar@^3.5.0

# 2. Initialize Husky (git hooks)
npx husky-init
npm install

# 3. Create automation directories
mkdir -p scripts/automation
mkdir -p design-docs
mkdir -p .claude-prompts

# 4. Add automation scripts to package.json
npm pkg set scripts.automation:start="node scripts/automation/claude-watcher.js"
npm pkg set scripts.automation:test="echo 'Testing automation setup...'"
npm pkg set scripts.local-ci="node scripts/automation/local-ci.js"
```

### Step 4: Create Configuration File

Create `.claude-automation-config.json` in your repository root:

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
      "quick": true
    },
    "prGeneration": {
      "enabled": true,
      "mode": "interactive"
    }
  },
  "testing": {
    "command": "npm test",
    "coverageThreshold": 80
  },
  "build": {
    "command": "npm run build"
  },
  "monitoring": {
    "enabled": false
  }
}
```

### Step 5: Verify Installation

```bash
# Test that everything is set up correctly
npm run automation:test

# Verify git hooks are installed
ls -la .husky/
```

---

## Configuration

### Configuration Cascade

The automation system uses a three-tier configuration system:

1. **Organization Defaults** (lowest priority)
   - Located in `.github` repository
   - Defines baseline for all InformUp projects

2. **Repository Config** (medium priority)
   - `.claude-automation-config.json` in your repo
   - Customizes automation for your project

3. **Developer Personal Config** (highest priority)
   - `~/.config/claude-automation/config.json` on your machine
   - Your personal preferences override everything

### Common Configuration Options

#### Repository Type

```json
{
  "repoType": "frontend" | "backend" | "infrastructure" | "mobile"
}
```

- **frontend**: React, Next.js, Vue, etc.
- **backend**: Node.js, Python, API services
- **infrastructure**: Terraform, CloudFormation, K8s
- **mobile**: React Native, Flutter

#### Automation Triggers

Enable or disable specific automation features:

```json
{
  "triggers": {
    "featurePlanning": {
      "enabled": true,              // Auto-start feature planning on branch creation
      "branches": ["feature/*"],    // Which branches trigger this
      "mode": "interactive"         // interactive | background | disabled
    },
    "testGeneration": {
      "enabled": true,
      "filePattern": "src/**/*.ts",
      "excludePattern": "**/*.test.ts",
      "mode": "background"          // Generate tests silently
    }
  }
}
```

#### Testing Configuration

```json
{
  "testing": {
    "command": "npm test",           // How to run tests
    "coverageThreshold": 80,         // Minimum coverage %
    "coverageCommand": "npm test -- --coverage"
  }
}
```

#### Claude Code Settings

```json
{
  "claude": {
    "model": "claude-3-5-sonnet-20241022",  // Claude model to use
    "timeout": 60000,                        // Timeout in ms
    "maxTokens": 4096                        // Max response tokens
  }
}
```

---

## Customization

### Customizing Prompts

You can override organization-wide AI prompts with repository-specific versions:

```bash
# Create custom prompts directory
mkdir -p .claude-prompts

# Copy and customize a prompt
cat > .claude-prompts/feature-planning.md << 'EOF'
# Custom Feature Planning Prompt for [Your Repo]

You are helping plan a feature for [Your Repo Name], which is a [description].

Our specific guidelines:
- [Custom guideline 1]
- [Custom guideline 2]

Please help the developer think through:
1. [Custom consideration 1]
2. [Custom consideration 2]
...
EOF
```

### Customizing Git Hooks

Edit hooks in `.husky/` to customize behavior:

```bash
# Example: Customize pre-commit hook
nano .husky/pre-commit
```

**Tip**: Keep hooks as lightweight as possible. Heavy operations should be in separate scripts.

### Per-Developer Customization

Create `~/.config/claude-automation/config.json` for personal preferences:

```json
{
  "enabled": true,
  "notifications": {
    "desktop": true,
    "sound": false
  },
  "triggers": {
    "testGeneration": {
      "enabled": false  // Disable if you prefer to write tests manually
    }
  },
  "verboseLogging": true  // More detailed logs
}
```

### VS Code Integration

Add custom VS Code tasks for AI assistance:

```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "AI: Review Current File",
      "type": "shell",
      "command": "claude code review --file ${file}",
      "presentation": {
        "reveal": "always",
        "panel": "new"
      }
    },
    {
      "label": "AI: Generate Tests for Current File",
      "type": "shell",
      "command": "claude code test generate --file ${file}",
      "presentation": {
        "reveal": "always"
      }
    }
  ]
}
```

Bind to keyboard shortcuts in `.vscode/keybindings.json`:

```json
[
  {
    "key": "cmd+shift+r",
    "command": "workbench.action.tasks.runTask",
    "args": "AI: Review Current File"
  },
  {
    "key": "cmd+shift+t",
    "command": "workbench.action.tasks.runTask",
    "args": "AI: Generate Tests for Current File"
  }
]
```

---

## Updating Automation

### Check for Updates

```bash
# Check your current version
cat .claude-automation-config.json | grep version

# Check latest available version (coming soon)
curl -sSL https://raw.githubusercontent.com/INFORMUP/.github/main/VERSION
```

### Update to Latest Version

```bash
# Automated update (coming soon)
npm run automation:update

# Manual update (current method)
# 1. Pull latest from .github repo
# 2. Copy updated scripts/prompts
# 3. Review changelog
# 4. Test locally
```

### Update Process (Manual - Temporary)

1. **Backup current configuration**:
   ```bash
   cp .claude-automation-config.json .claude-automation-config.json.backup
   ```

2. **Pull latest automation files** from `.github` repo:
   ```bash
   # Copy updated scripts from .github repo
   # (specific commands coming soon)
   ```

3. **Review changes**:
   ```bash
   # Compare your config with new defaults
   diff .claude-automation-config.json.backup .claude-automation-config.json
   ```

4. **Test updates**:
   ```bash
   npm run automation:test
   ```

5. **Commit updated configuration**:
   ```bash
   git add .claude-automation-config.json scripts/
   git commit -m "chore: Update automation to v1.x.x"
   ```

---

## Troubleshooting

### Common Issues

#### 1. Claude Code Not Found

**Error**: `claude: command not found`

**Solution**:
```bash
# Install Claude Code globally
npm install -g @anthropic/claude-code

# Verify installation
which claude

# If still not found, add to PATH:
echo 'export PATH="$PATH:$(npm global bin)"' >> ~/.zshrc  # or ~/.bashrc
source ~/.zshrc
```

#### 2. Git Hooks Not Running

**Error**: Hooks in `.husky/` don't execute

**Solution**:
```bash
# Ensure hooks are executable
chmod +x .husky/*

# Verify Husky is installed
npm list husky

# Reinstall if needed
npm install
npx husky install
```

#### 3. Automation Watcher Won't Start

**Error**: `npm run automation:start` fails

**Solution**:
```bash
# Check if script exists
npm run automation:start --if-present

# Check for syntax errors in watcher script
node scripts/automation/claude-watcher.js --check

# Check for port conflicts
lsof -i :3000  # Or whatever port the watcher uses
```

#### 4. Tests Fail on Pre-commit

**Error**: Commit blocked due to test failures

**Solution**:
```bash
# Run tests manually to see detailed output
npm test

# Use Claude to diagnose test failures
claude code analyze --failure "$(npm test 2>&1)"

# If tests are flaky, update them
# If real issue, fix the code

# Bypass ONLY if absolutely necessary (not recommended)
git commit --no-verify -m "message"
```

#### 5. Claude API Rate Limiting

**Error**: `Rate limit exceeded`

**Solution**:
```bash
# Check your Claude subscription status
claude auth status

# Reduce automation frequency in config
# Edit .claude-automation-config.json:
{
  "triggers": {
    "testGeneration": {
      "enabled": false  // Temporarily disable
    }
  }
}

# Wait and retry after cooldown period
```

#### 6. Prompt Not Found

**Error**: `Cannot load prompt template`

**Solution**:
```bash
# Ensure .claude-prompts/ directory exists
mkdir -p .claude-prompts

# Check if referencing correct prompt path
# in .claude-automation-config.json

# Fallback to organization defaults
rm -rf .claude-prompts/  # Remove custom prompts
```

### Getting Help

1. **Check the logs**:
   ```bash
   tail -f .claude-automation.log
   ```

2. **Run in verbose mode**:
   ```bash
   DEBUG=* npm run automation:start
   ```

3. **Ask on Slack**: #engineering channel

4. **Create an issue**: [INFORMUP/.github Issues](https://github.com/INFORMUP/.github/issues)

5. **Review documentation**:
   - [Engineering Overview](./EngineeringOverview.md)
   - [Implementation Guide](./EngineeringProcessImplementation.md)
   - [Automation Architecture](./AutomationArchitecture.md)

---

## FAQ

### General Questions

**Q: Do I need to use the automation system?**

A: While not mandatory, it's strongly recommended. The automation ensures consistency, catches issues early, and helps maintain high code quality across all InformUp projects.

**Q: Can I disable automation for specific commits?**

A: Yes. Use `git commit --no-verify` to bypass hooks. However, your PR will still need to pass CI checks.

**Q: Does this work with my IDE?**

A: Yes! The automation works with any IDE. We provide special integration for VS Code, but command-line automation works everywhere.

**Q: Will this slow down my workflow?**

A: Most automation runs in the background. Interactive sessions (design reviews) only trigger when starting new features. You control the pace.

### Cost & Billing

**Q: Does this cost money?**

A: You need a Claude Pro subscription ($20/month) to use Claude Code. There are no per-token API charges. InformUp may cover this for core team members.

**Q: What if I don't have Claude Pro?**

A: You can still contribute! The CI system will run AI checks on your behalf. You just won't have local AI assistance.

### Technical Questions

**Q: What happens if Claude Code is down?**

A: Automation gracefully degrades. Git hooks will run standard checks (linting, tests) and skip AI-powered checks. You can still commit and push.

**Q: Can I use a different AI model?**

A: Currently, the system is built for Claude Code. Support for other models may be added in the future.

**Q: How do I contribute to the automation system?**

A: Submit PRs to the `.github` repository. See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

**Q: What data is sent to Claude?**

A: Only the code and prompts you're actively working with. Review the [Privacy Policy](https://www.anthropic.com/privacy) for details.

### Process Questions

**Q: Do I still need human code reviews?**

A: Yes! AI reviews supplement but don't replace human reviews. See [approval matrix](./EngineeringProcessImplementation.md#pr-review-process).

**Q: What if AI suggests something wrong?**

A: AI is a tool, not a boss. Always use your judgment. AI suggestions should be reviewed and validated.

**Q: Can I use this for hotfixes?**

A: Yes, but you can streamline: create a `hotfix/*` branch and skip design review. Still run tests and code review.

---

## Next Steps

Now that you're set up, here's what to do next:

### 1. Read the Documentation

- **[Engineering Overview](./EngineeringOverview.md)** - Understand InformUp's engineering principles
- **[Implementation Guide](./EngineeringProcessImplementation.md)** - Detailed process for each development phase
- **[Automation Architecture](./AutomationArchitecture.md)** - How the automation system works

### 2. Try It Out

Start a simple feature to test the automation:

```bash
# Create a feature branch
git checkout -b feature/test-automation

# Create a design doc (you'll get AI assistance)
mkdir -p design-docs
touch design-docs/test-automation.md

# Make some code changes
# Watch as AI helps generate tests

# Commit (pre-commit checks will run)
git add .
git commit -m "feat: Test automation system"

# Create a PR (AI will help generate description)
gh pr create
```

### 3. Customize for Your Needs

Review the [Customization](#customization) section and adjust settings to match your workflow.

### 4. Join the Community

- Attend engineering standups
- Join #engineering on Slack
- Share feedback and suggestions

### 5. Help Improve the System

Found a bug? Have an idea? Contribute back:

```bash
# Clone the .github repo
gh repo clone INFORMUP/.github
cd .github

# Create a branch
git checkout -b feature/improve-automation

# Make your changes
# Submit a PR
gh pr create
```

---

## Support

**Need help?** We're here for you:

- **Slack**: #engineering channel
- **Email**: engineering@informup.org
- **GitHub Issues**: [INFORMUP/.github/issues](https://github.com/INFORMUP/.github/issues)
- **Office Hours**: Tuesdays 2-3 PM PT (check calendar for link)

---

**Welcome to the team!** 🎉

We're excited to have you contributing to InformUp's mission of increasing civic engagement through technology.
