---
title: Faur
nav: What is Faur?
lead: Describe the outcome you want. Faur recommends the simplest agent that achieves it, generates it as an ordinary Pi project, and helps you revise it as your needs change.
---

**The specialized agent is the product. [Pi](https://github.com/earendil-works/pi)
is its runtime; Faur is the maker.** Faur composes Pi resources—agents,
skills, packages, MCP servers and commands—without adding a workflow engine,
scheduler or launcher of its own.

```sh
pi install git:github.com/mihaiiova/faur@v0.34.0
```

Then, in your Pi session: `/faur <the outcome you want>`.

## The loop

| | |
|---|---|
| **Research** | `/faur` reads the repository you name and the public pages you give it, then summarizes what it learned, separating facts from inferences. |
| **Design** | It recommends the simplest system that fits and asks only the questions that change the design. |
| **Generate** | It writes `.pi/system.yaml`, previews the generated files, and applies them after you confirm. |
| **Check** | `/faur check` validates the design, compares the generated files, and reports what it could verify. |
| **Revise** | `/faur <change>` proposes a revision with a diff and applies it only if you approve. Hand edits to native files are detected and offered for adoption, never overwritten. |

## What a generated project looks like

```text
you ──▶ /faur (maker, conversational)
          │  faur CLI: discover · fetch · validate · generate
          ▼
   <project>/.pi/system.yaml   record of the agreed design
   <project>/.pi/…             native Pi settings, agents, skills and prompts
   <project>/.faur/            capability manifest Faur derives
          │
          ▼
   pi                           Pi runs the project without Faur or system.yaml
```

The native files govern execution. Generated projects never pin Faur; they
pin only the packages their design needs, and a minimal agent pins none. Plain
`pi` adds your user-level Pi configuration and is not an isolated
environment; `/faur check` reports known conflicts.

## Next

- [Install Faur](/install/).
- [Build your first agent](/build-an-agent/).
