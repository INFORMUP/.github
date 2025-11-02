#!/bin/bash
###############################################################################
# InformUp Engineering Automation Installer (Hybrid Model)
# Version: 2.0.0
#
# This script installs the InformUp hybrid automation system in a repository.
# It sets up Claude agents, git hooks, and hybrid model configuration.
#
# Features:
#   - Fresh installation of v2.0 (Hybrid Model)
#   - Automatic upgrade from v1.0 to v2.0
#   - Preserves user customizations during upgrades
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/INFORMUP/.github/main/automation-installer/install.sh | bash
#
# Or locally:
#   bash install.sh [--upgrade]
#
###############################################################################

set -e  # Exit on error

# Check for flags
UPGRADE_MODE=false
if [[ "$1" == "--upgrade" ]]; then
  UPGRADE_MODE=true
fi

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

  mkdir -p docs/reviews
  log_success "Created docs/reviews/"

  mkdir -p .claude/agents
  log_success "Created .claude/agents/"

  mkdir -p .claude/skills
  log_success "Created .claude/skills/"

  mkdir -p .claude
  log_success "Created .claude/"

  mkdir -p .claude-prompts
  log_success "Created .claude-prompts/ (for custom overrides)"

  # Create workspace for temporary files
  mkdir -p .claude_workspace/drafts
  mkdir -p .claude_workspace/analysis
  mkdir -p .claude_workspace/checklists
  mkdir -p .claude_workspace/scripts
  mkdir -p .claude_workspace/notes
  log_success "Created .claude_workspace/ (for temporary/intermediate files)"
}

###############################################################################
# Copy Templates
###############################################################################

copy_templates() {
  log_step "Copying automation templates..."

  if [ "$SOURCE_TYPE" = "local" ]; then
    # Copy Claude agents (primary automation method)
    cp "$TEMPLATES_DIR/claude-agents/"*.md .claude/agents/
    log_success "Copied Claude agent definitions"

    # Copy Hybrid Model skill (correct directory structure)
    if [ -d "$SCRIPT_DIR/../.claude/skills/informup-engineering-excellence" ]; then
      mkdir -p .claude/skills/informup-engineering-excellence
      cp "$SCRIPT_DIR/../.claude/skills/informup-engineering-excellence/SKILL.md" .claude/skills/informup-engineering-excellence/
      log_success "Copied Hybrid Model skill"
    else
      log_warning "Hybrid Model skill not found, skipping"
    fi

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
    log_success "Copied and activated git hooks"
  else
    # Download from remote
    log_warning "Remote installation not yet implemented"
    log_info "Please clone the .github repository and run install.sh from there"
    exit 1
  fi
}

###############################################################################
# Detect Existing Installation
###############################################################################

detect_existing_installation() {
  log_step "Checking for existing installation..."

  if [ ! -f ".claude-automation-config.json" ]; then
    log_info "No existing installation found"
    EXISTING_VERSION="none"
    return 0
  fi

  # Check version
  EXISTING_VERSION=$(node -p "try { require('./.claude-automation-config.json').version } catch(e) { '1.0.0' }" 2>/dev/null || echo "1.0.0")

  # Check for hybrid model
  HAS_HYBRID=$(node -p "try { require('./.claude-automation-config.json').operatingModel === 'hybrid' } catch(e) { false }" 2>/dev/null || echo "false")

  if [ "$EXISTING_VERSION" = "2.0.0" ] && [ "$HAS_HYBRID" = "true" ]; then
    log_success "Hybrid Model v2.0 already installed"
    NEEDS_UPGRADE=false
  elif [ "$EXISTING_VERSION" = "2.0.0" ]; then
    log_warning "v2.0 installed but not hybrid model - will upgrade to hybrid"
    NEEDS_UPGRADE=true
  else
    log_warning "v$EXISTING_VERSION installed - will upgrade to v2.0 (Hybrid Model)"
    NEEDS_UPGRADE=true
  fi
}

###############################################################################
# Backup Existing Configuration
###############################################################################

backup_config() {
  if [ ! -f ".claude-automation-config.json" ]; then
    return 0
  fi

  log_step "Backing up existing configuration..."

  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  cp .claude-automation-config.json ".claude-automation-config.json.backup_${TIMESTAMP}"

  log_success "Backed up to .claude-automation-config.json.backup_${TIMESTAMP}"
}

###############################################################################
# Upgrade Configuration to Hybrid Model
###############################################################################

