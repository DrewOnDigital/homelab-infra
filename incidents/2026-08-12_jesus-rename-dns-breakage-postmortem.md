# Postmortem: DNS Resolution Failure After Renaming Jesus in OPNsense UI

**System:** Jesus (OPNsense firewall)
**Component:** Unbound DNS resolver, gateway routing
**Status:** Resolved — fix confirmed, exact causal mechanism not fully isolated
**Severity:** Medium (single-firewall event, but broke internet access
network-wide since Jesus is the sole DNS resolver/gateway)

---

## Summary

After renaming Jesus from the OPNsense UI, DNS resolution stopped working
network-wide, which took down internet access entirely (name resolution
failing looks identical to "no internet" for almost every application, even
though routing itself may have been partially fine). Two changes were made
in the same troubleshooting pass — a gateway priority correction and adding
explicit DNS forwarders to Unbound — and the issue resolved after both were
in place. Root cause is confirmed to be one or both of those; the exact
mechanism (which change actually fixed it) hasn't been isolated yet, since
they weren't tested independently.

## Timeline / Diagnostic Sequence

**1. Symptom identified**
DNS stopped resolving after the Jesus rename, which prevented internet
access network-wide.

**2. Traceroute showed asymmetric-looking routing**
Traceroutes were bouncing back and forth between Zeus and Jesus interfaces —
a pattern consistent with asymmetric routing (traffic leaving one path,
return traffic arriving via another). This pointed at gateway selection as
a suspect.

**3. Gateway priority correction**
Checked System > Gateways > Configuration and raised WAN interface priority
above LAN interface priority, on the theory that the rename may have reset
or reshuffled gateway priority values (echoing the earlier `zeus_gw` vs.
`WAN_DHCP` priority conflict from the original NAT cascade incident).

**4. Unbound DNS forwarder check**
Checked Services > Unbound DNS > Query Forwarding and added explicit
forwarders — 1.1.1.1 and 8.8.8.8, both on port 53 — as known-good upstream
resolvers, in case the rename had disrupted Unbound's default resolution
path.

**5. Verified issue was not at the firewall/rule level**
Ran a `dig google.com` test against loopback to confirm the firewall itself
wasn't blocking DNS traffic — isolating the problem to routing/resolution
rather than a firewall rule change.

**6. Confirmed fix**
Traceroutes, pings, and dig queries had all failed prior to steps 3 and 4.
After making both changes (gateway priority + explicit forwarders),
resolution and connectivity came back.

## Root Cause

**Confirmed:** the fix required both the gateway priority correction and
the addition of explicit Unbound forwarders — connectivity did not work
before either change and did work after both were made.

**Not yet isolated:** which of the two changes was actually necessary, or
whether both were required together. Two live hypotheses:

- Renaming Jesus in the OPNsense UI reset or altered gateway priority
  values, reproducing the same "wrong device treated as default gateway"
  failure mode seen in the original LAN-to-WAN cascade incident — in which
  case the forwarder addition may have been incidental.
- The rename disrupted Unbound's resolution path or forwarder config
  specifically, and the gateway priority fix addressed a separate,
  coincidental asymmetric-routing symptom rather than the actual cause.

This is marked honestly as unconfirmed rather than assigning a single root
cause the evidence doesn't fully support.

## Resolution

Applied both fixes in the same session:
1. Corrected WAN gateway priority to rank above LAN gateway priority.
2. Added 1.1.1.1 and 8.8.8.8 as explicit Unbound query-forwarding targets
   on port 53.

Verified via `dig` against loopback that the firewall rule layer was not
the blocker, confirming the fix lived in routing/DNS configuration, not
firewall policy.

## Lessons Learned

- **A UI rename on a firewall/router is not a cosmetic change.** Renaming
  Jesus touched gateway and/or DNS resolver behavior in a way that wasn't
  obvious going in — any name change on core infrastructure should be
  treated as a config-risk event, not a label update.
- **Testing DNS and firewall independently is what actually isolates
  root cause.** The loopback `dig` test was the right move — it separated
  "is this a rule problem" from "is this a resolution/routing problem"
  before guessing at a fix.
- **Changing two things in the same pass makes root cause ambiguous.**
  This is the honest tradeoff of troubleshooting under time pressure: the
  fix worked, but because gateway priority and DNS forwarders were changed
  together, this postmortem can't yet say with certainty which one
  mattered. That's a gap to close, not a finding to fabricate confidence
  around.
- **This may be the same underlying gateway-priority failure mode
  recurring a second time**, now triggered by a rename instead of a
  routing change — worth testing that theory in isolation next time it's
  safe to do so.

## Network+ Domain Tie-In

- **1.0 Networking Concepts** — DNS resolution as a dependency almost every
  application relies on; "no internet" symptoms often being DNS problems
  in disguise
- **2.0 Implementation** — DNS forwarder/resolver configuration, gateway
  priority and default route selection
- **5.0 Troubleshooting** — using `dig`/loopback tests to isolate firewall
  vs. resolution vs. routing layers before changing configuration

## Prevention / Follow-up

- **To close the open question:** next low-stakes opportunity, test the
  gateway priority fix and the Unbound forwarder fix independently (revert
  one, confirm state, then the other) to actually isolate which change was
  load-bearing. Update this postmortem once confirmed.
- Treat any hostname/label change on Jesus (or any core node) as requiring
  a post-change connectivity and DNS check before closing the session —
  same standing checklist habit as the NAT alias lesson from the kazuya
  incident.
- Document current gateway priority values and Unbound forwarder config as
  the known-good baseline in `networking/`, so a future rename or edit can
  be diffed against a reference instead of reconstructed from memory.

---
*Written from live session notes — not backfilled. Root cause intentionally
marked as confirmed-fix / unconfirmed-mechanism rather than overstated.*
