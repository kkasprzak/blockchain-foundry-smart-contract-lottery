---
description: Remind Claude about TDD implementation rules and identify process violations
---

Please read our implementation process in CLAUDE.md and identify which TDD rules you are violating or have violated in recent actions. Specifically review:

1. The mandatory TDD steps: Write ONE failing test → Run to confirm failure → Write minimal implementation → Run to confirm success → Refactor → Repeat
2. The rule about writing only ONE test at a time (never multiple tests simultaneously)
3. The prohibition against writing multiple features without tests first
4. The requirement to let each test drive the next minimal implementation
5. Any violations of the Red-Green-Refactor cycle
6. The rule that you must STOP immediately if writing production code without a failing test

After identifying violations, clearly state:
- What specific TDD rule(s) were broken
- What you did wrong in concrete terms
- What the correct next step should be according to our TDD process
- Confirm your understanding before proceeding with any code changes

This is a critical reminder because TDD adherence is MANDATORY and NON-NEGOTIABLE for this project.