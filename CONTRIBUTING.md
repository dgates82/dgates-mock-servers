# Contributing

Thanks for your interest in improving these mocks. A few guidelines to keep things consistent.

## Before you start

- For anything beyond a small fix, open an issue first to discuss the change.
- These mocks implement only the subset of each vendor's API that current consumers
  (`DGates.Identity.NotificationProviders`, `angular-dotnet-auth-template`) actually call — see
  [README.md](README.md#scope). A missing feature is a legitimate gap to raise, not something to
  silently work around downstream.
- `twilio-mock` is a thin wrapper around the `twillio-sms-mock` npm package, not a hand-rolled
  server like the other two — API surface changes there belong upstream, not in this repo.

## Development setup

Each mock is a standalone Node/Express app (except `twilio-mock`, which wraps `twillio-sms-mock`
directly):

```sh
cd sendgrid-mock   # or postmark-mock, twilio-mock
npm install
npm start
```

Or run everything together via Docker:

```sh
docker compose up -d --wait
docker compose down -v
```

## Smoke tests

Each mock has a smoke test that builds its image, runs it, and exercises the send/inspect/clear
endpoints against the real container — no compose stack required:

```sh
./scripts/smoke-test.sh twilio-mock      # or sendgrid-mock, postmark-mock
./scripts/smoke-test-all.sh              # runs all three in sequence
```

Requires `docker`, `curl`, and `jq`. These bind each mock's default port on the host, so don't
run them while `docker compose up` is already using those ports. CI runs the same script as one
matrix job per mock, on every push and PR.

## Making changes

- Branch from `main`, open a PR.
- Commit format: `type: lowercase description` (e.g. `feat:`, `fix:`, `docs:`, `chore:`).
- Keep `sendgrid-mock` and `postmark-mock` consistent with each other — same response shapes for
  `/api/messages` and `/health`, same "no credential validation" behavior — unless the real
  vendor APIs genuinely diverge.
- If your change affects `docker-compose.yml` or any `*-mock` service, confirm the containers
  still build and pass their healthchecks, not just that the code runs locally.
- Update `CHANGELOG.md` under `[Unreleased]` for any user-facing change.

## Pull requests

- 1 approval required before merge (GitHub Ruleset on `main`).
- Merge via merge commit, not squash — keeps full commit history intact.

## Releasing

All three images are versioned together under one repo-wide tag (e.g. `v1.0.0`), even if only
one mock changed.

1. Push the tag explicitly: `git tag vX.Y.Z <sha> && git push origin vX.Y.Z`.
2. Let the publish workflow build and push all three images to GHCR.
3. Confirm the workflow run is green.
4. Create the GitHub Release by selecting the tag that already exists — never type a new tag
   name into the release form.

## What not to contribute

- API keys, secrets, or credentials for the real vendor services.
- Features that would require moving off "no credentials, no real network call" — that's the
  entire point of these mocks.

## Questions

Open an issue if you're not sure whether something fits.
