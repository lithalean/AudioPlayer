# .claude/ Directory Structure
*Complete AI Collaboration Context System*

## 📁 Directory Layout
```
.claude/
├── context.md              # Main AI collaboration context
├── architecture.md         # Technical architecture decisions
├── roadmap.md              # Development roadmap and priorities
├── issues.md               # Bug tracking and technical debt
├── sessions/               # AI collaboration session logs
│   ├── 2025-06-15.md      # Daily session logs
│   └── weekly-summary.md   # Weekly progress summaries
└── templates/              # Code and design templates
	├── view-template.swift # SwiftUI view template
	└── model-template.swift # @Observable model template
```

## 📄 File Descriptions

### context.md
**Primary AI context file** - Contains current project state, architecture decisions, implementation status, technical debt, and development priorities. This is the main file Claude should read to understand project state.

### architecture.md  
**Technical architecture documentation** - Deep dive into SwiftUI patterns, @Observable usage, document architecture, cross-platform considerations, and performance optimizations.

### roadmap.md
**Development planning** - Feature roadmap, release planning, timeline estimates, risk assessment, and success metrics tracking.

### issues.md
**Bug and debt tracking** - Critical bugs, technical debt items, performance issues, and enhancement requests with priority levels.

### sessions/[date].md
**Daily AI collaboration logs** - Record of what was worked on, decisions made, code generated, and next session preparation.

### templates/
**Code templates and patterns** - Established patterns for views, models, services, and extensions that maintain consistency across the codebase.

---

## 🔧 Usage Instructions

### For Developers:
1. **Update context.md** after major changes
2. **Log sessions** in daily session files  
3. **Maintain templates** as patterns evolve
4. **Track issues** in issues.md with priority levels

### For Claude.ai:
1. **Always read context.md first** when starting a session
2. **Check recent session logs** to understand latest work
3. **Update context.md** after significant contributions
4. **Reference architecture.md** for technical decisions
5. **Log session summary** in sessions/ directory

---

## 📋 Template Files

### .claude/architecture.md Template:
```markdown
# Technical Architecture Deep Dive
*Darwin ARM64 SwiftUI Architecture Documentation*

## SwiftUI Architecture Patterns
[Detailed SwiftUI patterns and conventions]

## @Observable State Management  
[State management approaches and patterns]

## Document Architecture
[Document-based app implementation details]

## Cross-Platform Considerations
[Platform-specific implementations and adaptations]

## Performance Optimization
[Performance patterns and optimization strategies]
```

### .claude/roadmap.md Template:
```markdown
# Development Roadmap & Planning
*Strategic development planning and timeline*

## Current Phase: [Phase Name]
[Current development focus and objectives]

## Feature Development Pipeline
[Prioritized feature development queue]

## Release Planning
[Version planning and release timeline]

## Risk Assessment
[Technical and timeline risks with mitigation]

## Success Metrics
[Measurable success criteria and KPIs]
```

### .claude/issues.md Template:
```markdown
# Issues & Technical Debt Tracking
*Bug tracking and technical debt management*

## Critical Issues (P0)
[High-priority bugs that block functionality]

## High Priority Issues (P1)  
[Important bugs affecting user experience]

## Technical Debt (P2)
[Code quality improvements and refactoring needs]

## Enhancement Requests (P3)
[Nice-to-have features and improvements]

## Performance Issues
[Performance optimization opportunities]
```

### .claude/sessions/[date].md Template:
```markdown
# Claude.ai Session - [Date]
*AI Collaboration Session Log*

## Session Focus
[What was the main focus of this session]

## Work Completed
- [Task 1]: [Description and outcome]
- [Task 2]: [Description and outcome]

## Decisions Made
- [Decision 1]: [Rationale and impact]
- [Decision 2]: [Rationale and impact]

## Code Generated/Modified
- [File]: [What was changed and why]
- [File]: [What was changed and why]

## Issues Identified
- [Issue]: [Description and proposed resolution]

## Next Session Prep
- [Task]: [What to focus on next time]
- [Context]: [Important context for next session]

## Architecture Updates Needed
[Any updates needed to architecture.md or context.md]
```

---

## 🤖 AI Integration Workflow

### Session Startup:
1. Read `.claude/context.md` for current state
2. Check latest session log for recent work  
3. Review any critical issues in `issues.md`
4. Understand current development phase from `roadmap.md`

### During Development:
1. Reference `architecture.md` for technical decisions
2. Use templates from `templates/` for consistency
3. Track new issues in `issues.md`
4. Make architectural decisions based on established patterns

### Session Completion:
1. Update `context.md` with new state
2. Log session summary in `sessions/[date].md`
3. Update roadmap if priorities changed
4. Commit any new templates or patterns

---

This directory structure ensures that every Claude.ai session can quickly understand the project state, pick up where the last session left off, and maintain consistency in architectural decisions and code patterns.