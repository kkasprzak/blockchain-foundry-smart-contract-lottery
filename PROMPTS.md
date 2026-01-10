# Prompts Library

Prompts organized by development phase. Subagents are defined in `.claude/agents/`.

---

## Planning Phase

### Story Planner

**Subagent:** `story-planner`

**Why:** Creates implementation plans for User Stories using Vertical Slices - organizes work by Acceptance Criteria (not technology layers), sorts from simplest to most complex, ensures each stage delivers testable value.

```
Use story-planner subagent to create implementation plan for US-XXX
```

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

*No prompts yet.*

---

## Testing Phase

*No prompts yet.*

---

## Deployment Phase

*No prompts yet.*
