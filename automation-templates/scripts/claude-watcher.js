#!/usr/bin/env node
/**
 * Claude Watcher - File system watcher for automated AI assistance
 * Part of InformUp Engineering Automation System
 * Version: 1.0.0
 *
 * Watches source files and triggers background AI tasks:
 * - Generate tests for new files
 * - Update documentation on changes
 * - Log all actions for debugging
 */

const chokidar = require('chokidar');
const {spawn} = require('child_process');
const fs = require('fs');
const path = require('path');

// Colors for console output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  dim: '\x1b[2m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
};

class ClaudeWatcher {
  constructor(configPath = '.claude-automation-config.json') {
    this.config = this.loadConfig(configPath);
    this.debounceTimers = new Map();
    this.logFile = '.claude-automation.log';

    // Check if watching is enabled
    if (!this.config.enabled) {
      this.log('Automation is disabled in config', 'yellow');
      process.exit(0);
    }

    this.log('Claude Watcher initializing...', 'cyan');
  }

  /**
   * Load configuration from file
   */
  loadConfig(configPath) {
    const defaults = {
      enabled: true,
      triggers: {
        testGeneration: {
          enabled: true,
          filePattern: 'src/**/*.{js,ts,jsx,tsx}',
          excludePattern: '**/*.test.*',
          mode: 'background',
        },
        docGeneration: {
          enabled: false,  // Disabled by default (can be noisy)
          mode: 'background',
        },
      },
    };

    if (fs.existsSync(configPath)) {
      try {
        const userConfig = JSON.parse(fs.readFileSync(configPath, 'utf8'));
        return this.mergeDeep(defaults, userConfig);
      } catch (error) {
        this.log(`Error loading config: ${error.message}`, 'red');
        return defaults;
      }
    }

    return defaults;
  }

  /**
   * Deep merge two objects
   */
  mergeDeep(target, source) {
    const output = Object.assign({}, target);
    if (this.isObject(target) && this.isObject(source)) {
      Object.keys(source).forEach((key) => {
        if (this.isObject(source[key])) {
          if (!(key in target)) {
            Object.assign(output, {[key]: source[key]});
          } else {
            output[key] = this.mergeDeep(target[key], source[key]);
          }
        } else {
          Object.assign(output, {[key]: source[key]});
        }
      });
    }
    return output;
  }

  isObject(item) {
    return item && typeof item === 'object' && !Array.isArray(item);
  }

  /**
   * Start watching files
   */
  start() {
    const watchPattern = this.config.triggers.testGeneration?.filePattern ||
      'src/**/*.{js,ts,jsx,tsx}';

    const ignored = [
      '**/node_modules/**',
      '**/.git/**',
      '**/*.test.*',
      '**/*.spec.*',
      '**/dist/**',
      '**/build/**',
      '**/coverage/**',
    ];

    this.log(`Watching pattern: ${watchPattern}`, 'cyan');
    this.log(`Starting file watcher...`, 'green');

    const watcher = chokidar.watch(watchPattern, {
      ignored,
      persistent: true,
      ignoreInitial: true,
      awaitWriteFinish: {
        stabilityThreshold: 2000,
        pollInterval: 100,
      },
    });

    watcher
      .on('add', (filepath) => this.onFileAdded(filepath))
      .on('change', (filepath) => this.onFileChanged(filepath))
      .on('error', (error) => this.log(`Watcher error: ${error}`, 'red'));

    this.log('🤖 Claude automation watcher started', 'green');
    this.log(`📝 Logging to: ${this.logFile}`, 'dim');
    this.log('Press Ctrl+C to stop', 'dim');

    // Handle graceful shutdown
    process.on('SIGINT', () => {
      this.log('\nShutting down watcher...', 'yellow');
      watcher.close();
      process.exit(0);
    });
  }

