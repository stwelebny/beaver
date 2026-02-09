# Signed APT repository (GitHub Pages)

This document sets up a signed APT repository for BEAVER using GitHub Pages.
It assumes you already have built `.deb` files (from CI or local builds).

## Summary

- Build `.deb` packages.
- Add them to an aptly repo.
- Publish a signed APT repo to `docs/apt/`.
- Push to GitHub and enable GitHub Pages for the `docs/` folder.

## 1) Install aptly

On macOS (Homebrew):

    brew install aptly

On Debian:

    sudo apt update
    sudo apt install aptly

## 2) Create a signing key

Create a dedicated GPG key for signing the repo:

    gpg --quick-gen-key "Beaver Repo <you@example.com>"

Get the key id:

    gpg --list-secret-keys --keyid-format LONG

Export the public key (this is what users will import):

    gpg --armor --export YOURKEYID > beaver-repo-public.gpg

## 3) Initialize local aptly repos

Run once from the repo root:

    ./scripts/aptly-init.sh

This creates two distributions:

- `bookworm` (stable)
- `bookworm-dev` (fast iteration)

## 4) Add `.deb` files

Put `.deb` files anywhere and add them:

    ./scripts/aptly-add.sh beaver /path/to/debs/*.deb

For dev channel:

    ./scripts/aptly-add.sh beaver-dev /path/to/debs/*.deb

## 5) Publish (signed)

Publish to `docs/apt/`:

    GPG_KEY=YOURKEYID ./scripts/aptly-publish.sh

This updates:

    docs/apt/

### Dev-only publish (keeps stable intact)

If you want to publish only the `bookworm-dev` repo without touching `bookworm`,
use:

    GPG_KEY=YOURKEYID ./scripts/aptly-publish-dev.sh

This syncs only `dists/bookworm-dev` and the `pool` directory, without deleting
existing stable content.

## 6) GitHub Pages

In GitHub repo settings:

- Pages source: `main` branch
- Folder: `/docs`

Your repo URL will look like:

    https://stwelebny.github.io/beaver/apt/

## CI: Publish dev channel without overwriting stable

A GitHub Actions workflow is included to publish `bookworm-dev` into `main/docs/apt`
while leaving `bookworm` intact.

Required secret (repo settings → Secrets and variables → Actions):

- `APT_SIGNING_KEY` — your **ASCII-armored** private key

Trigger: push to `dev` branch (or manual workflow dispatch).

## 7) Install on Raspberry Pi

On the Pi, import the public key and add the repo:

    curl -fsSL https://stwelebny.github.io/beaver/apt/beaver-repo-public.gpg | sudo gpg --dearmor -o /usr/share/keyrings/beaver-archive-keyring.gpg

    echo "deb [signed-by=/usr/share/keyrings/beaver-archive-keyring.gpg] https://stwelebny.github.io/beaver/apt bookworm main" | sudo tee /etc/apt/sources.list.d/beaver.list

    sudo apt update
    sudo apt install beaver

For fast iteration, use the dev channel instead:

    echo "deb [signed-by=/usr/share/keyrings/beaver-archive-keyring.gpg] https://stwelebny.github.io/beaver/apt bookworm-dev main" | sudo tee /etc/apt/sources.list.d/beaver-dev.list

## Notes

- `docs/apt/` is a generated artifact. Commit it to publish updates.
- Keep the private GPG key secure. The public key is safe to publish.
- The dev channel is for fast testing; stable should be used for releases.
