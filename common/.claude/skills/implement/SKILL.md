---
name: implement
description: Implement a spec written by /spec, test-first, and report against its acceptance criteria.
argument-hint: <path to spec>
disable-model-invocation: true
---

Spec: $ARGUMENTS

If no spec path was given, or the file doesn't exist, ask for it and stop.

## 1. Read

Read the spec, CLAUDE.md, and the code the spec touches.
The spec is the source of truth. If it is ambiguous, contradicts the code, or misses a decision you need, list the gaps and stop. Don't guess, and don't fill gaps with your own decisions.

## 2. Tests first

For each acceptance criterion with a test name, write that test, with that name, where the project's standards put tests.
Run them and confirm they fail for the right reason (missing behavior, not a typo).

## 3. Implement

Make the smallest change that makes the tests pass and satisfies the Decisions.
- Nothing from Out of scope, and no refactors the spec doesn't ask for.
- Public API shapes exactly as the spec names them.

## 4. Validate

Run the project's checks from CLAUDE.md. If there are none, or they can't run here, say so. Never report a check you didn't run.
Fix failures and re-run until they pass. If a failure looks like a spec problem, stop and report it.

## 5. Review your diff

Read `git diff`. Every change must trace back to a Decision or an acceptance criterion; revert anything that doesn't.
Tick the acceptance criteria in the spec that a passing test now covers. Leave `(manual)` ones unticked.

## 6. Report

- Files changed
- Acceptance criteria: passing / failing / manual
- Checks run, with results; checks skipped and why
- Deviations from the spec, and open questions

Don't commit.
