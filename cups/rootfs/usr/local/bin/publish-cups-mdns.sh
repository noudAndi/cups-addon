#!/usr/bin/with-contenv bash
set -euo pipefail

SERVICES_DIR="/etc/avahi/services"
SERVICE_TEMPLATE="/etc/avahi/templates/cups-printer.service.template"
STATE_FILE="/tmp/cups_printers_mdns.state"

mkdir -p "${SERVICES_DIR}"

if [[ ! -f "${SERVICE_TEMPLATE}" ]]; then
  echo "Missing service template: ${SERVICE_TEMPLATE}" >&2
  exit 1
fi

xml_escape() {
  printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e "s/'/\&apos;/g" -e 's/"/\&quot;/g'
}

safe_slug() {
  printf '%s' "$1" | tr -cs 'A-Za-z0-9._-' '_'
}

sed_escape_replacement() {
  printf '%s' "$1" | sed -e 's/[&|\\]/\\&/g'
}

render_service_file() {
  local queue="$1"
  local display_name="$2"
  local file_name
  local escaped_name
  local escaped_queue

  file_name="${SERVICES_DIR}/cups-printer-$(safe_slug "${queue}").service"
  escaped_name="$(xml_escape "${display_name}")"
  escaped_queue="$(xml_escape "${queue}")"

  sed \
    -e "s|__DISPLAY_NAME__|$(sed_escape_replacement "${escaped_name}")|g" \
    -e "s|__QUEUE_NAME__|$(sed_escape_replacement "${escaped_queue}")|g" \
    "${SERVICE_TEMPLATE}" > "${file_name}"
}

remove_stale_services() {
  find "${SERVICES_DIR}" -maxdepth 1 -type f -name 'cups-printer-*.service' -delete
}

wait_for_cups() {
  until lpstat -r >/dev/null 2>&1; do
    sleep 2
  done
}

sync_printers() {
  local printer_list
  local new_state

  printer_list="$(lpstat -e 2>/dev/null | sed '/^$/d' | sort || true)"
  new_state="${printer_list}"

  if [[ -f "${STATE_FILE}" ]] && [[ "$(cat "${STATE_FILE}")" == "${new_state}" ]]; then
    return
  fi

  remove_stale_services

  if [[ -n "${printer_list}" ]]; then
    while IFS= read -r queue; do
      [[ -z "${queue}" ]] && continue
      render_service_file "${queue}" "${queue} @ Home Assistant"
    done <<< "${printer_list}"
  fi

  printf '%s' "${new_state}" > "${STATE_FILE}"
}

wait_for_cups

while true; do
  sync_printers
  sleep 15
done
