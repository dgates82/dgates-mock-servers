# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `twilio-mock` — thin wrapper around the `twillio-sms-mock` npm package
- `sendgrid-mock` — hand-rolled Express mock of SendGrid's `POST /v3/mail/send`
- `postmark-mock` — hand-rolled Express mock of Postmark's `POST /email`
- Web UI for all three mocks, served at `/`
- `docker-compose.yml` to run all three together, plus LocalStack (SNS) and Mailpit for repos
  that need those alongside the vendor mocks

<!--
## [X.Y.Z] - YYYY-MM-DD

### Added
-

### Changed
-

### Fixed
-
-->