upgrade_config_to_hybrid() {
  log_step "Upgrading configuration to Hybrid Model v2.0..."

  # Read existing config to preserve customizations
  if [ -f ".claude-automation-config.json" ]; then
    # Extract custom settings we want to preserve
    CUSTOM_REPO_TYPE=$(node -p "try { require('./.claude-automation-config.json').repoType || 'unknown' } catch(e) { 'unknown' }" 2>/dev/null || echo "unknown")
    CUSTOM_ENABLED=$(node -p "try { require('./.claude-automation-config.json').enabled !== false } catch(e) { true }" 2>/dev/null || echo "true")
  else
    CUSTOM_REPO_TYPE="$REPO_TYPE"
    CUSTOM_ENABLED="true"
  fi

  # Copy new hybrid config from .github repo
  if [ -f "$SCRIPT_DIR/../.claude-automation-config.json" ]; then
    cp "$SCRIPT_DIR/../.claude-automation-config.json" .claude-automation-config.json
  else
    log_error "Hybrid model config template not found"
    return 1
  fi

  # Restore customizations
  if [ "$(uname)" = "Darwin" ]; then
    # macOS
    sed -i '' "s/\"repoType\": \"templates\"/\"repoType\": \"$CUSTOM_REPO_TYPE\"/" .claude-automation-config.json
    # Remove the _note about templates
    node -p "const fs=require('fs'); const c=JSON.parse(fs.readFileSync('.claude-automation-config.json')); delete c._note; JSON.stringify(c,null,2)" > .claude-automation-config.json.tmp && mv .claude-automation-config.json.tmp .claude-automation-config.json
  else
    # Linux
    sed -i "s/\"repoType\": \"templates\"/\"repoType\": \"$CUSTOM_REPO_TYPE\"/" .claude-automation-config.json
    node -p "const fs=require('fs'); const c=JSON.parse(fs.readFileSync('.claude-automation-config.json')); delete c._note; JSON.stringify(c,null,2)" > .claude-automation-config.json.tmp && mv .claude-automation-config.json.tmp .claude-automation-config.json
  fi

  log_success "Upgraded configuration to Hybrid Model v2.0"
  log_info "Preserved settings: repoType=$CUSTOM_REPO_TYPE"
}

###############################################################################
# Create Configuration
###############################################################################

create_config() {
  log_step "Creating configuration..."

  # Check if needs upgrade
  if [ "$NEEDS_UPGRADE" = "true" ]; then
    backup_config
    upgrade_config_to_hybrid
    return 0
  fi

  if [ -f ".claude-automation-config.json" ]; then
    log_warning ".claude-automation-config.json already exists. Skipping."
    return 0
  fi

  # Fresh installation - copy hybrid config
  if [ -f "$SCRIPT_DIR/../.claude-automation-config.json" ]; then
    cp "$SCRIPT_DIR/../.claude-automation-config.json" .claude-automation-config.json
  else
    log_error "Hybrid model config template not found"
    return 1
  fi

  # Update repo type
  if [ "$(uname)" = "Darwin" ]; then
    # macOS
    sed -i '' "s/\"repoType\": \"templates\"/\"repoType\": \"$REPO_TYPE\"/" .claude-automation-config.json
    # Remove the _note about templates
    node -p "const fs=require('fs'); const c=JSON.parse(fs.readFileSync('.claude-automation-config.json')); delete c._note; JSON.stringify(c,null,2)" > .claude-automation-config.json.tmp && mv .claude-automation-config.json.tmp .claude-automation-config.json
  else
    # Linux
    sed -i "s/\"repoType\": \"templates\"/\"repoType\": \"$REPO_TYPE\"/" .claude-automation-config.json
    node -p "const fs=require('fs'); const c=JSON.parse(fs.readFileSync('.claude-automation-config.json')); delete c._note; JSON.stringify(c,null,2)" > .claude-automation-config.json.tmp && mv .claude-automation-config.json.tmp .claude-automation-config.json
  fi

  log_success "Created .claude-automation-config.json (Hybrid Model v2.0)"
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
    ""
    "# Claude Workspace (temporary/intermediate files)"
    ".claude_workspace/"
  )

  if [ -f ".gitignore" ]; then
    # Check if already added
    if grep -q "Claude Automation" .gitignore; then
      # Check if workspace entry exists
      if ! grep -q ".claude_workspace/" .gitignore; then
        echo "" >> .gitignore
        echo "# Claude Workspace (temporary/intermediate files)" >> .gitignore
        echo ".claude_workspace/" >> .gitignore
        log_success "Added .claude_workspace/ to .gitignore"
      else
        log_success ".gitignore already configured"
      fi
      return
    fi

    # Append all entries
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
      echo "$entry" >> .gitignore
    done
  else
    # Create new .gitignore
    printf "%s\n" "${GITIGNORE_ENTRIES[@]}" > .gitignore
  fi

  log_success "Updated .gitignore (includes .claude_workspace/)"
}

