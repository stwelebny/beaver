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

if ! command -v aptly >/dev/null 2>&1; then
  echo "aptly not found in PATH."
  exit 1
fi

cd "$ROOT_DIR"

$APTLY repo add "$REPO" "$@"
