#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:-}"
IPTABLES_SAVE_PATH="${IPTABLES_SAVE_PATH:-/etc/iptables/rules.v4}"

if [[ -z "${CONFIG_FILE}" ]]; then
  echo "Usage: $0 <mapping-file>" >&2
  exit 1
fi

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "Mapping file not found: ${CONFIG_FILE}" >&2
  exit 1
fi

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root." >&2
  exit 1
fi

ensure_nat_absent() {
  if iptables -t nat -C "$@" 2>/dev/null; then
    iptables -t nat -D "$@"
  fi
}

ensure_nat_present() {
  if ! iptables -t nat -C "$@" 2>/dev/null; then
    iptables -t nat -A "$@"
  fi
}

ensure_filter_absent() {
  if iptables -C "$@" 2>/dev/null; then
    iptables -D "$@"
  fi
}

remove_stale_rules() {
  while IFS= read -r rule; do
    [[ -z "${rule}" ]] && continue
    [[ "${rule}" =~ ^# ]] && continue
    # shellcheck disable=SC2206
    parts=(${rule})
    ensure_filter_absent "${parts[@]}"
  done <<< "${REMOVE_FILTER_RULES:-}"

  while IFS= read -r rule; do
    [[ -z "${rule}" ]] && continue
    [[ "${rule}" =~ ^# ]] && continue
    # shellcheck disable=SC2206
    parts=(${rule})
    ensure_nat_absent "${parts[@]}"
  done <<< "${REMOVE_NAT_RULES:-}"
}

apply_mapping() {
  local public_ip="$1"
  local public_port="$2"
  local backend_ip="$3"
  local backend_port="$4"
  local proto="${5:-tcp}"

  ensure_nat_present PREROUTING -d "${public_ip}/32" -p "${proto}" --dport "${public_port}" -j DNAT --to-destination "${backend_ip}:${backend_port}"
  ensure_nat_present OUTPUT -d "${public_ip}/32" -p "${proto}" --dport "${public_port}" -j DNAT --to-destination "${backend_ip}:${backend_port}"
  ensure_nat_present POSTROUTING -d "${backend_ip}/32" -p "${proto}" -j MASQUERADE
}

remove_stale_rules

while read -r public_ip public_port backend_ip backend_port proto; do
  [[ -z "${public_ip:-}" ]] && continue
  [[ "${public_ip}" =~ ^# ]] && continue
  apply_mapping "${public_ip}" "${public_port}" "${backend_ip}" "${backend_port}" "${proto:-tcp}"
done < "${CONFIG_FILE}"

iptables-save > "${IPTABLES_SAVE_PATH}"
echo "NAT rules synchronized and persisted to ${IPTABLES_SAVE_PATH}"
