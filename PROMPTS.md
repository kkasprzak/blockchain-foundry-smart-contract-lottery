# Prompts Library

Prompts organized by development phase. Subagents are defined in `.claude/agents/`.

---

## Planning Phase

### Story Prioritizer

**Subagent:** `story-prioritizer`

**Why:** Analyzes User Stories and recommends optimal implementation order based on user value, business value, dependencies, complexity, available building blocks, and feedback loop speed. Use when deciding which User Story to implement next.

```
Which User Story next?
```

**Alternative prompts:**
- `Prioritize User Stories`
- `US-013 done. Reprioritize remaining stories.`

---

### Story Planner

**Subagent:** `story-planner`

**Why:** Creates Incremental Delivery Plans for User Stories using Vertical Slices methodology. Organizes work by Acceptance Criteria (not technology layers), sorts from simplest to most complex. Each stage delivers testable user value incrementally. Does NOT provide technical implementation details - focuses on WHAT to deliver, not HOW to build it.

```
Break down US-012 into delivery stages
```

**Alternative prompts:**
- `Plan US-014 using Vertical Slices`

---

### Task Creator

**Subagent:** `task-creator`

**Why:** Converts Incremental Delivery Plans into GitHub issues. Takes a plan file from `.ai/plans/` and creates individual GitHub issues for each stage with proper dependencies. Issues are created sequentially with correct dependency tracking using actual issue numbers. Always uses `feature` label. Has pre-approved permissions for `gh issue create/edit` commands.

```
Create tasks from .ai/plans/issue_35.md
```

**Alternative prompts:**
- `Convert .ai/plans/issue_44.md to tasks`
- `Create tasks from plan file .ai/plans/issue_35.md`

**Note:** Always specify the exact plan file path.

---

### Acceptance Test Creator

**Subagent:** `acceptance-test-creator`

**Why:** Generates Acceptance Tests for GitHub tasks/issues. Use after `task-creator` to fill in the "Acceptance Tests" section before development starts. Developer knows upfront how the task will be verified. Produces minimal, focused test scenarios for a solo developer (executable in 15-20 minutes). Prioritizes: AC verification, security (for blockchain features), and high-probability edge cases.

```
Generate acceptance tests for issue #59
```

**Alternative prompts:**
- `Create acceptance tests for #59`
- `What should I test for issue #59?`
- `Fill acceptance tests section for issue #59`

**Output format:**
- 🔴 MUST TEST: AC Verification
- 🔴 MUST TEST: Security (if applicable)
- 🟡 NICE TO HAVE
- ✅ Quick Checklist

---

## Session Startup

### Daily Session Startup Protocol

**Built-in:** Core Claude Code functionality (no subagent)

**Why:** Executes the Daily Session Startup Protocol from CLAUDE.md to prepare your work environment. Checks git status, identifies active GitHub issues, runs tests to find failing tests (Kent Beck warm start), checks for existing plans, and presents complete context. Use at the start of each session or when asking "what should we work on?"

```
Prepare environment to work on current task
```

**Alternative prompts:**
- `What are we working on?`
- `What's next?`
- `What should we do today?`
- `Start work session`

**What it does:**
1. Checks git status and current branch
2. Identifies active GitHub issues (in progress status)
3. Runs tests to find failing tests (Kent Beck technique)
4. Checks for existing implementation plans
5. Creates feature branch from latest main
6. Commits any pending changes
7. Presents complete context and next steps

---

## Code Review Phase

### Code Reviewer

**Subagent:** `code-reviewer`

**Why:** Reviews code for quality, security, and adherence to project conventions. Use after completing a logical chunk of work before committing.

```
Use code-reviewer to review my changes
```

---

## Implementation Phase

### Shadcn UI Components

**MCP Server:** `shadcn`

**Why:** Browse, search, and install Shadcn UI components using natural language. Automatically adds components with correct configuration.

**Browse & Search:**
```
Show me all available components in the shadcn registry
```
```
Find me a login form from the shadcn registry
```

**Install Components:**
```
Add the button component to my project
```
```
Add the button, dialog and card components to my project
```
```
Create a login form using shadcn components
```
```
Create a contact form using components from the shadcn registry
```

---

## Testing Phase

*No prompts yet.*

---

## Deployment Phase

*No prompts yet.*
