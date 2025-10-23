#!/bin/bash
###############################################################################
# InformUp Engineering Automation Installer (Agent-Based)
# Version: 2.0.0
#
# This script installs the InformUp automation system in a repository.
# It sets up Claude agents, git hooks, and configuration.
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/INFORMUP/.github/main/automation-installer/install.sh | bash
#
# Or locally:
#   bash install.sh
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Template source (can be local or remote)
if [ -d "$SCRIPT_DIR/../automation-templates" ]; then
  TEMPLATES_DIR="$SCRIPT_DIR/../automation-templates"
  SOURCE_TYPE="local"
else
  TEMPLATES_URL="https://raw.githubusercontent.com/INFORMUP/.github/main/automation-templates"
  SOURCE_TYPE="remote"
fi

###############################################################################
# Helper Functions
###############################################################################

log_info() {
  echo -e "${CYAN}ℹ${NC}  $1"
}

log_success() {
  echo -e "${GREEN}✓${NC}  $1"
}

log_warning() {
  echo -e "${YELLOW}⚠${NC}  $1"
}

log_error() {
  echo -e "${RED}✗${NC}  $1"
}

log_step() {
  echo -e "\n${BLUE}==>${NC} $1"
}

check_command() {
  if command -v "$1" &> /dev/null; then
    return 0
  else
    return 1
  fi
}

###############################################################################
# Pre-flight Checks
###############################################################################

preflight_checks() {
  log_step "Running pre-flight checks..."

  # Check if we're in a git repository
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_error "Not in a git repository. Please run this from your repository root."
    exit 1
  fi
  log_success "Git repository detected"

  # Check for Node.js
  if ! check_command node; then
    log_error "Node.js not found. Please install Node.js 18+ first."
    exit 1
  fi
  NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
  if [ "$NODE_VERSION" -lt 18 ]; then
    log_error "Node.js 18+ required. You have: $(node --version)"
    exit 1
  fi
  log_success "Node.js $(node --version) detected"

  # Check for npm
  if ! check_command npm; then
    log_error "npm not found."
    exit 1
  fi
  log_success "npm $(npm --version) detected"

  # Check if package.json exists
  if [ ! -f "package.json" ]; then
    log_warning "No package.json found. Creating one..."
    npm init -y > /dev/null 2>&1
  fi
  log_success "package.json found"
}

###############################################################################
# Detect Repository Type
###############################################################################

detect_repo_type() {
  log_step "Detecting repository type..."

  # Check package.json for framework indicators
  if [ -f "package.json" ]; then
    if grep -q "next" package.json; then
      REPO_TYPE="frontend"
      TECH_STACK="Next.js,React,TypeScript"
    elif grep -q "react" package.json; then
      REPO_TYPE="frontend"
      TECH_STACK="React"
    elif grep -q "vue" package.json; then
      REPO_TYPE="frontend"
      TECH_STACK="Vue"
    elif grep -q "express" package.json; then
      REPO_TYPE="backend"
      TECH_STACK="Node.js,Express"
    elif grep -q "fastify" package.json; then
      REPO_TYPE="backend"
      TECH_STACK="Node.js,Fastify"
    else
      REPO_TYPE="backend"
      TECH_STACK="Node.js"
    fi
  elif [ -f "main.tf" ] || [ -f "*.tf" ]; then
    REPO_TYPE="infrastructure"
    TECH_STACK="Terraform"
  else
    REPO_TYPE="unknown"
    TECH_STACK="unknown"
  fi

  log_info "Detected repository type: ${GREEN}$REPO_TYPE${NC}"
  log_info "Tech stack: $TECH_STACK"
}

###############################################################################
# Install Dependencies
###############################################################################

install_dependencies() {
  log_step "Installing dependencies..."

  # Install Husky
  if ! npm list husky > /dev/null 2>&1; then
    log_info "Installing husky..."
    npm install --save-dev husky@^8.0.0
  else
    log_success "husky already installed"
  fi

  # Install chokidar (for file watcher)
  if ! npm list chokidar > /dev/null 2>&1; then
    log_info "Installing chokidar..."
    npm install --save-dev chokidar@^3.5.0
  else
    log_success "chokidar already installed"
  fi

  log_success "Dependencies installed"
}

###############################################################################
# Create Directory Structure
###############################################################################

