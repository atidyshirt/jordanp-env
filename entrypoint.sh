#!/usr/bin/env bash
set -euo pipefail

export PATH="/usr/local/bin:/nix/jordanp-env/bin:${PATH:-}"
if [[ -f /nix/jordanp-env/etc/ssl/certs/ca-bundle.crt ]]; then
  export NIX_SSL_CERT_FILE=/nix/jordanp-env/etc/ssl/certs/ca-bundle.crt
  export SSL_CERT_FILE=/nix/jordanp-env/etc/ssl/certs/ca-bundle.crt
fi

if [[ -n "${JORDANP_WORKSPACE:-}" ]] && command -v git &>/dev/null; then
  if ! git config --global --get-all safe.directory 2>/dev/null | grep -qxF "$JORDANP_WORKSPACE"; then
    git config --global --add safe.directory "$JORDANP_WORKSPACE"
  fi
fi

exec "$@"
