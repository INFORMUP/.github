#!/usr/bin/env node
/**
 * PR Generator - Generate pull request descriptions using AI
 * Part of InformUp Engineering Automation System
 * Version: 1.0.0
 *
 * Analyzes git commits and generates comprehensive PR description
 */

const {execSync} = require('child_process');
const fs = require('fs');

class PRGenerator {
  constructor() {
    this.interactive = process.argv.includes('--interactive');
    this.dryRun = process.argv.includes('--dry-run');
  }

  /**
   * Generate PR description
   */
  async generate() {
    console.log('📝 Generating PR description...\n');

    // Get current branch
    const currentBranch = this.getCurrentBranch();
    console.log(`Branch: ${currentBranch}`);

    // Get base branch (usually main)
    const baseBranch = this.getBaseBranch();
    console.log(`Base: ${baseBranch}\n`);

    // Get commits since divergence
    const commits = this.getCommits(baseBranch, currentBranch);
    console.log(`Commits to include: ${commits.length}\n`);

    // Get diff stats
    const diffStats = this.getDiffStats(baseBranch);

    // Check for design doc
    const designDoc = this.findDesignDoc(currentBranch);

    // Generate description
    const description = this.generateDescription({
      branch: currentBranch,
      commits,
      diffStats,
      designDoc,
    });

    if (this.dryRun) {
      console.log('=== Generated PR Description (dry run) ===\n');
      console.log(description);
      console.log('\n=== End ===\n');
      return;
    }

    // Write to file for gh pr create
    const descFile = '.pr-description.md';
    fs.writeFileSync(descFile, description);

    console.log(`✅ PR description saved to ${descFile}`);
    console.log('\nTo create PR, run:');
    console.log(`  gh pr create --body-file ${descFile}`);
    console.log('\nOr let gh read it interactively:');
    console.log('  gh pr create');
  }

  /**
   * Get current branch name
   */
  getCurrentBranch() {
    return execSync('git rev-parse --abbrev-ref HEAD', {
      encoding: 'utf8',
    }).trim();
  }

  /**
   * Get base branch (main or master)
   */
  getBaseBranch() {
    try {
      execSync('git show-ref --verify --quiet refs/heads/main');
      return 'main';
    } catch {
      return 'master';
    }
  }

  /**
   * Get commits between base and current branch
   */
  getCommits(base, current) {
    const log = execSync(`git log ${base}..${current} --pretty=format:"%s|||%b"`, {
      encoding: 'utf8',
    });

    if (!log) return [];

    return log.split('\n').map((line) => {
      const [subject, body] = line.split('|||');
      return {subject, body: body || ''};
    });
  }

  /**
   * Get diff statistics
   */
  getDiffStats(base) {
    const stats = execSync(`git diff ${base} --stat`, {
      encoding: 'utf8',
    });

    // Parse the summary line
    const match = stats.match(/(\d+) files? changed(?:, (\d+) insertions?\(\+\))?(?:, (\d+) deletions?\(-\))?/);

    return {
      filesChanged: match ? parseInt(match[1]) : 0,
      insertions: match && match[2] ? parseInt(match[2]) : 0,
      deletions: match && match[3] ? parseInt(match[3]) : 0,
    };
  }

