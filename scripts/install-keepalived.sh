#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root." >&2
  exit 1
fi

if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y keepalived iptables iptables-persistent
  echo "Installed keepalived and iptables-persistent with apt."
  exit 0
fi

echo "Unsupported package manager. Install keepalived and iptables-persistent manually." >&2
exit 1
