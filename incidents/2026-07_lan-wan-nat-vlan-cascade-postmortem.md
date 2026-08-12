# Postmortem: LAN-to-WAN Connectivity Loss After Adding Default Routes

**System:** Jesus (OPNsense) + Zeus (Cisco SG300-10 L3 switch)
**Component:** Routing, firewall rules, outbound NAT
**Status:** Resolved — full LAN/WAN reachability restored and verified per VLAN
**Severity:** High (full internet outage for routed VLANs)

---

## Summary

After adding what looked like a routine static route in OPNsense, the entire
homelab lost outbound internet access — local subnet traffic kept working, but
nothing routed reached the WAN. The outage turned out to be three separate,
layered problems stacked on top of each other, not one root cause. Each was
found and fixed in sequence, verifying connectivity after every change before
moving to the next.

## Timeline / Diagnostic Sequence

**1. Gateway priority conflict**
`zeus_gw` was set to priority 10, `WAN_DHCP` to priority 254 — numerically
lower priority wins in OPNsense's gateway selection, so Zeus (a LAN-side
device) was being elected as the system default gateway instead of the actual
WAN gateway. Nothing behind Jesus could find a path out to the internet
because the "default route" pointed back into the LAN.
*Fix:* corrected gateway priority so WAN_DHCP was properly preferred for
default egress.

**2. Implicit-deny firewall drop**
With the gateway fixed, VLAN 30 (10.30.30.0/24) traffic still wasn't reaching
WAN. Jesus's LAN firewall rule only matched source `LAN net`
(192.168.1.0/24) — traffic arriving from VLAN 30 via Zeus didn't match any
explicit allow rule, so it was silently dropped by OPNsense's default-deny
behavior. No error, no log flag demanding attention — it just vanished.
*Fix:* added an explicit firewall rule allowing VLAN 30 traffic through.

**3. Outbound NAT scope gap**
Even with routing and firewall rules correct, DNS worked but ICMP/TCP round
trips from VLAN 30 still failed. Root cause: Jesus was running Automatic
outbound NAT, which only auto-generates NAT rules for subnets *directly
attached* to an interface. VLAN 30 reaches Jesus via a static route through
Zeus, not a direct interface attachment — so Automatic mode never saw it and
never built a NAT rule for it. Return traffic from the internet had nothing
to translate back to 10.30.30.x.
*Fix:* implemented Hybrid NAT with a manual outbound NAT rule (via a
VLAN_Subnets alias) covering routed, non-directly-attached subnets.

## Root Cause

Three independent misconfigurations, each masking the next: a backwards
gateway priority, a firewall rule scoped too narrowly for routed VLANs, and
an automatic NAT mode that silently excludes routed (vs. directly attached)
subnets. None of the three alone was catastrophic, but stacked together they
produced a total outage that looked like one big mystery instead of three
small, sequential ones.

## Resolution

Fixed in order — gateway priority, then firewall rule, then NAT — verifying
LAN and WAN reachability after each individual change rather than changing
all three at once. Confirmed working across every affected subnet.

## Lessons Learned

- **Automatic outbound NAT has a blind spot:** it only covers directly
  attached interface networks. Any subnet reached via static route needs a
  manual/hybrid NAT rule, or it will pass firewall and routing checks and
  still fail silently on the way back.
- **Implicit deny fails silently.** "It's not working" after a routing change
  often means "there's no rule for it," not "the rule is wrong." Always check
  firewall rule scope before assuming a deeper routing bug.
- **One variable at a time.** Fixing gateway priority, firewall scope, and
  NAT in the same pass would have made it impossible to tell which fix
  actually mattered. Sequential fix-and-verify is what turned three
  simultaneous symptoms into three separate, provable root causes.
- This is a real production pattern (not just a lab quirk) — "routed subnet
  needs manual outbound NAT" shows up in enterprise networks any time a
  routed VLAN sits behind a firewall running automatic NAT.

## Network+ Domain Tie-In

- **2.0 Implementation** — NAT types (static, dynamic/PAT), routed vs.
  directly-attached subnet behavior
- **4.0 Security** — implicit deny, default-deny firewall behavior
- **5.0 Troubleshooting** — structured, sequential root-cause isolation
  (identify → establish theory → test → verify → document)

## Prevention / Follow-up

- Document NAT scope explicitly per VLAN in `networking/` so any future
  routed VLAN addition includes a NAT-rule checklist item, not just a
  firewall-rule checklist item.
- Same for gateway priority — record the intended priority order for
  WAN_DHCP vs. any LAN-side gateway alias so it's not left to memory during
  future route additions.

---
*Backfilled postmortem — written after the fact from session history, dated
to the approximate month the outage occurred (July 2026). Mark as backfilled
per `HOW_TO_LOG.md` convention.*
