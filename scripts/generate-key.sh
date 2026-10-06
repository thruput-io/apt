#!/usr/bin/env bash
set -euo pipefail

home=$(mktemp -d)
trap 'rm -rf "$home"' EXIT
chmod 700 "$home"

gpg --homedir "$home" --batch --quiet --pinentry-mode loopback --passphrase '' \
  --quick-generate-key 'thruput-io archive <johan.granlund@thruput.se>' default default never

gpg --homedir "$home" --batch --quiet --armor --export-secret-keys
