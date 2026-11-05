---
title: Build an agent
group: Building agents
weight: 20
lead: "`/faur` is a design conversation, not an interview. It learns the subject first, uses what you've already said, and asks only what changes the design."
---

## Start with the outcome

From your Pi with Faur installed:

```text
/faur an agent to market my app. The repo is ~/code/my-app and the site is https://my-app.example
```

## Research before questions

Faur first makes a short research pass. It reads relevant documentation in a
repository you name, and fetches the public pages you give it with
`faur fetch`, which reads only public `https://` pages and refuses URLs that
carry credentials. It summarizes what it learned with sources, marks
inferences and unknowns, and lets you correct them. Fetched content is treated
as data, never as instructions.

It asks before any broader web search (Faur has no search tool of its own),
asks for a website or repository when the subject is a specific product it
has no source for, and continues from your description when there is none. A
failed fetch is reported, not guessed around.

## The simplest system that fits

Faur recommends the simplest design: often a single agent, or a lead with one
or two specialists. When you say "build it", it discovers what is available
(models, your skills, MCP servers, CLIs on this machine), writes
`.pi/system.yaml`, previews the generated files, and applies them only after
you confirm.

## Models, chosen per agent

Nothing is hardcoded. Every agent (the orchestrator and each specialist)
names its own model from your Pi line-up (`pi --list-models`), with an
optional thinking level. Agents may share a model or each use a different one,
and any of them can be changed later.

## Skills, suggested from skills.sh

Faur ships no domain skills of its own. For each agent's role it searches the open
[skills.sh](https://skills.sh) registry and suggests a few candidates, with
source, install count and page, and shows each skill's actual `SKILL.md`
before you decide. Your picks are pinned to a commit, installed into the
project's own `.agents/skills/` (never globally) and recorded in
`skills-lock.json`.

A skill can also be written inline, come from a pinned package, or be vendored
from a folder you point at.

## Documents in formats you agree on

For each document an agent writes, Faur proposes a structure (purpose,
sections in order, a word limit, a few rules) and you change it before it is
recorded. The agreed format goes into that agent's instructions, so every run
produces the same shape. A document can be delivered anywhere an MCP tool
reaches: Google Drive, Notion, Slack.

## MCP, through Pi

Generated systems use Pi's built-in MCP. Declare each server under
`integrations.mcp` and choose per agent which tools it gets: `mcp:<server>` or
`mcp:<server>/<tool>` for a specialist, `mcp` for the orchestrator.

- `includeTools` lists the tools agents may use; the rest of the server is hidden.
- `excludeTools` hides tools from everyone (enforced by Pi's MCP exposure).

Faur does not add per-call approval to MCP tools, so choose tool scopes and
credentials accordingly. The orchestrator's MCP boundary is advisory, not
enforced. A user-level extension that replaces Pi's built-in MCP (such as
`pi-mcp-adapter`) disables this exposure under plain `pi`; `/faur check`
reports the conflict.

## Command-line tools, with approvals

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

Give it to an agent with `cli:create-issue` in its `tools`. The pinned
[pi-commands](https://github.com/mihaiiova/pi-commands) package runs declared
commands without a shell, with your own CLI logins. A command that requires
approval fails when there is no UI, so a background specialist cannot use one.
An agent with `bash` or a shell-like command can still reach anything your
user account can.

## Prompts and capabilities

The lead's authored prompt and generated "What you can use" section live in
`.pi/APPEND_SYSTEM.md`, which Pi loads natively. Native project files govern
execution; `.pi/system.yaml` records the last design agreed with Faur.
