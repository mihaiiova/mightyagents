---
title: How it's built
group: Under the hood
weight: 50
lead: A small team of agents behind one MCP server. The server runs the workflow; the agents do the testing.
---

## The pieces

```
your coding agent
      │  MCP: run_project_test(handoff)
      ▼
toad mcp ─────────────── mcp/server.mjs
      │  runs the Forge workflow, maps the result back
      ▼
lead ─────────────────── plans scenarios, delegates, writes the report
 ├─ web-tester ───────── Chromium via Playwright MCP  → screenshots
 └─ cli-tester ───────── toad-exec in a sandbox       → command records
```

- **`agent/`** is the testing agent, a [Pi Forge](https://github.com/mihaiiova/pi-forge)
  project. A **lead** plans the request into scenarios and hands each to a
  specialist: a **web-tester** that drives Chromium through the
  [Playwright MCP](https://github.com/microsoft/playwright-mcp), or a
  **cli-tester** that runs commands through `agent/tools/toad-exec.mjs`. Its
  design is in `agent/.pi/system.yaml`.
- **`mcp/`** holds the MCP server (`server.mjs`), the run viewer (`ui.mjs`),
  setup (`setup.mjs`, `agent.mjs`) and the `toad` command (`cli.mjs`). The
  server runs the agent's workflow and maps the result onto the tool result.
  It holds no testing logic.
- **`skills/toad-mcp/SKILL.md`** is the guide served to coding agents.

The package ships the agent's definition. `toad setup` copies it and installs
its pinned Pi packages, and runs start Forge's workflow runner directly,
without a shell script. The model is DeepSeek, with your own key.

## Honest reports, by design

The lead never tests anything itself, and it is told to report only what the
testers observed: never to invent, soften or repair a result, and to keep
every receipt path exactly as given. A scenario that could not be run is
reported as `ERROR` with the reason, not as `FAIL`.

## How CLI tests run

Preparing a scenario copies the project to a new workspace under
`~/.cache/toad/scenarios/<id>`. The copy skips symlinks, `.git`, `.forge`,
`.toad`, `receipts`, `.env` and `.env.*` (except `.env.example`), common
credential folders and private-key files. This is a name-based filter, not
detection of every secret, so remove other credential files from the project
first.

Preparation checks that the sandbox starts and that only the workspace and
its home are writable. A failed preparation is an infrastructure error.
Nothing ever runs on the host instead.

### In a container

With Docker or Podman, on any OS, each command is a fresh `docker run` of the
project's image with the workspace mounted at `/work`, and:

- a read-only root filesystem and a private `/tmp`
- no Linux capabilities and no privilege escalation
- a process limit, and your user ID on Linux

Commands in one scenario share the workspace but not processes. The container
uses the runtime's default network: it can reach the internet, and your
machine as `host.docker.internal`, not as `localhost`. Selected credentials
reach it through a private env file that is deleted after the command.

### In Bubblewrap

On Linux, commands run in new user, PID, IPC and UTS namespaces with the
host's `/usr` and some system configuration read-only. They share the host
network, including `localhost`.

Either way, commands run through `/bin/sh` with no input unless provided,
stop after 120 seconds, and each produces a receipt. Exact secret values of at
least four characters are redacted from recorded text, but redaction is not
comprehensive.

## Use the agent without MCP

From a git checkout whose agent you have set up with `cd agent && ./run`
(`/login`, then exit):

```sh
cd agent
./run --workflow test \
  --input 'request=Test https://demo.playwright.dev/todomvc. Add "buy milk", complete it; expected: "0 items left".' \
  --input receipts=data/receipts/manual-1
```

The last line of output is JSON with `status` and the report in `answer`,
whose first line is `Verdict: PASS`, `FAIL` or `ERROR`.
