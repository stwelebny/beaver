#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT_DIR/scripts/aptly-config.json"
APTLY="aptly -config=$CONFIG"

if ! $APTLY repo show beaver >/dev/null 2>&1; then
  $APTLY repo create -distribution=bookworm -component=main beaver
fi

if ! $APTLY repo show beaver-dev >/dev/null 2>&1; then
  $APTLY repo create -distribution=bookworm-dev -component=main beaver-dev
fi

echo "Initialized aptly repos in $ROOT_DIR/.aptly"
