### April 2026 — Infrastructure baseline + GitHub portfolio setup

**What I did:**
Stood up Genesis as the primary bare-metal Proxmox host (Acer Nitro AN515-53,
i7, 32GB RAM). Overhauled the `homelab-infra` GitHub repo — replaced
placeholder/fictional hardware listings with real architecture docs, added a
native Mermaid topology diagram, cert tracker, project roadmap table, and
per-folder READMEs. Fixed a double-commit bug in `git_auto_push.sh`.

**Why:**
No documentation = no portfolio. A recruiter needs to understand the lab in
under 30 seconds, and writing the docs forced real clarity on what was
actually built vs. assumed.

**What broke:**
The repo's `index.html` had fictional hardware (Dell PowerEdge, Synology NAS,
Ubiquiti Dream Machine) left over from an early placeholder pass — none of it
matched the real lab. Caught and removed during the audit.

**What I learned:**
Fake documentation is worse than no documentation. Also — a broken automation
script (`git_auto_push.sh` double-committing) can sit silently failing for a
long time if you never check what it's actually doing.

**Next:** Migrate off the old nested-VM architecture onto real bare-metal
Proxmox.

---

### May 2026 — Alpha node storage crisis + stabilization

**What I did:**
Diagnosed and fully resolved a critical Proxmox storage crisis on the "alpha"
bare-metal node — EXT4 journal aborts and a reboot loop caused by a VM disk
creation consuming the last free Physical Extents in the volume group.
Executed a 7-step stabilization runbook: shrank swap, cleaned `/root`,
purged old packages, set journald limits, deployed hourly disk-monitoring
cron, and committed a formal incident report to GitHub.

**Why:**
Alpha was in a reboot loop with a read-only filesystem — this was a live
production-style incident, not a planned lab exercise.

**What broke:**
Ran the volume group's free space to zero without noticing, which cascaded
into I/O errors and forced the filesystem read-only.

**What I learned:**
LVM free-space monitoring isn't optional once you're running real workloads
on bare metal — the cron-based disk_check.sh threshold monitor came directly
out of this incident, not from planning ahead.

**Next:** Alpha was later decommissioned as the lab architecture consolidated
onto Genesis; this incident's monitoring habits carried forward.

---

### June 2026 — Genesis buildout, NIC research, VLAN foundations

**What I did:**
Migrated off the retired nested-VM setup and stood up Genesis clean under
Proxmox VE. Researched USB-C-to-Ethernet chipset compatibility for Jesus's
LAN interface (RTL8153 vs. AX88179A on FreeBSD/OPNsense), deployed an
RTL8153-chipset adapter, and began locking in the VLAN stack (10/20/30/40/
1001).

**Why:**
The nested VMware→Proxmox architecture was being formally retired in favor
of real bare-metal — Genesis needed to be the clean foundation everything
else builds on.

**What broke:**
The RTL8153 adapter that research flagged as the "safe" chipset didn't hold
up in production on Jesus. Swapped to a Belkin USB-C NIC, which has been
stable since. See: `incidents/2026-06_jesus-nic-rtl8153-postmortem.md`.

**What I learned:**
Chipset-level compatibility research is necessary but not sufficient —
real-world burn-in testing on the actual hardware is what actually validates
a component for production use, not a spec sheet.

**Next:** Full VLAN architecture rollout across Zeus and Jesus.

---

### July 2026 — VLAN rollout, HOW_TO_LOG.md, and the LAN-to-WAN cascade

**What I did:**
Locked in the VLAN stack (10 BYOD / 20 Desktops / 30 Servers / 40 IoT / 1001
Management), configured the VLAN 1001 management trunk on Zeus, and diagnosed
a full LAN-to-WAN outage caused by three stacked misconfigurations —
backwards gateway priority, an implicit-deny firewall drop on VLAN 30, and an
outbound NAT scope gap for routed subnets. Also created `HOW_TO_LOG.md` to
formalize session logging discipline going forward.

**Why:**
The VLAN stack needed to move from "designed" to "actually enforced," and the
outage needed root-causing before more VLAN work could safely continue on
top of it.

**What broke:**
Adding a routine static route took down all outbound internet access
network-wide. Root-caused and fixed in sequence — gateway priority, then
firewall rule, then NAT — verifying connectivity after each step. See:
`incidents/2026-07_lan-wan-nat-vlan-cascade-postmortem.md`.

**What I learned:**
Automatic outbound NAT in OPNsense only covers directly-attached interfaces
— any subnet reached via static route needs manual/hybrid NAT, or it fails
silently on the return path. Implicit-deny firewall behavior also fails
silently — "not working" usually means "no rule for it," not "wrong rule."

**Next:** Begin Network+ exam prep sprint; keep hardening the VLAN/NAT
config against regression.

---

### August 2026 — Network+ sprint, and two firewall regressions

**What I did:**
Ran DNS recursive-resolution deep dives (`nslookup`/`drill`) and port
memorization drilling as part of Network+ prep (exam date: August 29).
Also hit and resolved two firewall-related regressions on Jesus: kazuya
(VLAN 30) losing outbound internet access due to outbound NAT reverting to
Automatic mode, and DNS resolution breaking network-wide after renaming
Jesus in the OPNsense UI.

**Why:**
Network+ is the fixed near-term milestone; the two live incidents doubled
as real-world validation of the troubleshooting methodology being studied
for the exam.

**What broke:**
- Kazuya lost internet access; confirmed root cause was outbound NAT mode
  on Automatic instead of Hybrid, fixed by switching to Hybrid. See:
  `incidents/2026-08-11_kazuya-vlan30-nat-regression-postmortem.md`.
- Renaming Jesus in the UI broke DNS network-wide; fixed via a gateway
  priority correction and adding explicit Unbound DNS forwarders
  (1.1.1.1, 8.8.8.8) — fix confirmed, exact causal mechanism not yet
  isolated between the two changes. See:
  `incidents/2026-08-12_jesus-rename-dns-breakage-postmortem.md`.

**What I learned:**
This is the second time outbound NAT/gateway-priority behavior has caused
an outage on Jesus — a pattern, not a one-off. A UI rename on core
infrastructure is a config-risk event, not a cosmetic change. The
raw-IP-ping-vs-nslookup triage is the fastest way to fork "NAT problem" vs.
"DNS problem" before touching any config.

**Next:**
- Isolate incident 4's root cause by testing the gateway priority fix and
  the DNS forwarder fix independently.
- Add a standing post-change checklist item: ping/dig triage across all
  VLANs after any Jesus or Zeus config change, including renames.
- Continue Network+ sprint toward the August 29 exam date.
