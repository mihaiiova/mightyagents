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
allows the project resources to load in a headless run. Pi installs missing
pinned project packages at startup unless offline.

| Mode | Run failed (for example a provider error) |
|---|---|
| `-p` | exits 1, error on stderr |
| `--mode json -p` | **exits 0**; the last assistant message in `agent_end` has `stopReason: "error"` |

Either way, a successful run is not a successful task: a workflow whose test
failed still exits 0, so read the outcome from the answer.

Plain `pi` adds your user-level Pi configuration: global packages, skills in
`~/.agents/skills` and `AGENTS.md` files in parent folders. It is not an
isolated environment and not an OS sandbox; environment variables and
credentials are inherited, and tools run with your permissions. If you need
isolation, arrange it around Pi. A global extension that replaces Pi's
built-in MCP changes what the project's MCP settings enforce; `/faur check`
reports the conflict.

## Change it

From your own Pi with Faur installed, in the project directory:

| Command | What it does |
|---|---|
| `/faur [request]` | Propose a revision; discuss, apply or discard the preview. |
| `/faur review` | Read-only recommendations. |
| `/faur check` | Validate the record, compare files and report capability evidence. |
| `/faur status` | Summarize the design and last check. |
| `/faur sync` | Preview rebuilding with the Faur you are running; apply only after confirmation. |
| `/faur setup` | Preview declared setup installs and ask before running them. |
| `/faur env [set NAME]` | Report declared variable status without showing values, or write one to `.env`. |
| `/faur permissions [add \| remove <name>]` | Manage declared commands. |
| `/faur drift adopt <path>` | Preview adopting supported native edits into the design record. |
| `/faur drift reapply <path>` | Preview reapplying supported files from the design. |
| `/faur drift reconcile <path> adopt=…` | Preview a supported selected-field reconciliation. |

When a file you edited by hand blocks a change, Faur shows what differs and
how to keep or discard your edit; it never overwrites it. Faur reports known
native-only features and preserves them, or refuses a change it cannot safely
represent. Changes are previewed, approved and reversible with git. Headless
sessions cannot approve them.

## Credentials and trust

Set variables in the environment Pi starts in, or load a gitignored `.env`
with direnv. **Pi does not read `.env` itself**. Never put secrets into
prompts.

Pi, every agent, every tool and their subprocesses can access inherited
credentials; tool approval does not give same-user confidentiality. Use
trusted agents, tools and restricted test accounts. Output, screenshots, logs
and artifacts may expose secrets.

For moving a project made by Pi Forge, see [Install](/install/#projects-made-by-pi-forge).
