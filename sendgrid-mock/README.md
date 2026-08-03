# sendgrid-mock

A minimal mock of SendGrid's [Mail Send API](https://docs.sendgrid.com/api-reference/mail-send/mail-send).
Accepts a send request, stores it in memory, and lets you inspect what was "sent" — no real
SendGrid account, API key, or network call involved.

Hand-rolled (`server.js`), built for consistency with `postmark-mock` and `twilio-mock` in this
repo rather than because a gap was found in existing SendGrid mocks — see
[the parent README](../README.md#why-this-exists) for why.

## Run it

```sh
docker run -p 3040:3040 ghcr.io/dgates82/sendgrid-mock:1.0.0
```

Or from this folder, for local development on the mock itself:

```sh
npm install
npm start
```

## Endpoints

### Send an email

```
POST /v3/mail/send
Authorization: Bearer <any non-empty value>
Content-Type: application/json

{
  "personalizations": [{ "to": [{ "email": "user@example.com" }], "subject": "Test" }],
  "from": { "email": "sender@example.com" },
  "content": [{ "type": "text/html", "value": "<p>Hello</p>" }]
}
```

The `Authorization` header is not validated — any value works. Requires `to`, `from.email`, and
`subject`; a missing field returns `400` with an `errors` array, matching SendGrid's error shape.
On success, responds `202 Accepted` with an `X-Message-Id` header and no body, matching the real
API.

Only the first personalization and the first `to` recipient are read — `cc`/`bcc`, multiple
personalizations, template IDs, categories, and custom args are all ignored.

### Inspect sent messages

```
GET /api/messages
```

Returns every message sent since the container started, newest first. There's no query-param
filtering (e.g. by recipient) — you get the full list.

### Clear sent messages

```
DELETE /api/messages
```

### Health check

```
GET /health
```

### Web UI

Open `http://localhost:3040` in a browser for a UI listing sent messages, auto-refreshing every
2 seconds, with a button to clear all messages.

## Configuration

The port is fixed at `3040` in `server.js` — there's currently no env var to override it. If you
need a different port, remap it at the Docker layer (`-p <host-port>:3040`).

## What this doesn't cover

- No validation of the `Authorization` header — any value is accepted
- No attachments, templates (`template_id`), categories, or custom args
- No click/open tracking, sandbox mode, or webhook events
- Only the first personalization's first `to` recipient is captured — `cc`/`bcc` and additional
  personalizations are ignored

If your use case needs one of these, open an issue on the
[parent repo](https://github.com/dgates82/dgates-mock-servers) rather than working around it
silently.
