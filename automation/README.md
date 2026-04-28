# Automation

Scripts and automation tooling for the homelab.

---

## Current scripts

### `git_auto_push.sh` (root of repo)

Auto-stages, commits, and pushes all changes to GitHub.

Usage:
```bash
# From the repo root
chmod +x git_auto_push.sh
./git_auto_push.sh
```

Features:
- Safety check: validates you're inside a git repo before running
- Shows `git status` and a 3-second abort window before committing
- Skips commit if working tree is clean (nothing to commit)
- Single commit per run with timestamp and list of changed files
- Pushes to `origin/master`

---

## Planned automation

As the homelab evolves, this folder will house:

| Tool | Purpose | Project |
|---|---|---|
| Ansible playbooks | VM provisioning and configuration management | Homelab 06 |
| Terraform configs | Infrastructure-as-code for VM and resource definitions | Homelab 06 |
| GitHub Actions workflows | CI/CD for homelab project repos | Homelab 07 |
| Bash utilities | Node health checks, log collection helpers | Ongoing |

---

## Automation philosophy

Every manual process in this lab is a candidate for automation — eventually.
The progression is intentional:

1. Do it manually first (understand the process)
2. Script it (make it repeatable)
3. Parameterize it (make it reusable)
4. Declare it (Infrastructure as Code)
5. Pipeline it (CI/CD)

Scripts in this folder represent Steps 1-3. Steps 4-5 are tracked in the project roadmap.