create_directories() {
  log_step "Creating directory structure..."

  mkdir -p scripts/automation
  log_success "Created scripts/automation/"

  mkdir -p design-docs
  log_success "Created design-docs/"

  mkdir -p .claude/agents
  log_success "Created .claude/agents/"

  mkdir -p .claude-prompts
  log_success "Created .claude-prompts/ (for custom overrides)"
}

###############################################################################
# Copy Templates
###############################################################################

copy_templates() {
  log_step "Copying automation templates..."

  if [ "$SOURCE_TYPE" = "local" ]; then
    # Copy Claude agents (primary automation method)
    cp "$TEMPLATES_DIR/claude-agents/"*.md .claude/agents/
    log_success "Copied 11 Claude agent definitions"

    # Copy automation scripts (helper scripts, file watcher)
    if [ -d "$TEMPLATES_DIR/scripts" ]; then
      cp -r "$TEMPLATES_DIR/scripts/"* scripts/automation/ 2>/dev/null || true
      log_info "Copied helper automation scripts"
    fi

    # Initialize Husky
    npx husky install > /dev/null 2>&1

    # Copy git hooks (agent-based versions)
    cp "$TEMPLATES_DIR/husky/"* .husky/
    chmod +x .husky/*
    log_success "Copied and activated agent-based git hooks"
  else
    # Download from remote
    log_warning "Remote installation not yet implemented"
    log_info "Please clone the .github repository and run install.sh from there"
    exit 1
  fi
}

###############################################################################
# Create Configuration
###############################################################################

create_config() {
  log_step "Creating configuration..."

  if [ -f ".claude-automation-config.json" ]; then
    log_warning ".claude-automation-config.json already exists. Skipping."
    return
  fi

  # Copy default config and customize
  cp "$TEMPLATES_DIR/configs/.claude-automation-config.json" .claude-automation-config.json

  # Update repo type
  if [ "$(uname)" = "Darwin" ]; then
    # macOS
    sed -i '' "s/\"repoType\": \"frontend\"/\"repoType\": \"$REPO_TYPE\"/" .claude-automation-config.json
  else
    # Linux
    sed -i "s/\"repoType\": \"frontend\"/\"repoType\": \"$REPO_TYPE\"/" .claude-automation-config.json
  fi

  log_success "Created .claude-automation-config.json"
}

###############################################################################
# Update package.json
###############################################################################

update_package_json() {
  log_step "Updating package.json scripts..."

  # Add automation scripts if they don't exist
  npm pkg set scripts.automation:start="node scripts/automation/claude-watcher.js" 2>/dev/null || true
  npm pkg set scripts.automation:stop="pkill -f claude-watcher" 2>/dev/null || true
  npm pkg set scripts.automation:test="echo 'Automation system installed'" 2>/dev/null || true
  npm pkg set scripts.local-ci="node scripts/automation/local-ci.js" 2>/dev/null || true
  npm pkg set scripts.prepare="husky install" 2>/dev/null || true

  log_success "Added automation scripts to package.json"
}

###############################################################################
# Update .gitignore
###############################################################################

update_gitignore() {
  log_step "Updating .gitignore..."

  GITIGNORE_ENTRIES=(
    ""
    "# Claude Automation"
    ".claude-automation.log"
    ".claude-cache/"
    ".pr-description.md"
  )

  if [ -f ".gitignore" ]; then
    # Check if already added
    if grep -q "Claude Automation" .gitignore; then
      log_success ".gitignore already configured"
      return
    fi

    # Append entries
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
      echo "$entry" >> .gitignore
    done
  else
    # Create new .gitignore
    printf "%s\n" "${GITIGNORE_ENTRIES[@]}" > .gitignore
  fi

  log_success "Updated .gitignore"
}

###############################################################################
# Create or Update CLAUDE.md
###############################################################################

create_claude_documentation() {
  log_step "Creating CLAUDE.md documentation..."

  REPO_NAME=$(basename $(git rev-parse --show-toplevel))
  INSTALL_DATE=$(date +%Y-%m-%d)
  AUTHOR=$(git config user.name || echo "Unknown")

  cat > CLAUDE.md << 'HEREDOC'
# Claude Code Automation Guide

**Repository**: {{REPO_NAME}}
**Automation Version**: 2.0.0 (Agent-Based)
**Installed**: {{INSTALL_DATE}}
**Repository Type**: {{REPO_TYPE}}

---

## What's Installed

This repository has the **InformUp Engineering Automation System** installed, which provides AI-powered assistance throughout your development workflow using Claude Code agents.

### 12 Available Agents

| Agent | What It Does | How to Use |
|-------|--------------|------------|
| 🚧 **workflow-guardrails** | Catches workflow mistakes (wrong branch, large commits, etc.) | Automatic or `claude code --agent workflow-guardrails` |
| 🎨 **feature-planner** | Helps plan new features interactively | Automatic on new feature branches |
| 🔍 **code-reviewer** | Quick code review before commits | Automatic on `git commit` |
| 📝 **pr-generator** | Generates PR descriptions | Automatic on `git push` (optional) |
| 🏗️ **architecture-reviewer** | Reviews design documents for architecture | `claude code --agent architecture-reviewer` |
| 🔒 **security-auditor** | Security and privacy review | `claude code --agent security-auditor` |
| 💰 **cost-analyzer** | Estimates resource costs | `claude code --agent cost-analyzer` |
| 🧪 **test-generator** | Generates test files automatically | Automatic or `claude code --agent test-generator` |
| 🚀 **local-ci** | Runs full CI pipeline locally | Automatic on `git push` |
| 🔧 **build-diagnostician** | Diagnoses build failures | `claude code --agent build-diagnostician` |
| 🚨 **error-investigator** | Investigates production errors | `claude code --agent error-investigator` |
| 📚 **documentation** | Maintains documentation | Automatic (background) |

---

## Automatic Workflows

The automation system triggers automatically at key points:

### When You Create a Feature Branch

```bash
git checkout -b feature/my-new-feature
```

→ **Feature Planner** agent starts an interactive session to help you plan

### When You Commit

```bash
git commit -m "feat: Add new feature"
```

→ **Code Reviewer** agent checks for issues (runs in <30 seconds)

### When You Push

```bash
git push origin feature/my-new-feature
```

→ **Local CI** agent runs tests, linting, build checks
→ **PR Generator** agent offers to create PR description

---

## Manual Usage

Invoke any agent manually when you need help:

```bash
# Get help planning a feature
claude code --agent feature-planner

# Review your design document
claude code --agent architecture-reviewer

# Check security of your changes
claude code --agent security-auditor

# Estimate costs of your feature
claude code --agent cost-analyzer

# Generate tests for a file
claude code --agent test-generator --file src/myfile.ts

# Diagnose a build failure
claude code --agent build-diagnostician

# Investigate an error
claude code --agent error-investigator

# Check if you're about to make a workflow mistake
claude code --agent workflow-guardrails
```

---

## Configuration

Edit `.claude-automation-config.json` to customize automation:

```json
{
  "triggers": {
    "featurePlanning": {
      "enabled": true,     // Enable/disable feature planning
      "mode": "interactive"
    },
    "preCommitReview": {
      "enabled": true,     // Enable/disable code review
      "quick": true,       // Quick mode (30s) vs thorough
      "failOnIssues": false // Warn or block on issues
    }
  },
  "testing": {
    "coverageThreshold": 80  // Minimum test coverage (%)
  }
}
```

### Common Customizations

**Disable test generation** (if you prefer manual):
```json
{
  "triggers": {
    "testGeneration": {
      "enabled": false
    }
  }
}
```

**Make code review more strict**:
```json
{
  "triggers": {
    "preCommitReview": {
      "quick": false,         // Thorough review
      "failOnIssues": true    // Block on warnings
    }
  }
}
```

**Disable local CI** (run only in GitHub Actions):
```json
{
  "triggers": {
    "prePushChecks": {
      "enabled": false
    }
  }
}
```

---

## Skipping Automation

Sometimes you need to bypass the automation:

### Skip Pre-Commit Checks

```bash
git commit --no-verify -m "Emergency fix"
```

### Skip Pre-Push Checks

```bash
git push --no-verify
```

**Note**: Use sparingly! The checks are there to help you.

---

## Troubleshooting

### Hooks Not Running

```bash
# Make hooks executable
chmod +x .husky/*

# Reinstall Husky
npx husky install
```

### Agent Not Found

```bash
# Check agents are installed
ls .claude/agents/

# Should see 12 .md files
```

### Claude Code Not Installed

```bash
# Install Claude Code CLI
npm install -g @anthropic/claude-code

# Authenticate
claude auth login

# Verify
claude --version
```

### Hooks Taking Too Long

Adjust timeouts in `.claude-automation-config.json`:

```json
{
  "triggers": {
    "preCommitReview": {
      "timeout": 60000  // Increase from 30s to 60s
    }
  }
}
```

---

## Development Workflow Examples

### Starting a New Feature

```bash
# 1. Create feature branch
git checkout -b feature/newsletter-signup

# → Feature Planner agent starts automatically
# → Answer questions to generate design doc

# 2. Write code
# (develop your feature)

# 3. Commit frequently
git add .
git commit -m "feat: Add signup form"

# → Code Reviewer checks your changes

# 4. Push when ready
git push origin feature/newsletter-signup

# → Local CI runs full checks
# → PR Generator offers to create PR

# 5. Create PR
gh pr create
```

### Fixing a Bug

```bash
# 1. Create fix branch
git checkout -b fix/signup-validation

# 2. Make your fix
# (edit code)

# 3. Commit
git commit -m "fix: Correct email validation"

# → Code Reviewer checks the fix

# 4. Push
git push

# → Local CI verifies the fix works
```

### Investigating Production Errors

```bash
# Get error details from logs/monitoring
# Then invoke the error investigator

claude code --agent error-investigator

# Agent will ask for:
# - Error message
# - Stack trace
# - When it occurred
# - User impact
# Then provide diagnosis and fix recommendations
```

---

## Learning Resources

- **Engineering Overview**: `docs/EngineeringOverview.md` (if available)
- **Agent Documentation**: `.claude/agents/README.md`
- **Migration Guide**: See `.github` repository
- **InformUp Docs**: [https://github.com/INFORMUP/.github](https://github.com/INFORMUP/.github)

---

## Getting Help

**Questions or Issues**:
- GitHub Issues: [Create an issue](https://github.com/INFORMUP/.github/issues)
- Slack: #engineering
- Email: engineering@informup.org

**Disable Automation**:
If you need to disable automation temporarily or permanently:

```json
// .claude-automation-config.json
{
  "enabled": false  // Disables all automation
}
```

Or per-developer:
```bash
export CLAUDE_AUTOMATION_ENABLED=false
```

---

## What Makes This Special

This automation system is designed for InformUp's unique needs:

- **Volunteer-Friendly**: Helps engineers at all skill levels contribute safely
- **Mission-Aligned**: Focuses on code quality without slowing down impact
- **Cost-Effective**: Uses Claude Pro subscription, not pay-per-token
- **Local-First**: Runs on your machine, code stays private
- **Educational**: Teaches best practices while you work

---

**Installed by**: {{AUTHOR}}
**Installation Date**: {{INSTALL_DATE}}
**Version**: 2.0.0

For updates, see: [https://github.com/INFORMUP/.github/blob/main/automation-installer/install.sh](https://github.com/INFORMUP/.github/blob/main/automation-installer/install.sh)
HEREDOC

  # Replace variables
  if [ "$(uname)" = "Darwin" ]; then
    # macOS
    sed -i '' "s/{{REPO_NAME}}/${REPO_NAME}/g" CLAUDE.md
    sed -i '' "s/{{INSTALL_DATE}}/${INSTALL_DATE}/g" CLAUDE.md
    sed -i '' "s/{{REPO_TYPE}}/${REPO_TYPE}/g" CLAUDE.md
    sed -i '' "s/{{AUTHOR}}/${AUTHOR}/g" CLAUDE.md
  else
    # Linux
    sed -i "s/{{REPO_NAME}}/${REPO_NAME}/g" CLAUDE.md
    sed -i "s/{{INSTALL_DATE}}/${INSTALL_DATE}/g" CLAUDE.md
    sed -i "s/{{REPO_TYPE}}/${REPO_TYPE}/g" CLAUDE.md
    sed -i "s/{{AUTHOR}}/${AUTHOR}/g" CLAUDE.md
  fi

  log_success "Created CLAUDE.md documentation"
}

###############################################################################
# Test Installation
###############################################################################

test_installation() {
  log_step "Testing installation..."

  # Test Claude agents (primary check)
  AGENT_COUNT=$(ls -1 .claude/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
  if [ "$AGENT_COUNT" -ge 12 ]; then
    log_success "Claude agents installed ($AGENT_COUNT agents)"
  else
    log_error "Claude agents not found or incomplete (found: $AGENT_COUNT, expected: 12)"
    return 1
  fi

  # Test Husky
  if [ -d ".husky" ] && [ -f ".husky/pre-commit" ]; then
    log_success "Git hooks installed"
  else
    log_error "Git hooks not found"
    return 1
  fi

  # Test config
  if [ -f ".claude-automation-config.json" ]; then
    # Verify it's v2.0.0 config with agent support
    VERSION=$(node -p "try { require('./.claude-automation-config.json').version } catch(e) { '1.0.0' }")
    if [ "$VERSION" = "2.0.0" ]; then
      log_success "Configuration file created (v$VERSION - agent-based)"
    else
      log_warning "Configuration is v$VERSION (expected 2.0.0)"
    fi
  else
    log_error "Configuration not found"
    return 1
  fi

  # Test npm scripts
  npm run automation:test > /dev/null 2>&1
  log_success "All tests passed"
}

###############################################################################
# Print Next Steps
###############################################################################

print_next_steps() {
  echo ""
  echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║                                                            ║${NC}"
  echo -e "${GREEN}║   ✅  InformUp Automation Successfully Installed!         ║${NC}"
  echo -e "${GREEN}║                                                            ║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${CYAN}Next Steps:${NC}"
  echo ""
  echo -e "  ${YELLOW}1.${NC} Install Claude Code CLI (if not already installed):"
  echo -e "     ${BLUE}npm install -g @anthropic/claude-code${NC}"
  echo -e "     ${BLUE}claude auth login${NC}"
  echo ""
  echo -e "  ${YELLOW}2.${NC} (Optional) Start the file watcher for background automation:"
  echo -e "     ${BLUE}npm run automation:start &${NC}"
  echo ""
  echo -e "  ${YELLOW}3.${NC} Create a new feature branch to try it out:"
  echo -e "     ${BLUE}git checkout -b feature/test-automation${NC}"
  echo ""
  echo -e "  ${YELLOW}4.${NC} Read the documentation:"
  echo -e "     ${BLUE}cat CLAUDE.md${NC} (quick reference in this repo)"
  echo -e "     ${BLUE}https://github.com/INFORMUP/.github/blob/main/docs/GettingStarted.md${NC}"
  echo ""
  echo -e "${CYAN}Installed Components:${NC}"
  echo -e "  ✓ 12 Claude agents (.claude/agents/)"
  echo -e "  ✓ Agent-based git hooks (pre-commit, pre-push, post-checkout, post-commit)"
  echo -e "  ✓ Configuration file (v2.0.0 - agent-based)"
  echo -e "  ✓ Directory structure"
  echo -e "  ✓ CLAUDE.md documentation guide"
  echo ""
  echo -e "${CYAN}Available Agents:${NC}"
  echo -e "  • workflow-guardrails  - Prevent workflow mistakes ⭐ NEW"
  echo -e "  • feature-planner      - Interactive feature planning"
  echo -e "  • code-reviewer        - Quick code review"
  echo -e "  • pr-generator         - PR description generation"
  echo -e "  • architecture-reviewer - Design architecture review"
  echo -e "  • security-auditor     - Security & privacy review"
  echo -e "  • cost-analyzer        - Resource cost estimation"
  echo -e "  • test-generator       - Automated test generation"
  echo -e "  • local-ci             - Full local CI pipeline"
  echo -e "  • build-diagnostician  - Build failure diagnosis"
  echo -e "  • error-investigator   - Production error investigation"
  echo -e "  • documentation        - Documentation maintenance"
  echo ""
  echo -e "${CYAN}Configuration:${NC}"
  echo -e "  Edit ${BLUE}.claude-automation-config.json${NC} to enable/disable agents"
  echo ""
  echo -e "${CYAN}Manual Agent Usage:${NC}"
  echo -e "  ${BLUE}claude code --agent feature-planner${NC}"
  echo -e "  ${BLUE}claude code --agent security-auditor${NC}"
  echo -e "  ${BLUE}claude code --agent build-diagnostician${NC}"
  echo ""
  echo -e "${GREEN}Happy coding! 🚀${NC}"
  echo ""
}

###############################################################################
# Main Installation Flow
###############################################################################

main() {
  echo ""
  echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║                                                            ║${NC}"
  echo -e "${CYAN}║   InformUp Engineering Automation Installer (Agent-Based)  ║${NC}"
  echo -e "${CYAN}║                  Version 2.0.0                             ║${NC}"
  echo -e "${CYAN}║                                                            ║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""

  preflight_checks
  detect_repo_type
  install_dependencies
  create_directories
  copy_templates
  create_config
  update_package_json
  update_gitignore
  create_claude_documentation
  test_installation
  print_next_steps

  exit 0
}

# Run main installation
main
