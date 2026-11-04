---
title: Test a project
group: Using Toad
weight: 30
lead: You don't write test code. You ask your coding agent, and it writes the handoff for Toad.
---

## 1. Ask your agent

In your project, ask your coding agent in plain words. For example:

> Set up Toad in this project, then use it to test the sign-up flow on
> http://localhost:3000: a new user can register and lands on the dashboard.

> Use Toad to test our CLI: `node dist/cli.js --help` lists every command,
> and `init` in an empty folder creates `config.json`.

> Test the orders API on http://localhost:8080/api against `openapi.yaml`:
> creating an order returns 201, and a request without a token gets 401.

The agent calls `setup_project` once, writes a handoff (the target, the goal,
and scenarios with expected outcomes) and calls `run_project_test`. It gets
back the verdict, each scenario's result, the report and the receipt paths.

To keep the test, ask for a suite: *"Save that as a Toad suite tagged
smoke."* The agent writes `.toad/suites/<name>.yaml`, which you commit and
[run on every deploy](/run-on-every-deploy/).

### Before you ask

- **Web apps:** start the app first. The browser runs on your machine, so
  `localhost` works. Use a test or staging environment: Toad clicks, types
  and submits forms.
- **CLIs:** Toad copies the project into a fresh workspace and runs each
  command in a Linux container. It never changes your files. Build the
  program first, or let the scenario build it. Dependencies installed on a Mac
  or Windows machine may not run in Linux (native modules especially); a
  scenario can run `npm ci` itself.
- **APIs:** start the API first and use test data. Requests run in the same
  sandbox as CLI commands. For containers, a local API must listen on
  `0.0.0.0`; Toad directs the tester to `host.docker.internal`. Name an
  OpenAPI description to check responses against it.

### What makes a good test

The more specific the ask, the more useful the verdict:

- **Name the outcome you can see.** "Lands on the dashboard and shows the
  user's email" beats "sign-up works".
- **Include a failure case.** "A duplicate email shows an error" catches as
  much as the happy path.
- **Say what's off limits.** "Don't touch existing users" ends up in the
  handoff's limitations.
- **Give each scenario a distinct name.** Results come back by name, and the
  run page shows each one with its own receipts.

## 2. Save defaults (optional)

Setup creates `.toad/toad.yaml`. Fill it in, and your agent can leave the
target out of every handoff:

```yaml
web:
  url: http://localhost:3000
cli:
  workdir: .                  # relative to the project, or absolute
  program: node dist/cli.js
  image: node:22-bookworm     # the container image CLI commands run in
  setup:                      # run once in the sandbox before any scenario
    - npm ci --ignore-scripts
api:
  url: http://localhost:8080/api
  spec: openapi.yaml          # relative to workdir, which defaults to the project
models:                       # optional: this project's models, over toad setup's
  lead: anthropic/claude-sonnet-5-5
  tester: anthropic/claude-haiku-5-5
timeout_minutes: 15
```

It holds no secrets, so commit it. Pick an `image` with your CLI's runtime, for
example `python:3.12` or `golang:1.23`.

### Setup commands

`setup` (for `cli` and `api`) lists commands Toad runs once, in the sandbox,
before any scenario: installing dependencies, or a tool the tests need that
your project does not declare. Every scenario starts from a copy of the
result, and each command is recorded under `receipts/setup/`. If one fails,
the run ends as `ERROR` with `status: setup_failed` and no scenario runs. The
sandbox's root is read-only, so install locally:

```yaml
cli:
  setup:
    - npm ci --ignore-scripts
    - npm install --no-save some-tool@1.2.3   # its command is node_modules/.bin/some-tool
```

By default a tester that finds a program or module missing reports it as a
missing prerequisite (`ERROR`) rather than installing it. A handoff with
`"allow_installs": true` lets the tester install it inside the sandbox,
record the install, and retry.

## 3. Add test logins (if needed)

Put test-only values in `.toad/.env` **yourself**, in your editor, one
`NAME=value` per line:

```sh
TOAD_TEST_EMAIL=tester@example.com
TOAD_TEST_PASSWORD=a-test-password
```

Then tell your agent the names, never the values. Toad passes only the names
a handoff asks for to that run: the browser types them into the page, or CLI
commands and API requests read them as `$NAME`. `.toad/.gitignore` keeps `.env` and `runs/`
out of git.

## What setup creates

```
<project>/.toad/
├── toad.yaml        project defaults (commit it)
├── .env             secret values (ignored by git)
├── .env.example     the names, for your team (commit it)
├── .gitignore
├── suites/          saved suites for toad run (commit them)
│   └── example.yaml     a commented template
└── runs/            one folder per run (ignored by git)
    └── 2026-11-02T15-04-17-657Z-<id>/
        ├── handoff.yaml     what was asked, with defaults filled in
        ├── state.json       progress, verdict, each scenario's result, cost
        ├── reports/report.md
        ├── receipts/        screenshots, page snapshots, command and request records
        └── sessions/        the agents' Pi sessions (transcripts)
```

## Reading the result

The result has two parts that are easy to mix up:

- **`verdict`** is about your app: `PASS`, `FAIL`, `ERROR`, or `UNKNOWN`
  when the report has none.
- **`status`** is about the run itself: `ok`, `timeout`, `blocked`,
  `cancelled`, `error`, `configuration_error`, `setup_failed` or
  `cost_limit`.

**`scenarios`** gives each scenario's result by its name. A scenario the
report left out is `ERROR` with `missing: true`, never a silent pass, and the
verdict never contradicts a scenario: any `FAIL` makes the run `FAIL`.

A failing test is a normal result. A run that could not complete is a tool
error. The full shape is in the [reference](/reference/#handoff).
