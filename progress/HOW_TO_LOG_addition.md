## Post-change verification (added 2026-08-12, after 3rd NAT/DNS-related regression)

Any time you touch Jesus or Zeus configuration — firewall rules, NAT mode,
aliases, gateway priority, DNS/Unbound settings, or even a cosmetic change
like a hostname rename — run this before closing the session:

1. **Raw IP ping test** from at least one host per VLAN: `ping 8.8.8.8`
   (or another external IP). Confirms outbound NAT/routing/firewall path
   is intact, independent of DNS.
2. **DNS resolution test** from the same host(s): `nslookup google.com` or
   `dig google.com`. Confirms name resolution independently of the
   outbound path.
3. If either fails, you now know which half of the stack broke before you
   even start troubleshooting — don't skip straight to guessing.

**Why this exists:** three separate incidents (RTL8153 NIC swap follow-on,
the original LAN-WAN NAT cascade, kazuya's NAT mode regression, and the
Jesus rename DNS breakage) all traced back to this same corner of the
config, and none of them were caught until a device actually lost internet
access. This two-command check costs under 30 seconds and would have
caught every one of them immediately after the triggering change, instead
of on next use.

**Known-good baseline reference (update if intentionally changed):**
- Outbound NAT mode on Jesus: **Hybrid** (not Automatic — confirmed
  failure mode, see `incidents/2026-08-11_kazuya-vlan30-nat-regression-postmortem.md`)
- Gateway priority: WAN_DHCP ranked above any LAN-side gateway alias
- `VLAN_Subnets` alias: must include every routed (non-directly-attached)
  VLAN subnet, currently `10.30.30.0/24` at minimum
