---
title: Run and maintain
group: Running agents
weight: 30
lead: Run a generated project with plain Pi. Maintain it from your own Pi with Faur installed, or edit native files directly.
---

## Start it

```sh
cd /path/to/project
pi                                      # interactive
pi --approve -p "A request" </dev/null  # headless one-shot
pi --approve -p "/skill:workflow A request" </dev/null
```

A workflow is a skill. In print mode, Pi waits for stdin to close; `--approve`
allows the project resources to load in a headless run. A successful exit means
the run completed, not necessarily that the task succeeded. Pi installs
missing pinned project packages at startup unless offline.

Plain `pi` inherits your user-level Pi configuration. Projects with MCP servers
also get an optional `./run`, which sets `PI_CODING_AGENT_DIR` to the project's
`.faur/pi-home` and starts Pi. It isolates the Pi agent directory, **not the
operating system**: environment variables and credentials are inherited,
`~/.agents/skills` and parent `AGENTS.md` files can still load, and tools run
with your permissions. A global extension that replaces Pi's built-in MCP can
change enforcement under plain `pi`; `/faur check` reports the conflict.

## Change it

From your own Pi with Faur installed, in the project directory:

| Command | What it does |
|---|---|
| `/faur [request]` | Propose a revision; discuss, apply or discard the preview. |
| `/faur check` | Validate the record, compare files and report capability evidence. |
| `/faur status` | Summarize the design and last check. |
| `/faur sync` | Preview rebuilding with the Faur you are running; apply only after confirmation. |
| `/faur env` | Report declared variable status without showing values. |
| `/faur permissions [add \| remove <name>]` | Manage declared commands. |
| `/faur drift adopt <path>` | Preview adopting supported native edits into the design record. |
| `/faur drift reapply <path>` | Preview reapplying supported files from the design. |
| `/faur drift reconcile <path> adopt=…` | Preview a supported selected-field reconciliation. |

Faur reports known native-only features and preserves them or refuses a
conflicting change when it cannot safely preserve them. Detection is not a
complete inventory of every Pi feature; ambiguous cases need manual attention.
Changes are previewed, approved and reversible with git. Headless sessions
cannot approve them.

## Credentials and trust

Set variables in the environment Pi starts in, or load a gitignored `.env`
with direnv. **Pi does not read `.env` itself**. Configure integration secret
files outside Faur, and configure the integration to read them. Never put
secrets into prompts.

Pi, agents, tools and subprocesses can access inherited credentials; neither
an optional launcher nor tool approval gives same-user confidentiality. Use
trusted agents, tools and restricted test accounts. Output, screenshots, logs
and artifacts may expose secrets.

For the breaking migration from Pi Forge, see [Install](/install/#projects-made-by-pi-forge).
