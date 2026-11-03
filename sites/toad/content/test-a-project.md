---
title: Test a project
group: Using TOaD
weight: 30
lead: You don't write test code. You ask your coding agent, and it writes the handoff for TOaD.
---

## 1. Ask your agent

In your project, ask your coding agent in plain words. For example:

> Set up TOaD in this project, then use it to test the sign-up flow on
> http://localhost:3000: a new user can register and lands on the dashboard.

> Use TOaD to test our CLI: `node dist/cli.js --help` lists every command,
> and `init` in an empty folder creates `config.json`.

The agent calls `setup_project` once, writes a handoff (the target, the goal,
and scenarios with expected outcomes) and calls `run_project_test`. It gets
back the verdict, the report and the receipt paths.

### Before you ask

- **Web apps:** start the app first. The browser runs on your machine, so
  `localhost` works. Use a test or staging environment: TOaD clicks, types
  and submits forms.
- **CLIs:** TOaD copies the project into a fresh workspace and runs each
  command in a Linux container. It never changes your files. Build the
  program first, or let the scenario build it. Dependencies installed on a Mac
  or Windows machine may not run in Linux (native modules especially); a
  scenario can run `npm ci` itself.

### What makes a good test

The more specific the ask, the more useful the verdict:

- **Name the outcome you can see.** "Lands on the dashboard and shows the
  user's email" beats "sign-up works".
- **Include a failure case.** "A duplicate email shows an error" catches as
  much as the happy path.
- **Say what's off limits.** "Don't touch existing users" ends up in the
  handoff's limitations.

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
timeout_minutes: 15
```

It holds no secrets, so commit it. Pick an `image` with your CLI's runtime, for
example `python:3.12` or `golang:1.23`.

## 3. Add test logins (if needed)

Put test-only values in `.toad/.env` **yourself**, in your editor, one
`NAME=value` per line:

```sh
TOAD_TEST_EMAIL=tester@example.com
TOAD_TEST_PASSWORD=a-test-password
```

Then tell your agent the names, never the values. TOaD passes only the names
a handoff asks for to that run: the browser types them into the page, or CLI
commands read them as `$NAME`. `.toad/.gitignore` keeps `.env` and `runs/`
out of git.

## What setup creates

```
<project>/.toad/
├── toad.yaml        project defaults (commit it)
├── .env             secret values (ignored by git)
├── .env.example     the names, for your team (commit it)
├── .gitignore
└── runs/            one folder per run (ignored by git)
    └── 2026-11-02T15-04-17-657Z-<id>/
        ├── handoff.yaml     what was asked, with defaults filled in
        ├── reports/report.md
        └── receipts/        screenshots, page snapshots, command records
```

## Reading the result

The result has two parts that are easy to mix up:

- **`verdict`** is about your app: `PASS`, `FAIL`, `ERROR`, or `UNKNOWN`
  when the report has none.
- **`status`** is about the run itself: `ok`, `timeout`, `blocked`,
  `cancelled`, `error` or `configuration_error`.

A failing test is a normal result. A run that could not complete is a tool
error. The full shape is in the [reference](/reference/#handoff).
