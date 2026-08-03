#!/usr/bin/env bash
# Runs scripts/smoke-test.sh against every mock in sequence (they share ports across mocks'
# own defaults, so parallel runs would collide). Convenience wrapper for local use — CI runs
# each mock as its own matrix job instead.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for mock in twilio-mock sendgrid-mock postmark-mock; do
  "$DIR/smoke-test.sh" "$mock"
done