  /**
   * Find design doc for current branch
   */
  findDesignDoc(branch) {
    const featureName = branch.replace(/^feature\//, '');
    const possiblePaths = [
      `design-docs/${featureName}.md`,
      `design-docs/${branch}.md`,
    ];

    for (const path of possiblePaths) {
      if (fs.existsSync(path)) {
        return path;
      }
    }

    return null;
  }

  /**
   * Generate PR description
   */
  generateDescription({branch, commits, diffStats, designDoc}) {
    const featureName = branch.replace(/^(feature|fix|refactor)\//, '');
    const title = this.generateTitle(featureName, commits);

    const sections = [];

    // Summary
    sections.push('## Summary\n');
    sections.push(this.generateSummary(commits));

    // Changes
    if (diffStats.filesChanged > 0) {
      sections.push('\n## Changes\n');
      sections.push(`- **Files changed**: ${diffStats.filesChanged}`);
      sections.push(`- **Lines added**: +${diffStats.insertions}`);
      sections.push(`- **Lines removed**: -${diffStats.deletions}\n`);
    }

    // Design doc reference
    if (designDoc) {
      sections.push(`\n## Design Document\n`);
      sections.push(`See [${designDoc}](./${designDoc}) for detailed design.\n`);
    }

    // Type of change
    sections.push('\n## Type of Change\n');
    sections.push(this.inferChangeType(commits));

    // Test plan
    sections.push('\n## Test Plan\n');
    sections.push('- [ ] Unit tests added/updated');
    sections.push('- [ ] Integration tests pass');
    sections.push('- [ ] Manual testing completed');
    sections.push('- [ ] Coverage meets threshold (80%+)\n');

    // Checklist
    sections.push('\n## Checklist\n');
    sections.push('- [ ] Code follows project style guidelines');
    sections.push('- [ ] Self-review completed');
    sections.push('- [ ] Comments added for complex code');
    sections.push('- [ ] Documentation updated');
    sections.push('- [ ] No new warnings introduced');
    sections.push('- [ ] Tests added and passing');
    if (designDoc) {
      sections.push('- [ ] Implementation matches design doc');
    }
    sections.push('');

    // Footer
    sections.push('\n---\n');
    sections.push('🤖 Generated with [Claude Code](https://claude.com/claude-code)\n');
    sections.push('Co-Authored-By: Claude <noreply@anthropic.com>');

    return sections.join('\n');
  }

  /**
   * Generate title from feature name and commits
   */
  generateTitle(featureName, commits) {
    // Use first commit subject as base
    if (commits.length > 0) {
      return commits[0].subject;
    }

    // Fallback to feature name
    return featureName
      .split('-')
      .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
      .join(' ');
  }

  /**
   * Generate summary from commits
   */
  generateSummary(commits) {
    if (commits.length === 0) {
      return 'No commits found.';
    }

    if (commits.length === 1) {
      return commits[0].subject + '\n';
    }

    // Group commits by type
    const features = commits.filter((c) => c.subject.startsWith('feat'));
    const fixes = commits.filter((c) => c.subject.startsWith('fix'));
    const others = commits.filter(
      (c) => !c.subject.startsWith('feat') && !c.subject.startsWith('fix'),
    );

    const summary = [];

    if (features.length > 0) {
      summary.push('**New Features:**');
      features.forEach((c) => {
        summary.push(`- ${c.subject.replace(/^feat(\([^)]+\))?:\s*/, '')}`);
      });
      summary.push('');
    }

    if (fixes.length > 0) {
      summary.push('**Bug Fixes:**');
      fixes.forEach((c) => {
        summary.push(`- ${c.subject.replace(/^fix(\([^)]+\))?:\s*/, '')}`);
      });
      summary.push('');
    }

    if (others.length > 0) {
      summary.push('**Other Changes:**');
      others.forEach((c) => {
        summary.push(`- ${c.subject}`);
      });
      summary.push('');
    }

    return summary.join('\n');
  }

  /**
   * Infer type of change from commits
   */
  inferChangeType(commits) {
    const hasFeatures = commits.some((c) => c.subject.startsWith('feat'));
    const hasFixes = commits.some((c) => c.subject.startsWith('fix'));
    const hasBreaking = commits.some(
      (c) => c.subject.includes('!') || c.body.includes('BREAKING CHANGE'),
    );

    const types = [];

    if (hasBreaking) {
      types.push('- [x] Breaking change');
    } else {
      types.push('- [ ] Breaking change');
    }

    if (hasFeatures) {
      types.push('- [x] New feature');
    } else {
      types.push('- [ ] New feature');
    }

    if (hasFixes) {
      types.push('- [x] Bug fix');
    } else {
      types.push('- [ ] Bug fix');
    }

    types.push('- [ ] Refactoring');
    types.push('- [ ] Documentation update\n');

    return types.join('\n');
  }
}

// Main execution
if (require.main === module) {
  const generator = new PRGenerator();
  generator.generate().catch((error) => {
    console.error('Failed to generate PR description:', error.message);
    process.exit(1);
  });
}

module.exports = PRGenerator;
