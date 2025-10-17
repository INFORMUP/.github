#!/usr/bin/env node
/**
 * Feature Planning - Interactive feature planning with AI
 * Part of InformUp Engineering Automation System
 * Version: 1.0.0
 *
 * Guides developers through feature planning process
 */

const {execSync, spawn} = require('child_process');
const fs = require('fs');
const path = require('path');

class FeaturePlanning {
  constructor() {
    this.featureName = process.argv[2];
    this.interactive = process.argv.includes('--interactive');

    if (!this.featureName) {
      console.error('Usage: node feature-planning.js <feature-name> [--interactive]');
      process.exit(1);
    }
  }

  /**
   * Run feature planning
   */
  async run() {
    console.log(`\n🎨 Feature Planning: ${this.featureName}\n`);

    // Create design docs directory
    const designDocsDir = 'design-docs';
    if (!fs.existsSync(designDocsDir)) {
      fs.mkdirSync(designDocsDir, {recursive: true});
    }

    // Design doc path
    const designDocPath = path.join(designDocsDir, `${this.featureName}.md`);

    // Check if already exists
    if (fs.existsSync(designDocPath)) {
      console.log(`Design doc already exists: ${designDocPath}`);
      console.log('Opening for editing...\n');

      // Open in editor
      this.openInEditor(designDocPath);
      return;
    }

    // Create template
    const template = this.createTemplate();
    fs.writeFileSync(designDocPath, template);

    console.log(`✅ Created design doc template: ${designDocPath}\n`);

    // Interactive mode with Claude
    if (this.interactive && this.isClaudeAvailable()) {
      console.log('🤖 Starting interactive planning session with Claude...\n');
      await this.runInteractiveSession(designDocPath);
    } else {
      console.log('Next steps:');
      console.log(`  1. Edit design doc: code ${designDocPath}`);
      console.log(`  2. Get AI review: claude code review --file ${designDocPath}`);
      console.log('  3. Start implementing!\n');

      // Open in editor
      this.openInEditor(designDocPath);
    }
  }

  /**
   * Create design doc template
   */
  createTemplate() {
    const author = this.getGitConfig('user.name') || '[Your Name]';
    const date = new Date().toISOString().split('T')[0];
    const branch = this.getCurrentBranch();

    return `# Feature Plan: ${this.featureName}

**Author**: ${author}
**Date**: ${date}
**Status**: Draft
**Branch**: ${branch}

## 1. Problem Statement

What problem are we solving? Who is affected?

[Describe the problem this feature addresses]

## 2. Proposed Solution

### 2.1 User Experience

Describe how users will interact with this feature.

[Add user flow, mockups, or wireframes if applicable]

### 2.2 Technical Approach

**Components/Services**:
- Component 1: [Description]
- Component 2: [Description]

**Data Models**:
\`\`\`typescript
// Example data model
interface FeatureData {
  // Add fields
}
\`\`\`

**API Endpoints**:
- \`GET /api/feature\` - [Description]
- \`POST /api/feature\` - [Description]

### 2.3 Dependencies

- External services: [List any external APIs or services]
- New libraries: [List any new dependencies to add]
- Other features: [List related features or systems]

## 3. Implementation Plan

### Phase 1: Foundation
- [ ] Set up data models
- [ ] Create API endpoints
- [ ] Write initial tests

### Phase 2: Core Features
- [ ] Implement main functionality
- [ ] Add validation
- [ ] Handle error cases

### Phase 3: Polish
- [ ] Add UI components
- [ ] Improve error messages
- [ ] Optimize performance

## 4. Testing Strategy

**Unit Tests**:
- Test data model validations
- Test business logic
- Test edge cases

**Integration Tests**:
- Test API endpoints
- Test database operations
- Test external service integrations

**E2E Tests**:
- Test complete user flows
- Test error scenarios

**Manual Testing Checklist**:
- [ ] Happy path works
- [ ] Error handling works
- [ ] Edge cases handled
- [ ] Performance acceptable

## 5. Rollout Plan

**Deployment Strategy**:
- [ ] Deploy to staging first
- [ ] Run smoke tests
- [ ] Monitor for errors
- [ ] Deploy to production

**Feature Flags** (if needed):
\`\`\`javascript
// Example feature flag usage
if (featureFlags.${this.featureName.toUpperCase()}) {
  // New feature code
}
\`\`\`

**Rollback Plan**:
- How to rollback if issues occur
- What data needs to be preserved
- Who to notify

## 6. Success Metrics

How will we know this feature is successful?

- Metric 1: [Description and target]
- Metric 2: [Description and target]

## 7. Open Questions

- [ ] Question 1?
- [ ] Question 2?

## 8. AI Assistant Consultation

[This section will be populated during interactive planning]

---

## Design Review Results

[This section will be populated after design review]

### Architecture Review
[AI and human feedback on architecture]

### Security Review
[Security considerations and recommendations]

### Cost Analysis
[Estimated costs and resource usage]
`;
  }

