---
title: Reference
group: Reference
weight: 40
lead: The `system.yaml` design record, the Faur CLI, and project setup checks.
---

## system.yaml

The last design agreed with Faur; native Pi files govern execution. Every agent names its own
model and the skills it receives:

```yaml
schema: 1
name: research-desk
orchestrator:
  name: lead
  model: openai-codex/gpt-6-sol
  thinking: medium
  tools: [read, grep, subagent]
agents:
  - name: researcher
    model: deepseek/deepseek-flash
    thinking: high
    tools: [read, grep]
    skills: [notes, house-style]
skills:
  - name: notes
    source: ../my-skills/notes            # vendored into .pi/skills/notes/ once
  - name: house-style
    source: npm:@acme/house-style@1.2.0   # pinned package
  - name: seo-audit                       # from skills.sh, pinned to a commit
    source: skills:coreyhaines31/marketingskills/skills/seo-audit@17772c7a80b7b8c7a47af30f648374cd8bd8adc5
```

Plain Pi loads its applicable context files, including parent `AGENTS.md`
files. Review untrusted instructions before a run.

Every field, validation rule and the file-ownership contract are in
[`schema.md`](https://github.com/mihaiiova/faur/blob/v0.32.0/skills/faur/schema.md).

## Faur CLI

The deterministic tool behind `/faur`, run from a Faur checkout:

| Command | |
|---|---|
| `faur.mjs discover [dir]` | Models, your skills, MCP servers and CLIs on this machine |
| `faur.mjs validate <dir>` | Validate a project's `system.yaml` |
| `faur.mjs generate <dir> [--dry-run]` | Preview, then write, the generated files |
| `faur.mjs modify <dir> [--dry-run]` | Apply a structured change |
| `faur.mjs check-agent <project> [--connect]` | Check capabilities outside a session; `--connect` also lists MCP tools |
| `faur.mjs search-skills <words…>` | Search skills.sh |
| `faur.mjs preview-skill <owner/repo@skill>` | Show a skill's files before installing |

All live in `skills/faur/faur.mjs`, for example
`node skills/faur/faur.mjs generate ./my-agent --dry-run`.

## Setup checks

A trusted project can declare setup steps, at project level or on an MCP or
CLI integration:

```yaml
setup:
  - description: Install the browser
    check: { file: ./browser }
    install: npm run install-browser
```

`/faur check` reports unmet steps, and `/faur setup` previews installs and asks
first. **Command checks run shell code with your permissions**, including
during checks and workflow startup, so use only declarations you trust. Steps
marked `needsRoot` are printed, not run.

## Tests

```sh
bash skills/faur/test/test.sh
```
