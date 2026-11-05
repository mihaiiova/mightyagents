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
[`schema.md`](https://github.com/mihaiiova/faur/blob/v0.33.0/skills/faur/schema.md).

## Faur CLI

The deterministic tool behind `/faur`, run from a Faur checkout as
`node src/faur.mjs <command>`:

| Command | |
|---|---|
| `discover [dir] [--cli <name>]…` | Models, your skills, MCP servers and the CLIs you name |
| `fetch <url> [--offset <n>]` | Read a public `https://` page as untrusted text (a GitHub repo URL returns its README) |
| `validate <dir>` | Validate a project's `system.yaml` |
| `generate <dir> [--dry-run] [--yes]` | Preview, then write, the generated files |
| `modify <dir> [--dry-run] [--yes]` | Reconcile the project with its design |
| `change <dir> --operations <file> [--dry-run] [--yes]` | Preview or apply a structured change |
| `check-agent <project> [--connect]` | Check capabilities without a model call; `--connect` starts MCP servers |
| `search-skills <words…>` | Search skills.sh |
| `preview-skill <owner/repo@skill>` | Show a skill's files before installing |
| `import <dir>` | Reconstruct `system.yaml` from an existing Pi project |

For example: `node src/faur.mjs generate ./my-agent --dry-run`.

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
first. **Command checks run shell code with your permissions**, so use only
declarations you trust. Steps marked `needsRoot` are printed, not run.

## Tests

```sh
bash test/test.sh
```

Opt-in gates: `RUN_FAUR_DELEGATION_TEST=1` (real Pi with a local fake model),
`RUN_FAUR_LIVE_TESTS=1` and `RUN_CLEAN_ENV_TEST=1` (real providers; they cost
tokens).
