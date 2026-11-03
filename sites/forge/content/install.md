---
title: Install
group: Getting started
weight: 10
lead: Pi Forge is a Pi package. Install it once, and `/faur` is available in every Pi session.
---

## Requirements

| | Needed for |
|---|---|
| Node.js 22.19+ | Pi |
| [Pi](https://github.com/earendil-works/pi) | the runtime Forge builds for |
| A model provider Pi can use (DeepSeek, OpenAI, …) | running the agents you build |
| Network access to GitHub | the first `./run` of a generated project installs its pinned Forge release |

## Install from a release tag

```sh
pi install git:github.com/mihaiiova/pi-forge@v0.29.1
```

This is the recommended way. A generated project pins its own Forge release,
and installing from a tag lets that pin replace your copy inside the project.

## Install from a checkout

To work on Forge itself:

```sh
git clone https://github.com/mihaiiova/pi-forge.git /path/to/pi-forge
pi install /path/to/pi-forge
```

Pi treats a local checkout and a project's git pin as different packages, so
inside a generated project both load and each command appears twice.

## Check it

Start Pi anywhere outside a Forge project and type `/faur`. You can also call
the skill directly with `/skill:forge`.
