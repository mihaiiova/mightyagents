---
title: Build an agent
group: Building agents
weight: 20
lead: "`/faur` is a design conversation, not an interview. It uses what you've already said and asks only what changes the design."
---

## Start with the outcome

From any Pi session outside a Forge project:

```text
/faur a desk that reads new papers on agents every Monday and writes me a one-page brief
```

Forge recommends the simplest system that fits: often a single agent, or a
lead with one or two specialists. When you say "build it", it runs
`forge discover` (models, your skills, MCP servers, CLIs on this machine),
writes `.pi/system.yaml`, previews the generated files, and applies them only
after you confirm.

## Models, chosen per agent

Nothing is hardcoded. Every agent (the orchestrator and each specialist)
names its own model from your Pi line-up (`pi --list-models`), with an
optional thinking level. Agents may share a model or each use a different one,
and any of them can be changed later.

## Skills, suggested from skills.sh

Forge ships no skills of its own. For each agent's role it searches the open
[skills.sh](https://skills.sh) registry and suggests a few candidates, with
source, install count and page, and shows each skill's actual `SKILL.md`
before you decide. Your picks are pinned to a commit, installed into the
project's own `.agents/skills/` (never globally) and recorded in
`skills-lock.json`.

A skill can also be written inline, come from a pinned package, or be vendored
from a folder you point at.

## Documents in formats you agree on

For each document an agent writes, Forge proposes a structure (purpose,
sections in order, a word limit, a few rules) and you change it before it is
recorded. The agreed format goes into that agent's instructions, so every run
produces the same shape. A document can be delivered anywhere an MCP tool
reaches: Google Drive, Notion, Slack.

## MCP, through Pi

Generated systems use Pi's built-in MCP; there is nothing extra to install.
Declare each server under `integrations.mcp` and choose per agent which tools
it gets: `mcp:<server>` or `mcp:<server>/<tool>` for a specialist, `mcp` for
the orchestrator.

- `includeTools` lists the tools agents may use.
- `excludeTools` hides tools from everyone.
- `approveTools` makes a tool ask you before every call. Without a UI, such a
  call is blocked.

## Command-line tools, with permissions

Agents can run tools you already use (`gh`, `wrangler`, your own scripts)
through declared commands instead of a full shell. Each one is a fixed shape
where the agent fills in only the `{placeholders}`:

```yaml
integrations:
  cli:
    - name: create-issue
      command: gh
      args: [issue, create, --repo, you/your-app, --title, "{title}", --body-file, "{body:file}"]
      approve: true   # the default: you approve each run
```

Give it to an agent with `cli:create-issue` in its `tools`. Commands run
without a shell, with your own CLI logins. When the orchestrator needs a
command it has no tool for, it asks with `request_permission`: allow once,
always (saved to `system.yaml`), or deny.

## Memory and prompts

- **Memory is always on.** The orchestrator keeps short notes (up to 4,000
  characters) in `.pi/MEMORY.md`: corrections, preferences, and what worked
  when something failed. It's plain Markdown you can edit.
- **Prompts describe roles, not tool manuals.** What an agent can use is
  generated from `system.yaml` into a "What you can use" section, so removing
  an integration also removes it from what the agent is told.
