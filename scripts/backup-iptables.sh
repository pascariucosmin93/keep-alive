#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="${1:-/etc/iptables}"
TIMESTAMP="$(date +%F-%H%M%S)"
BACKUP_PATH="${BACKUP_DIR}/rules.v4.bak-${TIMESTAMP}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root." >&2
  exit 1
fi

mkdir -p "${BACKUP_DIR}"
iptables-save > "${BACKUP_PATH}"
echo "Saved backup to ${BACKUP_PATH}"