###############################################################################
# Create or Update CLAUDE.md (Hybrid Model)
###############################################################################

create_claude_documentation() {
  log_step "Installing CLAUDE.md (Hybrid Model enforcement)..."

  # Copy the hybrid model CLAUDE.md from .github repo
  if [ -f "$SCRIPT_DIR/../CLAUDE.md" ]; then
    if [ -f "CLAUDE.md" ]; then
      # Backup existing CLAUDE.md
      TIMESTAMP=$(date +%Y%m%d_%H%M%S)
      mv CLAUDE.md "CLAUDE.md.backup_${TIMESTAMP}"
      log_info "Backed up existing CLAUDE.md"
    fi

    cp "$SCRIPT_DIR/../CLAUDE.md" CLAUDE.md
    log_success "Installed CLAUDE.md (Hybrid Model v2.0 with anti-reversion protection)"
  else
    log_warning "CLAUDE.md template not found in .github repo"
  fi

  # Create decision log
  if [ ! -f ".claude/decisions.md" ]; then
    REPO_NAME=$(basename $(git rev-parse --show-toplevel))
    INSTALL_DATE=$(date +%Y-%m-%d)

    cat > .claude/decisions.md << 'EOF'
# Engineering Decisions Log

**Purpose**: Track major engineering decisions for context across sessions and prevent unintentional reversions.

**Repository**: {{REPO_NAME}}
**Created**: {{INSTALL_DATE}}

---

## {{INSTALL_DATE}} - Hybrid Operating Model Installation

**Context**: Installed InformUp Hybrid Operating Model v2.0 for transparent standards enforcement.

**Decision**: Use hybrid model with medium enforcement for all engineering tasks.

**Key Features**:
- Task classification (9 types)
- Compliance scoring (0-100)
- Transparent standards
- Edge case & risk analysis
- Anti-reversion protection

**Impact**: All engineering workflows in this repository

**Author**: InformUp Automation Installer

---

## Template for Future Decisions

```markdown
## [YYYY-MM-DD] - [Decision Title]

**Context**: [Why was this needed?]
**Decision**: [What was decided?]
**Rationale**: [Why this approach?]
**Impact**: [Who/what is affected?]
**Alternatives Considered**: [What else was considered?]
**Author**: [Who decided]
```

---

**Note to Claude**: Check this file before suggesting to revert or remove features.
EOF

    # Replace variables
    if [ "$(uname)" = "Darwin" ]; then
      sed -i '' "s/{{REPO_NAME}}/${REPO_NAME}/g" .claude/decisions.md
      sed -i '' "s/{{INSTALL_DATE}}/${INSTALL_DATE}/g" .claude/decisions.md
    else
      sed -i "s/{{REPO_NAME}}/${REPO_NAME}/g" .claude/decisions.md
      sed -i "s/{{INSTALL_DATE}}/${INSTALL_DATE}/g" .claude/decisions.md
    fi

    log_success "Created .claude/decisions.md (decision tracking)"
  else
    log_info ".claude/decisions.md already exists"
  fi
}

###############################################################################
# Test Installation
###############################################################################

