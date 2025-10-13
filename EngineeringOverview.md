# Purpose of this Doc

InformUp is a low-resource, nonprofit newsroom which is focused on dramatically reducing the barriers for residents to regularly engage with their elected officials, a mission that requires the development of new software enabled tools.

This document outlines the procedures and practices necessary for engineers working in support of InformUo, be they full time staff or occasional volunteers, to make contributions with ease and with the confidence that they are not going to break any of our products.

Included in this document are the high level goals for our engineering processes as well as the details outlining how our development and release processes are built.

# Introduction: Ai supported Software development

**Goal**: Establish professional level engineering best practices for small, less mature engineering teams, enabling them to move quickly while maintaining a high level of confidence in the quality, security, and maintainability of their code.

**Key Principles**:

- Move fast and don't break things - Engineers, at whatever skill level , should be able to quickly contribute to production code without fear of breaking anything.
- Protect against "Ready, Fire, Aim" - AI coding tools make it very easy to build something before you've thought through all of the implications.
- Maximum value for time - Volunteer contributors' time is precious. it should be spent where it can have the highest impact.
- AI Supported - AI tools, such as Claude code should be leveraged wherever possible to support and accelerate the development process.
- Human Readable - Decisions at every stage of the development process should be easily accessible and in interpretable formats
- Comprehensive: From bug fixing to Product Launches, the process provides the right-sized supports for the task at hand

# What the Development Process in cludes

- Feature planning
- Design Review
    - Architecture
    - Security audit
    - Cost analysis
- Making code changes/ Feature development
- test writing
- Bug fixes, root causing production bugs
- Test Running
- Code Reviews
- Documentation Writing
    - For Humans
    - Context management for AI
- Build
- Deployment
- Monitoring

# Feature Planning

#### Task:

When a developer wants to create a new feature, from adding a new newsletter selection flow to creating an entirely new product like a survey results dashboard, there needs to be a feature planning document. The goal is to ensure that the engineer has a complete understanding of the task they are about to set out on.

- Should new features be started in a new branch?
- Should branching auto intiate this design dialogue with the Coding assistant?

#### AI Support

This document can and should be generated with support from AI tools such as Claude Code. IF you have a fully formed understanding, then the tool can just help generate the documentation. If you don't the tool can help think through the necessary planning steps before you start to make code changes:

- Is there a standard best practice for this problem?
- What is the complexity in terms of # of calls, compute, data quirements, etc.
- ????

[Link to document outlining custom instructions for AI for this step]

# Design Review

#### Task

[Only for features, not bug fixes]The design document should be robust enough to support a series of reviews to ensure that the plan is a sound one.

The review should cover:

- Architecture
- Security / Data Privacy
- Cost analysis

#### AI Support

Coding assistants should be tasked with performing the first pass of this audit. It should be done in an interactive way where the develop can accept or reject design suggestions. The final analysis should generate a report which is human readable and shared with the Design document.
[Link to document outlining custom instructions for AI for this step]

#### Human Review

This design document should be shared in a manner such that the rest of the engineering community can review and provide feedback. IT is also helpful context as the feature makes progress towards deployment. This review should be nonblocking for smaller features, and blocking for new products.

# Making Code Changes

#### Task

Once the plan has been reviewed, it should be followed for actually developing the feature.

#### AI Support

Have the coding assistant perform whatever aspects of the coding task you feel comfortable offloading.

# Test writing

#### Task

Test coverage should follow these standards of practice:

- what target test coverage of what types should we follow?

#### AI Support

Have the AI write all of the tests.

#### Human Review

- Should tests be human readable, reviewable?

# Committing Code Changes

#### Task

Regular commits on stable states of the feaure so you can easily roll back changes if AI assistants go off the rails.

#### AI Support

Tests should be run on each code commit

- should the commit fail until the tests pass?

#### AI Support

- Should the assistant try to auto diagnose any failing tests?

#### Human Review.

Commit messages should be human readable.

# Submitting a PR

#### Task

The PR should be Human readable, describe the major changes, and link to the design doc and results of the design reviews.

- How/when do we accept PRs?
- Can they be accepted on AI review?
    - What if I am the originator?
    - What if someone we don't know is the originator?

#### AI Support

- Can AI do PR checks? if so, in what cases?

# Kicking off a build

#### Task

On PR Merge, it should generate a new build for deployment

#### AI Support?

- Aautomatic diagnosis of build failureS?

# Deploying to Production

# Monitoring
