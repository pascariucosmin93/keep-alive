#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="/usr/local/sbin"
KEEPALIVED_DIR="/etc/keepalived"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root." >&2
  exit 1
fi

install -d "${BIN_DIR}"
install -d "${KEEPALIVED_DIR}"

install -m 0755 "${ROOT_DIR}/scripts/backup-iptables.sh" "${BIN_DIR}/backup-iptables.sh"
install -m 0755 "${ROOT_DIR}/scripts/apply-nat-mappings.sh" "${BIN_DIR}/apply-nat-mappings.sh"
install -m 0755 "${ROOT_DIR}/scripts/set-iptables-vip.sh" "${BIN_DIR}/set-iptables-vip.sh"
install -m 0755 "${ROOT_DIR}/scripts/set-keepalived-role.sh" "${BIN_DIR}/set-keepalived-role.sh"
install -m 0755 "${ROOT_DIR}/scripts/show-ha-status.sh" "${BIN_DIR}/show-ha-status.sh"

install -m 0644 "${ROOT_DIR}/examples/nat-mappings.conf.example" "${KEEPALIVED_DIR}/nat-mappings.conf.example"
install -m 0644 "${ROOT_DIR}/examples/keepalived.conf.example" "${KEEPALIVED_DIR}/keepalived.conf.example"

echo "Installed toolkit to ${BIN_DIR}"
echo "Installed examples to ${KEEPALIVED_DIR}"
