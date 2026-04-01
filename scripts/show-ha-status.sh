#!/usr/bin/env bash
set -euo pipefail

VIP_FILTER="${1:-}"

echo "Hostname: $(hostname)"
echo
echo "Keepalived:"
systemctl status keepalived --no-pager -l || true
echo
echo "IPv4 addresses:"
ip -4 addr show
echo
echo "NAT PREROUTING:"
if [[ -n "${VIP_FILTER}" ]]; then
  iptables -t nat -L PREROUTING -n -v --line-numbers | grep "${VIP_FILTER}" || true
else
  iptables -t nat -L PREROUTING -n -v --line-numbers
fi