  /**
   * Handle new file added
   */
  onFileAdded(filepath) {
    this.log(`File added: ${filepath}`, 'blue');

    // Generate tests for new source files
    if (this.config.triggers.testGeneration?.enabled) {
      const testFile = this.getTestFilePath(filepath);

      if (!fs.existsSync(testFile)) {
        this.log(`Generating tests for ${filepath}...`, 'yellow');
        this.generateTests(filepath, testFile);
      }
    }
  }

  /**
   * Handle file changed
   */
  onFileChanged(filepath) {
    this.log(`File changed: ${filepath}`, 'blue');

    // Update documentation (debounced)
    if (this.config.triggers.docGeneration?.enabled) {
      this.debounce(filepath, () => {
        this.log(`Updating docs for ${filepath}...`, 'yellow');
        this.updateDocs(filepath);
      }, 2000);
    }
  }

  /**
   * Generate tests for a source file
   */
  generateTests(sourceFile, testFile) {
    // Check if Claude is available
    if (!this.isClaudeAvailable()) {
      this.log('Claude Code not available, skipping test generation', 'yellow');
      return;
    }

    const args = [
      'code',
      'test',
      'generate',
      '--file',
      sourceFile,
      '--output',
      testFile,
    ];

    this.log(`Running: claude ${args.join(' ')}`, 'dim');

    const child = spawn('claude', args, {
      detached: true,
      stdio: ['ignore', 'pipe', 'pipe'],
    });

    let output = '';
    let errorOutput = '';

    child.stdout.on('data', (data) => {
      output += data.toString();
    });

    child.stderr.on('data', (data) => {
      errorOutput += data.toString();
    });

    child.on('close', (code) => {
      if (code === 0) {
        this.log(`✅ Generated tests: ${testFile}`, 'green');
      } else {
        this.log(`❌ Failed to generate tests for ${sourceFile}`, 'red');
        if (errorOutput) {
          this.log(`Error: ${errorOutput}`, 'red');
        }
      }
    });

    child.unref();
  }

  /**
   * Update documentation for a file
   */
  updateDocs(filepath) {
    if (!this.isClaudeAvailable()) {
      return;
    }

    const args = [
      'code',
      'docs',
      'update',
      '--file',
      filepath,
      '--background',
    ];

    const child = spawn('claude', args, {
      detached: true,
      stdio: 'ignore',
    });

    child.on('close', (code) => {
      if (code === 0) {
        this.log(`✅ Updated docs for ${filepath}`, 'green');
      }
    });

    child.unref();
  }

  /**
   * Get test file path for a source file
   */
  getTestFilePath(filepath) {
    const ext = path.extname(filepath);
    const base = filepath.replace(ext, '');
    return `${base}.test${ext}`;
  }

  /**
   * Check if Claude Code CLI is available
   */
  isClaudeAvailable() {
    try {
      const result = spawn('which', ['claude'], {
        stdio: 'pipe',
      });
      return result.status === 0;
    } catch (error) {
      return false;
    }
  }

  /**
   * Debounce function calls
   */
  debounce(key, func, wait) {
    if (this.debounceTimers.has(key)) {
      clearTimeout(this.debounceTimers.get(key));
    }

    this.debounceTimers.set(
      key,
      setTimeout(() => {
        func();
        this.debounceTimers.delete(key);
      }, wait),
    );
  }

  /**
   * Log message to console and file
   */
  log(message, color = 'reset') {
    const timestamp = new Date().toISOString();
    const colorCode = colors[color] || colors.reset;
    const consoleMsg = `${colorCode}${message}${colors.reset}`;
    const fileMsg = `[${timestamp}] ${message}`;

    console.log(consoleMsg);

    try {
      fs.appendFileSync(this.logFile, fileMsg + '\n');
    } catch (error) {
      // Ignore log file errors
    }
  }
}

// Main execution
if (require.main === module) {
  const watcher = new ClaudeWatcher();
  watcher.start();
}

module.exports = ClaudeWatcher;
