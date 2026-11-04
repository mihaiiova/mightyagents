---
title: Security and limits
group: Under the hood
weight: 60
lead: Toad is a tool for testing your own code with test accounts. Here is exactly what it protects, and what it doesn't.
---

## It runs with your permissions

The agent, its tools and the browser run as your user. Use Toad on code and
sites you trust, with test accounts and restricted keys.

## The CLI and API sandbox limits damage

It is not a security boundary for hostile code. Containers share the host
kernel, and both backends allow network access. Workspaces persist until
pruned and may contain sensitive data. Copying and workspace checks assume no
hostile process of your user is racing them.

`--sandbox none` removes even that: commands run on the machine as your
user. Use it only on disposable CI runners, for suites you trust.

## Credentials are protected on a best-effort basis, not isolated

- Handoffs carry only names (`{ "env": "NAME" }`), never values. The `.env`
  format is `NAME=value`, with optional matching quotes and no shell
  expansion. Duplicate, malformed, missing and empty referenced values are
  rejected. Don't give values to the coding agent in chat.
- Each run gets a mode-0600 file, in a mode-0700 folder, with only the values
  its handoff names. Web runs pass it to the browser launcher; CLI and API runs pass
  the variables to the sandboxed command. A run without credentials gets an
  empty file, never the shared store. Names that affect process startup or the
  container runtime (`PATH`, `LD_*`, `NODE_OPTIONS`, `DOCKER_*`, …) are
  rejected for CLI and API runs.
- The configured model provider keys are passed to the agent's environment. Pi Forge passes that
  whole environment to Pi, its tools and subprocesses, and other processes of
  your user can read it. A tested program can send credentials over the
  network or write them into its workspace.
- After the run, Toad removes the per-run file. If Forge reports incomplete
  cleanup, or the server is killed, the file stays in the runtime folder's
  `secrets/` and the result names it. Remove it once no process can still be
  using it.
- With `toad run --env NAME`, values come from the CI job's environment
  instead of `.toad/.env`, and the same rules apply once they are read. The
  agent inherits the whole job environment, other secrets included, so give
  the job only the secrets its suites need.
- Redaction of the report and result is best effort. Screenshots, page
  content, logs, files, transformed values and the Pi session transcripts in
  `runs/<id>/sessions/` can still expose secrets. Treat every run folder, and
  any CI artifact made from it, as sensitive.

## Paths are checked, not confined

`project_path` must be absolute and canonical. Symlinked projects and `.toad`
folders are rejected, and the `.env` file is opened without following
symlinks. These checks assume no hostile process is changing the project at
the same time.

## Web and API tests act on the target

The browser clicks, types and submits forms; API requests can create, change
or delete data. Point tests at a test or staging environment, not production data.

A suite's read-only default is an instruction to the agent, not an enforced
limit; `--allow-writes` only decides which suites `toad run` starts.

## Spending limits are approximate

`--max-cost` adds up the prices Pi records for each reply, checked every two
seconds, so a run can go slightly over before it stops, and a model without
catalog prices counts as free. Set a spending limit with your provider too.
