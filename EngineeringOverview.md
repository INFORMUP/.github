# Purpose of this Doc

InformUp is a low-resource, nonprofit newsroom which is focused on dramatically reducing the barriers for residents to regularly engage with their elected officials, a mission that requires the development of new software enabled tools.

This document outlines the procedures and practices necessary for engineers working in support of InformUp, be they full time staff or occasional volunteers, to make contributions with ease and with the confidence that they are not going to break any of our products.

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

- Roadmap &Prioritizaiton
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

# Roadmap & Prioritization

The Roadmap is maintained by InformUp with prioritizaiton based on the needs of the organization and what work will drive the most progress towards the organization's mission. This super scientific process will be carried out in conversation with engineering guidance.

The roadmap is maintained in the Engineering Project hosted on Github at
[https://github.com/orgs/INFORMUP/projects/1](https://github.com/orgs/INFORMUP/projects/1)

### It's your time, you decide

That said, it's your time that you are so generously giving, so spend it however you findmost interesting. We only ask that you track it in the Engineering project page.

# Feature Planning

#### Task:

When someone wants to create a new feature, from adding a new newsletter selection flow to creating an entirely new product like a survey results dashboard, there needs to be a feature planning document. The goal is to ensure that the originator has a complete understanding of the task they are about to set out on.

**Who can start a feature**

With the rise of AI coding assistants, someone with little to know coding experience can create code that that solves the problem they set out to solve. These contributors, who we grant permissions to, should be empowered to create new features.

    **Who has permission?**
    - People internal to the InformUp org.
    - People who have been approved by InformIp

    **Additional Guard rails**
    - New features cannot be shipped without approval from InformUp
    - Code form these contributors cannot be merged with out human review.

    ***Prioritization**
    Engineering resources should prioritize support for planned features first, but time permitting, or if they are personally motivated, they can and should review feature submissions from this cohort.


    **Feature suggestions**
    Suggested features will be tracked in github in the project board and tagged as feature requests. We'll prioritize as we are able.

- Should new features be started in a new branch?
- Should branching auto intiate this design dialogue with the Coding assistant?
-

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

Coding assistants should be tasked with performing the first pass of this design review. It should be done in an interactive way where the develop can accept or reject design suggestions. The final analysis should generate a report which is human readable and shared with the Design document.
[Link to document outlining custom instructions for AI for this step]

#### Human Review

This design document should be shared in a manner such that the rest of the engineering community can review and provide feedback. IT is also helpful context as the feature makes progress towards deployment. This review should be nonblocking for smaller features, and blocking for new products.

This will live as a markdown file in the design docs repository in the root directory of the repo.

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

- tests should be human readable and regularly pruned for utility
- What guideliness do we need to provide for test writing?
- can we audit the tests with LLMs too?

# Committing Code Changes

#### Task

Regular commits on stable states of the feaure so you can easily roll back changes if AI assistants go off the rails.

#### AI Support

Tests should be run on each code commit

- should the commit fail until the tests pass?

#### AI Support

The assistant should automatically attempt to diagnose failing tests and present the diagnosis and code change for the contributor to review.

#### Human Review.

Commit messages should be human readable.

# Submitting a PR

#### Task

The PR should be Human readable, describe the major changes, and link to the design doc and results of the design reviews.

- How/when do we accept PRs?
- Can they be accepted on AI review?
    - What if I am the originator?
    - What if someone we don't know is the originator?

After the PR check, we will run a full test pass and if everything passes, the PR will be merged.

#### AI Support

- Can AI do PR checks? if so, in what cases?

# Kicking off a build

#### Task

#### AI Support?

- Aautomatic diagnosis of build failureS?

# Deploying to Production

#### Task

#### AI Support

# Monitoring

We will connect Ai assistant monitoring of error logs so it can create tickets and attempt to auto diagnose and resolve. Ai generated fixes should go through the full design review process as if it were a new feature.
