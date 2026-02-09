#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT_DIR/scripts/aptly-config.json"
APTLY=(aptly -config="$CONFIG")

if ! command -v aptly >/dev/null 2>&1; then
  echo "aptly not found in PATH."
  exit 1
fi

cd "$ROOT_DIR"

GPG_KEY="${GPG_KEY:-}"
GPG_ARGS=()
if [ -n "$GPG_KEY" ]; then
  GPG_ARGS+=("-gpg-key=$GPG_KEY")
fi

PUBLISH_LIST="$("${APTLY[@]}" publish list -raw || true)"

if echo "$PUBLISH_LIST" | grep -q "^bookworm-dev$"; then
  "${APTLY[@]}" publish update -batch "${GPG_ARGS[@]}" bookworm-dev
else
  "${APTLY[@]}" publish repo -batch "${GPG_ARGS[@]}" -distribution=bookworm-dev -component=main beaver-dev
fi

PUBLISH_DIR="${PUBLISH_DIR:-$ROOT_DIR/docs/apt}"
mkdir -p "$PUBLISH_DIR/dists"

# Sync only dev distribution + pool. Do not delete existing stable repo content.
rsync -a "$ROOT_DIR/.aptly/public/dists/bookworm-dev" "$PUBLISH_DIR/dists/"
rsync -a "$ROOT_DIR/.aptly/public/pool" "$PUBLISH_DIR/"

echo "Published dev APT repo to $PUBLISH_DIR"
