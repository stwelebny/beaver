#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT_DIR/scripts/aptly-config.json"
APTLY="aptly -config=$CONFIG"

GPG_KEY="${GPG_KEY:-}"
GPG_ARGS=()
if [ -n "$GPG_KEY" ]; then
  GPG_ARGS+=("-gpg-key=$GPG_KEY")
fi

PUBLISH_LIST="$($APTLY publish list -raw || true)"

if echo "$PUBLISH_LIST" | grep -q "^bookworm$"; then
  $APTLY publish update -batch "${GPG_ARGS[@]}" bookworm
else
  $APTLY publish repo -batch "${GPG_ARGS[@]}" -distribution=bookworm -component=main beaver
fi

if echo "$PUBLISH_LIST" | grep -q "^bookworm-dev$"; then
  $APTLY publish update -batch "${GPG_ARGS[@]}" bookworm-dev
else
  $APTLY publish repo -batch "${GPG_ARGS[@]}" -distribution=bookworm-dev -component=main beaver-dev
fi

mkdir -p "$ROOT_DIR/docs/apt"
rsync -a --delete "$ROOT_DIR/.aptly/public/" "$ROOT_DIR/docs/apt/"

echo "Published APT repo to $ROOT_DIR/docs/apt"
