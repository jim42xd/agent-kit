# agent-kit

Shared Claude Code setup for my projects: code standards, settings, and (soon) skills and agents.
One source of truth, installed into each project and re-run to update.

## Quick Start

From your project's root folder:

```sh
curl -fsSL https://raw.githubusercontent.com/jim42xd/agent-kit/main/install.sh | bash
```

The profile is detected automatically (Unity projects get `unity`). To pick it yourself:

```sh
curl -fsSL https://raw.githubusercontent.com/jim42xd/agent-kit/main/install.sh | bash -s -- unity
```

Requires `curl`, `tar` and `jq`. Works on Linux and macOS (Git Bash on Windows).

## What gets installed

`common/` is installed first, then the profile folder (e.g. `unity/`):

| File | On install / update |
|---|---|
| `.claude/settings.json` | Merged; your project's own entries are kept |
| `CLAUDE.md` | Created from the template if missing; otherwise only missing `@` imports are added |
| Everything else (`.editorconfig`, `.claude/code_standards.md`, skills, agents) | Overwritten |

Change shared files here, not in projects, or the next update overwrites them.
Settings entries removed from the kit are not removed from projects; delete those by hand.

## Options

| Env var | Default | Use |
|---|---|---|
| `AGENT_KIT_REF` | `main` | Install a tag or commit |
| `AGENT_KIT_REPO` | `jim42xd/agent-kit` | Install from a fork |

## Developing

Clone the repo, edit, then run the local copy against a project:

```sh
~/projects/agent-kit/install.sh [profile] [project-dir]
```

Add a skill or agent by dropping it in `common/.claude/skills/<name>/SKILL.md` or
`<profile>/.claude/agents/<name>.md`; the next install copies it.
