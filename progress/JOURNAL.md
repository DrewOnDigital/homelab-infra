# Engineering Journal

> Running log of decisions made, things broken, things learned, and ground gained.
> Not polished. Just honest.

---

## How to read this

Each entry covers:

- **What I did** — the actual task or change
- **Why** — the reasoning behind it
- **What broke / surprised me** — real talk
- **What I learned** — the actual takeaway
- **Next** — what this unlocks

---

## 2026

---

### April 2026 — Infrastructure baseline + GitHub portfolio setup

**What I did:**
- Documented existing lab architecture: Win11 + VMware Workstation (Type 2) with 3 nested
  Proxmox VE VMs (pve-vm-1/2/3), all running Ubuntu 22.04 LTS as the workload OS
- Bare metal Proxmox node on Switch B identified as high-performance / future K8s node
- Overhauled homelab-infra GitHub repo: replaced placeholder content with real architecture docs,
  Mermaid topology diagram, cert tracker, project roadmap table, and per-folder READMEs
- Fixed git_auto_push.sh — removed double-commit bug
- Removed index.html which contained fictional hardware that did not match the actual lab

**Why:**
No documentation = no portfolio. Writing architecture docs also forces you to actually understand
your own architecture — gaps become visible immediately.

**What broke / surprised me:**
- index.html listed a Dell PowerEdge R640, Synology NAS, and Ubiquiti Dream Machine — none of
  which are in the actual lab. Lesson: fake documentation is worse than no documentation.
- git_auto_push.sh double-commit bug was silently failing on every push.

**What I learned:**
- The VMware → Proxmox → Ubuntu nested virtualization stack is a legitimate interview talking point.
- GitHub repos are part of the portfolio. Treat them that way from day one.
- Documenting limitations honestly is more credible than pretending the lab is further along.

**Next:**
- Homelab Project 01: Docker containerization baseline
- Network Phase 1: Static IP assignment
- AWS SAA-C03 prep begins in parallel with new job ramp-up

---

### February 2026 — Lab genesis + cert track begins

**What I did:**
- Stood up VMware Workstation on Win11 desktop as primary lab host
- Created 3 nested Proxmox VE VMs (pve-vm-1/2/3) inside VMware
- Spun up Ubuntu 22.04 VMs inside Proxmox as primary workload environment
- Set up RHEL 9 VM directly in VMware for enterprise sysadmin practice
- Enrolled in AWS CLF-C02 study track

**Why:**
After years of being golden handcuffed in IT Support, the decision was made to aggressively
close the gap through a real homelab — depth you can demonstrate, not just describe.

**What broke / surprised me:**
Nested virtualization requires explicitly enabling VT-x/AMD-V passthrough in VMware settings.
First attempt had Proxmox VMs running without hardware virtualization — sluggish, Proxmox complained.

**What I learned:**
- Type 1 vs Type 2 performance difference is tangible when you run nested layers.
- Ubuntu 22.04 LTS is the right workload OS: stable, 5-year LTS window, massive docs.
- Starting with DHCP is fine. Staying with DHCP is a problem.

**Next:**
Pass AWS CLF-C02 (March 2026) ✅

---

## Skills log

| Skill | Context | Confidence |
|---|---|---|
| Proxmox VE — VM provisioning | Lab setup | Comfortable |
| Nested virtualization (VMware → PVE) | Lab architecture | Comfortable |
| Ubuntu 22.04 — server baseline | All lab VMs | Comfortable |
| VMware Workstation Pro | Lab host | Comfortable |
| Git — branching, staging, committing | Daily practice | Comfortable |
| Bash scripting | git_auto_push.sh + utilities | Developing |
| AWS — cloud fundamentals | CLF-C02 passed | Comfortable |
| Azure — cloud fundamentals | AZ-900 passed | Comfortable |
| Docker + Compose | Project 01 — in progress | Developing |

---

## Template

```
### [Month Year] — [Short title]

**What I did:**

**Why:**

**What broke / surprised me:**

**What I learned:**

**Next:**
```

*This journal is part of [homelab-infra](https://github.com/DrewOnDigital/homelab-infra)*
