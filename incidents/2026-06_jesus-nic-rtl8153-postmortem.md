# Postmortem: Jesus LAN NIC Instability (RTL8153 → Belkin Swap)

**System:** Jesus (OPNsense firewall)
**Component:** LAN-side USB-to-Ethernet adapter
**Status:** Resolved — Belkin USB-C NIC confirmed stable in production
**Severity:** High (LAN-facing interface, affects all downstream VLANs)

---

## Summary

Jesus needed a second NIC to serve as the LAN interface, since the host only has a
single onboard port (WAN). Chipset research pointed to the Realtek RTL8153 as the
safe, FreeBSD/OPNsense-compatible choice — the alternative chipset in the same
adapter family, ASIX AX88179A, had documented instability on FreeBSD (link drops
under sustained load, watchdog timeouts, hotplug events after traffic flowed for a
while). Based on that research, an RTL8153-chipset adapter was purchased and put
into production on Jesus's LAN interface.

In practice, the RTL8153 adapter did not hold up on this specific
host/driver/power-delivery combination. It was swapped for a Belkin USB-C NIC,
which has since been stable in continuous production use.

## Timeline

1. Identified need for a second NIC on Jesus (single onboard WAN port only).
2. Researched chipset compatibility for USB-C-to-Ethernet adapters on
   FreeBSD/OPNsense. Found AX88179A flagged as unstable — recognized in dmesg,
   works initially, then drops link after traffic under load.
3. Cross-checked budget adapter brands (TP-Link, UGREEN, Anker) — confirmed most
   share the same RTL8153 or AX88179A chipsets depending on hardware revision.
4. Purchased and deployed an RTL8153-chipset USB-C adapter as Jesus's LAN NIC,
   based on RTL8153 being the documented-stable option.
5. Adapter did not perform reliably in production on Jesus.
6. Swapped to a Belkin USB-C NIC. Confirmed stable under sustained LAN traffic
   across all VLANs.

## Root Cause

Chipset-level compatibility research (RTL8153 = FreeBSD-stable per community
reports) was necessary but not sufficient. It doesn't account for
adapter-specific variables outside the chipset itself — USB controller behavior on
the specific host port, power delivery under sustained load, and build-quality
differences between vendors shipping the "same" chipset. The RTL8153 label on the
box guaranteed the chip, not the adapter's real-world behavior on this exact
hardware pairing.

## Resolution

Replaced the RTL8153 adapter with a Belkin USB-C NIC on Jesus's LAN interface.
No further link drops or instability observed since the swap.

## Lessons Learned

- Spec-sheet / chipset-level compatibility is a filter, not a guarantee. The next
  step after "the chipset is documented-stable" is still "test it on the actual
  host under actual load" before calling it production-ready.
- A firewall's LAN interface is not a place to tolerate "probably fine" hardware —
  it's the single point every downstream VLAN depends on. Any instability there
  is a full network outage, not a component annoyance.
- Documenting the *why* behind a hardware choice (not just the final pick) is
  what makes a postmortem valuable later — the RTL8153 recommendation was
  reasonable given the information available at the time; the postmortem is what
  captures that reasoning turned out to be incomplete, not wrong.

## Prevention / Follow-up

- Standing rule: before committing to a NIC (or any component) for Genesis,
  Zeus, Jesus, or Lucifer, verify against the 10-point homelab vision *and*
  budget in a short burn-in/load test window before calling it production.
- Keep the Belkin adapter's exact model/part number recorded in
  `environments/jesus.md` (or equivalent) as the confirmed-good reference, so
  future replacements start from a known-working baseline instead of re-doing
  this research from scratch.

---
*Backfilled postmortem — written after the fact from session history, dated to
the approximate month the swap occurred (June 2026). Mark as backfilled per
`HOW_TO_LOG.md` convention.*