  /**
   * Run interactive planning session
   */
  async runInteractiveSession(designDocPath) {
    const promptPath = this.getPromptPath('feature-planning.md');

    if (!fs.existsSync(promptPath)) {
      console.log('⚠️  Feature planning prompt not found');
      console.log('Using default interactive session...\n');

      // Use Claude directly
      const claude = spawn(
        'claude',
        ['code', '--file', designDocPath, '--interactive'],
        {
          stdio: 'inherit',
        },
      );

      return new Promise((resolve, reject) => {
        claude.on('close', (code) => {
          if (code === 0) {
            console.log('\n✅ Interactive planning complete!');
            console.log(`Review your design doc: ${designDocPath}\n`);
            resolve();
          } else {
            reject(new Error('Interactive session failed'));
          }
        });
      });
    }

    // Use custom prompt
    const claude = spawn(
      'claude',
      [
        'code',
        '--file',
        designDocPath,
        '--prompt-file',
        promptPath,
        '--interactive',
      ],
      {
        stdio: 'inherit',
      },
    );

    return new Promise((resolve, reject) => {
      claude.on('close', (code) => {
        if (code === 0) {
          console.log('\n✅ Feature planning complete!');
          resolve();
        } else {
          reject(new Error('Feature planning failed'));
        }
      });
    });
  }

  /**
   * Get git config value
   */
  getGitConfig(key) {
    try {
      return execSync(`git config ${key}`, {encoding: 'utf8'}).trim();
    } catch {
      return null;
    }
  }

  /**
   * Get current branch
   */
  getCurrentBranch() {
    try {
      return execSync('git rev-parse --abbrev-ref HEAD', {
        encoding: 'utf8',
      }).trim();
    } catch {
      return 'unknown';
    }
  }

  /**
   * Check if Claude is available
   */
  isClaudeAvailable() {
    try {
      execSync('which claude', {stdio: 'pipe'});
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Get prompt file path
   */
  getPromptPath(promptName) {
    // Check local overrides first
    const localPath = `.claude-prompts/${promptName}`;
    if (fs.existsSync(localPath)) {
      return localPath;
    }

    // Check org templates (if .github repo is accessible)
    // This would need to be configured based on where .github repo is
    const orgPath = path.join(
      process.env.HOME,
      '.informup-automation/prompts',
      promptName,
    );
    if (fs.existsSync(orgPath)) {
      return orgPath;
    }

    return null;
  }

  /**
   * Open file in editor
   */
  openInEditor(filepath) {
    const editor = process.env.EDITOR || process.env.VISUAL || 'code';

    try {
      spawn(editor, [filepath], {
        detached: true,
        stdio: 'ignore',
      }).unref();
    } catch (error) {
      console.log(`Could not open editor. Open manually: ${filepath}`);
    }
  }
}

// Main execution
if (require.main === module) {
  const planner = new FeaturePlanning();
  planner.run().catch((error) => {
    console.error('Feature planning failed:', error.message);
    process.exit(1);
  });
}

module.exports = FeaturePlanning;
