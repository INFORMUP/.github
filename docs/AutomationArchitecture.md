# Automation Architecture

**Document Type**: Technical Architecture
**Audience**: Engineering team, system maintainers
**Related Docs**: [Getting Started](./GettingStarted.md) | [Implementation Guide](./EngineeringProcessImplementation.md)

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture Principles](#architecture-principles)
3. [System Components](#system-components)
4. [Repository Structure](#repository-structure)
5. [Installation System](#installation-system)
6. [Configuration Cascade](#configuration-cascade)
7. [Automation Triggers](#automation-triggers)
8. [Prompt Management](#prompt-management)
9. [Update Mechanism](#update-mechanism)
10. [Repository Type Variations](#repository-type-variations)
11. [Versioning Strategy](#versioning-strategy)
12. [Design Decisions](#design-decisions)

---

## Overview

The InformUp Engineering Automation system is a **local-first, AI-powered development workflow** that integrates Claude Code CLI into every phase of the software development lifecycle.

### Key Characteristics

- **Local-First**: Runs entirely on developer machines, no remote API calls beyond Claude
- **Git-Integrated**: Triggers on git events (branch creation, commits, pushes)
- **File-Watching**: Monitors code changes and provides real-time assistance
- **Centrally Managed**: Templates and prompts maintained in `.github` repository
- **Distributed Execution**: Each repository runs its own automation instance
- **Configurable**: Three-tier configuration system (org → repo → developer)

### Design Goals

1. **Consistency**: Every developer gets the same high-quality AI assistance
2. **Flexibility**: Teams can customize for their specific needs
3. **Maintainability**: Update once in `.github`, propagate everywhere
4. **Reliability**: Graceful degradation if AI services are unavailable
5. **Performance**: Non-blocking operations, background processing where possible
6. **Cost-Effective**: Subscription-based pricing (not per-token)

---

## Architecture Principles

### 1. Local-First Computing

All automation runs on the developer's machine. This provides:
- **Privacy**: Code never leaves the developer's control (except to Claude API)
- **Speed**: No network latency for file operations
- **Reliability**: Works without internet (for non-AI features)
- **Cost Control**: Subscription-based, not pay-per-use

### 2. Progressive Enhancement

The system layers capabilities:

```
Base Layer:          Standard git hooks (lint, test, format)
Enhancement Layer:   AI-powered reviews and assistance
Optional Layer:      Background automation, monitoring
```

If Claude Code is unavailable, the base layer still works.

### 3. Separation of Concerns

```
┌─────────────────────────────────────────────────┐
│  .github Repository (Organization Level)        │
│  - Templates                                    │
│  - Prompts                                      │
│  - Documentation                                │
│  - Installer scripts                            │
└─────────────────────────────────────────────────┘
         │
         │ install / update
         ↓
┌─────────────────────────────────────────────────┐
│  Individual Repository (Project Level)          │
│  - Git hooks (copied)                           │
│  - Automation scripts (copied)                  │
│  - Local configuration                          │
│  - Design docs (project-specific)               │
└─────────────────────────────────────────────────┘
         │
         │ personal overrides
         ↓
┌─────────────────────────────────────────────────┐
│  Developer Machine (User Level)                 │
│  - Personal configuration                       │
│  - Claude Code CLI                              │
│  - Local preferences                            │
└─────────────────────────────────────────────────┘
```

### 4. Event-Driven Architecture

Automation triggers on specific events:

```
Git Events          →  Hooks execute
File Changes        →  Watcher responds
User Commands       →  CLI runs
Scheduled Times     →  Cron jobs trigger
CI Events           →  GitHub Actions run
```

---

## System Components

### 1. Git Hooks (Husky)

**Location**: `.husky/` in each repository

**Purpose**: Intercept git operations to run checks

**Hooks Implemented**:

```bash
.husky/
├── pre-commit          # Lint, test, quick AI review
├── post-commit         # Update docs in background
├── commit-msg          # Validate commit message format
├── post-checkout       # Trigger feature planning on feature branches
├── pre-push            # Run full local CI, generate PR description
└── prepare-commit-msg  # Suggest commit message improvements
```

**Key Features**:
- Configurable enable/disable per hook
- Timeout protection (won't hang forever)
- Error handling (exit codes 0 = success, 1 = fail/block)
- Logging for debugging

### 2. File Watcher Daemon

**Location**: `scripts/automation/claude-watcher.js`

**Purpose**: Watch file system for changes, trigger background automation

**Technology**: Node.js + Chokidar

**Responsibilities**:
- Monitor `src/**/*` for code changes
- Debounce events (wait 2s of inactivity before triggering)
- Generate tests for new files
- Update documentation for changed files
- Log all actions to `.claude-automation.log`

**Lifecycle**:
```bash
# Start (manual)
npm run automation:start

# Stop
npm run automation:stop

# Status
npm run automation:status

# Logs
tail -f .claude-automation.log
```

**Resource Management**:
- Runs as background process (`&` or systemd service)
- Low CPU usage (<5% typically)
- Minimal memory footprint (<100MB)
- Auto-restart on crash (if using systemd/launchd)

### 3. Claude Code Integration Layer

**Location**: `scripts/automation/claude-commands.sh`

**Purpose**: Wrapper around Claude Code CLI for consistent invocation

**Modes of Operation**:

1. **Interactive Mode**:
   ```bash
   claude code review --interactive --file design.md
   ```
   - User can chat with Claude
   - Used for: design reviews, planning, complex analysis
   - Blocks until user completes session

2. **Non-Interactive Mode**:
   ```bash
   claude code test generate --file src/feature.js --output src/feature.test.js
   ```
   - No user input required
   - Used for: test generation, documentation
   - Returns results to STDOUT

3. **Background Mode**:
   ```bash
   claude code docs update --file README.md &
   ```
   - Spawned as detached process
   - Doesn't block user workflow
   - Logs results to file

4. **Batch Mode**:
   ```bash
   for file in src/**/*.js; do
     claude code review --file "$file" --quick
   done
   ```
   - Process multiple files
   - Used in CI/CD pipelines

### 4. Prompt Template System

**Location**:
- Organization: `.github/automation-templates/prompts/`
- Repository: `.claude-prompts/` (optional overrides)

**Structure**:
```
prompts/
├── feature-planning.md
├── architecture-review.md
├── security-review.md
├── cost-analysis.md
├── test-generation.md
├── pr-description.md
├── build-failure-analysis.md
├── error-investigation.md
└── commit-message.md
```

**Template Variables**:
Prompts support variable substitution:

```markdown
# Feature Planning Prompt

You are planning a feature for {{REPO_NAME}}.

Repository type: {{REPO_TYPE}}
Tech stack: {{TECH_STACK}}
Feature name: {{FEATURE_NAME}}
...
```

Variables are replaced at runtime:
```bash
claude code --prompt-file prompts/feature-planning.md \
  --var REPO_NAME="informup-web" \
  --var REPO_TYPE="frontend" \
  --var TECH_STACK="Next.js,React,TypeScript"
```

### 5. Configuration System

**Files**:
```
Organization:  .github/automation-templates/configs/.claude-automation-config.json
Repository:    .claude-automation-config.json
Developer:     ~/.config/claude-automation/config.json
```

**Schema**:
```json
{
  "version": "1.0.0",
  "enabled": true,
  "repoType": "frontend|backend|infrastructure|mobile",
  "triggers": {
    "featurePlanning": { ... },
    "designReview": { ... },
    "testGeneration": { ... },
    "preCommitReview": { ... },
    "prGeneration": { ... }
  },
  "testing": { ... },
  "build": { ... },
  "monitoring": { ... },
  "claude": {
    "model": "claude-3-5-sonnet-20241022",
    "timeout": 60000,
    "maxTokens": 4096
  }
}
```

### 6. Local CI System

**Location**: `scripts/automation/local-ci.js`

**Purpose**: Run full CI pipeline locally before pushing

**Checks Performed**:
1. Linting (ESLint, Prettier)
2. Type checking (TypeScript)
3. Unit tests with coverage
4. Integration tests
5. AI security review (quick)
6. AI architecture review (quick)
7. Build verification
8. Bundle size check

**Usage**:
```bash
# Automatic (pre-push hook)
git push origin feature/my-feature

# Manual
npm run local-ci

# Skip (not recommended)
git push --no-verify
```

---

## Repository Structure

### Organization-Level (`.github` repo)

```
.github/
├── README.md                          # Quick start + links
│
├── docs/                              # Documentation
│   ├── EngineeringOverview.md         # High-level principles
│   ├── EngineeringProcessImplementation.md  # Detailed process
│   ├── AutomationArchitecture.md      # This document
│   ├── GettingStarted.md              # Setup guide
│   └── code_change_and_release_process.md   # Legacy doc
│
├── automation-templates/              # Templates for repos
│   ├── husky/                         # Git hook templates
│   │   ├── pre-commit
│   │   ├── post-commit
│   │   ├── post-checkout
│   │   ├── pre-push
│   │   └── commit-msg
│   │
│   ├── scripts/                       # Automation scripts
│   │   ├── claude-watcher.js
│   │   ├── claude-commands.sh
│   │   ├── local-ci.js
│   │   ├── pr-generator.js
│   │   └── error-analyzer.js
│   │
│   ├── prompts/                       # AI prompt templates
│   │   ├── feature-planning.md
│   │   ├── architecture-review.md
│   │   ├── security-review.md
│   │   ├── cost-analysis.md
│   │   ├── test-generation.md
│   │   └── ...
│   │
│   ├── configs/                       # Default configurations
│   │   ├── .claude-automation-config.json
│   │   ├── .vscode-tasks.json
│   │   ├── .vscode-settings.json
│   │   └── .eslintrc.js
│   │
│   └── workflows/                     # GitHub Actions templates
│       ├── ci-template.yml
│       ├── deploy-staging-template.yml
│       └── deploy-production-template.yml
│
├── automation-installer/              # Installation system
│   ├── install.sh                     # Main installer
│   ├── update.sh                      # Updater
│   ├── uninstall.sh                   # Cleanup
│   ├── lib/                           # Helper functions
│   │   ├── detect-repo-type.sh
│   │   ├── install-hooks.sh
│   │   └── merge-configs.sh
│   └── VERSION                        # Current version
│
└── tests/                             # Test the automation itself
    ├── test-installation.sh
    ├── test-hooks.sh
    └── test-prompts.sh
```

### Individual Repository (after installation)

```
my-repo/
├── .github/
│   ├── workflows/                     # Copied from templates
│   │   ├── ci.yml
│   │   └── deploy-staging.yml
│   └── pull_request_template.md       # Copied from template
│
├── .husky/                            # Git hooks (copied)
│   ├── pre-commit
│   ├── post-commit
│   ├── post-checkout
│   ├── pre-push
│   └── commit-msg
│
├── scripts/
│   ├── automation/                    # Copied from templates
│   │   ├── claude-watcher.js
│   │   ├── claude-commands.sh
│   │   ├── local-ci.js
│   │   └── pr-generator.js
│   └── README.md
│
├── design-docs/                       # Created during install
│   └── .gitkeep
│
├── .claude-automation-config.json     # Local config (customizable)
├── .claude-prompts/                   # Optional: custom prompts
│   └── (overrides go here)
│
├── .claude-automation.log             # Runtime logs
├── .gitignore                         # Updated to ignore logs
└── package.json                       # Updated with scripts
```

---

## Installation System

### Installation Flow

```
┌─────────────────────────────────────────┐
│ Developer runs install script           │
└────────────────┬────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────┐
│ 1. Detect repository type               │
│    - Scan package.json, requirements.txt│
│    - Identify: frontend/backend/infra   │
└────────────────┬────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────┐
│ 2. Install dependencies                 │
│    - husky, chokidar, etc.              │
│    - npm/yarn/pnpm detected             │
└────────────────┬────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────┐
│ 3. Copy templates                       │
│    - Git hooks                          │
│    - Automation scripts                 │
│    - Default config                     │
└────────────────┬────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────┐
│ 4. Customize for repo type              │
│    - Adjust config values               │
│    - Set test/build commands            │
│    - Select relevant prompts            │
└────────────────┬────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────┐
│ 5. Initialize structure                 │
│    - Create design-docs/                │
│    - Set up .claude-prompts/            │
│    - Update .gitignore                  │
└────────────────┬────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────┐
│ 6. Run validation                       │
│    - Test git hooks                     │
│    - Verify Claude Code access          │
│    - Check permissions                  │
└────────────────┬────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────┐
│ 7. Print instructions                   │
│    - Next steps                         │
│    - Configuration tips                 │
│    - Links to docs                      │
└─────────────────────────────────────────┘
```

### Installer Script (`install.sh`)

**Key Functions**:

```bash
#!/bin/bash
# automation-installer/install.sh

# Detect repository type
detect_repo_type() {
  if [ -f "package.json" ]; then
    # Check for React, Next.js, etc.
    if grep -q "next" package.json; then
      echo "frontend"
    elif grep -q "express" package.json; then
      echo "backend"
    fi
  elif [ -f "main.tf" ]; then
    echo "infrastructure"
  else
    echo "unknown"
  fi
}

# Copy templates with substitution
install_templates() {
  REPO_NAME=$(basename $(git rev-parse --show-toplevel))
  REPO_TYPE=$1

  # Copy hooks
  cp -r ${TEMPLATES_DIR}/husky/ .husky/

  # Substitute variables in templates
  find .husky/ -type f -exec sed -i '' \
    "s/{{REPO_NAME}}/${REPO_NAME}/g" {} \;

  # Make hooks executable
  chmod +x .husky/*
}

# Merge configurations
merge_configs() {
  # Start with org defaults
  jq -s '.[0] * .[1]' \
    ${TEMPLATES_DIR}/configs/.claude-automation-config.json \
    .claude-automation-config.json \
    > .claude-automation-config.json.tmp

  mv .claude-automation-config.json.tmp .claude-automation-config.json
}

# Main installation
main() {
  echo "Installing InformUp Engineering Automation..."

  # 1. Detect repo type
  REPO_TYPE=$(detect_repo_type)
  echo "Detected repository type: ${REPO_TYPE}"

  # 2. Install dependencies
  npm install --save-dev husky@^8.0.0 chokidar@^3.5.0

  # 3. Copy templates
  install_templates ${REPO_TYPE}

  # 4. Create directories
  mkdir -p design-docs scripts/automation .claude-prompts

  # 5. Update package.json
  npm pkg set scripts.automation:start="node scripts/automation/claude-watcher.js"
  npm pkg set scripts.local-ci="node scripts/automation/local-ci.js"

  # 6. Run tests
  npm run automation:test

  echo "✅ Installation complete!"
  echo "See docs/GettingStarted.md for next steps."
}

main
```

---

## Configuration Cascade

### How Configuration Merges

```javascript
// Pseudo-code for config resolution

function loadConfig() {
  // 1. Load org defaults (lowest priority)
  const orgDefaults = loadFromGitHub('.github/automation-templates/configs/');

  // 2. Load repo config (medium priority)
  const repoConfig = loadFromFile('.claude-automation-config.json');

  // 3. Load developer config (highest priority)
  const devConfig = loadFromFile('~/.config/claude-automation/config.json');

  // 4. Merge with priority
  return deepMerge(orgDefaults, repoConfig, devConfig);
}

// Example merge:
// Org:  { triggers: { testGen: { enabled: true } } }
// Repo: { triggers: { testGen: { mode: "background" } } }
// Dev:  { triggers: { testGen: { enabled: false } } }
//
// Result: { triggers: { testGen: { enabled: false, mode: "background" } } }
```

### Configuration Precedence Rules

1. **Boolean flags**: Later value wins (dev > repo > org)
2. **Objects**: Deep merge (combine all properties)
3. **Arrays**: Later value replaces completely
4. **Strings**: Later value wins

### Environment-Specific Overrides

```bash
# Disable automation temporarily
export CLAUDE_AUTOMATION_ENABLED=false

# Use different Claude model
export CLAUDE_MODEL=claude-3-opus-20240229

# Verbose logging
export CLAUDE_AUTOMATION_DEBUG=true
```

---

## Automation Triggers

### Trigger Matrix

| Event | When | AI Task | Mode | Config Key |
|-------|------|---------|------|------------|
| **Branch Created** | `git checkout -b feature/*` | Generate feature plan template | Interactive | `triggers.featurePlanning` |
| **Design Doc Saved** | Design doc modified & staged | Architecture + Security + Cost review | Interactive | `triggers.designReview` |
| **New File Created** | New `.js/.ts` file in `src/` | Generate test file | Background | `triggers.testGeneration` |
| **File Saved** | Code file modified | Update inline docs | Background | `triggers.docGeneration` |
| **Pre-Commit** | Before commit completes | Quick code review + run tests | Blocking | `triggers.preCommitReview` |
| **Post-Commit** | After commit completes | Update changelog, API docs | Background | `triggers.postCommitDocs` |
| **Pre-Push** | Before push to remote | Full CI checks + PR prep | Blocking | `triggers.prePushChecks` |
| **Post-Push** | After push to remote | Update issue status | Background | `triggers.postPushUpdate` |
| **CI Failure** | GitHub Action fails | Analyze failure, suggest fix | On-demand | `triggers.ciFail ureAnalysis` |
| **Error Logged** | Error appears in logs | Triage and create issue | Scheduled | `triggers.errorMonitoring` |
| **Scheduled** | Every 4 hours | Review recent errors | Background | `monitoring.enabled` |

### Trigger Configuration

```json
{
  "triggers": {
    "featurePlanning": {
      "enabled": true,                    // Enable this trigger
      "branches": ["feature/*"],          // Which branches
      "mode": "interactive",              // How to run
      "timeout": 300000                   // 5 min timeout
    },
    "testGeneration": {
      "enabled": true,
      "filePattern": "src/**/*.{js,ts}",  // What files to watch
      "excludePattern": "**/*.test.*",    // Exclude patterns
      "mode": "background",               // Run without blocking
      "debounce": 2000                    // Wait 2s after last change
    },
    "preCommitReview": {
      "enabled": true,
      "quick": true,                      // Fast checks only
      "failOnIssues": false,              // Warn, don't block
      "mode": "blocking"                  // Must complete before commit
    }
  }
}
```

### Disabling Triggers

**Per-trigger**:
```json
{
  "triggers": {
    "testGeneration": {
      "enabled": false  // Disable test generation
    }
  }
}
```

**Globally**:
```json
{
  "enabled": false  // Disable all automation
}
```

**Environment variable**:
```bash
export CLAUDE_AUTOMATION_ENABLED=false
```

**Per-commit bypass**:
```bash
git commit --no-verify -m "Skip hooks"
```

---

## Prompt Management

### Centralized Prompts

Prompts live in `.github/automation-templates/prompts/`:

```markdown
# feature-planning.md

You are helping plan a feature for {{REPO_NAME}}, which is a {{REPO_TYPE}} application.

Tech stack: {{TECH_STACK}}
Feature name: {{FEATURE_NAME}}

Please help think through:
1. Requirements completeness
2. Edge cases
3. Security implications
4. Performance considerations
5. Testing strategy
...
```

### Accessing Prompts

**From automation scripts**:

```bash
# Option 1: Reference from .github repo (remote)
PROMPT_URL="https://raw.githubusercontent.com/INFORMUP/.github/main/automation-templates/prompts/feature-planning.md"
curl -sSL "$PROMPT_URL" | claude code --prompt-stdin

# Option 2: Local cache (faster)
PROMPT_DIR="$HOME/.informup-automation/prompts"
claude code --prompt-file "$PROMPT_DIR/feature-planning.md"
```

### Repository-Specific Overrides

Create `.claude-prompts/feature-planning.md` in your repo:

```markdown
# Custom Feature Planning for My Repo

[Your custom prompt here]
```

The system checks for overrides first:
```bash
# Prompt resolution order:
1. .claude-prompts/feature-planning.md    # Repo-specific
2. $HOME/.claude-prompts/feature-planning.md  # Developer personal
3. .github/automation-templates/prompts/feature-planning.md  # Org default
```

### Versioning Prompts

Prompts include version metadata:

```markdown
<!--
Prompt: feature-planning
Version: 1.2.0
Last Updated: 2024-01-15
-->

# Feature Planning Prompt
...
```

When updating, increment version and note changes in `.github/CHANGELOG.md`.

---

## Update Mechanism

### Checking for Updates

```bash
# Check current version
cat .claude-automation-config.json | jq '.version'

# Check latest version
curl -sSL https://raw.githubusercontent.com/INFORMUP/.github/main/automation-installer/VERSION
```

### Update Process

**Automated** (future):
```bash
npm run automation:update
```

**Manual** (current):

1. **Backup current state**:
   ```bash
   cp .claude-automation-config.json .claude-automation-config.json.backup
   cp -r .husky .husky.backup
   ```

2. **Fetch latest templates**:
   ```bash
   curl -sSL https://github.com/INFORMUP/.github/archive/main.zip -o automation-update.zip
   unzip automation-update.zip
   ```

3. **Smart merge**:
   ```bash
   # Update scripts (overwrite)
   cp -r .github-main/automation-templates/scripts/* scripts/automation/

   # Update prompts (overwrite, unless customized)
   # Don't overwrite .claude-prompts/ (user customizations)

   # Merge configs (preserve user changes)
   jq -s '.[0] * .[1]' \
     .github-main/automation-templates/configs/.claude-automation-config.json \
     .claude-automation-config.json.backup \
     > .claude-automation-config.json
   ```

4. **Test**:
   ```bash
   npm run automation:test
   ```

5. **Commit**:
   ```bash
   git add .
   git commit -m "chore: Update automation to v1.2.0"
   ```

### Breaking Changes

Updates that require manual intervention are documented:

```markdown
# CHANGELOG.md (in .github repo)

## [2.0.0] - 2024-02-01

### Breaking Changes

- Configuration schema changed: `triggers.testGeneration.pattern` → `triggers.testGeneration.filePattern`
- Manual migration required: run `npm run automation:migrate`

### Migration Guide

1. Backup config: `cp .claude-automation-config.json .claude-automation-config.json.backup`
2. Run migrator: `npm run automation:migrate --from=1.x --to=2.0`
3. Review changes: `diff .claude-automation-config.json.backup .claude-automation-config.json`
4. Test: `npm run automation:test`
```

---

## Repository Type Variations

Different repository types have different needs:

### Frontend Repositories

**Type**: `"repoType": "frontend"`

**Characteristics**:
- React, Next.js, Vue, Svelte, etc.
- Focus on component testing
- Build output optimization
- Accessibility checks

**Configuration**:
```json
{
  "repoType": "frontend",
  "testing": {
    "command": "npm test",
    "types": ["unit", "component", "e2e"],
    "coverageThreshold": 80
  },
  "build": {
    "command": "npm run build",
    "sizeLimitMB": 5
  },
  "triggers": {
    "componentTests": {
      "enabled": true,
      "library": "react-testing-library"
    },
    "a11yCheck": {
      "enabled": true
    }
  }
}
```

### Backend Repositories

**Type**: `"repoType": "backend"`

**Characteristics**:
- Node.js, Python, Go, etc.
- API endpoint testing
- Database migrations
- Security focus (auth, input validation)

**Configuration**:
```json
{
  "repoType": "backend",
  "testing": {
    "command": "npm test",
    "types": ["unit", "integration", "api"],
    "coverageThreshold": 85
  },
  "security": {
    "checks": ["npm audit", "snyk test"],
    "failOnHigh": true
  },
  "triggers": {
    "apiTests": {
      "enabled": true,
      "framework": "supertest"
    },
    "migrationCheck": {
      "enabled": true
    }
  }
}
```

### Infrastructure Repositories

**Type**: `"repoType": "infrastructure"`

**Characteristics**:
- Terraform, CloudFormation, K8s manifests
- Security config critical
- Cost analysis important
- Validation before apply

**Configuration**:
```json
{
  "repoType": "infrastructure",
  "testing": {
    "command": "terraform validate"
  },
  "security": {
    "checks": ["tfsec", "checkov"],
    "failOnHigh": true
  },
  "triggers": {
    "costAnalysis": {
      "enabled": true,
      "estimateTool": "infracost"
    },
    "securityScan": {
      "enabled": true,
      "blocking": true
    },
    "planReview": {
      "enabled": true,
      "mode": "interactive"
    }
  }
}
```

### Mobile Repositories

**Type**: `"repoType": "mobile"`

**Characteristics**:
- React Native, Flutter
- Platform-specific builds (iOS + Android)
- Simulator testing
- App store compliance

**Configuration**:
```json
{
  "repoType": "mobile",
  "testing": {
    "command": "npm test",
    "types": ["unit", "component", "e2e"],
    "platforms": ["ios", "android"]
  },
  "build": {
    "ios": "npm run ios:build",
    "android": "npm run android:build"
  },
  "triggers": {
    "platformTests": {
      "enabled": true,
      "runBoth": true
    }
  }
}
```

---

## Versioning Strategy

### Semantic Versioning

We use [SemVer](https://semver.org/): `MAJOR.MINOR.PATCH`

```
1.2.3
│ │ └─ Patch: Bug fixes, no breaking changes
│ └─── Minor: New features, backwards compatible
└───── Major: Breaking changes
```

### Version Tracking

**In `.github` repo**:
```bash
# automation-installer/VERSION
1.2.3
```

**In each installed repo**:
```json
// .claude-automation-config.json
{
  "version": "1.2.3",
  "source": "github.com/INFORMUP/.github",
  "installedAt": "2024-01-15T10:30:00Z",
  "lastUpdated": "2024-01-20T14:00:00Z"
}
```

### Compatibility Matrix

| Automation Version | Claude Code CLI Version | Node.js Version | Supported Repos |
|--------------------|-------------------------|-----------------|-----------------|
| 1.0.x | ≥0.5.0 | ≥18.0 | All |
| 1.1.x | ≥0.6.0 | ≥18.0 | All |
| 2.0.x | ≥1.0.0 | ≥20.0 | Frontend, Backend |

### Deprecation Policy

1. **Announce** deprecation 2 minor versions in advance
2. **Warn** in console logs when using deprecated features
3. **Remove** in next major version
4. **Provide** migration guide

Example:
```
v1.0: Feature introduced
v1.2: Feature marked deprecated (warning added)
v1.4: Warning becomes error in new installations
v2.0: Feature removed, must migrate
```

---

## Design Decisions

### Why Local-First?

**Decision**: Run automation on developer machines, not in the cloud.

**Rationale**:
- **Privacy**: Code stays under developer control
- **Speed**: No network latency
- **Cost**: Subscription pricing, not pay-per-use
- **Reliability**: Works offline for non-AI features
- **Developer Experience**: Immediate feedback

**Tradeoff**: Requires setup on each machine vs. zero-config cloud solution.

### Why Centralized Templates?

**Decision**: Store templates in `.github` repo, copy to individual repos.

**Rationale**:
- **Consistency**: Everyone uses same automation
- **Maintainability**: Fix bugs once, benefit everywhere
- **Versioning**: Track changes to automation over time
- **Flexibility**: Repos can still customize

**Tradeoff**: Updates require running update script vs. automatic updates.

### Why Three-Tier Config?

**Decision**: Org → Repo → Developer configuration cascade.

**Rationale**:
- **Standards**: Org sets baseline
- **Flexibility**: Teams customize for their needs
- **Autonomy**: Developers control their experience
- **Balance**: Central control + local freedom

**Tradeoff**: More complex config system vs. single config file.

### Why Git Hooks vs. IDE Plugin?

**Decision**: Use git hooks for automation triggers.

**Rationale**:
- **Universal**: Works with any IDE/editor
- **Reliable**: Always runs on git operations
- **Team-wide**: Can't be accidentally disabled
- **Scriptable**: Easy to customize

**Tradeoff**: Less integrated with IDE vs. seamless IDE experience.

### Why Husky?

**Decision**: Use Husky for git hook management.

**Rationale**:
- **Cross-platform**: Works on macOS, Linux, Windows
- **Well-maintained**: Active project, large community
- **npm-integrated**: Fits Node.js workflow
- **Simple**: Easy to install and configure

**Alternative considered**: Git hooks directly → harder to manage across team.

### Why Claude Code CLI?

**Decision**: Use Claude Code CLI instead of API.

**Rationale**:
- **Subscription pricing**: Predictable costs
- **Local execution**: Privacy and speed
- **Context management**: CLI handles conversation state
- **Simpler**: No API key management

**Tradeoff**: Requires Claude Pro subscription vs. pay-as-you-go API.

### Why File Watcher?

**Decision**: Run file watcher daemon for background automation.

**Rationale**:
- **Real-time**: Respond immediately to changes
- **Non-intrusive**: Works in background
- **Flexible**: Can debounce, filter, prioritize
- **Efficient**: Only processes changed files

**Tradeoff**: Additional process running vs. only on git events.

### Why Not a GitHub App?

**Decision**: Don't build this as a GitHub App (yet).

**Rationale**:
- **Local-first priority**: Feedback before pushing
- **Privacy**: Code doesn't leave local machine
- **Simplicity**: Fewer moving parts
- **Cost**: No server infrastructure needed

**Future consideration**: GitHub App for CI/CD integration may be added later.

---

## Security Considerations

### Secrets Management

- **Never commit** Claude API keys (uses CLI auth instead)
- **Environment variables** for sensitive config
- **`.gitignore`** automation logs (may contain code snippets)

### Code Privacy

- **Claude API**: Code sent to Anthropic API (see [privacy policy](https://www.anthropic.com/privacy))
- **Local processing**: Logs stay on developer machine
- **Opt-out**: Developers can disable AI features

### Supply Chain

- **Trusted sources**: Templates from official `.github` repo only
- **Version pinning**: Lock dependency versions in `package.json`
- **Audit**: Regular `npm audit` in installer scripts

---

## Performance Characteristics

### Resource Usage

| Component | CPU | Memory | Disk | Network |
|-----------|-----|--------|------|---------|
| File Watcher | <5% | <100MB | <1MB logs/day | 0 (local) |
| Git Hooks | <2% during commit | <50MB | N/A | 0 |
| Claude Code | Varies | 200-500MB | N/A | Per API call |

### Latency

| Operation | Typical Time |
|-----------|--------------|
| Pre-commit hooks | 5-15 seconds |
| Test generation | 10-30 seconds |
| Design review | 2-5 minutes (interactive) |
| PR description | 15-30 seconds |
| Local CI | 2-5 minutes |

### Scalability

- **Small repos** (<100 files): All automation works great
- **Medium repos** (100-1000 files): May want to disable file watcher
- **Large repos** (>1000 files): Selective automation, custom config

---

## Future Enhancements

### Planned Features (v1.x)

- [ ] Automated installer script
- [ ] Automated update mechanism
- [ ] VS Code extension for better integration
- [ ] Team dashboard showing automation metrics
- [ ] Caching layer for repeated AI queries

### Under Consideration (v2.x)

- [ ] GitHub App for PR checks
- [ ] Slack integration for notifications
- [ ] Multi-model support (Gemini, GPT-4)
- [ ] Web UI for configuration management
- [ ] Analytics and insights dashboard

### Community Requests

See [GitHub Issues](https://github.com/INFORMUP/.github/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement) for feature requests.

---

## Contributing

Want to improve the automation system?

1. **Report issues**: [Create an issue](https://github.com/INFORMUP/.github/issues/new)
2. **Suggest features**: Open a discussion
3. **Submit PRs**: Fork, branch, code, test, PR
4. **Improve docs**: PRs welcome for documentation

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

---

## References

- [Getting Started Guide](./GettingStarted.md)
- [Engineering Overview](./EngineeringOverview.md)
- [Implementation Guide](./EngineeringProcessImplementation.md)
- [Claude Code Docs](https://claude.com/docs)
- [Husky Documentation](https://typicode.github.io/husky/)

---

**Document Version**: 1.0
**Last Updated**: 2025-01-17
**Maintained By**: InformUp Engineering Team
