# InformUp Engineering Automation Installer

This directory contains the installation system for InformUp's AI-powered engineering automation.

## Quick Install

From your repository root:

```bash
# If you have the .github repo cloned locally
bash /path/to/.github/automation-installer/install.sh

# Or download and run (when deployed)
curl -sSL https://raw.githubusercontent.com/INFORMUP/.github/main/automation-installer/install.sh | bash
```

## What Gets Installed

- **Git Hooks**: pre-commit, pre-push, post-checkout, post-commit, commit-msg
- **Automation Scripts**: File watcher, local CI, PR generator, quick review
- **Configuration**: `.claude-automation-config.json`
- **Directory Structure**: `design-docs/`, `scripts/automation/`, `.claude-prompts/`
- **npm Scripts**: `automation:start`, `automation:stop`, `local-ci`

## Requirements

- Node.js 18+
- npm
- Git repository
- (Optional) Claude Code CLI for AI features

## Files

- **install.sh**: Main installation script
- **VERSION**: Current version of automation system
- **lib/**: Helper functions (future)

## How It Works

1. **Pre-flight checks**: Verifies Node.js, npm, git repository
2. **Detect repo type**: Identifies frontend, backend, or infrastructure
3. **Install dependencies**: Adds husky, chokidar to package.json
4. **Copy templates**: Installs git hooks and scripts from `automation-templates/`
5. **Create config**: Generates `.claude-automation-config.json`
6. **Update files**: Adds scripts to package.json, updates .gitignore
7. **Test**: Verifies installation
8. **Print next steps**: Shows how to get started

## Customization

After installation, edit `.claude-automation-config.json` to:

- Enable/disable specific automation triggers
- Adjust timeouts and thresholds
- Configure repository-specific settings

See [docs/GettingStarted.md](../docs/GettingStarted.md) for full documentation.

## Updating

To update automation to latest version:

```bash
# Pull latest .github repo
cd /path/to/.github
git pull

# Re-run installer (preserves your config)
cd /path/to/your-repo
bash /path/to/.github/automation-installer/install.sh
```

## Uninstalling

To remove automation:

```bash
# Remove git hooks
rm -rf .husky

# Remove scripts
rm -rf scripts/automation

# Remove config (optional - preserves customizations)
# rm .claude-automation-config.json

# Remove npm scripts manually from package.json
```

## Version

Current version: **1.0.0**

See [VERSION](./VERSION) file.

## Support

- **Documentation**: [docs/GettingStarted.md](../docs/GettingStarted.md)
- **Issues**: [GitHub Issues](https://github.com/INFORMUP/.github/issues)
- **Slack**: #engineering channel
