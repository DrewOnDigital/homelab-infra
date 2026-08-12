# Postmortem: Recurring VLAN 30 Outbound Failure (kazuya) — NAT Alias Regression + DNS Misconfig Found

**System:** kazuya (Windows Server 2022 VM, VLAN 30) → Zeus (SG300-10) → Jesus (OPNsense)
**Component:** Outbound NAT alias, VLAN 30 firewall path, DNS client config
**Status:** Diagnosed and isolated to Jesus's NAT/alias config; DNS misconfig identified as a secondary, non-blocking finding
**Severity:** Medium (single-VLAN outage, not network-wide; recurrence of a known failure mode)

---

## Summary

kazuya (10.30.30.2/24, gateway 10.30.30.1) lost outbound internet access after
working on unrelated VLAN 1001 configuration on Zeus. Internal reachability was
fully intact — kazuya could ping itself, its gateway, and every other node
(Apex, Zeus, Jesus) — but nothing reached the internet. This is the same
symptom signature as the earlier LAN-to-WAN NAT cascade outage, but scoped to
one subnet this time, which pointed straight at the `VLAN_Subnets` alias or
outbound NAT mode having reverted or dropped a member while editing aliases
for VLAN 1001.

## Diagnostic Sequence

**1. Isolate NAT/firewall vs. DNS**
Ran two tests from kazuya before touching Jesus:
- `ping 8.8.8.8` (raw IP, no DNS) → 100% loss
- `nslookup google.com` → resolved successfully

Result: DNS resolution was working perfectly. The raw IP ping failing while
DNS succeeded confirmed this was an outbound NAT/firewall path problem, not a
DNS problem — ruling out an entire branch of troubleshooting in ten seconds
instead of working through it blind.

**2. Narrowed to the known regression point**
Given internal L2/L3 reachability was fully intact (proving Zeus's trunk to
Jesus was fine), the fault had to be on Jesus itself, in one of:
- Firewall > NAT > Outbound mode (Hybrid vs. reverted to Automatic/Manual)
- Firewall > Aliases > `VLAN_Subnets` — whether `10.30.30.0/24` was still a
  member
- Firewall > Rules > VLAN30 interface — outbound allow rule intact
- System > Gateways > Status — WAN gateway not down/flagged

Top suspect going in: the `VLAN_Subnets` alias, since it was the piece most
likely to have been touched collaterally while working on VLAN 1001 in the
same session.

**3. Secondary finding — DNS misconfiguration (non-blocking)**
While confirming DNS worked, the resolver kazuya was actually querying showed
as `192.168.1.1` — OPNsense's factory-default LAN IP — instead of the correct
VLAN 30 resolver address (`10.30.30.1`). This currently works because
`unbound` listens on all interfaces, so the wrong-but-reachable IP still
answered. It's not causing an outage today, but it's a latent
misconfiguration: if that default LAN interface or its listener config ever
changes, kazuya's DNS breaks silently with no warning, on a completely
separate timeline from any NAT issue.

## Root Cause

Same underlying pattern as the earlier LAN-to-WAN cascade: OPNsense's
`VLAN_Subnets` alias / outbound NAT scope is fragile to *adjacent*
configuration work. Editing aliases or NAT rules while working on an
unrelated VLAN (1001, in this case) has now caused a routed subnet to drop
out of outbound NAT scope twice. The regression risk isn't in any one
setting — it's that alias membership and outbound NAT mode aren't
change-controlled or verified after every edit in that area of the firewall.

## Resolution

**Confirmed root cause:** Jesus's outbound NAT mode had reverted to (or was
left on) **Automatic**. Switching it to **Hybrid** — so explicit rules are
evaluated first, then Automatic fills in whatever isn't explicitly covered —
resolved the outage. This matches the original NAT cascade postmortem's
lesson directly: Automatic mode doesn't reliably cover routed, non-directly-
attached subnets like VLAN 30, and Hybrid is the durable fix, not a one-time
patch.

DNS misconfiguration on kazuya (pointed at `192.168.1.1` instead of
`10.30.30.1`) flagged for correction separately — confirmed non-blocking,
not the cause of this outage.

## Lessons Learned

- **The two-command triage (`ping <raw IP>` vs. `nslookup`) is the fastest
  possible fork in the road** for "no internet" symptoms — it separates NAT/
  firewall problems from DNS problems in seconds, before touching any device
  configuration.
- **This is a recurrence, not a new failure mode.** The first time a
  routed-subnet NAT gap happened, it was three stacked misconfigurations
  found and fixed once. This time, the same alias/NAT surface regressed
  again as a side effect of unrelated work — which means the fix from the
  first incident wasn't paired with a safeguard to stop it from happening
  again.
- **Working "in the same firewall neighborhood" carries collateral risk.**
  Touching aliases for VLAN 1001 put `VLAN_Subnets` at risk even though VLAN
  1001 and VLAN 30 aren't related — a reminder that shared config objects
  (aliases, groups) are a blast-radius multiplier.
- **DNS server misassignment can hide behind "it still works."** kazuya
  pointing at the wrong resolver IP produced zero symptoms today only
  because of how `unbound` is currently configured. A working symptom-free
  state is not the same as a correct configuration — worth a periodic audit
  pass on DNS settings per VM, not just a "did it resolve" check.

## Network+ Domain Tie-In

- **5.0 Troubleshooting** — structured triage (ping raw IP vs. DNS lookup)
  to isolate the failure domain before touching any config
- **2.0 Implementation** — outbound NAT modes and alias-based scoping
- **1.0 Networking Concepts** — DNS client configuration vs. actual resolver
  reachability (a host can "work" while pointed at the wrong server)

## Prevention / Follow-up

- Add a standing checklist item to `HOW_TO_LOG.md`: after any edit to a
  firewall alias or NAT rule on Jesus — regardless of which VLAN prompted
  the change — ping-test outbound connectivity from every VLAN before
  closing the session.
- Consider a lightweight health-check script: a bash loop pinging `8.8.8.8`
  from each VLAN gateway, run after any Zeus or Jesus config change. Cheap
  insurance against this exact regression happening a third time.
- Correct kazuya's DNS client setting to point at `10.30.30.1` (or the
  intended VLAN 30 resolver) instead of the default `192.168.1.1`, and spot
  check other VMs for the same latent misconfiguration.
- Document `VLAN_Subnets` alias membership and outbound NAT mode explicitly
  in `networking/` as the "known-good" reference state, so a regression is
  a quick diff instead of a re-diagnosis from scratch.

## Standing Fix (carry forward)

Outbound NAT on Jesus should stay on **Hybrid**, not Automatic, going
forward. Automatic is the recurring failure mode across two separate
incidents now — treat any drift back to Automatic as a regression, not a
neutral default.

---
*Written from live session notes — not backfilled. Date to the session date
once confirmed for `HOW_TO_LOG.md` sequencing.*
