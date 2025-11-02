# Engineering Decisions Log

**Purpose**: Track major engineering decisions for context across sessions and prevent unintentional reversions.

**Usage**: Claude should check this before reverting/removing features and add entries for significant decisions.

---

## 2025-01-31 - Hybrid Operating Model v2.0

**Context**: Need for transparent decision-making in automation system. Previous v1.0 lacked visibility into why agents ran and what standards applied.

**Decision**: Implement Hybrid Operating Model combining agent-based automation with transparent standards enforcement.

**Key Features**:
- Task classification (9 types)
- Compliance scoring (0-100)
- Transparent standards display
- Configurable enforcement levels
- Document linking for human review
- Concise technical report format

**Rationale**:
- Maintains agent flexibility and intelligence
- Adds measurable, transparent standards
- Enables graduated enforcement
- Supports volunteer contributors with clear expectations

**Impact**: All InformUp repositories, all engineering workflows

**Alternatives Considered**:
- Pure enforcement model (rejected - too rigid)
- Keep v1.0 as-is (rejected - not transparent enough)

**Author**: Chris Maury (with Claude assistance)

---

## 2025-01-31 - Edge Case & Risk Analysis Phase

**Context**: Tests were being generated without systematic analysis of edge cases and failure modes, leading to bugs in production.

**Decision**: Add mandatory edge case and risk analysis phase between design review and test generation for major features.

**Key Features**:
- Systematic edge case enumeration
- Failure mode analysis
- Risk prioritization matrix (P0-P4)
- Test requirement generation
- P0 risks must have tests

**Rationale**:
- Prevents bugs before they're written
- Guides comprehensive test generation
- Identifies security issues early
- Documents "what could go wrong"
- Expected 60-80% reduction in edge case bugs

**Impact**: NEW_FEATURE_MAJOR workflow, test generation quality

**Alternatives Considered**:
- Leave edge case thinking to developers (rejected - inconsistent)
- Add to test plan only (rejected - comes too late)

**Author**: Chris Maury (with Claude assistance)

---

## 2025-01-31 - Concise Technical Report Format

**Context**: Initial hybrid model reports were too verbose (527 lines in CLAUDE.md, overly detailed compliance reports).

**Decision**: Reduce to concise technical report format. Move detailed instructions to skill file.

**Changes**:
- CLAUDE.md: 527 lines → 73 lines (86% reduction)
- All detailed instructions in skill file
- Compliance reports use compact format
- Remove excessive formatting/decoration

**Rationale**:
- Faster to read and understand
- Less noise, more signal
- Maintainable (skill file is single source of truth)
- Professional technical report style

**Impact**: All compliance reports, CLAUDE.md, install script output

**Alternatives Considered**:
- Keep verbose format (rejected - too much noise)
- Remove standards display entirely (rejected - defeats transparency goal)

**Author**: Chris Maury (with Claude assistance)

---

## 2025-01-31 - Skill Directory Structure

**Context**: Skills were not being recognized because of incorrect directory structure.

**Decision**: Use correct structure: `.claude/skills/{skill-name}/SKILL.md` instead of `.claude/skills/{skill-name}.md`

**Impact**: Skill recognition, install script, all repositories

**Rationale**: Follows Claude Code skill conventions

**Author**: Chris Maury (identified issue)

---

## 2025-01-31 - Workspace Management for Clean Repositories

**Context**: Need to keep repositories clean by separating temporary/intermediate files from final artifacts.

**Decision**: Add `.claude_workspace/` directory for all temporary files. Claude must use this for drafts, checklists, analysis, and any intermediate work.

**Key Rules**:
- ALL temporary files go in `.claude_workspace/`
- Workspace is gitignored (never committed)
- Final artifacts move from workspace → repository
- Organized subdirectories: drafts/, analysis/, checklists/, scripts/, notes/

**Rationale**:
- Prevents repository clutter
- Clear separation of working vs final files
- Easy cleanup
- Prevents accidental commits of temporary files
- Professional repository structure

**Impact**: All Claude interactions, all file creation workflows

**Alternatives Considered**:
- Use tmp/ directory (rejected - not descriptive enough)
- No workspace, just be careful (rejected - error-prone)
- Commit everything (rejected - clutters git history)

**Author**: Chris Maury

**Reversible?**: No - this is a core organizational principle

---

## 2025-01-31 - Design Review Enforcement with Phase Gates

**Context**: System had design review agents (architecture, security, cost) but nothing enforced that they actually ran and produced review artifacts before proceeding to testing/implementation. Gap between "having agents" and "requiring their output."

**Decision**: Add design-review-coordinator agent with phase gate enforcement.

**Key Features**:
- Orchestrates all design reviews (architecture, security, cost)
- Creates review artifacts in docs/reviews/
- Blocks progression without ALL required review artifacts
- Phase gates prevent skipping ahead
- Status checking for gate compliance

**Required Artifacts** (NEW_FEATURE_MAJOR):
- docs/reviews/architecture-{feature}.md
- docs/reviews/security-{feature}.md
- docs/reviews/cost-{feature}.md

**Workflow Enforcement**:
```
Design Doc → Design Review (GATE) → Edge Case Analysis (GATE) → Tests → Code
```

**Rationale**:
- Having review agents is useless if they're not required to run
- Review artifacts provide audit trail for human reviewers
- Phase gates prevent "ready, fire, aim"
- Parallel execution keeps process fast
- Clear gate status shows what's blocking progression

**Impact**: NEW_FEATURE_MAJOR and NEW_FEATURE_MINOR workflows, all feature development

**Alternatives Considered**:
- Manual checklist (rejected - not enforced)
- Single combined review (rejected - loses specialized expertise)
- Reviews optional (rejected - defeats quality purpose)
- Human-only reviews (rejected - AI can catch 80% of issues faster)

**Author**: Chris Maury

**Reversible?**: No - this is a core quality gate

---

## Template for Future Decisions

```markdown
## [YYYY-MM-DD] - [Decision Title]

**Context**: [Why was this decision needed? What problem does it solve?]

**Decision**: [What was decided?]

**Rationale**: [Why this approach? What makes it better?]

**Impact**: [Who/what is affected?]

**Alternatives Considered**: [What else was considered and why rejected?]

**Author**: [Who made the decision]

**Reversible?**: [Yes/No - Can this be changed later?]
```

---

**Note to Claude**: Check this file before suggesting to revert or remove features. Ask the user before undoing previous decisions documented here.
