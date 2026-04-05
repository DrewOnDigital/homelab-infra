# My Self-Hosted Infrastructure Lab (SRE Track)

# Andrew Jones
# https://www.linkedin.com/in/andrew-jones-8779b6247/
# https://twitch.tv/DrewOnDigital
# https://youtube.com/@DrewonDigital
# https://tiktok.com/@drewondigital


## 🧠 Purpose

This repository documents the design, deployment, and evolution of my homelab infrastructure.

The goal is to simulate real-world production environments and develop skills in:
- Systems Engineering
- Site Reliability Engineering (SRE)
- Infrastructure Design
- Enterprise Automation

This is not a static lab — it is an evolving system.

---

## 🏗️ System Overview

Current architecture:

- ISP-connected network
- Dual-switch topology (unmanaged)
- Mixed virtualization stack:
  - VMware Workstation (Type 2 Hypervisor)
  - Proxmox VE (nested + bare metal)

---

## 🖥️ Physical Infrastructure

### Switch A
- Windows 11 Host
  - VMware Workstation
    - 3x Proxmox VE (nested)
    - 1x RHEL VM

### Switch B
- macOS Admin Machine
- Bare Metal Proxmox Node

---

## 🌐 Network Design (Current State)

- DHCP-based addressing (no static IPs yet)
- Flat network (no VLAN segmentation)
- Basic connectivity between nodes

---

## ⚠️ Current Limitations

- No deterministic IP addressing
- No segmentation or isolation
- No centralized logging or monitoring
- No service exposure layer (reverse proxy, DNS)

---

## 🚀 Roadmap (SRE Evolution)

### Phase 1 — Stability
- [ ] Implement static IP addressing
- [ ] Document IP schema
- [ ] Introduce basic DNS

### Phase 2 — Control
- [ ] VLAN segmentation
- [ ] Internal routing strategy
- [ ] Firewall rules (east/west traffic)

### Phase 3 — Service Layer
- [ ] Deploy reverse proxy (NGINX)
- [ ] Host internal services
- [ ] Build first user-facing app

### Phase 4 — Observability
- [ ] Metrics (Prometheus)
- [ ] Visualization (Grafana)
- [ ] Log aggregation

### Phase 5 — Automation
- [ ] Infrastructure as Code (Terraform / Ansible)
- [ ] CI/CD pipeline for deployments

---

## 🧠 Engineering Mindset

This environment is intentionally designed with increasing complexity to mirror real-world infrastructure challenges.

Every change is:
1. Planned
2. Implemented
3. Documented
4. Evaluated
