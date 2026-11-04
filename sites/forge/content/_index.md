---
title: Faur
nav: What is Faur?
lead: Describe the outcome you want. Faur recommends the simplest agent that achieves it, generates it as an ordinary Pi project, and helps you revise it as your needs change.
---

**The specialized agent is the product. [Pi](https://github.com/earendil-works/pi)
is its runtime; Faur is the maker.** Faur composes Pi resources—agents,
skills, packages, MCP servers and commands—without adding a workflow engine or
scheduler of its own.

```sh
pi install git:github.com/mihaiiova/faur@v0.32.0
```

Then, in your Pi session: `/faur <the outcome you want>`.

## Built with each other

[Toad]({{< link toad >}}), the testing agent, was designed and generated with
Pi Forge, Faur's former name. Toad's current agent still pins an older Pi Forge
release; it has not yet been regenerated with Faur. Toad also tests Faur.

## The loop

| | |
|---|---|
| **Design** | `/faur` holds a design conversation, recommends the simplest system that fits, and asks questions that change the design. |
| **Generate** | It writes `.pi/system.yaml`, previews the generated files, and applies them after approval. |
| **Check** | `/faur check` validates the design, compares generated files, and reports what can be verified. |
| **Revise** | Your Pi with Faur installed proposes a change, previews it and applies it only if you approve. Native-file edits can be reconciled within the documented boundary. |

## What a generated project looks like

```text
you ──▶ /faur (maker, conversational)
          │  faur CLI: discover · validate · generate
          ▼
   <project>/.pi/system.yaml   record of the agreed design
   <project>/.pi/…             native Pi settings, agents, skills and prompts
   <project>/.faur/            maker metadata; isolated Pi home when needed
   <project>/run               optional Pi-configuration isolation launcher
          │
          ▼
   pi                           Pi runs the project without Faur or system.yaml
```

The native files govern execution. Faur does not run inside generated projects,
and projects pin only the packages their design needs—not Faur itself. Plain
`pi` inherits your user configuration; the optional `run` is not an OS sandbox.

## Next

- [Install Faur](/install/).
- [Build your first agent](/build-an-agent/).
