# Welcome to InformUp Engineering

**Mission**: Dramatically increase local civic participation by giving residents the information they need to be informed and the tools to take action.

---

## Quick Start

### For New Contributors

1. **Read the docs** → [Engineering Overview](./docs/EngineeringOverview.md) - Understand our principles
2. **Get set up** → [Getting Started Guide](./docs/GettingStarted.md) - Install automation in your repo
3. **Learn the process** → [Implementation Guide](./docs/EngineeringProcessImplementation.md) - Step-by-step workflows
4. **Understand the system** → [Automation Architecture](./docs/AutomationArchitecture.md) - How automation works

### Installing Automation in Your Repository

From your repository directory:

```bash
# Quick install (script in development)
curl -sSL https://raw.githubusercontent.com/INFORMUP/.github/main/automation-installer/install.sh | bash

# Manual install (current method)
# See docs/GettingStarted.md for detailed steps
```

### Your First Contribution

```bash
# 1. Pick up work from the project board
#    https://github.com/orgs/INFORMUP/projects/1

# 2. Create a feature branch
git checkout -b feature/my-feature

# 3. Follow the engineering process
#    (AI assistance will guide you)

# 4. Submit a PR
gh pr create
```

---

## Table of Contents

1. [About InformUp](#about-informup)
2. [Engineering Documentation](#engineering-documentation)
3. [Open Source Philosophy](#open-source-philosophy)
4. [How We Build Software](#how-we-build-software)
5. [Projects & Repositories](#projects--repositories)
6. [Getting Involved](#getting-involved)
7. [Support & Community](#support--community)

---

## About InformUp

InformUp is a low-resource, nonprofit newsroom focused on dramatically reducing barriers for residents to regularly engage with their elected officials. This mission requires innovative software tools that:

- Simplify collection of civic information
- Enable high-quality reporting generation
- Distribute reporting effectively
- Provide engaging ways for residents to participate in local government

We believe that no one should have to pay to access their elected officials, and no organization should have to pay to use tools that help inform and organize their communities.

---

## Engineering Documentation

### Core Documents

| Document | Description | Audience |
|----------|-------------|----------|
| **[Engineering Overview](./docs/EngineeringOverview.md)** | High-level principles, process overview, contributor guidelines | All engineers |
| **[Getting Started](./docs/GettingStarted.md)** | Setup, configuration, troubleshooting | New contributors |
| **[Implementation Guide](./docs/EngineeringProcessImplementation.md)** | Detailed workflows for each development phase | Active contributors |
| **[Automation Architecture](./docs/AutomationArchitecture.md)** | Technical architecture of the automation system | Maintainers, advanced users |
| **[Code Change Process](./docs/code_change_and_release_process.md)** | Detailed Claude CLI integration patterns | Advanced users |

### Quick Links

- **Project Board**: [https://github.com/orgs/INFORMUP/projects/1](https://github.com/orgs/INFORMUP/projects/1)
- **Slack Channel**: #engineering
- **Issues**: [INFORMUP/.github Issues](https://github.com/INFORMUP/.github/issues)
- **Engineering Email**: engineering@informup.org

---

## Open Source Philosophy

Our goal is to create a welcoming community of volunteer software developers who help develop tools InformUp relies on for its core mission. While InformUp is the primary user of these tools, we aim to guide their development but not keep them proprietary.

### Core Beliefs

- **Open Access**: Just as no one should pay to access elected officials, no organization should pay for civic engagement tools
- **Community-Driven**: We welcome contributions from volunteers and external contributors
- **AI-Augmented**: We leverage AI tools to maximize the value of volunteer time
- **Quality-First**: Professional-level engineering practices ensure stability and security

---

## How We Build Software

### AI-Supported Development

We use **Claude Code CLI** and automation to:

- Generate feature plans and design reviews
- Automatically create tests for code changes
- Run security and architecture reviews
- Generate PR descriptions and documentation
- Provide real-time assistance during development

**Local-First**: All automation runs on your machine using your Claude subscription (no API charges).

### Engineering Principles

1. **Move fast and don't break things** - Engineers at any skill level can contribute confidently
2. **Protect against "Ready, Fire, Aim"** - AI makes it easy to build; we ensure you think first
3. **Maximum value for time** - Volunteer time is precious; spend it on high-impact work
4. **Human Readable** - All decisions are documented in accessible formats
5. **Comprehensive** - Right-sized support from bug fixes to product launches

See [Engineering Overview](./docs/EngineeringOverview.md) for full details.

---

## Projects & Repositories

### Active Projects

#### 1. InformUp Website (informup.org)

**Technology**: Ghost CMS on AWS

**Areas**:
- Hosting and deployment
- Theme development and design
- Feature enhancements
  - Social share cards for survey responses
  - Multi-city support
  - Address/district specification

**Repository**: [INFORMUP/informup-website]

#### 2. Survey Tools (Formbricks Integration)

**Technology**: Formbricks (open-source survey platform)

**Areas**:
- Hosting configuration
- Custom integrations with Ghost
- Survey result aggregation

**Repository**: [INFORMUP/survey-tools]

#### 3. Reporter Dashboard

**Technology**: Node.js, React, Python (AI components)

**Features**:
- Collection of public meeting content
- Automated meeting agenda retrieval
- Draft article generation from transcripts
- Survey results aggregation and visualization

**Components**:
- Automated emailing to clerks/admins for agendas
- Meeting recording upload and transcription
- Content synthesis and summarization

**Repository**: [INFORMUP/reporter-dashboard]

#### 4. Experiments

**Cutting-Edge Features** (in development):
- Public comment transcription and summarization
- Tools for local governments to digitize workflows
- AI-powered legislative tracking
- Automated fact-checking systems

**Repository**: [INFORMUP/experiments]

### Repository Structure

Each repository follows our [engineering process](./docs/EngineeringProcessImplementation.md) and includes:

- Automation setup (git hooks, file watchers)
- Design docs in `design-docs/`
- Comprehensive tests (80%+ coverage)
- CI/CD pipelines
- Clear documentation

---

## Getting Involved

### For Contributors

#### 1. Choose Your Path

**Full-Time Engineers**:
- Work on planned features from the roadmap
- Lead major initiatives
- Mentor volunteers
- Design system architecture

**Volunteer Engineers**:
- Pick up tasks that interest you
- Contribute on your own schedule
- Learn from AI-assisted development
- Make real impact with limited time

**Non-Technical Contributors**:
- With AI coding assistants, you can contribute code!
- Requires approval from InformUp team
- Additional review requirements apply
- See [Engineering Overview](./docs/EngineeringOverview.md) for details

#### 2. Set Up Your Environment

**Prerequisites**:
- Git, Node.js (18+), GitHub CLI
- Claude Code CLI ([install guide](./docs/GettingStarted.md#prerequisites))
- VS Code (recommended)

**Setup Steps**:
1. Clone a repository
2. Run automation installer
3. Start file watcher (optional)
4. Begin contributing!

Full instructions: [Getting Started Guide](./docs/GettingStarted.md)

#### 3. Find Work

Browse the [Engineering Project Board](https://github.com/orgs/INFORMUP/projects/1):

- **Ready**: Planned work ready to start
- **Backlog**: Ideas and feature requests
- **In Progress**: Active development

Or create new issues for features you want to build!

#### 4. Follow the Process

1. **Feature Planning** - Create design doc with AI assistance
2. **Design Review** - Get AI + human review
3. **Implementation** - Build with AI support
4. **Testing** - Auto-generate comprehensive tests
5. **Code Review** - Submit PR for review
6. **Deployment** - Merge and deploy

Detailed process: [Implementation Guide](./docs/EngineeringProcessImplementation.md)

### For Maintainers

#### Responsibilities

- Review and approve PRs
- Maintain automation system
- Update documentation
- Support contributors
- Plan roadmap

#### Automation Maintenance

The automation system is centralized in this repository:

```
.github/ (this repo)
├── docs/                      # Documentation
├── automation-templates/      # Templates (coming soon)
├── automation-installer/      # Installer scripts (coming soon)
└── README.md                  # This file
```

To update automation across all repos:
1. Update templates in this repo
2. Version and test changes
3. Run updater in each repo

See [Automation Architecture](./docs/AutomationArchitecture.md) for details.

---

## Support & Community

### Getting Help

- **Documentation**: Start with [Getting Started](./docs/GettingStarted.md)
- **Slack**: #engineering channel
- **Email**: engineering@informup.org
- **GitHub Issues**: [Create an issue](https://github.com/INFORMUP/.github/issues/new)
- **Office Hours**: Tuesdays 2-3 PM PT (check calendar)

### Contributing to This Repository

This repository contains organization-wide engineering resources. To contribute:

1. **Documentation improvements**: Submit PRs directly
2. **Automation enhancements**: Discuss in issues first
3. **New templates**: Follow template guidelines
4. **Bug reports**: Create detailed issues

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

### Code of Conduct

We are committed to providing a welcoming and inclusive environment. All contributors must:

- Be respectful and professional
- Focus on constructive feedback
- Welcome newcomers and help them learn
- Prioritize the mission: increasing civic engagement

Report concerns to engineering@informup.org.

---

## Contact

- **Website**: [https://informup.org](https://informup.org)
- **Engineering**: engineering@informup.org
- **General**: info@informup.org
- **Slack**: [Join our workspace](https://informup.slack.com)

---

## License

InformUp's open-source projects are licensed under [specify license]. See individual repositories for specific license details.

Our goal is maximum openness while protecting the mission of increasing civic engagement.

---

**Thank you for contributing to InformUp!**

Together, we're building tools that help communities engage with their local government and make democracy more accessible for everyone.
