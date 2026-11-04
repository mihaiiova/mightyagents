---
title: Run tests on every deploy
nav: Run on every deploy
group: Using Toad
weight: 35
lead: Save a test as a suite once, then run it again with toad run, on your machine or in CI after every deploy. No coding agent needed.
---

## Suites

A suite is `.toad/suites/<name>.yaml` in your project: a handoff, plus tags
and whether it may change data. Commit it; like `toad.yaml`, it holds no
secrets. The easiest way to get one is to ask your coding agent, after a
handoff works: *"Save that as a Toad suite tagged smoke."* Setup also creates
a commented `suites/example.yaml`.

```yaml
kind: web                      # web, cli or api
title: Checkout smoke
target:                        # omitted fields come from toad.yaml
  url: https://staging.example.com
goal: Check that a signed-in customer can buy one item.
tags: [smoke]
writes: true                   # it places orders, so toad run needs --allow-writes
credentials:
  email: { env: TOAD_TEST_EMAIL }
  password: { env: TOAD_TEST_PASSWORD }
scenarios:
  - name: Adds to the cart
    steps: Sign in, open the first product, add it to the cart.
    expected: The cart badge shows 1.
  - name: Pays with the test card
    steps: Check out with card 4242 4242 4242 4242.
    expected: An order confirmation with an order number.
    tags: [payments]
limitations:
  - Use only the test card.
timeout_minutes: 10
```

Scenario names must be distinct, because results come back by name. Every
scenario needs steps and an expected result. A suite without `writes: true`
is told it is read-only, and `toad run` refuses a suite with `writes: true`
unless you pass `--allow-writes`.

## toad run

```sh
toad run                                   # every suite
toad run --suite checkout --suite search   # these suites, in this order
toad run --tag smoke --max-scenarios 10    # tagged scenarios, at most 10, in file order
toad run --url "$PREVIEW_URL"              # test a preview deploy instead of the suite's URL
toad run --junit toad.xml --summary toad.md --json
```

Each suite is one Toad run, saved under `.toad/runs/` and shown in the
[run viewer](/viewer/) like any other. A scenario that does not pass is run
once more, in a new run with only those scenarios (`--retries 0` turns this
off). A scenario that fails and then passes is **flaky**: it does not fail
the build, but the output, the JUnit file and the summary all say so.

| Exit code | Meaning |
|---|---|
| `0` | Every scenario passed (flaky ones included) |
| `1` | A scenario failed |
| `2` | A run errored, timed out, hit the spending limit or was interrupted, so a result is unknown |
| `3` | Toad could not start: no model key, invalid suites or options, a write suite without `--allow-writes`, a missing credential |

`--junit` writes one test case per scenario, with its attempts, report and
receipts folder. `--summary` writes markdown for a pull request comment or a
job summary. `--json` prints the whole result. `toad run --help` lists every
option.

## In CI

`toad run` needs nothing but a model key in the environment. On first use it
prepares the agent, and the browser if a web suite needs it, so a CI job has
no `toad setup` step.

| What | How |
|---|---|
| **Model key** | The provider's variable, such as `ANTHROPIC_API_KEY`. It is checked before anything starts; a missing key exits 3. |
| **Models** | `--lead-model`, `--tester-model` or `--model`, else `models:` in `toad.yaml`, else what `toad setup` chose. A run on other models uses a copy of the agent, so other runs are unaffected. |
| **Test logins** | `--env TOAD_TEST_EMAIL,TOAD_TEST_PASSWORD` takes those names from the job's secrets instead of `.toad/.env`. They are still referenced by name only. |
| **CLI and API sandbox** | Docker on Linux runners. Where there is no Docker, Podman or Bubblewrap (macOS and Windows runners), `--sandbox none` runs commands directly on the runner, in a copy of the project. It is never chosen for you, and the receipts say when it was used. |
| **Spending** | `--max-cost 2` stops the runs once Pi has recorded $2 across them; the stopped run counts as an error. |
| **Evidence** | Upload `.toad/runs/` as an artifact: every report, receipt and transcript is in it. |

## A GitHub Actions job

This job tests every successful deployment and comments on its pull request:

```yaml
name: Toad
on: deployment_status

jobs:
  toad:
    if: github.event.deployment_status.state == 'success'
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.deployment.sha }}
      - uses: actions/setup-node@v4
        with:
          node-version: 22
      # Pin a release you have reviewed.
      - run: npm install --global github:mihaiiova/toad#v0.7.0
      - id: toad
        run: echo "version=$(toad --version)" >> "$GITHUB_OUTPUT"
      - uses: actions/cache@v4
        with:
          path: |
            ~/.cache/ms-playwright
            ~/.local/share/toad/agent
          key: toad-${{ runner.os }}-${{ steps.toad.outputs.version }}
      - name: Test the deployment
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          TOAD_TEST_EMAIL: ${{ secrets.TOAD_TEST_EMAIL }}
          TOAD_TEST_PASSWORD: ${{ secrets.TOAD_TEST_PASSWORD }}
          # Through the environment, never pasted into the script.
          TARGET_URL: ${{ github.event.deployment_status.environment_url }}
        run: >
          toad run --tag smoke --url "$TARGET_URL"
          --env TOAD_TEST_EMAIL,TOAD_TEST_PASSWORD --max-cost 2
          --junit toad.xml --summary toad.md
      - if: always()
        uses: actions/upload-artifact@v4
        with:
          name: toad-runs
          path: .toad/runs/
      - name: Post the summary
        if: always() && hashFiles('toad.md') != ''
        env:
          GH_TOKEN: ${{ github.token }}
          SHA: ${{ github.event.deployment.sha }}
        run: |
          cat toad.md >> "$GITHUB_STEP_SUMMARY"
          pr=$(gh pr list --state open --search "$SHA" --json number --jq '.[0].number')
          if [ -n "$pr" ]; then gh pr comment "$pr" --body-file toad.md; fi
```

`--url` replaces the URL of every selected web and API suite, so select
suites that test the same deployment, or run `toad run` once per target.

The summary it posts looks like this:

```
## Toad: FAIL

1 passed, 1 failed, 1 flaky · 4m 12s · $0.0931

| Result | Suite | Scenario       | Evidence                                  |
|--------|-------|----------------|-------------------------------------------|
| PASS   | api   | Reads a post   | .toad/runs/…/receipts/reads-a-post        |
| FLAKY  | web   | Adds a todo    | .toad/runs/…/receipts/adds-a-todo         |
| FAIL   | cli   | Shouts         | .toad/runs/…/receipts/shouts              |
```
