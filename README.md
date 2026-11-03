# Mighty Agents

**Small agents. Mighty useful.**

The source for [mightyagents.dev](https://mightyagents.dev) and the docs of each
agent listed there, such as [toad.mightyagents.dev](https://toad.mightyagents.dev).

## Layout

```
themes/mighty/   the shared look: layouts, partials, one stylesheet
sites/www/       mightyagents.dev; the agents shown come from data/agents.yaml
sites/toad/      toad.mightyagents.dev, the TOaD docs
```

Each site is a [Hugo](https://gohugo.io) site deployed as a Cloudflare Worker
with static assets (`wrangler.jsonc` in each site folder).

## Work on it

Needs Hugo extended (0.140+) and, to deploy, [Wrangler](https://developers.cloudflare.com/workers/wrangler/).

```sh
make dev       # www on http://localhost:1313, toad on http://localhost:1314
make build
make deploy
```

## Add an agent

1. Add an entry to `sites/www/data/agents.yaml`, a logo partial in
   `themes/mighty/layouts/partials/`, and a terminal partial in
   `sites/www/layouts/partials/`.
2. Copy `sites/toad` to `sites/<agent>` for its docs, and set its domain in
   `wrangler.jsonc`.
3. Add `<agent>` to `SITES` in the Makefile and its URL to `params.links`.
