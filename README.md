# BEAVER

**BEAVER** is a **Braille-first, terminal-only Linux environment** designed for blind and especially deaf-blind users.

It builds on standard Debian Linux tools and focuses on:
- predictability
- keyboard / Braille efficiency
- no GUI dependencies
- full usability over SSH, serial, or local console

---

## Philosophy

- Terminal first, not GUI adapted
- Explicit commands, no hidden automation
- Standard tools over custom replacements
- Everything works over SSH
- User data always stays in the user’s home directory

---

## What BEAVER provides

After installation, BEAVER gives you:

- Mail: neomutt + mbsync + msmtp
- Web: lynx
- Social: toot (Mastodon)
- AI access: beaver-ai (terminal-based ChatGPT client)
- Consistent help system via the `beaver` command

---

## Installation

Beaver installs cleanly **on existing Debian-based systems** (including Raspberry Pi OS), tested on Debian bookworm.

A. If you use Docker, check out the project in git and there is a Dockerfile in /docker.

B. For installation on existing Debian Linux systems BEAVER is currently distributed via GitHub releases as `.deb` packages:

C. APT install + updates 

1) Install the repo key:

    curl -fsSL https://stwelebny.github.io/beaver/apt/beaver-dev-repo-public.gpg | sudo gpg --dearmor -o /usr/share/keyrings/beaver-archive-keyring.gpg

2) Add the repo:

    echo "deb [signed-by=/usr/share/keyrings/beaver-archive-keyring.gpg] https://stwelebny.github.io/beaver/apt bookworm-dev main" | sudo tee /etc/apt/sources.list.d/beaver-dev.list

3) Update + install:

    sudo apt update
    sudo apt install beaver

4) Later updates:

    sudo apt update
    sudo apt upgrade


### 1. Download the release packages

From the release page:

https://github.com/stwelebny/beaver/releases

Download **all** `.deb` files for the version.

Example files:
- beaver_0.1.0_all.deb
- beaver-ai_0.1.0_all.deb
- beaver-core_0.1.0_all.deb
- beaver-core-config_0.1.0_all.deb
- beaver-internet_0.1.0_all.deb
- beaver-mail_0.1.0_all.deb
- beaver-social_0.1.0_all.deb

---

### 2. Install on a Debian-based system

From the directory containing the `.deb` files:

sudo apt update  
sudo apt install ./*.deb

APT will automatically install required dependencies.

---

## Using BEAVER

After installation, type:

beaver

This shows the BEAVER help overview.

### Available commands

- beaver  
  Show help overview

- beaver help [topic]  
  Show help for a topic

- beaver version  
  Show installed BEAVER components

- beaver onboard [...]  
  Initialize/check persistent userdata

### Topics

- ai        – AI access via beaver-ai  
- internet – Web browsing with lynx  
- mail     – Email with neomutt / mbsync / msmtp  
- social   – Mastodon via toot  

Example:

beaver help mail

---

## Mail setup (short overview)

BEAVER uses standard Unix mail tools:

- Receive mail: mbsync
- Send mail: msmtp
- Read/write mail: neomutt

Mail data lives in:

~/.mail

Configuration files:

- ~/.mbsyncrc
- ~/.msmtprc
- ~/.config/neomutt/

BEAVER does **not** hide these files — they are user-owned and fully transparent.

---

## AI access

To use AI features:

beaver-ai chat

Configuration file:

~/.config/beaver/ai.env

Example contents:

OPENAI_API_KEY="sk-..."  
BEAVER_AI_MODEL="gpt-5"

---

## Backup and restore (important)

BEAVER never stores user data inside packages.

Back ups should include:

tar -czf beaver-backup.tgz \
  ~/.mail \
  ~/.mbsyncrc \
  ~/.msmtprc \
  ~/.config \
  ~/.local

Restore by extracting the archive into your home directory.

---

## Target platforms

- Raspberry Pi (recommended for native Braille via BRLTTY)
- Hosted Linux servers (SSH access)
- Containers / virtual machines for testing

---

## Status

BEAVER is **early-stage but functional**.

Current focus:
- correctness
- reproducibility
- real-world Braille workflows

Expect changes, but not breakage.

---

## License

MIT License

---

##  Training & Workshops

BEAVER is a skill-oriented system.
While it can be explored independently, many users benefit from guided introduction.

Workshops and group trainings may be offered, especially in cooperation with organizations supporting blind and deaf-blind users.
These sessions can cover installation, daily workflows, accessibility concepts, and advanced usage.

https://it.welebny.com/