test_installation() {
  log_step "Testing installation..."

  # Test Claude agents (primary check)
  AGENT_COUNT=$(ls -1 .claude/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
  if [ "$AGENT_COUNT" -ge 13 ]; then
    log_success "Claude agents installed ($AGENT_COUNT agents)"
  else
    log_error "Claude agents not found or incomplete (found: $AGENT_COUNT, expected: 13)"
    return 1
  fi

  # Test Hybrid Model skill (correct directory structure)
  if [ -f ".claude/skills/informup-engineering-excellence/SKILL.md" ]; then
    log_success "Hybrid Model skill installed (correct structure)"
  else
    log_warning "Hybrid Model skill not found or incorrect structure"
    log_info "Should be: .claude/skills/informup-engineering-excellence/SKILL.md"
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
    # Verify it's v2.0.0 config with hybrid model
    VERSION=$(node -p "try { require('./.claude-automation-config.json').version } catch(e) { '1.0.0' }")
    HAS_HYBRID=$(node -p "try { require('./.claude-automation-config.json').operatingModel === 'hybrid' } catch(e) { false }")
    if [ "$VERSION" = "2.0.0" ] && [ "$HAS_HYBRID" = "true" ]; then
      log_success "Configuration file created (v$VERSION - Hybrid Model)"
    else
      log_warning "Configuration is v$VERSION (expected 2.0.0 with hybrid model)"
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
# Check and Create Initial Commit
###############################################################################

check_initial_commit() {
  log_step "Checking for initial commit..."

  # Check if repository has any commits
  if git rev-parse HEAD > /dev/null 2>&1; then
    log_success "Repository has commits - hooks will work correctly"
    return 0
  fi

  # No commits yet
  log_warning "No commits found in this repository"
  echo ""
  echo -e "${YELLOW}⚠ Important:${NC} Git hooks require at least one commit to work properly."
  echo -e "   Without a commit, automation hooks will ${RED}not trigger${NC} on git operations."
  echo ""
  echo -e "Would you like to create an initial commit now?"
  echo ""
  echo -e "  ${BLUE}1)${NC} Yes, commit automation setup files"
  echo -e "  ${BLUE}2)${NC} No, I'll commit manually later"
  echo ""
  printf "Choice [1-2]: "

  # Read user input (with timeout of 30 seconds)
  read -t 30 CHOICE || CHOICE="2"

  case $CHOICE in
    1)
      echo ""
      log_info "Creating initial commit..."

      # Stage all automation files
      git add .

      # Create commit
      git commit --no-verify -m "chore: Initialize InformUp automation system

- Add Claude Code agents (12 agents)
- Configure git hooks (pre-commit, pre-push, post-checkout, post-commit)
- Set up automation scripts and configuration
- Add design-docs directory structure

Generated by InformUp Automation Installer v2.0.0" > /dev/null 2>&1

      if [ $? -eq 0 ]; then
        log_success "Initial commit created successfully"
        echo -e "   ${GREEN}✓${NC} Git hooks will now work on all branches"
      else
        log_error "Failed to create initial commit"
        echo -e "   ${YELLOW}Please create a commit manually before git hooks will work${NC}"
      fi
      ;;

    2|*)
      echo ""
      log_warning "Skipping initial commit"
      echo ""
      echo -e "${YELLOW}Remember:${NC} Git hooks will ${RED}not work${NC} until you create an initial commit:"
      echo -e "  ${BLUE}git add .${NC}"
      echo -e "  ${BLUE}git commit -m \"Initial commit\"${NC}"
      echo ""
      ;;
  esac
}

###############################################################################
# Print Next Steps
###############################################################################

