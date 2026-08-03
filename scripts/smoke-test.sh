#!/usr/bin/env bash
# Builds one mock's image, runs it, exercises its send/inspect/clear endpoints, and tears it
# down. Used by CI (one matrix job per mock) and locally (./scripts/smoke-test.sh twilio-mock).
#
# Requires: docker, curl, jq. Binds the mock's default port on the host, so don't run this
# while `docker compose up` is already using that port.
set -euo pipefail

MOCK="${1:?usage: smoke-test.sh <twilio-mock|sendgrid-mock|postmark-mock>}"

case "$MOCK" in
  twilio-mock)   PORT=3030 ;;
  sendgrid-mock) PORT=3040 ;;
  postmark-mock) PORT=3050 ;;
  *)
    echo "unknown mock: $MOCK (expected twilio-mock, sendgrid-mock, or postmark-mock)" >&2
    exit 1
    ;;
esac

IMAGE="smoke-test/$MOCK"
CONTAINER="smoke-test-$MOCK"
BASE="http://localhost:$PORT"

cleanup() {
  docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "==> [$MOCK] building image"
docker build -q -t "$IMAGE" "$MOCK" >/dev/null

echo "==> [$MOCK] starting container on port $PORT"
docker run -d --name "$CONTAINER" -p "$PORT:$PORT" "$IMAGE" >/dev/null

echo "==> [$MOCK] waiting for /health"
for i in $(seq 1 30); do
  if curl -sf "$BASE/health" >/dev/null 2>&1; then
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "[$MOCK] never became healthy" >&2
    docker logs "$CONTAINER" >&2
    exit 1
  fi
  sleep 1
done

echo "==> [$MOCK] sending a test message"
case "$MOCK" in
  twilio-mock)
    STATUS=$(curl -s -o /tmp/smoke-send.json -w '%{http_code}' -u "AC_test:secret" \
      -X POST "$BASE/2010-04-01/Accounts/AC_test/Messages.json" \
      --data-urlencode "To=+15555550100" \
      --data-urlencode "From=+15555550101" \
      --data-urlencode "Body=smoke test")
    EXPECTED=201
    ;;
  sendgrid-mock)
    STATUS=$(curl -s -o /tmp/smoke-send.json -w '%{http_code}' \
      -X POST "$BASE/v3/mail/send" \
      -H "Authorization: Bearer test" \
      -H "Content-Type: application/json" \
      -d '{"personalizations":[{"to":[{"email":"user@example.com"}],"subject":"smoke test"}],"from":{"email":"sender@example.com"},"content":[{"type":"text/html","value":"<p>hi</p>"}]}')
    EXPECTED=202
    ;;
  postmark-mock)
    STATUS=$(curl -s -o /tmp/smoke-send.json -w '%{http_code}' \
      -X POST "$BASE/email" \
      -H "X-Postmark-Server-Token: test" \
      -H "Content-Type: application/json" \
      -d '{"To":"user@example.com","From":"sender@example.com","Subject":"smoke test","HtmlBody":"<p>hi</p>"}')
    EXPECTED=200
    ;;
esac

if [ "$STATUS" != "$EXPECTED" ]; then
  echo "[$MOCK] expected $EXPECTED from send endpoint, got $STATUS" >&2
  cat /tmp/smoke-send.json >&2
  exit 1
fi

echo "==> [$MOCK] checking /api/messages has 1 message"
COUNT=$(curl -sf "$BASE/api/messages" | jq 'length')
if [ "$COUNT" != "1" ]; then
  echo "[$MOCK] expected 1 message in /api/messages, got $COUNT" >&2
  exit 1
fi

echo "==> [$MOCK] clearing messages"
# Status code on clear isn't asserted here: twilio-mock (twillio-sms-mock upstream) returns 200,
# sendgrid-mock/postmark-mock return 204. What matters is that messages are actually cleared.
curl -sf -X DELETE "$BASE/api/messages" -o /dev/null

COUNT_AFTER=$(curl -sf "$BASE/api/messages" | jq 'length')
if [ "$COUNT_AFTER" != "0" ]; then
  echo "[$MOCK] expected 0 messages after clear, got $COUNT_AFTER" >&2
  exit 1
fi

echo "==> [$MOCK] smoke test passed"
