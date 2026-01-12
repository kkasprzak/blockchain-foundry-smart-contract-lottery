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
