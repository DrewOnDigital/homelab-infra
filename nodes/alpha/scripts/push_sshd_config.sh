#!/usr/bin/env bash
# push_sshd_config.sh
# Copies alpha's sshd_config to all Proxmox nodes,
# validates, restarts sshd, and confirms connectivity.
# Run from: alpha
# Usage: ./push_sshd_config.sh

set -euo pipefail

NODES=(bravo charlie echo)
CONFIG_SRC="/etc/ssh/sshd_config"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "=== Pushing sshd_config from alpha to all nodes ==="
echo ""

for node in "${NODES[@]}"; do
  echo "--- $node ---"

  echo "  [1/3] Backing up existing config..."
  ssh root@$node "cp $CONFIG_SRC ${CONFIG_SRC}.bak.${TIMESTAMP}"

  echo "  [2/3] Copying new config..."
  scp $CONFIG_SRC root@$node:$CONFIG_SRC

  echo "  [3/3] Validating config..."
  ssh root@$node "sshd -t && echo '  config OK'"

  echo ""
done

echo "=== All nodes updated. Restarting sshd... ==="
echo ""

for node in "${NODES[@]}"; do
  ssh root@$node "systemctl restart sshd && echo '$node sshd restarted OK'"
done

echo ""
echo "=== Final connectivity test ==="
for node in "${NODES[@]}"; do
  ssh root@$node "echo '  $node SSH responding OK'"
done

echo ""
echo "=== Done ==="
