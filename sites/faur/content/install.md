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
| Network access | installing Faur, reading pages you give it, and any project packages your design needs |

## Install from a release tag

```sh
pi install git:github.com/mihaiiova/faur@v0.33.0
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

Projects made by Pi Forge, Faur's former name, are not updated in place.
Generate into a **new empty directory** from the old project's
`.pi/system.yaml`, then review and reconcile your authored files by hand.
Keep the old project unchanged until you have verified the new one. Remove
declarations Faur no longer accepts (for example `approveTools`), and check
relative paths such as vendored skill sources: they resolve from the new
project directory.

```sh
mkdir -p /path/to/new-agent/.pi
cp /path/to/old-agent/.pi/system.yaml /path/to/new-agent/.pi/system.yaml
node /path/to/faur/src/faur.mjs generate /path/to/new-agent --dry-run
node /path/to/faur/src/faur.mjs generate /path/to/new-agent
```

Review the preview before applying and inspect the regenerated project before
moving any authored content. Roll back with git.
