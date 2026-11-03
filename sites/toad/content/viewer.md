---
title: The run viewer
nav: Run viewer
group: Using TOaD
weight: 40
lead: One local page with every run from every project, so you can see the screenshots and commands behind each verdict.
---

```sh
toad ui                 # http://127.0.0.1:8787, or the next free port
toad ui --port 9000
```

The viewer shows the runs of every project TOaD is set up in, newest first,
with a project filter. Open a run to see its scenarios, the report, every
screenshot and every recorded command.

It listens on localhost only.

## Projects in the list

A project joins the list when it is set up or runs a test.

```sh
toad projects                     # the projects in the list
toad projects forget /path/to/x   # drop one from the list (its files stay)
```

The list lives in `~/.config/toad/projects.json`. The runs themselves stay in
each project's `.toad/runs/`.
