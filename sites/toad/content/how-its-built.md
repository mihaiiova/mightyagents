---
title: How it's built
group: Under the hood
weight: 50
lead: A small team of agents behind one MCP server and one command. Both run the same workflow; the agents do the testing.
---

## The pieces

```
your coding agent              CI, or you
      │  MCP: run_project_test     │  toad run (saved suites)
      ▼                            ▼
toad mcp ── mcp/server.mjs     toad run ── mcp/toad-run.mjs
      └─────────────┬──────────────┘
                    ▼
run engine ───────────── mcp/run.mjs: setup, the Forge workflow, results
      ▼
lead ─────────────────── plans scenarios, delegates, writes the report
 ├─ web-tester ───────── Chromium via Playwright MCP  → screenshots
 ├─ cli-tester ───────── toad-exec in a sandbox       → command records
 └─ api-tester ───────── curl in the same sandbox     → request records
```

- **`agent/`** is the testing agent, generated with Pi Forge (the former
  name of [Faur]({{< link faur >}})). Toad's current agent still pins Pi Forge
  v0.29.1; it has not yet migrated to Faur v0.32.0. A **lead** plans the request into scenarios and hands each to a
  specialist: a **web-tester** that drives Chromium through the
  [Playwright MCP](https://github.com/microsoft/playwright-mcp), or a
  **cli-tester** or **api-tester** that runs commands or HTTP requests through
  `agent/tools/toad-exec.mjs`. Its
  design is in `agent/.pi/system.yaml`.
- **`mcp/`** holds the run engine (`run.mjs`), which runs any setup
  commands and the agent's workflow and maps the result onto a verdict and
  each scenario's result; the MCP server (`server.mjs`) and `toad run`
  (`toad-run.mjs`), which both use it; the run viewer (`ui.mjs`); setup
  (`setup.mjs`, `agent.mjs`) and the `toad` command (`cli.mjs`). None of them
  holds testing logic.
- **`skills/toad-mcp/SKILL.md`** is the guide served to coding agents.

The package ships the agent's definition. `toad setup` copies it and installs
its pinned Pi packages, and runs start the pinned Pi Forge workflow runner directly,
without a shell script. You choose the lead and tester models and provide your own provider keys.
A run on other models (from `toad.yaml` or `toad run --model`) uses a cached
copy of the agent with those models applied, so the shared agent never
changes under a run in progress.

Each project run keeps its Pi sessions in its folder. That is where the run's
cost comes from: Toad adds up the price Pi records for every reply of the
lead and each tester, which is also how `toad run --max-cost` knows when to
stop.

## Honest reports, by design

The lead never tests anything itself, and it is told to report only what the
testers observed: never to invent, soften or repair a result, and to keep
every receipt path exactly as given. A scenario that could not be run is
reported as `ERROR` with the reason, not as `FAIL`. The report starts with a
`Results:` block, one line per scenario by its exact name; Toad reads it, and
a scenario missing from it counts as `ERROR`.

## How CLI and API tests run

API tests send requests with `curl` in the same sandbox as CLI tests. An
optional OpenAPI description lets the tester check responses against it.

Preparing a scenario copies the project to a new workspace under
`~/.cache/toad/scenarios/<id>`. The copy skips symlinks, `.git`, `.forge`,
`.toad`, `receipts`, `.env` and `.env.*` (except `.env.example`), common
credential folders and private-key files. This is a name-based filter, not
detection of every secret, so remove other credential files from the project
first.

Preparation checks that the sandbox starts and that only the workspace and
its home are writable. A failed preparation is an infrastructure error.
Nothing ever runs on the host instead, unless you ask for it with
`--sandbox none`.

When a handoff has setup commands, Toad runs them once in a prepared
workspace, and every scenario's workspace starts as a copy of it, installs
included.

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

### Without a sandbox

Only when you pass `--sandbox none` to `toad run` (or set
`TOAD_CLI_SANDBOX=none`), for CI runners without Docker, Podman or
Bubblewrap: commands run on the machine as your user, in the copied
workspace, with only `PATH`, a `HOME` and `TMPDIR` inside the workspace, and
the selected credentials. There is no isolation, and the receipts say so.

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
whose first line is `Verdict: PASS`, `FAIL` or `ERROR`, followed by a
`Results:` block with one `- PASS | <scenario name>` line per scenario.
