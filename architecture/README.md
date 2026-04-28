# Architecture

Documentation of the physical and virtual topology of the homelab.

---

## Physical topology

```
ISP
 └── Switch A (unmanaged)
      ├── Switch B (unmanaged)
      │    ├── Mac (admin client)
      │    └── Bare Metal Proxmox VE node (Type 1)
      │         └── Ubuntu 22.04 VMs
      └── Win11 Desktop
           └── VMware Workstation Pro (Type 2)
                ├── Proxmox VE VM 1 (pve-vm-1)
                │    └── Ubuntu 22.04 VMs
                ├── Proxmox VE VM 2 (pve-vm-2)
                │    └── Ubuntu 22.04 VMs
                ├── Proxmox VE VM 3 (pve-vm-3)
                │    └── Ubuntu 22.04 VMs
                └── RHEL 9 VM (direct, no Proxmox layer)
```

---

## Virtualization layers

| Layer | Technology | Type | Notes |
|---|---|---|---|
| Win11 Desktop | VMware Workstation Pro | Type 2 | Host for all nested VMs |
| pve-vm-1/2/3 | Proxmox VE | Nested hypervisor | Primary SRE/DevOps workload platform |
| Ubuntu 22.04 | Guest OS | VM | Primary workload OS for all lab projects |
| RHEL 9 | Guest OS | VM (direct in VMware) | Enterprise / cert practice environment |
| Bare metal PVE | Proxmox VE | Type 1 (Switch B node) | High-performance workloads, future K8s node |

---

## Design decisions

### Why VMware Workstation + nested Proxmox instead of bare metal Proxmox everywhere?

The Win11 desktop is a shared machine — it needs to run normally for daily use.
VMware Workstation lets me carve off resources for the lab without a dedicated server.
Running Proxmox inside VMware requires enabling nested virtualization (Intel VT-x/AMD-V passthrough),
which was deliberately set up to mirror how enterprise environments sometimes nest hypervisors for
test/dev isolation. This is a real-world pattern, not just a homelab workaround.

### Why three Proxmox VE instances instead of one?

Simulates a multi-node cluster environment. Allows me to practice:
- Cross-node VM migration concepts
- Cluster-level networking (future: Proxmox Cluster Manager)
- Workload isolation between project categories (dev/staging/services)

### Why unmanaged switches?

Current state — no VLAN capability. This is a documented limitation, not an oversight.
VLAN segmentation is on the networking roadmap (Phase 2). Documenting current constraints
is part of honest infrastructure documentation.

---

## Current known limitations

| Limitation | Impact | Planned fix |
|---|---|---|
| No static IPs | Nodes can change IP on reboot | Networking Phase 1 |
| No VLAN segmentation | Flat network, no isolation | Networking Phase 2 |
| Unmanaged switches | No VLAN tagging possible at switch level | Hardware upgrade (future) |
| No internal DNS | Name resolution requires IP | Homelab Project 02 |
| No centralized logging | No visibility across nodes | Homelab Project 04 |

---

## Files in this folder

| File | Contents |
|---|---|
| `README.md` | This file — topology and design decisions |

*Diagrams will be added as the architecture evolves.*
