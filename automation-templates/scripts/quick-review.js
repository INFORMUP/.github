#!/usr/bin/env node
/**
 * Quick Review - Fast AI code review for pre-commit hook
 * Part of InformUp Engineering Automation System
 * Version: 1.0.0
 *
 * Performs quick code review on staged files
 */

const {execSync} = require('child_process');
const fs = require('fs');

class QuickReview {
  constructor() {
    this.config = this.loadConfig();
  }

  loadConfig() {
    const configPath = '.claude-automation-config.json';
    if (fs.existsSync(configPath)) {
      return JSON.parse(fs.readFileSync(configPath, 'utf8'));
    }
    return {};
  }

  /**
   * Run quick review on staged files
   */
  async run() {
    // Get staged files
    const stagedFiles = this.getStagedFiles();

    if (stagedFiles.length === 0) {
      console.log('No code files to review');
      return;
    }

    console.log(`Reviewing ${stagedFiles.length} file(s)...`);

    // For quick review, just check for common issues
    const issues = this.checkCommonIssues(stagedFiles);

    if (issues.length > 0) {
      console.log('\n⚠️  Quick review found potential issues:');
      issues.forEach((issue) => console.log(`  - ${issue}`));
      console.log('\nConsider addressing these before committing.');

      // Return non-zero if configured to fail on issues
      const failOnIssues =
        this.config.triggers?.preCommitReview?.failOnIssues || false;
      if (failOnIssues) {
        process.exit(1);
      }
    } else {
      console.log('✓ Quick review passed');
    }
  }

  /**
   * Get staged files
   */
  getStagedFiles() {
    try {
      const output = execSync('git diff --cached --name-only --diff-filter=ACM', {
        encoding: 'utf8',
      });

      return output
        .split('\n')
        .filter((file) => file.match(/\.(js|jsx|ts|tsx)$/))
        .filter((file) => fs.existsSync(file));
    } catch (error) {
      return [];
    }
  }

  /**
   * Check for common issues
   */
  checkCommonIssues(files) {
    const issues = [];

    files.forEach((file) => {
      const content = fs.readFileSync(file, 'utf8');

      // Check for console.log
      if (content.match(/console\.(log|debug|info)/)) {
        issues.push(`${file}: Contains console.log statements`);
      }

      // Check for debugger
      if (content.match(/debugger;?/)) {
        issues.push(`${file}: Contains debugger statement`);
      }

      // Check for TODO without issue number
      if (content.match(/\/\/\s*TODO(?!\s*#\d+)/)) {
        issues.push(`${file}: TODO without issue number`);
      }

      // Check for hardcoded credentials (simple check)
      if (
        content.match(
          /(password|api[_-]?key|secret|token)\s*=\s*['"][^'"]{8,}['"]/i,
        )
      ) {
        issues.push(`${file}: Possible hardcoded credentials`);
      }
    });

    return issues;
  }
}

// Main execution
if (require.main === module) {
  const review = new QuickReview();
  review.run().catch((error) => {
    console.error('Quick review failed:', error.message);
    process.exit(1);
  });
}

module.exports = QuickReview;
