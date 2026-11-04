---
title: Install
group: Getting started
weight: 10
lead: Faur is a Pi package. Install it in your Pi, then use `/faur` to design and maintain projects.
---

## Requirements

| | Needed for |
|---|---|
| Node.js 22.19+ | Pi |
| [Pi](https://github.com/earendil-works/pi) | the runtime Faur builds for |
| A model provider Pi can use | design conversations and running your agents |
| Network access | installing Faur and any project packages your design needs |

## Install from a release tag

```sh
pi install git:github.com/mihaiiova/faur@v0.32.0
```

Generated projects do not pin Faur. They run with Pi and the packages they
actually need, even when Faur is not installed.

## Install from a checkout

```sh
git clone https://github.com/mihaiiova/faur.git /path/to/faur
pi install /path/to/faur
```

Start Pi and type `/faur`. You can also call the design skill directly with
`/skill:faur`.

## Projects made by Pi Forge

Old pinned `/faur sync` cannot update directly to this release. Generate into
a **new empty directory** from the old project's `.pi/system.yaml`, then
review and manually reconcile your authored files and edits; renamed Faur does
not recognize legacy ownership markers or move the old pin automatically.
Keep the old project unchanged until you have verified the new one.

```sh
mkdir -p /path/to/new-agent/.pi
cp /path/to/old-agent/.pi/system.yaml /path/to/new-agent/.pi/system.yaml
node /path/to/faur/skills/faur/faur.mjs generate /path/to/new-agent --dry-run
node /path/to/faur/skills/faur/faur.mjs generate /path/to/new-agent
```

Review the preview before applying and inspect the regenerated project before
moving any authored content. Roll back with git.
