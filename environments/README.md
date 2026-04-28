# Environments

Node inventory and per-environment specifications for the homelab.

---

## Node inventory

### Win11 Desktop — VMware Host

| Attribute | Value |
|---|---|
| Role | Primary lab host (Type 2 hypervisor) |
| OS | Windows 11 |
| Hypervisor | VMware Workstation Pro |
| Location | Switch A |
| IP | DHCP (static assignment pending) |
| Hosts | pve-vm-1, pve-vm-2, pve-vm-3, rhel-vm |

---

### pve-vm-1

| Attribute | Value |
|---|---|
| Role | Proxmox VE node (nested) — Lab cluster node 1 |
| Guest OS | Proxmox VE (running inside VMware) |
| Workload OS | Ubuntu 22.04 LTS VMs |
| IP | DHCP (static assignment pending) |
| Proxmox UI | http://\<ip\>:8006 |

---

### pve-vm-2

| Attribute | Value |
|---|---|
| Role | Proxmox VE node (nested) — Lab cluster node 2 |
| Guest OS | Proxmox VE (running inside VMware) |
| Workload OS | Ubuntu 22.04 LTS VMs |
| IP | DHCP (static assignment pending) |
| Proxmox UI | http://\<ip\>:8006 |

---

### pve-vm-3

| Attribute | Value |
|---|---|
| Role | Proxmox VE node (nested) — Lab cluster node 3 |
| Guest OS | Proxmox VE (running inside VMware) |
| Workload OS | Ubuntu 22.04 LTS VMs |
| IP | DHCP (static assignment pending) |
| Proxmox UI | http://\<ip\>:8006 |

---

### rhel-vm

| Attribute | Value |
|---|---|
| Role | Enterprise sysadmin / cert practice |
| Guest OS | RHEL 9 (direct VMware VM, no Proxmox layer) |
| IP | DHCP (static assignment pending) |
| Notes | Used for RHEL-specific tooling, subscription-based practice |

---

### Bare Metal Proxmox Node (Switch B)

| Attribute | Value |
|---|---|
| Role | Type 1 hypervisor — higher-performance workloads |
| OS | Proxmox VE (bare metal install) |
| Workload OS | Ubuntu 22.04 LTS VMs |
| Location | Switch B |
| IP | DHCP (static assignment pending) |
| Proxmox UI | http://\<ip\>:8006 |
| Notes | Future target for Kubernetes node workloads |

---

### Mac — Admin Client (Switch B)

| Attribute | Value |
|---|---|
| Role | Administration workstation |
| OS | macOS |
| Location | Switch B |
| IP | DHCP |
| Notes | Primary terminal / SSH access point for all lab nodes |

---

## IP schema (planned)

Static IP assignment is a Phase 1 networking task. Schema TBD.
See [`../networking/README.md`](../networking/README.md) for planning notes.

---

## Ubuntu 22.04 VM baseline

All Ubuntu 22.04 VMs in the lab are built from a common baseline:

- [ ] Static hostname set (e.g. `lab-docker-01`)
- [ ] SSH key-based auth only (password auth disabled)
- [ ] `ufw` firewall enabled
- [ ] `qemu-guest-agent` installed (Proxmox integration)
- [ ] Baseline packages: `curl`, `wget`, `git`, `htop`, `net-tools`, `unzip`
- [ ] Static IP assigned (pending networking Phase 1)

*Checklist updated as baseline is enforced across nodes.*
