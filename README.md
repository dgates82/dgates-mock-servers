# dgates-mock-servers

Small, no-account-needed mock servers for local dev/testing of third-party APIs. Point your app
at one of these instead of a real vendor account — no credentials, no rate limits, no risk of
actually sending anything.

Currently included:

| Mock             | Mocks               | Image                                     |
|------------------|----------------------|--------------------------------------------|
| `twilio-mock`    | Twilio SMS API       | `ghcr.io/dgates82/twilio-mock`             |
| `sendgrid-mock`  | SendGrid Email API   | `ghcr.io/dgates82/sendgrid-mock`           |
| `postmark-mock`  | Postmark Email API   | `ghcr.io/dgates82/postmark-mock`           |

## Why this exists

Some vendor APIs don't offer a local sandbox mode with inspectable output — you either send a
real message, or you don't test the integration at all. These mocks fill that gap for local
development and CI: each one implements just enough of its vendor's real API surface to accept a
send request and let you inspect what was "sent," without ever touching the real service.

`sendgrid-mock` and `postmark-mock` are hand-rolled Express servers built for this repo.
`twilio-mock` is a thin wrapper around the [`twillio-sms-mock`](https://www.npmjs.com/package/twillio-sms-mock)
npm package (MIT-licensed, by [dgeorgiev](https://github.com/dgeorgiev/twillio-sms-mock)) — no
published image exists for it, so it's containerized here.

An existing SendGrid mock already exists at
[`janjaali/sendGrid-mock`](https://github.com/janjaali/sendGrid-mock) — `sendgrid-mock` here was
built independently for consistency with the other two mocks in this repo (matching
request/response shapes, matching inspection-endpoint conventions) rather than because a gap was
found in that project.

## Also in the box

`docker-compose.yml` brings up two official images alongside the three mocks this repo builds:
`localstack/localstack:3` (SNS, port 4566) and `axllent/mailpit:latest` (SMTP, ports 1025/8025).
Between the three built mocks and these two, `docker compose up -d --wait` gives you a complete
local stand-in for every provider `DGates.Identity.NotificationProviders` supports, in one shot.

## Usage

Each mock runs standalone — pull the image and run it:

```sh
docker run -p 3030:3030 ghcr.io/dgates82/twilio-mock:1.0.0
```

Or run all three together for local development against this repo itself:

```sh
docker compose up -d --wait
```

| Mock             | Port | Send endpoint                                    | Inspect endpoint    |
|------------------|------|----------------------------------------------------|-----------------------|
| `twilio-mock`    | 3030 | `POST /2010-04-01/Accounts/{Sid}/Messages.json`     | `GET /api/messages` |
| `sendgrid-mock`  | 3040 | `POST /v3/mail/send`                                | `GET /api/messages` |
| `postmark-mock`  | 3050 | `POST /email`                                       | `GET /api/messages` |

None of the mocks validate credentials — any non-empty API key/token/SID works. Each also serves
a small web UI at `/` for browsing sent messages without hitting the API directly. See each
mock's own README for full endpoint details, request/response shapes, and limitations.

## Versioning

All three images are versioned together under one repo-wide tag (e.g. `v1.0.0` bumps all three,
even if only one changed) rather than independently. Pin to a specific version in any consumer's
`docker-compose.yml` — don't float on `:latest`.

## Part of a small ecosystem

| Project | What it is | Reach for it when |
| --- | --- | --- |
| **dgates-mock-servers** (you are here) | Public GHCR images mocking SendGrid, Twilio, and Postmark, plus a compose file bundling LocalStack (SNS) and Mailpit | you want to develop or test notification flows with no vendor accounts |
| [DGates.Identity.NotificationProviders](https://github.com/dgates82/DGates.Identity.NotificationProviders) | Email/SMS senders for ASP.NET Core Identity — its local dev stack and tests run against these mocks | you want the library these mocks exist to support |
| [angular-dotnet-auth-template](https://github.com/dgates82/angular-dotnet-auth-template) | Angular + .NET auth starter — its [live demo](https://angular-dotnet-auth-template-1019453023791.us-central1.run.app) runs `sendgrid-mock`/`twilio-mock` as their own Cloud Run services | you want to see these mocks running live, in production, not just locally |
| [dotnet-nuget-release-template](https://github.com/dgates82/dotnet-nuget-release-template) | The GitHub template `NotificationProviders` was scaffolded from | more from the same portfolio |

## Scope

These mocks implement only the subset of each vendor's API that `DGates.Identity.NotificationProviders`
and `angular-dotnet-auth-template` actually call — not full API parity with the real service. If
you need a real feature and this mock doesn't cover it, that's a legitimate gap to raise as an
issue, not an oversight to silently work around.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).
