---
title: Pi Forge
nav: What is Pi Forge?
lead: Describe the outcome you want. Forge recommends the simplest agent that achieves it, generates it as an ordinary Pi project, and keeps it working as your needs change.
---

**The specialized agent is the product. [Pi](https://github.com/earendil-works/pi)
is its runtime.** Forge composes Pi's own resources (agents, skills, packages,
MCP servers, commands, workflows and permissions) and adds no workflow engine
or scheduler of its own.

```sh
pi install git:github.com/mihaiiova/pi-forge@v0.29.1
```

Then, in any Pi session: `/faur <the outcome you want>`.

## Built with each other

[Toad]({{< link toad >}}), the testing agent, is a Pi Forge
project: its lead, web-tester and cli-tester were designed and generated with
Forge, and Toad pins a Forge release like any other generated agent. In
return, Toad is what tests Pi Forge. Each keeps the other honest.

## The loop

| | |
|---|---|
| **Design** | `/faur` holds a design conversation, recommends the simplest system that fits, and asks only questions that change the design. |
| **Generate** | It writes `.pi/system.yaml`, previews the generated files, and writes them only after you confirm. Generation is deterministic and idempotent, and never silently overwrites your edits. |
| **Check** | `/faur check` validates the design, compares generated files, and reports what each agent can actually use: live, last seen, missing or not verifiable. |
| **Revise** | Inside a project, `/faur <request>` proposes a small change. Forge shows the diff and applies it only if you approve. |

## What a generated agent looks like

```text
you ──▶ /faur (builder, conversational)
          │  forge CLI: discover · validate · generate --dry-run · generate
          ▼
   <project>/.pi/system.yaml   compact desired state (schema 1)
   <project>/.pi/…             native Pi files: settings, agents, skills, mcp.json, prompts
   <project>/run               launcher with its own Pi home and logins
   <project>/.forge/           build record, capability manifest, isolated Pi home
          │
          ▼
   ./run, ./run -p "…"   Pi runs the agent; /faur revises it in place
```

> **Coming next: Faur.** Forge is becoming **Faur**, and generated projects
> are becoming ordinary Pi projects that run with plain `pi`, with Faur
> uninstalled. The command is already `/faur`. These docs describe the current
> release.

## Next

- [Install Pi Forge](/install/).
- [Build your first agent](/build-an-agent/).