print_next_steps() {
  echo ""
  if [ "$NEEDS_UPGRADE" = "true" ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                            ║${NC}"
    echo -e "${GREEN}║   ✅  Upgraded to Hybrid Operating Model v2.0!           ║${NC}"
    echo -e "${GREEN}║                                                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}What Changed:${NC}"
    echo -e "  ✓ Configuration upgraded from v$EXISTING_VERSION → v2.0.0 (Hybrid Model)"
    echo -e "  ✓ Added task classification system (9 task types)"
    echo -e "  ✓ Added compliance scoring (0-100)"
    echo -e "  ✓ Added transparent standards enforcement"
    echo -e "  ✓ Installed CLAUDE.md to enforce hybrid model"
    echo -e "  ✓ Your customizations preserved in backup"
    echo ""
  else
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                            ║${NC}"
    echo -e "${GREEN}║   ✅  InformUp Hybrid Model Successfully Installed!       ║${NC}"
    echo -e "${GREEN}║                                                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
  fi
  echo -e "${CYAN}Next Steps:${NC}"
  echo ""
  echo -e "  ${YELLOW}1.${NC} Install Claude Code CLI (if not already installed):"
  echo -e "     ${BLUE}npm install -g @anthropic/claude-code${NC}"
  echo -e "     ${BLUE}claude auth login${NC}"
  echo ""
  echo -e "  ${YELLOW}2.${NC} Read about the Hybrid Model:"
  echo -e "     ${BLUE}cat CLAUDE.md${NC} (enforcement instructions for Claude)"
  echo -e "     ${BLUE}https://github.com/INFORMUP/.github/blob/main/docs/HybridOperatingModel.md${NC}"
  echo ""
  echo -e "  ${YELLOW}3.${NC} Create a new feature branch to try it out:"
  echo -e "     ${BLUE}git checkout -b feature/test-hybrid-model${NC}"
  echo -e "     ${CYAN}Note: Claude will classify your task and show applicable standards${NC}"
  echo ""
  echo -e "  ${YELLOW}4.${NC} (Optional) Start the file watcher for background automation:"
  echo -e "     ${BLUE}npm run automation:start &${NC}"
  echo ""
  echo -e "${CYAN}Installed Components:${NC}"
  echo -e "  ✓ 13 Claude agents (.claude/agents/) - includes edge-case-analyzer"
  echo -e "  ✓ Hybrid Model skill (.claude/skills/informup-engineering-excellence/SKILL.md)"
  echo -e "  ✓ Agent-based git hooks (pre-commit, pre-push, post-checkout, post-commit)"
  echo -e "  ✓ Configuration file (v2.0.0 - Hybrid Model with medium enforcement)"
  echo -e "  ✓ CLAUDE.md (enforces skill usage + workspace management)"
  echo -e "  ✓ Decision log (.claude/decisions.md)"
  echo -e "  ✓ Workspace directory (.claude_workspace/ - gitignored)"
  echo -e "  ✓ Directory structure"
  echo ""
  echo -e "${CYAN}Available Agents:${NC}"
  echo -e "  • workflow-guardrails  - Prevent workflow mistakes"
  echo -e "  • feature-planner      - Interactive feature planning"
  echo -e "  • edge-case-analyzer   - Edge case & risk analysis ⭐ NEW"
  echo -e "  • code-reviewer        - Quick code review"
  echo -e "  • pr-generator         - PR description generation"
  echo -e "  • architecture-reviewer - Design architecture review"
  echo -e "  • security-auditor     - Security & privacy review"
  echo -e "  • cost-analyzer        - Resource cost estimation"
  echo -e "  • test-generator       - Automated test generation (uses edge case analysis)"
  echo -e "  • local-ci             - Full local CI pipeline"
  echo -e "  • build-diagnostician  - Build failure diagnosis"
  echo -e "  • error-investigator   - Production error investigation"
  echo -e "  • documentation        - Documentation maintenance"
  echo ""
  echo -e "${CYAN}Hybrid Model Features:${NC}"
  echo -e "  • Task Classification - 9 types (major/minor features, bugs, hotfixes, etc.)"
  echo -e "  • Compliance Scoring - 0-100 score with breakdown"
  echo -e "  • Transparent Standards - Claude shows WHAT applies and WHY"
  echo -e "  • Configurable Enforcement - Currently: ${YELLOW}MEDIUM${NC} (blocks <80)"
  echo ""
  echo -e "${CYAN}Configuration:${NC}"
  echo -e "  Edit ${BLUE}.claude-automation-config.json${NC} to:"
  echo -e "    - Change enforcement level (minimal/soft/medium/strict)"
  echo -e "    - Adjust standards for task types"
  echo -e "    - Enable/disable specific agents"
  echo ""
  echo -e "${CYAN}Manual Agent Usage:${NC}"
  echo -e "  ${BLUE}claude code --agent workflow-guardrails${NC} - Check compliance"
  echo -e "  ${BLUE}claude code --agent feature-planner${NC}     - Plan new feature"
  echo -e "  ${BLUE}claude code --agent security-auditor${NC}    - Security review"
  echo ""
  echo -e "${GREEN}Happy coding with transparent standards! 🚀${NC}"
  echo ""
}

###############################################################################
# Main Installation Flow
###############################################################################

main() {
  echo ""
  echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║                                                            ║${NC}"
  echo -e "${CYAN}║   InformUp Engineering Automation Installer (Hybrid Model) ║${NC}"
  echo -e "${CYAN}║                  Version 2.0.0                             ║${NC}"
  echo -e "${CYAN}║                                                            ║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""

  preflight_checks
  detect_existing_installation  # NEW: Detect v1.0 installations
  detect_repo_type
  install_dependencies
  create_directories
  copy_templates
  create_config               # Will upgrade if needed
  update_package_json
  update_gitignore
  create_claude_documentation  # NEW: Hybrid Model CLAUDE.md
  test_installation
  check_initial_commit
  print_next_steps

  exit 0
}

# Run main installation
main
