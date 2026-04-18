#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./blind_recon.sh <target> [--output <dir>] [--full-ports]

Options:
  --output, -o     Output directory (default: blind_recon_<target>_<timestamp>)
  --full-ports     Run an additional full TCP port scan (can take a long time)
  --help, -h       Show this help

Examples:
  ./blind_recon.sh example.com
  ./blind_recon.sh 192.168.1.10 --output results_local
  ./blind_recon.sh example.com --full-ports

Important:
  Only scan systems you own or have explicit permission to test.
EOF
}

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

run_and_capture() {
  local label="$1"
  local outfile="$2"
  shift 2

  log "Running: ${label}"
  if "$@" >"${outfile}" 2>&1; then
    log "Saved: ${outfile}"
  else
    log "Command failed (continuing): ${label}"
    log "Check output: ${outfile}"
  fi
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

sanitize_target() {
  echo "$1" | tr '/: ' '___'
}

TARGET=""
OUT_DIR=""
FULL_PORTS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -o|--output)
      if [[ $# -lt 2 ]]; then
        echo "Error: --output requires a value"
        exit 1
      fi
      OUT_DIR="$2"
      shift
      ;;
    --full-ports)
      FULL_PORTS=true
      ;;
    *)
      if [[ -z "${TARGET}" ]]; then
        TARGET="$1"
      else
        echo "Error: Unknown argument: $1"
        usage
        exit 1
      fi
      ;;
  esac
  shift
done

if [[ -z "${TARGET}" ]]; then
  usage
  exit 1
fi

if [[ -z "${OUT_DIR}" ]]; then
  SAFE_TARGET="$(sanitize_target "${TARGET}")"
  OUT_DIR="blind_recon_${SAFE_TARGET}_$(date '+%Y%m%d_%H%M%S')"
fi

mkdir -p "${OUT_DIR}"
log "Target: ${TARGET}"
log "Output directory: ${OUT_DIR}"

if have_cmd whois; then
  run_and_capture "WHOIS" "${OUT_DIR}/01_whois.txt" whois "${TARGET}"
else
  log "Skipping WHOIS (whois not installed)"
fi

if have_cmd dig; then
  run_and_capture "DNS ANY" "${OUT_DIR}/02_dig_any.txt" dig any "${TARGET}"
  run_and_capture "DNS NS" "${OUT_DIR}/03_dig_ns.txt" dig ns "${TARGET}"
  run_and_capture "DNS MX" "${OUT_DIR}/04_dig_mx.txt" dig mx "${TARGET}"
else
  log "Skipping dig lookups (dig not installed)"
fi

if have_cmd nslookup; then
  run_and_capture "NSLOOKUP" "${OUT_DIR}/05_nslookup.txt" nslookup "${TARGET}"
else
  log "Skipping nslookup (nslookup not installed)"
fi

if have_cmd host; then
  run_and_capture "HOST" "${OUT_DIR}/06_host.txt" host "${TARGET}"
else
  log "Skipping host (host not installed)"
fi

if have_cmd ping; then
  run_and_capture "PING (4 packets)" "${OUT_DIR}/07_ping.txt" ping -c 4 "${TARGET}"
else
  log "Skipping ping (ping not installed)"
fi

if have_cmd traceroute; then
  run_and_capture "Traceroute" "${OUT_DIR}/08_traceroute.txt" traceroute "${TARGET}"
else
  log "Skipping traceroute (traceroute not installed)"
fi

if have_cmd curl; then
  run_and_capture "HTTP headers" "${OUT_DIR}/09_http_headers.txt" curl -sS -I --max-time 10 "http://${TARGET}"
  run_and_capture "HTTPS headers" "${OUT_DIR}/10_https_headers.txt" curl -sS -I --max-time 10 "https://${TARGET}"
else
  log "Skipping HTTP header checks (curl not installed)"
fi

if have_cmd nmap; then
  run_and_capture "Nmap top 1000 TCP ports" "${OUT_DIR}/11_nmap_top1000.txt" nmap -sV -Pn --top-ports 1000 "${TARGET}"

  if [[ "${FULL_PORTS}" == true ]]; then
    run_and_capture "Nmap full TCP scan" "${OUT_DIR}/12_nmap_full_tcp.txt" nmap -sV -Pn -p- "${TARGET}"
  fi
else
  log "Skipping nmap scans (nmap not installed)"
fi

if have_cmd whatweb; then
  run_and_capture "WhatWeb HTTP" "${OUT_DIR}/13_whatweb_http.txt" whatweb "http://${TARGET}"
  run_and_capture "WhatWeb HTTPS" "${OUT_DIR}/14_whatweb_https.txt" whatweb "https://${TARGET}"
else
  log "Skipping WhatWeb (whatweb not installed)"
fi

log "Blind recon complete. Results saved in: ${OUT_DIR}"
