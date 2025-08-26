---
allowed-tools: Bash(git log:*), Bash(git status:*)
description: Generate notes from Pair Programming session
---

## Context
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -5`
- Git status: !`git status --porcelain`

## Your task

You are the Driver in our pair programming session. Your task is to generate concise session notes for the Navigator who needs to pause their work on implementing a new feature. These notes should quickly remind the Navigator of the work context when they return.

### Task Instructions

When the Navigator requests session notes or when pausing work, follow these steps:

1. **Ask the Navigator for additional context** before generating notes:
   - "Before I create the session notes, would you like to provide any additional information about our next tasks, work context, or other important details that should be captured?"
   - Wait for their response and incorporate any provided information

2. **Analyze the work done** based on commits and context

3. **Analyze our conversation history** combined with any additional context to extract key information:
   - Feature description
   - Current progress
   - Planned next steps
   - Any potential issues or important reminders

4. **Generate session notes** using the following structure:
   - Brief summary of the feature (2-3 sentences)
   - Current status of the implementation (3-5 bullet points)
   - Next tasks to be completed (3-5 bullet points)
   - Important reminders or potential issues (1-2 bullet points, if applicable)

5. **Write the notes to `.ai/session_notes.md`** - create this file if it doesn't exist, or update it with the latest session information.

### Output Format

Before generating the final notes, provide your analysis incorporating both conversation history and any additional context provided by the Navigator:

```
<conversation_breakdown>
Feature Description:
[Quote from our conversation]
Reasoning: [Explanation for including this information]

Current Progress:
[Quote from our conversation]
Reasoning: [Explanation for including this information]

Next Steps:
[Quote from our conversation]
Reasoning: [Explanation for including this information]

Important Reminders:
[Quote from our conversation]
Reasoning: [Explanation for including this information]
</conversation_breakdown>
```

Then write the session notes to `.ai/session_notes.md` in this format:

```markdown
# Session Notes - [Date/Time]

## Feature Summary
[2-3 sentence summary of what we're building]

## Current Status
• [Status point 1]
• [Status point 2]
• [Status point 3]

## Next Tasks
• [Task 1]
• [Task 2]
• [Task 3]

## Important Reminders
• [Reminder or potential issue if applicable]

---
*Generated automatically by Driver during pair programming session*
```

### Key Guidelines

- Keep notes concise and focused on quickly reminding the Navigator of work context
- Extract all information from our conversation history and any additional context provided by the Navigator
- Ensure the `.ai/` directory exists before writing the file
- If updating existing session notes, preserve previous sessions or clearly mark the new session
- Focus on actionable information that will help resume work efficiently

Remember: You're documenting our collaborative work so the Navigator can seamlessly continue when they return.