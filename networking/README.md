# Networking

Network design documentation for the homelab.

---

## Current state (April 2026)

| Attribute | Current value | Target |
|---|---|---|
| IP addressing | DHCP (dynamic) | Static assignments |
| Segmentation | Flat network (no VLANs) | VLAN-segmented |
| DNS | None (IP-only) | Internal CoreDNS |
| Firewall | None (host OS firewalls only) | pfSense or host-based rules |
| Switch type | Unmanaged | Managed (future) |

---

## Physical layout

```
ISP
 └── Switch A (unmanaged, 192.168.x.x/24 — DHCP from ISP router)
      ├── Win11 Desktop (VMware host)
      └── Switch B (unmanaged, same subnet)
           ├── Mac (admin client)
           └── Bare Metal Proxmox node
```

All nodes currently share a single flat subnet. No isolation between lab traffic and general LAN traffic.

---

## Phase 1 — Static IPs (planned)

Goal: deterministic addressing so nodes don't move on reboot.

Planned schema (subject to finalization):

| Node | Planned IP | Notes |
|---|---|---|
| Win11 / VMware Host | 192.168.x.10 | TBD based on existing subnet |
| pve-vm-1 | 192.168.x.11 | |
| pve-vm-2 | 192.168.x.12 | |
| pve-vm-3 | 192.168.x.13 | |
| Bare Metal PVE | 192.168.x.20 | |
| Mac (admin) | 192.168.x.5 | |
| rhel-vm | 192.168.x.30 | |

*Actual subnet TBD — will be documented here once assigned.*

---

## Phase 2 — VLAN segmentation (planned)

Requires switch upgrade to managed hardware. Planned segments:

| VLAN | ID | Purpose |
|---|---|---|
| Management | 10 | Proxmox UIs, SSH, admin access |
| Lab workloads | 20 | VMs running active lab projects |
| Services | 30 | Exposed services (reverse proxy, DNS, etc.) |
| IoT / general | 40 | General LAN, non-lab traffic |

---

## Phase 3 — Internal DNS (planned)

Target: CoreDNS running inside lab, resolving `.lab` or `.internal` domain.

Allows referring to nodes by name (`pve-vm-1.lab`) instead of IP.
Prerequisite: static IPs must be assigned first (Phase 1).

---

## Notes

This is a living document. Entries will be updated as each networking phase is implemented.
