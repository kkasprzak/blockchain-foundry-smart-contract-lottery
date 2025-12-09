You are ending the current work session. Prepare the workspace for seamless resumption by following these steps:

## 1. Check Current Operational Status

Run these commands to gather operational context:
```bash
git status
git log --oneline -3
forge test
```

Identify:
- Current branch and issue number
- Recent commits (just to understand progress)
- Test status (passing/failing/skipped counts)
- Uncommitted changes (which files)

## 2. Update Plan File

**IMPORTANT: Plans are ALWAYS stored in `.ai/plans/` directory (NOT `.claude/plans/`)**

Find the plan file in `.ai/plans/` matching current issue (e.g., `.ai/plans/issue_9.md` for issue #9).

Update the plan with **CONCEPTUAL and STRATEGIC** information only:

**WHAT TO UPDATE:**
- ✅ What was accomplished (which features/cycles implemented)
- ✅ What remains to be done (which features/cycles pending)
- ✅ Design decisions and their rationale
- ✅ Implementation strategy and approach
- ✅ Architecture patterns used (CEI, reentrancy protection, etc.)

**WHAT NOT TO UPDATE (operational details handled by Startup Protocol):**
- ❌ Test counts (X passing, Y failing, Z skipped)
- ❌ Commit hashes and messages
- ❌ Git branch names
- ❌ Uncommitted file lists
- ❌ "Next steps when resuming" checklists

**WHY:** Startup Protocol will check operational status fresh at next session start. Plan file captures design knowledge, not transient operational state.

## 3. Present Summary to User

Show concise summary:

```
✅ Session End Summary

Work Completed:
- [List features/cycles implemented]

Remaining Work:
- [List features/cycles pending]

Operational Status (from Startup Protocol next session):
- Will check: git status, test results, commits

Plan updated: .ai/plans/issue_X.md
Ready for next session! 🎯
```

## 4. Key Principles

- **Plan = Knowledge**: Design decisions, architecture, strategy
- **Startup Protocol = Operations**: git status, test counts, commits
- **Separation of Concerns**: Don't duplicate what Startup Protocol provides
- **Focus on "Why" and "How"**: Not "What's the current git status"

Execute these steps now to end the current session properly.
