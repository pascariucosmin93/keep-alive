#!/usr/bin/env bash
set -euo pipefail

CONFIG_PATH="${1:-}"
ROLE="${2:-}"
PRIORITY="${3:-}"

if [[ -z "${CONFIG_PATH}" || -z "${ROLE}" || -z "${PRIORITY}" ]]; then
  echo "Usage: $0 <keepalived.conf> <MASTER|BACKUP> <priority>" >&2
  exit 1
fi

if [[ ! -f "${CONFIG_PATH}" ]]; then
  echo "Config file not found: ${CONFIG_PATH}" >&2
  exit 1
fi

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root." >&2
  exit 1
fi

case "${ROLE}" in
  MASTER|BACKUP) ;;
  *)
    echo "Role must be MASTER or BACKUP." >&2
    exit 1
    ;;
esac

cp "${CONFIG_PATH}" "${CONFIG_PATH}.bak-$(date +%F-%H%M%S)"
perl -0pi -e "s/state\\s+(MASTER|BACKUP)/state ${ROLE}/; s/priority\\s+\\d+/priority ${PRIORITY}/" "${CONFIG_PATH}"
echo "Updated ${CONFIG_PATH} to role=${ROLE} priority=${PRIORITY}"
