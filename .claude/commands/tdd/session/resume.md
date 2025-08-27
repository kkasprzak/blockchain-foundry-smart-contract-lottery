---
allowed-tools: Bash(cat:*), Bash(awk:*), Bash(head:*), Bash(grep:*), Bash(sed:*), Bash(date:*), Bash(git branch --show-current:*), Bash(git status:*)
argument-hint: [N sessions]
description: Summarize latest session notes and propose immediate next actions for the Navigator
---

## Context

- Current branch: !`git branch --show-current`
- Git status: !`git status --porcelain`
- Current time: !`date '+%Y-%m-%d %H:%M:%S'`

### Latest session excerpt(s)

- Source file: `.ai/session_notes.md` (newest sessions are at the top)
- You may pass a number to include multiple sessions (defaults to 1): `/session-resume 2`

```
!`awk -v n=${ARGUMENTS:-1} 'BEGIN{printing=0; hcount=0} { if($0 ~ /^# Session Notes - /){ hcount++; if(hcount==1) printing=1; else if(hcount>n) exit } if(printing) print }' .ai/session_notes.md`
```

### Focused sections from the latest session (top-most only)

- Feature Summary (with fallback if section missing):
```
!`awk 'BEGIN{infirst=0; p=0}
/^# Session Notes - /{if(infirst) exit; infirst=1}
/^## Feature Summary/{p=1; next}
/^## / && p{exit}
p{print}' .ai/session_notes.md`
```

- Fallback intro (first non-heading lines after the top session header):
```
!`awk 'BEGIN{infirst=0; started=0; count=0}
/^# Session Notes - /{if(infirst) exit; infirst=1; next}
/^## /{if(started && count>0) exit; next}
/^\s*$/ {next}
{ if(!started){started=1} if(count<5){print; count++} }' .ai/session_notes.md`
```

- Current Status:
```
!`awk 'BEGIN{infirst=0; p=0} /^# Session Notes - /{if(infirst) exit; infirst=1} /^## Current Status/{p=1; next} /^## / && p{exit} p{print}' .ai/session_notes.md`
```

- Next Tasks (supports "Next Tasks" or "Next Steps"):
```
!`awk 'BEGIN{infirst=0; p=0}
/^# Session Notes - /{if(infirst) exit; infirst=1}
/^## (Next Tasks|Next Steps)/{p=1; next}
/^## / && p{exit}
p{print}' .ai/session_notes.md`
```

- Important Reminders:
```
!`awk 'BEGIN{infirst=0; p=0} /^# Session Notes - /{if(infirst) exit; infirst=1} /^## Important Reminders/{p=1; next} /^## / && p{exit} p{print}' .ai/session_notes.md`
```

### Quick start candidates (from notes)

- Test Commands (if present):
```
!`awk 'BEGIN{infirst=0; p=0}
/^# Session Notes - /{if(infirst) exit; infirst=1}
/^### Test Commands/{p=1; print; next}
/^### / && p{p=0}
p{print}' .ai/session_notes.md`
```

- Code Quality Commands (if present):
```
!`awk 'BEGIN{infirst=0; p=0}
/^# Session Notes - /{if(infirst) exit; infirst=1}
/^### Code Quality Commands/{p=1; print; next}
/^### / && p{p=0}
p{print}' .ai/session_notes.md`
```

## Your task

Create a concise Navigator handoff based strictly on the latest session notes (and, if provided, the last N sessions). Do not invent details. If anything is unclear, make the smallest safe assumption and call it out.

Prioritize making it easy to resume work immediately.

## Output format

Produce ONLY the following Markdown, nothing else. Replace `[date/time]` with the Current time above and `[branch]` with the Current branch above:

```markdown
## Navigator Resume (for [date/time] on [branch])

- What we were doing: [1–2 sentences]
- Immediate next action: [single actionable step]

### Current Status
• [status point]
• [status point]

### Next Tasks
1. [next task]
2. [next task]
3. [next task]

### Quick Start
- [Command or file to open]
- [Command or file to open]

### Notes
- [Any important reminder or risk]
```

Guidelines:
- Base the resume on the top-most session block in `.ai/session_notes.md` (newest first). If a number N is provided, include insights from the last N sessions but keep the resume focused and concise.
- Prefer tasks and bullets exactly as written in the notes; do not change their meaning.
- In Quick Start, list up to 3 immediate commands or files to open. If none are present in the notes, suggest minimal safe defaults (e.g., `git status`, relevant test command if known, or opening a key file mentioned in notes).

