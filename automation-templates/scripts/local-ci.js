#!/usr/bin/env node
/**
 * Local CI - Run full CI pipeline locally before pushing
 * Part of InformUp Engineering Automation System
 * Version: 1.0.0
 *
 * Runs same checks as CI/CD but locally:
 * - Linting
 * - Type checking
 * - Tests with coverage
 * - Build
 * - Security audit
 */

const {execSync} = require('child_process');
const fs = require('fs');

// Colors
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

class LocalCI {
  constructor() {
    this.config = this.loadConfig();
    this.results = [];
    this.startTime = Date.now();
  }

  loadConfig() {
    const configPath = '.claude-automation-config.json';
    const defaults = {
      testing: {
        command: 'npm test',
        coverageThreshold: 80,
      },
      build: {
        command: 'npm run build',
      },
    };

    if (fs.existsSync(configPath)) {
      try {
        const userConfig = JSON.parse(fs.readFileSync(configPath, 'utf8'));
        return {...defaults, ...userConfig};
      } catch (error) {
        return defaults;
      }
    }

    return defaults;
  }

  /**
   * Run all CI checks
   */
  async run() {
    this.log('🚀 Running local CI checks...', 'cyan');
    this.log('');

    const checks = [
      {name: 'Linting', fn: () => this.runLinter()},
      {name: 'Type Checking', fn: () => this.runTypeCheck()},
      {name: 'Unit Tests', fn: () => this.runTests()},
      {name: 'Coverage Check', fn: () => this.checkCoverage()},
      {name: 'Build', fn: () => this.runBuild()},
      {name: 'Security Audit', fn: () => this.runSecurityAudit()},
    ];

    for (const check of checks) {
      await this.runCheck(check.name, check.fn);
    }

    this.printSummary();

    const failedChecks = this.results.filter((r) => !r.passed);
    if (failedChecks.length > 0) {
      process.exit(1);
    }
  }

  /**
   * Run a single check
   */
  async runCheck(name, fn) {
    process.stdout.write(`  ${colors.yellow}⏳ ${name}...${colors.reset}`);

    try {
      await fn();
      process.stdout.write(`\r  ${colors.green}✓ ${name}${colors.reset}\n`);
      this.results.push({check: name, passed: true});
    } catch (error) {
      process.stdout.write(`\r  ${colors.red}✗ ${name}${colors.reset}\n`);
      this.results.push({
        check: name,
        passed: false,
        error: error.message,
      });

      // Show error details
      if (error.stdout) {
        this.log(`    ${error.stdout.toString().trim()}`, 'dim');
      }
    }
  }

  /**
   * Run linter
   */
  runLinter() {
    try {
      execSync('npm run lint', {stdio: 'pipe'});
    } catch (error) {
      // Try eslint directly if npm script doesn't exist
      try {
        execSync('npx eslint . --ext .js,.jsx,.ts,.tsx', {stdio: 'pipe'});
      } catch (eslintError) {
        throw new Error('Linting failed');
      }
    }
  }

  /**
   * Run type checker (TypeScript)
   */
  runTypeCheck() {
    if (!fs.existsSync('tsconfig.json')) {
      // Skip if not TypeScript project
      return;
    }

    try {
      execSync('npm run type-check', {stdio: 'pipe'});
    } catch (error) {
      // Try tsc directly
      try {
        execSync('npx tsc --noEmit', {stdio: 'pipe'});
      } catch (tscError) {
        throw new Error('Type checking failed');
      }
    }
  }

  /**
   * Run tests
   */
  runTests() {
    const testCommand = this.config.testing?.command || 'npm test';

    try {
      execSync(`${testCommand} -- --coverage --passWithNoTests`, {
        stdio: 'pipe',
      });
    } catch (error) {
      throw new Error('Tests failed');
    }
  }

  /**
   * Check test coverage
   */
  checkCoverage() {
    const coveragePath = 'coverage/coverage-summary.json';

    if (!fs.existsSync(coveragePath)) {
      // Coverage report not generated
      return;
    }

    const coverage = JSON.parse(fs.readFileSync(coveragePath, 'utf8'));
    const lineCoverage = coverage.total.lines.pct;
    const threshold = this.config.testing?.coverageThreshold || 80;

    if (lineCoverage < threshold) {
      throw new Error(
        `Coverage ${lineCoverage}% below threshold ${threshold}%`,
      );
    }
  }

  /**
   * Run build
   */
  runBuild() {
    const buildCommand = this.config.build?.command;

    if (!buildCommand) {
      // No build command configured
      return;
    }

    try {
      execSync(buildCommand, {stdio: 'pipe'});
    } catch (error) {
      throw new Error('Build failed');
    }
  }

  /**
   * Run security audit
   */
  runSecurityAudit() {
    try {
      execSync('npm audit --audit-level=moderate', {stdio: 'pipe'});
    } catch (error) {
      // Audit found vulnerabilities
      throw new Error('Security vulnerabilities found');
    }
  }

  /**
   * Print summary
   */
  printSummary() {
    const duration = ((Date.now() - this.startTime) / 1000).toFixed(2);
    const passed = this.results.filter((r) => r.passed).length;
    const failed = this.results.filter((r) => !r.passed).length;

    this.log('');
    this.log('📊 Summary:', 'cyan');
    this.log(`  ${colors.green}✓ Passed: ${passed}${colors.reset}`);

    if (failed > 0) {
      this.log(`  ${colors.red}✗ Failed: ${failed}${colors.reset}`);

      this.log('');
      this.log('Failed checks:', 'yellow');
      this.results
        .filter((r) => !r.passed)
        .forEach((r) => {
          this.log(`  - ${r.check}`, 'red');
          if (r.error) {
            this.log(`    ${r.error}`, 'dim');
          }
        });

      this.log('');
      this.log('💡 Fix the issues above and try again', 'yellow');
    } else {
      this.log('');
      this.log('🎉 All checks passed! Ready to push.', 'green');
    }

    this.log('');
    this.log(`⏱️  Duration: ${duration}s`, 'dim');
  }

  /**
   * Log message with color
   */
  log(message, color = 'reset') {
    const colorCode = colors[color] || colors.reset;
    console.log(`${colorCode}${message}${colors.reset}`);
  }
}

// Main execution
if (require.main === module) {
  const ci = new LocalCI();
  ci.run().catch((error) => {
    console.error(`${colors.red}CI failed: ${error.message}${colors.reset}`);
    process.exit(1);
  });
}

module.exports = LocalCI;
