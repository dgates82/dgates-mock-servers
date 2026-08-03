# postmark-mock

A minimal mock of Postmark's [email send API](https://postmarkapp.com/developer/api/email-api).
Accepts a send request, stores it in memory, and lets you inspect what was "sent" — no real
Postmark account, server token, or network call involved.

Hand-rolled (`server.js`), built for consistency with `sendgrid-mock` and `twilio-mock` in this
repo — see [the parent README](../README.md#why-this-exists) for why.

## Run it

```sh
docker run -p 3050:3050 ghcr.io/dgates82/postmark-mock:1.0.0
```

Or from this folder, for local development on the mock itself:

```sh
npm install
npm start
```

## Endpoints

### Send an email

```
POST /email
X-Postmark-Server-Token: <any non-empty value>
Content-Type: application/json

{
  "To": "user@example.com",
  "From": "sender@example.com",
  "Subject": "Test",
  "HtmlBody": "<p>Hello</p>"
}
```

The `X-Postmark-Server-Token` header is not validated — any value works. Requires `To`, `From`,
and `Subject`; a missing field returns `422` with `ErrorCode`/`Message`, matching Postmark's error
shape. On success, responds `200 OK` with a body shaped like Postmark's real response, including
a generated `MessageID` (a real GUID — Postmark client SDKs often type this as a GUID, so an
arbitrary string won't round-trip).

`HtmlBody` is preferred over `TextBody` when both are present; `TemplateId`/`TemplateModel`,
`Attachments`, `Tag`, `Metadata`, and `MessageStream` are all ignored.

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

Open `http://localhost:3050` in a browser for a UI listing sent messages, auto-refreshing every
2 seconds, with a button to clear all messages.

## Configuration

The port is fixed at `3050` in `server.js` — there's currently no env var to override it. If you
need a different port, remap it at the Docker layer (`-p <host-port>:3050`).

## What this doesn't cover

- No validation of the `X-Postmark-Server-Token` header — any value is accepted
- No attachments, templates (`TemplateId`/`TemplateModel`), tags, or metadata
- No open/link tracking or message streams
- No delivery-status webhooks

If your use case needs one of these, open an issue on the
[parent repo](https://github.com/dgates82/dgates-mock-servers) rather than working around it
silently.
