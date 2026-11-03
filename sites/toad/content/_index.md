---
title: Toad
nav: What is Toad?
lead: A testing agent for the web apps, command-line programs and HTTP APIs you build. You say what should work, in plain words. Toad tests it and comes back with a verdict and the receipts to prove it.
---

Toad is built to be called by your coding agent: Claude Code, Pi, Codex,
Cursor or any MCP client. The agent hands Toad a test, Toad runs it
independently, and the agent gets back **evidence instead of its own opinion
of its work**.

```sh
npm install -g github:mihaiiova/toad && toad setup
```

## What you get back

Every run ends with:

- **A verdict**: `PASS`, `FAIL` or `ERROR`. A scenario that could not be run
  (the site was down, a secret was missing) is `ERROR`, never a quiet `FAIL`.
- **A report per scenario**: what was done, what was expected, what happened.
- **Receipts**: a screenshot for every web step, and a record of every
  command or request for CLI and API steps.

Everything is saved in your project under `.toad/runs/`, and you can browse
it in the [run viewer](/viewer/).

## What it tests

| | How |
|---|---|
| **Web apps** | A real headless Chromium on your machine, so `localhost` works. It clicks, types and submits forms. |
| **CLIs** | A copy of your project in a locked-down Linux container (Docker or Podman), or Bubblewrap on Linux. It never changes your files. |
| **HTTP APIs** | Requests from the same sandbox, with recorded responses and optional OpenAPI checks. |

## How a run works

1. You ask your coding agent, in plain words, to test something.
2. The agent writes a **handoff**: the target, the goal, and scenarios with
   expected outcomes. Secrets go in by name only, never by value.
3. Toad's **lead** agent splits the handoff into scenarios and gives each to a
   specialist: a **web-tester** that drives the browser, a **cli-tester**
   that runs commands, or an **api-tester** that sends HTTP requests.
4. The testers report only what they observed. The lead writes the report,
   and your agent gets the verdict, the report and the receipt paths.

More detail is in [How it's built](/how-its-built/).

## Built with Pi Forge

Toad's testing agent was designed and generated with
[Pi Forge]({{< link forge >}}), the workshop the Mighty Agents come from, and
it pins a Forge release like any other generated agent. In return, Toad is
what tests Pi Forge. Each keeps the other honest.

## Next

- [Install Toad](/install/), about five minutes.
- [Connect your coding agent](/connect/).
- [Test your first project](/test-a-project/).
