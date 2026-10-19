---
name: spec
description: Grill the user about a task until every decision is settled, then write it up as a spec file for implementation.
argument-hint: <task description>
disable-model-invocation: true
---

Task: $ARGUMENTS

## 1. Explore

Read CLAUDE.md and the code the task touches before asking anything.
Facts are your job, never the user's: don't ask anything you can look up. Use an Explore subagent for wide searches.

## 2. Grill

Interview the user until you reach a shared understanding. Map the task as a **design tree**: every decision branches into the decisions that depend on it.

Work in **rounds**. The **frontier** is every open decision whose prerequisites are settled. Ask the whole frontier in one round, numbered, each with your recommended answer, worded so "yes" accepts it:

```
❓ **Q1** - **<title>**: <question, with options if there are any>

➡️ <recommended answer>
```

Then wait. A question that depends on another one still open this round belongs to a later round.
If a question needs a fact you're still looking up, ask the rest of the frontier now and hold back only what depends on it.

Done when the frontier is empty: every branch visited, nothing silently assumed. Ask the user to confirm before writing.

## 3. Write the spec

Write `docs/specs/<kebab-case-title>.md` with this template:

```md
# <Title>

## Goal
<1-3 sentences: the problem and the outcome, from the user's side.>

## Decisions
- <Each decision settled in the grill, with the reason when it isn't obvious.
  Name modules, types and public API shapes; no line numbers or code bodies.>

## Acceptance criteria
- [ ] `Method_Condition_Result`: <what it checks>
- [ ] (manual) <anything that can't be tested in code>

## Out of scope
- <What was raised and deliberately left out.>
```

- The implementer will not see this conversation. A decision that isn't in the spec doesn't exist.
- Write only what was settled. Don't add requirements or decisions of your own.
- Every acceptance criterion must be checkable; prefer test names over prose.
- Keep it short: no user stories, no restating the code.

Then give the user the path and stop. Don't implement.
