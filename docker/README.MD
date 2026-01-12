# Beaver Docker Dev/Test Wrapper

This Docker setup is intended for **development and testing** of Beaver on a
resettable Debian Bookworm environment.

Beaver’s **source of truth** is the Debian packages and configuration that also
run on the Raspberry Pi (scenario 1). The container is only a convenient wrapper
to:
- build and install Beaver `.deb` packages quickly
- run repeatable tests with a persistent `/userdata` volume
- reset by rebuilding the container

This is **not** the long-term hosted production architecture decision.

## What this container does

- Builds `beaver-core-config` and `beaver-core` from the repository source.
- Installs the resulting `.deb` packages into a clean Debian Bookworm runtime.
- Runs an SSH server inside the container for convenient remote-style testing.
- Persists `/userdata` via a Docker volume.

## What this container is NOT

- Not a Raspberry Pi image.
- Not a replacement for hardware testing (boot + BRLTTY + device enumeration).
- Not the final multi-user hosting design.

## SSH access

This dev container exposes SSH on host port `2222`:

    ssh -p 2222 beaver@localhost

Authentication uses an SSH public key injected via a bind mount:
- Host file: `./ssh/authorized_keys`
- Container path: `/userdata/home/beaver/.ssh/authorized_keys` (mounted read-only)

To set it up:

1. Create the directory and copy your public key:

    mkdir -p ssh
    cp ~/.ssh/id_ed25519.pub ssh/authorized_keys
    chmod 644 ssh/authorized_keys

2. Build and start:

    docker compose -f docker/docker-compose.yml up --build -d

3. Connect:

    ssh -p 2222 beaver@localhost

## Persistent data

`/userdata` is a named Docker volume (`beaver_userdata`). Rebuilding the image
does not delete it. To remove everything (including userdata), stop the
container and delete the volume:

    docker compose -f docker/docker-compose.yml down
    docker volume rm beaver_beaver_userdata  # name may vary; list with: docker volume ls

## Notes

- Any "platform behavior" should live in `beaver-core-config` (scripts/systemd),
  not in Docker-specific hacks.
- If you are testing hosted or multi-user scenarios, prefer a real Debian VM and
  install Beaver packages directly to stay close to the Raspberry Pi target.
