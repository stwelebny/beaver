# syntax=docker/dockerfile:1

########################
# 1) Builder: build .deb
########################
FROM debian:bookworm AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    devscripts \
    debhelper \
    dh-make \
    fakeroot \
    lintian \
    ca-certificates \
    git \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Copy the whole repo into the build context
COPY . /src

# Build beaver-core-config
WORKDIR /src/packages/beaver-core-config
RUN dpkg-buildpackage -us -uc

# Build beaver-core
WORKDIR /src/packages/beaver-core
RUN dpkg-buildpackage -us -uc

# Collect artifacts
WORKDIR /out
RUN set -eu; \
    find /src/packages -maxdepth 1 -type f -name "*.deb" -print -exec cp -v {} /out/ \; ; \
    ls -la /out


##################################
# 2) Runtime: install + run sshd
##################################
FROM debian:bookworm-slim AS runtime

ENV DEBIAN_FRONTEND=noninteractive

# Minimal runtime deps for SSH + basic diagnostics
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    ca-certificates \
    sudo \
    locales \
    tzdata \
 && rm -rf /var/lib/apt/lists/*

# Create user "beaver" (no password login; SSH keys only)
RUN useradd -m -s /bin/bash beaver && \
    mkdir -p /home/beaver/.ssh && \
    chown -R beaver:beaver /home/beaver/.ssh && \
    chmod 700 /home/beaver/.ssh && \
    echo "beaver ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/010-beaver-nopasswd && \
    chmod 440 /etc/sudoers.d/010-beaver-nopasswd

# SSH server setup
RUN mkdir -p /run/sshd && \
    sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?KbdInteractiveAuthentication .*/KbdInteractiveAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    printf "\nAllowUsers beaver\n" >> /etc/ssh/sshd_config

# Where we keep persistent user data in the container
RUN mkdir -p /userdata && chown -R beaver:beaver /userdata

# Copy built packages from builder and install them
COPY --from=builder /out/*.deb /tmp/debs/

RUN apt-get update && \
    apt-get install -y --no-install-recommends /tmp/debs/*.deb || (apt-get -f install -y && apt-get install -y --no-install-recommends /tmp/debs/*.deb) && \
    rm -rf /var/lib/apt/lists/* /tmp/debs

# Optional: make /home/beaver point to persistent storage
# (This is "container persistence", not your final /userdata partition story.)
RUN rm -rf /home/beaver && ln -s /userdata/home/beaver /home/beaver && \
    mkdir -p /userdata/home/beaver && chown -R beaver:beaver /userdata/home/beaver

EXPOSE 22

# Start SSH daemon in foreground
CMD ["/usr/sbin/sshd","-D","-e"]
