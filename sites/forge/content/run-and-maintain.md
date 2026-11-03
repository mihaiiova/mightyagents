---
title: Run and maintain
group: Running agents
weight: 30
lead: A generated agent starts with `./run`. From then on, `/faur` is the one command for checking and changing it.
---

## Start it

```sh
./run              # interactive
./run -p "…"       # one prompt, then exit
./run --workflow <name> --input key=value
```

`./run` isolates the project from your global Pi configuration: its own config
folder and its own Pi logins (`/login` once per project). On every start it
checks that each agent will get the tools and skills it is declared to have,
and names any that are missing.

The first `./run` installs the pinned packages, so it needs network access to
GitHub.

## Change it

Inside a generated project:

| Command | What it does |
|---|---|
| `/faur [request]` | Revise the agent, for example `/faur add a research specialist` or `/faur use a cheaper model for the writer`. When a proposal is ready you can **discuss**, **apply** or **discard** it. |
| `/faur check` | Validate `system.yaml`, compare the generated files with it, and run the launch check. |
| `/faur status` | Agents and models, capabilities, the pinned Forge release and whether a newer one exists, pending permission requests. |
| `/faur sync` | Move to the newest Forge release after two confirmations, or rebuild with the current one. |
| `/faur env [set NAME]` | Declare and set environment variables; values go to the project's gitignored `.env`. |
| `/faur permissions [add \| remove <name> \| review]` | Manage which commands agents may run. |

Headless sessions never apply a change.

## Pin, update, roll back

A generated project pins one Forge release in `.pi/settings.json`, for example
`git:github.com/mihaiiova/pi-forge@v0.29.1`. Nothing is copied into the
project, and Pi never moves a pinned tag by itself.

`/faur sync` asks twice:

1. **Run the new release to preview it?** The dialog names the tag, its commit
   and a link to the changes. Nothing is written yet.
2. **Apply it?** The preview shows the pin change and every file the new
   release generates differently. Approving writes them and installs the new
   pin.

Declining either step leaves the project unchanged. To roll back, use git:

```sh
git checkout <commit> -- .pi run README.md
```

Then restart `./run`, and Pi installs the older pin again.

## Credentials and trust

Declare variable names under `integrations.env` and set values with
`/faur env set NAME`, which asks for the value interactively, never through
the model. Don't put credentials in `--input`: workflow inputs become prompt
text.

**`./run` is not an OS sandbox.** Your shell environment is inherited, and
Pi, agents, tools and their subprocesses can access inherited credentials.
Tool approval and `secret: true` do not isolate values, and Forge does not
guarantee redaction of tool output, screenshots, logs or artifacts. Use
trusted agents and tools, and prefer restricted test accounts.
