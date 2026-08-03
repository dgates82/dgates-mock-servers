# twilio-mock

A minimal mock of Twilio's SMS-sending API. Accepts a send request, stores it in memory, and lets
you inspect what was "sent" — no real Twilio account, credentials, or network call involved.

This is a thin wrapper (see `server.js`) around the
[`twillio-sms-mock`](https://www.npmjs.com/package/twillio-sms-mock) npm package
(MIT-licensed, by [dgeorgiev](https://github.com/dgeorgiev/twillio-sms-mock)) — no published
image exists for it upstream, so it's containerized here.

## Run it

```sh
docker run -p 3030:3030 ghcr.io/dgates82/twilio-mock:1.0.0
```

Or from this folder, for local development on the mock itself:

```sh
npm install
npm start
```

## Endpoints

### Send a message

```
POST /2010-04-01/Accounts/{AccountSid}/Messages.json
Authorization: Basic <any non-empty base64 value>
Content-Type: application/x-www-form-urlencoded

To=%2B15555550100&From=%2B15555550101&Body=Test+message
```

`AccountSid` in the path is not validated — any value works. Responds `201 Created` with a body
shaped like Twilio's real message resource, including a generated `sid`.

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

Open `http://localhost:3030` in a browser for a UI listing sent messages, auto-refreshing every
5 seconds, with a button to clear all messages.

## Configuration

The port is fixed at `3030` in `server.js` — there's currently no env var to override it. If you
need a different port, remap it at the Docker layer (`-p <host-port>:3030`).

## What this doesn't cover

- No delivery-status webhooks
- No validation of `AccountSid`/`AuthToken` — anything is accepted
- No support for MMS media attachments (the message shape includes a `num_media` field, but no
  actual media upload/storage)

If your use case needs one of these, open an issue on the
[parent repo](https://github.com/dgates82/dgates-mock-servers) rather than working around it
silently.
