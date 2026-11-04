---
title: The run viewer
nav: Run viewer
group: Using Toad
weight: 40
lead: One local page with every run from every project, so you can see the screenshots and commands behind each verdict.
---

```sh
toad ui                 # http://127.0.0.1:8787, or the next free port
toad ui --port 9000
```

The viewer shows the runs of every project Toad is set up in, newest first,
with a project filter. Each run is listed by its title. Open one to see:

- the goal, and a tally of passed, failed and errored scenarios;
- each scenario with its result and its own receipts, and the setup
  commands when there were any;
- the report, every screenshot and every recorded command or request;
- for runs started by [`toad run`](/run-on-every-deploy/), a *toad run* tag,
  what the run cost and the models it used.

Two buttons copy the run's handoff, with every scenario or only the ones that
failed or errored, for your coding agent to run again. A run whose server
stopped before it finished is shown as interrupted, not as running.

It listens on localhost only.

## Projects in the list

A project joins the list when it is set up or runs a test.

```sh
toad projects                     # the projects in the list
toad projects forget /path/to/x   # drop one from the list (its files stay)
```

The list lives in `~/.config/toad/projects.json`. The runs themselves stay in
each project's `.toad/runs/`.
