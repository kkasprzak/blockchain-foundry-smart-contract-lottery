# Prompts Library

Prompts organized by development phase. Subagents are defined in `.claude/agents/`.

---

## Planning Phase

### Planning Workflow Summary

**Complete workflow for planning a User Story:**

1. **story-planner** → Creates `.ai/plans/issue_XX.md` with stages and test placeholders
2. **acceptance-test-creator** → Fills Acceptance Tests in the plan file
3. **task-creator** → Creates GitHub issues from complete plan (with tests)

**Example:**
```bash
# Step 1: Create plan
Break down US-017 into delivery stages

# Step 2: Fill tests
Fill acceptance tests for .ai/plans/issue_40.md

# Step 3: Create issues
Create tasks from .ai/plans/issue_40.md
```

---

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

**Why:** Creates Incremental Delivery Plans for User Stories using Vertical Slices methodology. Organizes work by Acceptance Criteria (not technology layers), sorts from simplest to most complex. Each stage delivers testable user value incrementally. Does NOT provide technical implementation details - focuses on WHAT to deliver, not HOW to build it. Creates `.ai/plans/issue_XX.md` with placeholders for Acceptance Tests (to be filled by acceptance-test-creator).

```
Break down US-012 into delivery stages
```

**Alternative prompts:**
- `Plan US-014 using Vertical Slices`

**Next step:** Use `acceptance-test-creator` to fill in the Acceptance Tests for each stage.

---

### Acceptance Test Creator

**Subagent:** `acceptance-test-creator`

**Why:** Generates Acceptance Tests for each stage in the Incremental Delivery Plan. Use AFTER `story-planner` to fill in the "Acceptance Tests" section in `.ai/plans/issue_XX.md` before creating GitHub issues. Replaces placeholders with minimal, focused test scenarios for a solo developer (executable in 15-20 minutes per stage). Prioritizes: AC verification, security (for blockchain features), and high-probability edge cases. Developer knows upfront how each stage will be verified.

```
Fill acceptance tests for .ai/plans/issue_60.md
```

**Alternative prompts:**
- `Generate acceptance tests for issue_60.md`
- `Add tests to plan in .ai/plans/issue_35.md`

**Output format (per stage):**
- MUST TEST: AC Verification
- MUST TEST: Security (if applicable)
- NICE TO HAVE
- Quick Checklist

**Next step:** Use `task-creator` to convert the complete plan (with tests) into GitHub issues.

---

### Task Creator

**Subagent:** `task-creator`

**Why:** Converts Incremental Delivery Plans into GitHub issues. Takes a COMPLETE plan file from `.ai/plans/` (with Acceptance Tests already filled) and creates individual GitHub issues for each stage with proper dependencies. Issues are created sequentially with correct dependency tracking using actual issue numbers. Always uses `feature` label. Has pre-approved permissions for `gh issue create/edit` commands. Each issue includes the Acceptance Tests from the plan.

```
Create tasks from .ai/plans/issue_35.md
```

**Alternative prompts:**
- `Convert .ai/plans/issue_44.md to tasks`
- `Create tasks from plan file .ai/plans/issue_35.md`

**Note:** Always specify the exact plan file path. Ensure acceptance tests are filled before running this.

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

### QA Manual Testing

**Built-in:** Core Claude Code functionality (no subagent)

**Why:** Activates Manual QA Tester mode following `.ai/qa-testing-protocol.md`. Tests Acceptance Criteria from user perspective without analyzing source code. Guides you step-by-step through testing scenarios, documents behavior, and reports bugs. Use when you need to verify that implemented features match the Acceptance Criteria defined in the plan.

```
Continue testing as QA
```

**Alternative prompts:**
- `Test as QA`
- `Act as QA tester`
- `Start QA testing session`

**What it does:**
1. Reads the current branch and identifies issue number
2. Loads the implementation plan from `.ai/plans/issue_XX.md`
3. Presents available stages and Acceptance Criteria to test
4. Asks which AC you want to test
5. Guides you step-by-step through test execution
6. Documents results as PASS/FAIL/BLOCKED
7. Creates bug reports in `.ai/bugs/` if issues found

---

---

## Deployment Phase

*No prompts yet.*
