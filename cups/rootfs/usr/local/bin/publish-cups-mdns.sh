#!/usr/bin/with-contenv bash
set -euo pipefail

SERVICES_DIR="/etc/avahi/services"
SERVICE_TEMPLATE="/etc/avahi/templates/cups-printer.service.template"
STATE_FILE="/tmp/cups_printers_mdns.state"
CUPS_CONFIG_DIR="/data/cups/config"
PRINTERS_CONF="/etc/cups/printers.conf"

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
  local rp="$3"
  local note="$4"
  local ty="$5"
  local pdl="$6"
  local urf="$7"
  local color="$8"
  local duplex="$9"
  local file_name
  local escaped_name
  local escaped_rp
  local escaped_note
  local escaped_ty
  local escaped_product
  local escaped_pdl
  local escaped_urf
  local escaped_color
  local escaped_duplex
  local product

  file_name="${SERVICES_DIR}/cups-printer-$(safe_slug "${queue}").service"
  escaped_name="$(xml_escape "${display_name}")"
  escaped_rp="$(xml_escape "${rp}")"
  escaped_note="$(xml_escape "${note}")"
  escaped_ty="$(xml_escape "${ty}")"
  product="(${ty})"
  escaped_product="$(xml_escape "${product}")"
  escaped_pdl="$(xml_escape "${pdl}")"
  escaped_urf="$(xml_escape "${urf}")"
  escaped_color="$(xml_escape "${color}")"
  escaped_duplex="$(xml_escape "${duplex}")"

  sed \
    -e "s|__DISPLAY_NAME__|$(sed_escape_replacement "${escaped_name}")|g" \
    -e "s|__RP__|$(sed_escape_replacement "${escaped_rp}")|g" \
    -e "s|__NOTE__|$(sed_escape_replacement "${escaped_note}")|g" \
    -e "s|__TY__|$(sed_escape_replacement "${escaped_ty}")|g" \
    -e "s|__PRODUCT__|$(sed_escape_replacement "${escaped_product}")|g" \
    -e "s|__PDL__|$(sed_escape_replacement "${escaped_pdl}")|g" \
    -e "s|__URF__|$(sed_escape_replacement "${escaped_urf}")|g" \
    -e "s|__COLOR__|$(sed_escape_replacement "${escaped_color}")|g" \
    -e "s|__DUPLEX__|$(sed_escape_replacement "${escaped_duplex}")|g" \
    "${SERVICE_TEMPLATE}" > "${file_name}"
}

get_shared_printers() {
  if [[ ! -f "${PRINTERS_CONF}" ]]; then
    return
  fi

  awk '
    function flush() {
      if (in_printer && shared == "Yes") {
        print name "|" info "|" model
      }
    }
    /^<Printer / || /^<DefaultPrinter / {
      flush()
      in_printer=1
      name=$2
      sub(/>$/, "", name)
      shared="No"
      info=""
      model=""
      next
    }
    in_printer && $1 == "Shared" {
      shared=$2
      next
    }
    in_printer && $1 == "Info" {
      sub(/^Info /, "")
      info=$0
      next
    }
    in_printer && $1 == "MakeModel" {
      sub(/^MakeModel /, "")
      model=$0
      next
    }
    /^<\/Printer>/ || /^<\/DefaultPrinter>/ {
      flush()
      in_printer=0
      next
    }
    END {
      flush()
    }
  ' "${PRINTERS_CONF}"
}

detect_color_duplex() {
  local queue="$1"
  local opts

  opts="$(lpoptions -p "${queue}" -l 2>/dev/null || true)"

  COLOR="F"
  DUPLEX="F"

  if echo "${opts}" | grep -Eiq '(Color(Model|Mode)|print-color-mode)'; then
    if echo "${opts}" | grep -Eiq '(CMYK|RGB|Color|AutoColor|color)'; then
      COLOR="T"
    fi
  fi

  if echo "${opts}" | grep -Eiq '(Duplex|sides|two-sided)'; then
    DUPLEX="T"
  fi
}

build_state() {
  while IFS='|' read -r queue info model; do
    [[ -z "${queue}" ]] && continue

    detect_color_duplex "${queue}"
    printf '%s|%s|%s|%s|%s\n' "${queue}" "${info}" "${model}" "${COLOR}" "${DUPLEX}"
  done < <(get_shared_printers)
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
  local printer_state
  local new_state
  local queue
  local info
  local model
  local color
  local duplex
  local display_name
  local rp
  local pdl
  local urf
  local note
  local ty

  printer_state="$(build_state | sort || true)"
  new_state="${printer_state}"

  if [[ -f "${STATE_FILE}" ]] && [[ "$(cat "${STATE_FILE}")" == "${new_state}" ]]; then
    return
  fi

  remove_stale_services

  if [[ -n "${printer_state}" ]]; then
    while IFS='|' read -r queue info model color duplex; do
      [[ -z "${queue}" ]] && continue

      display_name="${queue} @ Home Assistant"
      rp="printers/${queue}"
      pdl="application/pdf,image/urf,image/jpeg,image/png,application/postscript,application/octet-stream"
      urf="none"
      note="${info:-${queue}}"
      ty="${model:-CUPS Printer}"

      render_service_file "${queue}" "${display_name}" "${rp}" "${note}" "${ty}" "${pdl}" "${urf}" "${color}" "${duplex}"
    done <<< "${printer_state}"
  fi

  printf '%s' "${new_state}" > "${STATE_FILE}"
}

wait_for_changes() {
  if command -v inotifywait >/dev/null 2>&1; then
    inotifywait -qq -e close_write,create,delete,move "${CUPS_CONFIG_DIR}" || true
  else
    sleep 15
  fi
}

wait_for_cups

while true; do
  sync_printers
  wait_for_changes
done
