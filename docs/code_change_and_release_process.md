# Engineering Document: Modern Development Pipeline with Claude CLI Integration

## Table of Contents
- [Introduction: Building a Claude CLI-Powered Development Pipeline](#introduction-building-a-claude-cli-powered-development-pipeline)

**Part I: Getting Started**
- [1. Automated Development Environment](#1-automated-development-environment)
  - [1.1 Mac Setup Stack](#11-mac-setup-stack)
  - [1.2 Docker Compose](#12-docker-compose)
  - [1.3 VS Code Configuration](#13-vs-code-configuration)
  - [1.4 Dotfiles Management](#14-dotfiles-management)

**Part II: Planning & Design**
- [2. Feature Planning with Claude CLI](#2-feature-planning-with-claude-cli)
  - [2.1 Interactive Design Reviews](#21-interactive-design-reviews)
  - [2.2 Architecture Impact Analysis](#22-architecture-impact-analysis)
  - [2.3 Security Threat Modeling](#23-security-threat-modeling)
  - [2.4 Automated Background Tasks](#24-automated-background-tasks)

**Part III: Development Workflow**
- [3. AI-Powered Testing](#3-ai-powered-testing)
  - [3.1 Testing Philosophy](#31-testing-philosophy)
  - [3.2 Claude-Generated Test Coverage](#32-claude-generated-test-coverage)
  - [3.3 Vitest Configuration](#33-vitest-configuration)
  - [3.4 React Testing](#34-react-testing)
  - [3.5 E2E with Playwright](#35-e2e-with-playwright)
- [4. Code Quality Automation](#4-code-quality-automation)
  - [4.1 Git Hooks with Claude](#41-git-hooks-with-claude)
  - [4.2 Pre-commit Reviews](#42-pre-commit-reviews)
  - [4.3 Automated Documentation](#43-automated-documentation)

**Part IV: CI/CD Pipeline**
- [5. Local-First CI Strategy](#5-local-first-ci-strategy)
  - [5.1 Pre-push Validation](#51-pre-push-validation)
  - [5.2 PR Automation](#52-pr-automation)
  - [5.3 Branch Protection](#53-branch-protection)

**Part V: Deployment & Infrastructure**
- [6. Infrastructure Reviews](#6-infrastructure-reviews)
  - [6.1 IaC Validation](#61-iac-validation)
  - [6.2 Security Configuration](#62-security-configuration)
  - [6.3 Cost Optimization](#63-cost-optimization)
- [7. Deployment Strategies](#7-deployment-strategies)
  - [7.1 Environment Management](#71-environment-management)
  - [7.2 Release Patterns](#72-release-patterns)

**Part VI: Operations & Monitoring**
- [8. Production Observability](#8-production-observability)
  - [8.1 Log Analysis](#81-log-analysis)
  - [8.2 Incident Response](#82-incident-response)
- [9. Operational Excellence](#9-operational-excellence)
  - [9.1 Database Operations](#91-database-operations)
  - [9.2 Documentation Automation](#92-documentation-automation)
  - [9.3 Performance Reviews](#93-performance-reviews)

---

## Introduction: Building a Claude CLI-Powered Development Pipeline

**Goal**: Create a development pipeline where Claude CLI acts as your AI pair programmer at every stage - from design to deployment. This guide provides a complete blueprint for integrating Claude into your local development workflow.

**Key Principles**:
- **Local-first**: Every automation runs on your machine using Claude CLI
- **Interactive by default**: Design and security reviews use interactive mode for real-time collaboration
- **Background automation**: Tests and docs generate automatically without interrupting flow
- **Zero friction**: Claude integrates into your existing tools and workflows
- **Subscription-based**: Uses your Claude subscription, no per-token API costs

**Key Outcomes**:
- AI pair programming at every development stage
- Comprehensive test coverage generated automatically
- Security and architecture reviews before code reaches production
- Living documentation that updates with your code
- 80% reduction in manual review time

**Tech Stack**: Node.js, Express, React, PostgreSQL, Claude CLI, GitHub

**Philosophy**: Claude becomes part of your development team, not just a tool.

---

# Part I: Getting Started

## 1. Automated Development Environment

**Motivation**: A properly configured environment with Claude CLI integration accelerates development from day one.

### 1.1 Mac Setup Stack

```bash
# Install Claude CLI globally
npm install -g @claude-ai/claude-code

# Authenticate with your Claude account (one-time setup)
claude auth login

# Install other development tools
brew bundle install  # Uses Brewfile for consistency
```

**Essential Brewfile additions**:
```ruby
# Development essentials
brew "fnm"          # Fast Node.js version manager
brew "pnpm"         # Efficient package manager
brew "colima"       # Docker Desktop alternative
cask "visual-studio-code"
```

### 1.2 Docker Compose

```yaml
services:
  postgres:
    image: postgres:15-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  # Optional: Claude review service for team sharing
  claude-reviews:
    image: node:20-alpine
    volumes:
      - .:/app
      - ~/.claude:/root/.claude  # Share auth
    command: |
      sh -c "npm install -g @claude-ai/claude-code && 
             claude code watch --config /app/.claude-config.json"
```

### 1.3 VS Code Configuration

**Claude-optimized VS Code settings**:
```json
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "eslint.autoFixOnSave": true,
  
  // Claude integration
  "terminal.integrated.env.osx": {
    "CLAUDE_AUTO_REVIEW": "true"
  },
  "saveAndRun": {
    "commands": [
      {
        "match": "\\.(js|jsx|ts|tsx)$",
        "cmd": "claude code docs update --file ${file} --background",
        "isAsync": true,
        "silent": true
      }
    ]
  }
}
```

**VS Code Tasks for Claude**:
```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Claude: Design Review",
      "type": "shell",
      "command": "claude code review --interactive --context ${workspaceFolder}",
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "problemMatcher": []
    },
    {
      "label": "Claude: Generate Tests",
      "type": "shell",
      "command": "claude code test generate --file ${file}",
      "group": "test",
      "isBackground": true
    },
    {
      "label": "Claude: Update Documentation",
      "type": "shell",
      "command": "claude code docs update --file ${file} --background",
      "runOptions": {
        "runOn": "folderOpen"
      }
    },
    {
      "label": "Claude: Security Review",
      "type": "shell",
      "command": "claude code review --template security --interactive",
      "group": "build"
    },
    {
      "label": "Claude: Architecture Review",
      "type": "shell",
      "command": "claude code review --template architecture --context src/",
      "group": "build"
    }
  ]
}
```

**Keyboard Shortcuts**:
```json
// .vscode/keybindings.json
[
  {
    "key": "cmd+shift+r",
    "command": "workbench.action.tasks.runTask",
    "args": "Claude: Design Review"
  },
  {
    "key": "cmd+shift+t",
    "command": "workbench.action.tasks.runTask",
    "args": "Claude: Generate Tests"
  }
]
```

### 1.4 Dotfiles Management

**Shell integration for Claude**:
```bash
# ~/.zshrc or ~/.bashrc

# Claude CLI aliases
alias cr="claude code review"
alias cri="claude code review --interactive"
alias ct="claude code test generate"
alias cd="claude code docs"
alias cs="claude code review --template security"
alias ca="claude code review --template architecture"

# Auto-review function
function claude_auto_review() {
  if [[ -f ".claude-config.json" ]]; then
    claude code review --diff --quick
  fi
}

# Hook into cd command
function cd() {
  builtin cd "$@"
  claude_auto_review
}

# Project initialization with Claude
function init_claude_project() {
  cat > .claude-config.json << 'EOF'
{
  "defaultModes": {
    "design": "interactive",
    "architecture": "interactive",
    "security": "interactive",
    "tests": "background",
    "docs": "background"
  },
  "autoTriggers": {
    "onSave": ["docs"],
    "onCommit": ["tests"],
    "onPush": ["security"]
  }
}
EOF
  echo "✅ Claude configuration created"
}
```

---

# Part II: Planning & Design

## 2. Feature Planning with Claude CLI

**Motivation**: Claude acts as your senior architect, reviewing designs interactively and catching issues before implementation begins.

### 2.1 Interactive Design Reviews

**Starting a new feature**:
```bash
# Create RFC and get interactive feedback
cat > docs/rfcs/new-feature.md << 'EOF'
# RFC: User Authentication System
## Problem Statement
...
## Proposed Solution
...
EOF

# Interactive design session
claude code review --file docs/rfcs/new-feature.md --interactive

# Claude enters conversation mode:
# - Asks clarifying questions
# - Suggests edge cases
# - Recommends patterns
# - Identifies security concerns
```

**Design Review Workflow**:
```javascript
#!/usr/bin/env node
// scripts/design-review.js

const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const chalk = require('chalk');

class DesignReviewer {
  async reviewFeature(featurePath) {
    console.log(chalk.blue('🎨 Starting interactive design review...'));
    
    // Launch interactive Claude session
    const claude = spawn('claude', [
      'code', 'review',
      '--file', featurePath,
      '--interactive',
      '--instructions', `You are a senior architect reviewing a feature design.
        Focus on:
        1. Completeness of requirements
        2. Edge cases and error handling
        3. Security implications
        4. Performance considerations
        5. API design and contracts
        6. Database schema impacts
        7. Testing strategy
        
        Ask clarifying questions and suggest improvements.`
    ], {
      stdio: 'inherit',
      shell: true
    });
    
    return new Promise((resolve, reject) => {
      claude.on('close', (code) => {
        if (code === 0) {
          this.saveReviewNotes(featurePath);
          console.log(chalk.green('✅ Design review completed'));
          resolve();
        } else {
          reject(new Error(`Review failed with code ${code}`));
        }
      });
    });
  }
  
  saveReviewNotes(featurePath) {
    const reviewPath = featurePath.replace('.md', '-review.md');
    const timestamp = new Date().toISOString();
    
    // Append review metadata
    fs.appendFileSync(reviewPath, `
---
Review completed: ${timestamp}
Reviewer: Claude CLI
Status: Reviewed
---
    `);
  }
}

// Usage
if (require.main === module) {
  const reviewer = new DesignReviewer();
  const featurePath = process.argv[2] || 'docs/rfcs/current.md';
  reviewer.reviewFeature(featurePath).catch(console.error);
}
```

### 2.2 Architecture Impact Analysis

**Claude-powered architecture reviews**:
```bash
# Analyze architecture impact of changes
claude code review --template architecture \
  --context src/ \
  --context docs/architecture/ \
  --interactive

# Generate architecture decision records (ADRs)
claude code docs generate --template adr \
  --context "We need to choose between REST and GraphQL" \
  --output docs/adrs/001-api-design.md
```

**Automated Architecture Checks**:
```javascript
// scripts/architecture-check.js
const { execSync } = require('child_process');
const fs = require('fs');

class ArchitectureGuard {
  constructor() {
    this.rules = this.loadArchitectureRules();
  }
  
  loadArchitectureRules() {
    return {
      layers: {
        'src/controllers': ['src/services', 'src/models'],
        'src/services': ['src/models', 'src/utils'],
        'src/models': ['src/utils']
      },
      forbidden: {
        'src/models': ['express', 'http'],
        'src/utils': ['src/controllers', 'src/services']
      }
    };
  }
  
  async checkArchitecture() {
    console.log('🏗️ Running architecture conformance check...');
    
    // Use Claude to analyze architecture
    const analysis = execSync(
      `claude code review --template architecture \
        --context src/ \
        --instructions "Check for:
          1. Layering violations
          2. Circular dependencies
          3. God objects/modules
          4. Proper separation of concerns
          5. SOLID principle violations
          Output findings as JSON"`,
      { encoding: 'utf8' }
    );
    
    const findings = JSON.parse(analysis);
    
    if (findings.violations.length > 0) {
      console.log('❌ Architecture violations found:');
      findings.violations.forEach(v => {
        console.log(`  - ${v.type}: ${v.description}`);
        console.log(`    File: ${v.file}`);
        console.log(`    Suggestion: ${v.suggestion}`);
      });
      
      // Offer to start interactive session for complex issues
      if (findings.severity === 'high') {
        console.log('\n💡 Starting interactive session to discuss solutions...');
        execSync('claude code review --interactive --context src/', {
          stdio: 'inherit'
        });
      }
    } else {
      console.log('✅ Architecture check passed');
    }
    
    return findings;
  }
}
```

### 2.3 Security Threat Modeling

**Interactive security reviews**:
```bash
# STRIDE threat modeling session
claude code review --template security \
  --file src/auth/ \
  --interactive \
  --instructions "Perform STRIDE threat modeling:
    - Spoofing
    - Tampering
    - Repudiation
    - Information Disclosure
    - Denial of Service
    - Elevation of Privilege"

# OWASP Top 10 check
claude code review --template security \
  --context src/ \
  --instructions "Check for OWASP Top 10 vulnerabilities"
```

**Security Review Automation**:
```javascript
// scripts/security-review.js
const { execSync } = require('child_process');
const chalk = require('chalk');

class SecurityReviewer {
  async reviewSecurity(targetPath) {
    console.log(chalk.red('🔒 Starting security review...'));
    
    // Run comprehensive security analysis
    const stages = [
      {
        name: 'Authentication',
        command: 'claude code review --template security --file src/auth/ --quick'
      },
      {
        name: 'Authorization',
        command: 'claude code review --template security --file src/middleware/auth.js --quick'
      },
      {
        name: 'Input Validation',
        command: 'claude code review --template security --file src/validators/ --quick'
      },
      {
        name: 'SQL Injection',
        command: 'claude code review --template security --context src/ --instructions "Check for SQL injection vulnerabilities"'
      },
      {
        name: 'XSS Prevention',
        command: 'claude code review --template security --file src/views/ --instructions "Check for XSS vulnerabilities"'
      }
    ];
    
    const findings = [];
    
    for (const stage of stages) {
      console.log(`\n📋 Checking ${stage.name}...`);
      try {
        const result = execSync(stage.command, { encoding: 'utf8' });
        
        if (result.includes('CRITICAL') || result.includes('HIGH')) {
          findings.push({
            stage: stage.name,
            severity: 'critical',
            details: result
          });
          console.log(chalk.red(`❌ Critical issues found in ${stage.name}`));
        } else {
          console.log(chalk.green(`✅ ${stage.name} passed`));
        }
      } catch (error) {
        console.error(chalk.red(`Error checking ${stage.name}: ${error.message}`));
      }
    }
    
    // If critical issues found, start interactive session
    if (findings.some(f => f.severity === 'critical')) {
      console.log(chalk.yellow('\n⚠️ Critical security issues detected'));
      console.log('Starting interactive security review session...\n');
      
      execSync('claude code review --template security --interactive --context src/', {
        stdio: 'inherit'
      });
    }
    
    return findings;
  }
}
```

### 2.4 Automated Background Tasks

**Configure background automation**:
```javascript
// scripts/claude-automation.js
const { execSync, spawn } = require('child_process');
const fs = require('fs');
const chokidar = require('chokidar');
const chalk = require('chalk');

class ClaudeAutomation {
  constructor() {
    this.config = this.loadConfig();
  }
  
  loadConfig() {
    const configPath = '.claude-config.json';
    const defaults = {
      defaultModes: {
        design: 'interactive',
        architecture: 'interactive',
        security: 'interactive',
        tests: 'background',
        docs: 'background'
      },
      autoTriggers: {
        onSave: ['docs'],
        onCommit: ['tests'],
        onPush': ['security']
      }
    };
    
    if (fs.existsSync(configPath)) {
      return { ...defaults, ...JSON.parse(fs.readFileSync(configPath, 'utf8')) };
    }
    return defaults;
  }
  
  startWatchers() {
    console.log(chalk.blue('👀 Starting Claude file watchers...'));
    
    const watcher = chokidar.watch('src/**/*.{js,jsx,ts,tsx}', {
      ignored: /(^|[\/\\])\../,
      persistent: true
    });
    
    // Debounce to avoid multiple triggers
    const debounce = (func, wait) => {
      let timeout;
      return (...args) => {
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(this, args), wait);
      };
    };
    
    watcher.on('change', debounce(async (filepath) => {
      console.log(chalk.gray(`File changed: ${filepath}`));
      
      // Auto-generate/update documentation
      if (this.config.autoTriggers.onSave.includes('docs')) {
        this.runBackground('docs', filepath);
      }
      
      // Auto-generate tests for new files
      if (!fs.existsSync(filepath.replace('.js', '.test.js'))) {
        this.runBackground('tests', filepath);
      }
    }, 2000));
    
    console.log(chalk.green('✅ Watchers active'));
  }
  
  runBackground(type, filepath) {
    console.log(chalk.gray(`⚙️ Running ${type} generation in background...`));
    
    let command;
    switch (type) {
      case 'tests':
        command = `claude code test generate --file ${filepath} --output ${filepath.replace('.js', '.test.js')}`;
        break;
      case 'docs':
        command = `claude code docs update --file ${filepath} --background`;
        break;
      default:
        return;
    }
    
    // Run in background without blocking
    spawn('sh', ['-c', command], {
      detached: true,
      stdio: 'ignore'
    }).unref();
    
    console.log(chalk.gray(`✅ ${type} generation started`));
  }
}

// Start watchers
if (require.main === module) {
  const automation = new ClaudeAutomation();
  automation.startWatchers();
}
```

---

# Part III: Development Workflow

## 3. AI-Powered Testing

**Motivation**: Claude generates comprehensive tests that match your coding style and catch edge cases humans might miss.

### 3.1 Testing Philosophy

- **Testing Trophy**: Focus on integration tests (best ROI)
- **Coverage Target**: 80% as baseline, 100% for critical paths
- **Claude Generation**: Tests written in your project's style

### 3.2 Claude-Generated Test Coverage

**Generate tests for a single file**:
```bash
# Generate comprehensive tests
claude code test generate --file src/services/userService.js

# Generate with specific testing library
claude code test generate --file src/components/Button.jsx \
  --style "React Testing Library"

# Generate E2E tests from user stories
claude code test generate --file docs/user-stories.md \
  --template e2e \
  --output tests/e2e/
```

**Batch test generation**:
```javascript
// scripts/generate-all-tests.js
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const glob = require('glob');
const chalk = require('chalk');

class TestGenerator {
  async generateMissingTests() {
    const files = glob.sync('src/**/*.{js,jsx}', {
      ignore: ['**/*.test.js', '**/*.spec.js']
    });
    
    let generated = 0;
    
    for (const file of files) {
      const testFile = file.replace(/\.jsx?$/, '.test.js');
      
      if (!fs.existsSync(testFile)) {
        console.log(chalk.yellow(`📝 Generating tests for ${file}...`));
        
        try {
          execSync(
            `claude code test generate --file ${file} --output ${testFile}`,
            { stdio: 'pipe' }
          );
          generated++;
          console.log(chalk.green(`✅ Created ${testFile}`));
        } catch (error) {
          console.error(chalk.red(`❌ Failed to generate tests for ${file}`));
        }
      }
    }
    
    console.log(chalk.blue(`\n📊 Generated ${generated} test files`));
    
    // Run coverage check
    console.log(chalk.blue('\n📊 Running coverage analysis...'));
    execSync('npm test -- --coverage', { stdio: 'inherit' });
  }
  
  async improveTestCoverage(threshold = 80) {
    console.log(chalk.blue(`🎯 Improving test coverage to ${threshold}%...`));
    
    // Get coverage report
    const coverage = JSON.parse(
      fs.readFileSync('coverage/coverage-summary.json', 'utf8')
    );
    
    // Find files below threshold
    const lowCoverage = Object.entries(coverage)
      .filter(([file, data]) => data.lines.pct < threshold)
      .map(([file, data]) => ({
        file,
        coverage: data.lines.pct,
        uncovered: data.lines.uncovered
      }));
    
    for (const item of lowCoverage) {
      console.log(chalk.yellow(
        `\n📝 Improving coverage for ${item.file} (current: ${item.coverage}%)`
      ));
      
      // Use Claude to analyze uncovered lines and generate tests
      execSync(
        `claude code test improve --file ${item.file} \
          --coverage-report coverage/lcov.info \
          --target ${threshold}`,
        { stdio: 'inherit' }
      );
    }
  }
}

if (require.main === module) {
  const generator = new TestGenerator();
  generator.generateMissingTests()
    .then(() => generator.improveTestCoverage())
    .catch(console.error);
}
```

### 3.3 Vitest Configuration

```javascript
// vitest.config.js
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './tests/setup.js',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html', 'lcov'],
      thresholds: {
        statements: 80,
        branches: 80,
        functions: 80,
        lines: 80
      }
    },
    pool: 'threads',
    fileParallelism: true,
    // Custom reporter that triggers Claude on failures
    reporters: ['default', './tests/claude-reporter.js']
  }
});
```

**Claude test failure analyzer**:
```javascript
// tests/claude-reporter.js
export default class ClaudeReporter {
  onTestFailed(test, errors) {
    // Analyze test failure with Claude
    const analysis = execSync(
      `claude code analyze --failure "${errors[0].message}" \
        --file ${test.file} \
        --context ${test.code}`,
      { encoding: 'utf8' }
    );
    
    console.log('🤖 Claude Analysis:', analysis);
  }
}
```

### 3.4 React Testing

**Component test generation**:
```bash
# Generate React Testing Library tests
claude code test generate --file src/components/UserProfile.jsx \
  --template react \
  --instructions "Test all user interactions, accessibility, and edge cases"
```

### 3.5 E2E with Playwright

**Generate E2E tests from user stories**:
```bash
# Convert user stories to E2E tests
claude code test generate --file docs/user-stories/authentication.md \
  --template playwright \
  --output tests/e2e/authentication.spec.js
```

---

## 4. Code Quality Automation

**Motivation**: Claude reviews every change before it's committed, maintaining high code quality without slowing down development.

### 4.1 Git Hooks with Claude

**Install comprehensive git hooks**:
```bash
#!/bin/bash
# scripts/install-hooks.sh

# Initialize husky
npx husky-init && npm install

# Pre-commit: Format and quick review
cat > .husky/pre-commit << 'EOF'
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

# Format staged files
npx lint-staged

# Quick Claude review of staged changes
claude code review --diff --quick --staged || {
  echo "⚠️ Claude found issues. Fix them or use --no-verify to skip"
  exit 1
}
EOF

# Pre-push: Comprehensive review
cat > .husky/pre-push << 'EOF'
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

# Check for security issues
claude code review --diff --template security --quick || {
  echo "🔒 Security issues detected. Review required."
  claude code review --diff --template security --interactive
  exit 1
}

# Architecture conformance
claude code review --diff --template architecture --quick || {
  echo "🏗️ Architecture issues detected"
  exit 1
}
EOF

# Commit-msg: Enhance commit messages
cat > .husky/commit-msg << 'EOF'
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

# Enhance commit message with Claude
original_msg=$(cat $1)
enhanced_msg=$(claude code enhance-commit --message "$original_msg")
echo "$enhanced_msg" > $1
EOF

chmod +x .husky/*
echo "✅ Git hooks installed"
```

### 4.2 Pre-commit Reviews

**Lint-staged configuration with Claude**:
```json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "prettier --write",
      "eslint --fix --max-warnings=0",
      "claude code review --file"
    ],
    "*.test.{js,jsx,ts,tsx}": [
      "claude code test review --file"
    ],
    "*.md": [
      "claude code docs review --file"
    ]
  }
}
```

### 4.3 Automated Documentation

**Documentation generation workflow**:
```javascript
// scripts/doc-generator.js
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const chalk = require('chalk');

class DocGenerator {
  async generateProjectDocs() {
    console.log(chalk.blue('📚 Generating project documentation...'));
    
    const tasks = [
      {
        name: 'README',
        command: 'claude code docs generate --template readme --context . --output README.md'
      },
      {
        name: 'API Documentation',
        command: 'claude code docs generate --template api --context src/api/ --output docs/API.md'
      },
      {
        name: 'Architecture Guide',
        command: 'claude code docs generate --template architecture --context src/ --output docs/ARCHITECTURE.md'
      },
      {
        name: 'Contributing Guide',
        command: 'claude code docs generate --template contributing --output CONTRIBUTING.md'
      },
      {
        name: 'Component Library',
        command: 'claude code docs generate --template components --context src/components/ --output docs/COMPONENTS.md'
      }
    ];
    
    for (const task of tasks) {
      console.log(chalk.yellow(`📝 Generating ${task.name}...`));
      try {
        execSync(task.command, { stdio: 'pipe' });
        console.log(chalk.green(`✅ ${task.name} generated`));
      } catch (error) {
        console.error(chalk.red(`❌ Failed to generate ${task.name}`));
      }
    }
  }
  
  async updateDocsOnChange(filepath) {
    // Determine which docs need updating
    const updates = [];
    
    if (filepath.includes('api/')) {
      updates.push('claude code docs update --file docs/API.md --context ' + filepath);
    }
    
    if (filepath.includes('components/')) {
      updates.push('claude code docs update --file docs/COMPONENTS.md --context ' + filepath);
    }
    
    // Always update README for public API changes
    if (filepath.includes('index.js') || filepath.includes('public')) {
      updates.push('claude code docs update --file README.md --context ' + filepath);
    }
    
    // Run updates in background
    updates.forEach(cmd => {
      spawn('sh', ['-c', cmd], {
        detached: true,
        stdio: 'ignore'
      }).unref();
    });
  }
}
```

---

# Part IV: CI/CD Pipeline

## 5. Local-First CI Strategy

**Motivation**: Run the same validations locally that will run in CI, catching issues before they reach the pipeline.

### 5.1 Pre-push Validation

**Local CI script that mirrors GitHub Actions**:
```javascript
#!/usr/bin/env node
// scripts/local-ci.js

const { execSync } = require('child_process');
const chalk = require('chalk');

class LocalCI {
  constructor() {
    this.checks = [
      { name: 'Linting', command: 'npm run lint' },
      { name: 'Type Checking', command: 'npm run type-check' },
      { name: 'Unit Tests', command: 'npm test' },
      { name: 'Claude Security Review', command: 'claude code review --diff --template security --quick' },
      { name: 'Claude Architecture Review', command: 'claude code review --diff --template architecture --quick' },
      { name: 'Build', command: 'npm run build' }
    ];
  }
  
  async runAllChecks() {
    console.log(chalk.blue('🚀 Running local CI checks...\n'));
    
    const results = [];
    
    for (const check of this.checks) {
      process.stdout.write(chalk.yellow(`⏳ ${check.name}...`));
      
      try {
        execSync(check.command, { stdio: 'pipe' });
        console.log(chalk.green(' ✅'));
        results.push({ check: check.name, passed: true });
      } catch (error) {
        console.log(chalk.red(' ❌'));
        results.push({ check: check.name, passed: false, error: error.message });
        
        // Offer Claude help for failures
        if (check.name.includes('Claude')) {
          console.log(chalk.yellow('\n💡 Starting interactive session to resolve issues...\n'));
          execSync('claude code review --interactive --diff', { stdio: 'inherit' });
        }
      }
    }
    
    // Summary
    const passed = results.filter(r => r.passed).length;
    const failed = results.filter(r => !r.passed).length;
    
    console.log(chalk.blue('\n📊 Summary:'));
    console.log(chalk.green(`  ✅ Passed: ${passed}`));
    if (failed > 0) {
      console.log(chalk.red(`  ❌ Failed: ${failed}`));
      process.exit(1);
    }
    
    console.log(chalk.green('\n🎉 All checks passed! Ready to push.'));
  }
}

if (require.main === module) {
  const ci = new LocalCI();
  ci.runAllChecks().catch(error => {
    console.error(chalk.red('CI failed:', error.message));
    process.exit(1);
  });
}
```

### 5.2 PR Automation

**Create PRs with Claude-generated descriptions**:
```javascript
#!/usr/bin/env node
// scripts/create-pr.js

const { execSync } = require('child_process');
const chalk = require('chalk');

class PRCreator {
  async createPR(options = {}) {
    console.log(chalk.blue('📝 Creating pull request...'));
    
    // Generate PR description with Claude
    const description = execSync(
      'claude code review --diff origin/main...HEAD --template pr-description',
      { encoding: 'utf8' }
    );
    
    // Generate PR title
    const title = execSync(
      'claude code review --diff origin/main...HEAD --template pr-title',
      { encoding: 'utf8' }
    ).trim();
    
    // Run comprehensive local checks
    if (!options.skipChecks) {
      console.log(chalk.blue('\n🔍 Running pre-PR validations...'));
      execSync('npm run local-ci', { stdio: 'inherit' });
    }
    
    // Create PR using GitHub CLI
    const prUrl = execSync(
      `gh pr create --title "${title}" --body "${description}"`,
      { encoding: 'utf8' }
    ).trim();
    
    console.log(chalk.green(`\n✅ PR created: ${prUrl}`));
    
    // Optional: Run additional Claude reviews and post as comments
    if (options.comprehensive) {
      console.log(chalk.blue('\n🤖 Running comprehensive Claude reviews...'));
      
      const prNumber = prUrl.match(/\/(\d+)$/)[1];
      
      // Post architecture review
      const archReview = execSync(
        'claude code review --diff origin/main...HEAD --template architecture',
        { encoding: 'utf8' }
      );
      execSync(`gh pr comment ${prNumber} --body "${archReview}"`);
      
      // Post security review
      const secReview = execSync(
        'claude code review --diff origin/main...HEAD --template security',
        { encoding: 'utf8' }
      );
      execSync(`gh pr comment ${prNumber} --body "${secReview}"`);
      
      console.log(chalk.green('✅ Reviews posted to PR'));
    }
    
    return prUrl;
  }
}

if (require.main === module) {
  const creator = new PRCreator();
  creator.createPR({
    comprehensive: process.argv.includes('--comprehensive'),
    skipChecks: process.argv.includes('--skip-checks')
  }).catch(console.error);
}
```

### 5.3 Branch Protection

**Pre-merge validation script**:
```javascript
// scripts/pre-merge.js
const { execSync } = require('child_process');
const chalk = require('chalk');

class PreMergeValidator {
  async validate(targetBranch = 'main') {
    console.log(chalk.blue(`🔍 Validating merge to ${targetBranch}...`));
    
    const validations = [
      {
        name: 'Breaking Changes',
        command: `claude code review --diff origin/${targetBranch}...HEAD --check breaking-changes`
      },
      {
        name: 'Migration Required',
        command: `claude code review --diff origin/${targetBranch}...HEAD --check migrations`
      },
      {
        name: 'Documentation Updated',
        command: `claude code review --diff origin/${targetBranch}...HEAD --check docs-updated`
      },
      {
        name: 'Test Coverage',
        command: 'npm test -- --coverage --coverageThreshold=\'{"global":{"lines":80}}\''
      }
    ];
    
    for (const validation of validations) {
      console.log(chalk.yellow(`Checking ${validation.name}...`));
      
      try {
        const result = execSync(validation.command, { encoding: 'utf8' });
        console.log(chalk.green(`✅ ${validation.name} passed`));
      } catch (error) {
        console.log(chalk.red(`❌ ${validation.name} failed`));
        
        // Start interactive session for critical failures
        if (validation.name === 'Breaking Changes') {
          console.log(chalk.yellow('\n⚠️ Breaking changes detected. Starting migration guide generation...'));
          execSync(
            'claude code docs generate --template migration-guide --diff origin/main...HEAD --interactive',
            { stdio: 'inherit' }
          );
        }
        
        throw error;
      }
    }
    
    console.log(chalk.green('\n✅ All pre-merge validations passed'));
  }
}
```

---

# Part V: Deployment & Infrastructure

## 6. Infrastructure Reviews

**Motivation**: Infrastructure as Code needs the same review rigor as application code. Claude reviews IaC for security and best practices.

### 6.1 IaC Validation

**Review Terraform/CDK changes**:
```bash
# Review Terraform changes
claude code review --file terraform/ --template infrastructure

# Review AWS CDK
claude code review --file lib/stacks/ --template cdk

# Check for security misconfigurations
claude code review --file terraform/ --template security \
  --instructions "Check for:
    - Public S3 buckets
    - Open security groups
    - Unencrypted storage
    - Missing IAM least privilege
    - Exposed secrets"
```

### 6.2 Security Configuration

**Infrastructure security scanner**:
```javascript
// scripts/infra-security.js
const { execSync } = require('child_process');
const chalk = require('chalk');

class InfraSecurityScanner {
  async scan() {
    console.log(chalk.blue('🔒 Scanning infrastructure for security issues...'));
    
    const scans = [
      {
        name: 'AWS Security Groups',
        command: 'claude code review --file terraform/security_groups.tf --template security'
      },
      {
        name: 'IAM Policies',
        command: 'claude code review --file terraform/iam.tf --check least-privilege'
      },
      {
        name: 'S3 Buckets',
        command: 'claude code review --file terraform/s3.tf --check public-access'
      },
      {
        name: 'RDS Configuration',
        command: 'claude code review --file terraform/rds.tf --check encryption'
      },
      {
        name: 'Secrets Management',
        command: 'claude code review --file terraform/ --check hardcoded-secrets'
      }
    ];
    
    const issues = [];
    
    for (const scan of scans) {
      console.log(chalk.yellow(`\nScanning ${scan.name}...`));
      
      try {
        const result = execSync(scan.command, { encoding: 'utf8' });
        
        if (result.includes('CRITICAL') || result.includes('HIGH')) {
          issues.push({
            area: scan.name,
            severity: 'high',
            details: result
          });
          console.log(chalk.red(`❌ Issues found in ${scan.name}`));
        } else {
          console.log(chalk.green(`✅ ${scan.name} secure`));
        }
      } catch (error) {
        console.error(chalk.red(`Failed to scan ${scan.name}`));
      }
    }
    
    if (issues.length > 0) {
      console.log(chalk.red('\n⚠️ Security issues found in infrastructure'));
      console.log(chalk.yellow('Starting interactive remediation session...\n'));
      
      execSync('claude code review --file terraform/ --template security --interactive', {
        stdio: 'inherit'
      });
    }
    
    return issues;
  }
}
```

### 6.3 Cost Optimization

**Review infrastructure for cost optimization**:
```bash
# Analyze for cost optimization opportunities
claude code review --file terraform/ --template cost-optimization \
  --instructions "Identify:
    - Oversized instances
    - Unused resources
    - Missing auto-scaling
    - Expensive storage tiers
    - NAT gateway alternatives
    - Spot instance opportunities"
```

## 7. Deployment Strategies

### 7.1 Environment Management

**Environment configuration validator**:
```javascript
// scripts/validate-env.js
const { execSync } = require('child_process');
const chalk = require('chalk');

class EnvValidator {
  async validateEnvironment(env) {
    console.log(chalk.blue(`🔍 Validating ${env} environment configuration...`));
    
    // Use Claude to check environment configs
    const validation = execSync(
      `claude code review --file config/${env}.json \
        --template environment-config \
        --instructions "Check for:
          - Missing required variables
          - Hardcoded secrets
          - Incorrect service endpoints
          - Database connection strings
          - API keys and tokens"`,
      { encoding: 'utf8' }
    );
    
    console.log(validation);
    
    // Interactive fix for issues
    if (validation.includes('ISSUE') || validation.includes('WARNING')) {
      console.log(chalk.yellow('\nStarting interactive configuration session...'));
      execSync(`claude code review --file config/${env}.json --interactive`, {
        stdio: 'inherit'
      });
    }
  }
}
```

### 7.2 Release Patterns

**Deployment safety checks**:
```bash
# Pre-deployment validation
claude code review --diff main...release --template deployment-safety \
  --instructions "Check for:
    - Database migrations required
    - Breaking API changes
    - Feature flag requirements
    - Rollback procedures
    - Performance impact"

# Generate deployment runbook
claude code docs generate --template deployment-runbook \
  --context "Release version 2.0.0 with database migrations" \
  --output docs/deployments/v2.0.0-runbook.md
```

---

# Part VI: Operations & Monitoring

## 8. Production Observability

### 8.1 Log Analysis

**Claude-powered log analysis**:
```javascript
// scripts/analyze-logs.js
const { execSync } = require('child_process');
const chalk = require('chalk');

class LogAnalyzer {
  async analyzeLogs(logFile, timeRange = '1h') {
    console.log(chalk.blue('📊 Analyzing logs with Claude...'));
    
    // Extract relevant logs
    const logs = execSync(
      `grep -E 'ERROR|WARN|CRITICAL' ${logFile} | tail -n 1000`,
      { encoding: 'utf8' }
    );
    
    // Analyze with Claude
    const analysis = execSync(
      `echo "${logs}" | claude code analyze --template logs \
        --instructions "Identify:
          - Error patterns
          - Root causes
          - Affected services
          - User impact
          - Recommended fixes"`,
      { encoding: 'utf8' }
    );
    
    console.log(analysis);
    
    // If critical issues, start interactive debugging
    if (analysis.includes('CRITICAL')) {
      console.log(chalk.red('\n⚠️ Critical issues detected'));
      console.log(chalk.yellow('Starting interactive debugging session...\n'));
      
      execSync('claude code debug --interactive --context logs/', {
        stdio: 'inherit'
      });
    }
    
    return analysis;
  }
}
```

### 8.2 Incident Response

**Incident analysis helper**:
```bash
# Analyze incident for root cause
claude code analyze --template incident \
  --file logs/error.log \
  --context "Service returned 500 errors starting at 14:30 UTC" \
  --interactive

# Generate post-mortem
claude code docs generate --template post-mortem \
  --context "Database connection pool exhaustion caused 30-minute outage" \
  --output docs/post-mortems/2024-01-incident.md
```

## 9. Operational Excellence

### 9.1 Database Operations

**Database migration reviews**:
```bash
# Review Prisma migrations
claude code review --file prisma/migrations/ --template database \
  --instructions "Check for:
    - Backward compatibility
    - Index requirements
    - Performance impact
    - Data integrity"

# Generate migration testing plan
claude code test generate --file prisma/migrations/20240101_add_user_status \
  --template migration-test
```

### 9.2 Documentation Automation

**Continuous documentation updates**:
```javascript
// scripts/update-docs.js
const { execSync } = require('child_process');
const cron = require('node-cron');
const chalk = require('chalk');

class DocUpdater {
  constructor() {
    // Schedule daily documentation updates
    cron.schedule('0 2 * * *', () => {
      this.updateAllDocs();
    });
  }
  
  async updateAllDocs() {
    console.log(chalk.blue('📚 Updating documentation...'));
    
    const updates = [
      'claude code docs update --file README.md',
      'claude code docs update --file docs/API.md --context src/api/',
      'claude code docs generate --template changelog --output CHANGELOG.md',
      'claude code docs update --file docs/ARCHITECTURE.md --context src/'
    ];
    
    for (const update of updates) {
      try {
        execSync(update, { stdio: 'pipe' });
        console.log(chalk.green(`✅ ${update.split('--file')[1]?.split(' ')[1] || 'Doc'} updated`));
      } catch (error) {
        console.error(chalk.red(`Failed: ${error.message}`));
      }
    }
    
    // Commit updates if changes exist
    try {
      execSync('git add -A docs/ README.md CHANGELOG.md');
      execSync('git commit -m "docs: automated documentation update"');
      console.log(chalk.green('✅ Documentation updates committed'));
    } catch {
      console.log(chalk.gray('No documentation changes'));
    }
  }
}
```

### 9.3 Performance Reviews

**Performance analysis with Claude**:
```bash
# Analyze performance metrics
claude code analyze --template performance \
  --file metrics/performance.json \
  --instructions "Identify:
    - Performance regressions
    - Bottlenecks
    - Optimization opportunities
    - Caching improvements"

# Generate performance optimization plan
claude code docs generate --template performance-optimization \
  --context "API response times increased by 30%" \
  --interactive
```

---

## Summary

This guide demonstrates how Claude CLI transforms every aspect of the development lifecycle:

1. **Design Phase**: Interactive reviews catch issues before code is written
2. **Development**: Automatic test and documentation generation
3. **Quality Assurance**: Pre-commit and pre-push reviews maintain standards
4. **Deployment**: Infrastructure reviews and deployment safety checks
5. **Operations**: Log analysis and incident response assistance

**Key Benefits**:
- No API costs - uses your Claude subscription
- Interactive mode for complex discussions
- Background mode for automatic generation
- Integrates with existing tools and workflows
- Learns your codebase and style over time

**Getting Started**:
```bash
# Install Claude CLI
npm install -g @claude-ai/claude-code

# Authenticate
claude auth login

# Initialize project
claude init

# Start developing with AI assistance
claude code watch
```

The future of development is AI-assisted at every step, and Claude CLI makes that future available today.
