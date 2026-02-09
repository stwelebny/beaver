#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <beaver|beaver-dev> <path-to-debs>"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT_DIR/scripts/aptly-config.json"
APTLY="aptly -config=$CONFIG"

REPO="$1"
shift

$APTLY repo add "$REPO" "$@"
