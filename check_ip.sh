#!/usr/bin/env bash
# check_ip.sh — Query common IP-info endpoints and display results

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

TIMEOUT=5

declare -A ENDPOINTS=(
  ["ipify"]="https://api.ipify.org?format=json"
  ["ipinfo.io"]="https://ipinfo.io/json"
  ["ip-api.com"]="http://ip-api.com/json"
  ["ifconfig.me"]="https://ifconfig.me/all.json"
  ["ipwho.is"]="https://ipwho.is/"
  ["geoip.nekudo.com"]="https://geoip.nekudo.com/api"
  ["ip.seeip.org"]="https://ip.seeip.org/geoip"
  ["extreme-ip-lookup"]="https://extreme-ip-lookup.com/json/"
  ["ipgeolocation.io"]="https://api.ipgeolocation.io/ipgeo?apiKey=free"
  ["myip.com"]="https://api.myip.com"
)

# Plain-text fallbacks (no JSON, just returns the IP)
declare -A PLAIN_ENDPOINTS=(
  ["ipify (plain)"]="https://api.ipify.org"
  ["ifconfig.me (plain)"]="https://ifconfig.me"
  ["icanhazip.com"]="https://icanhazip.com"
  ["ident.me"]="https://ident.me"
  ["ipecho.net"]="https://ipecho.net/plain"
  ["checkip.amazonaws.com"]="https://checkip.amazonaws.com"
  ["bot.whatismyipaddress.com"]="https://bot.whatismyipaddress.com"
)

extract() {
  local json="$1"
  local ip country

  ip=$(echo "$json" | grep -oP '"(ip|query|YourFuckingIPAddress|ipAddress)"\s*:\s*"\K[^"]+' | head -1)
  country=$(echo "$json" | grep -oP '"(country|country_name|countryCode|country_code)"\s*:\s*"\K[^"]+' | head -1)

  echo "${ip:-unknown} | ${country:-N/A}"
}

echo ""
echo -e "${BOLD}${CYAN}══════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${CYAN}         IP & Country Endpoint Checker         ${RESET}"
echo -e "${BOLD}${CYAN}══════════════════════════════════════════════${RESET}"
echo ""

echo -e "${BOLD}${YELLOW}── JSON Endpoints ──────────────────────────────${RESET}"
printf "%-28s %-20s %-10s\n" "Service" "IP" "Country"
printf "%-28s %-20s %-10s\n" "-------" "--" "-------"

for name in "${!ENDPOINTS[@]}"; do
  url="${ENDPOINTS[$name]}"
  response=$(curl -sf --max-time "$TIMEOUT" "$url" 2>/dev/null)
  if [[ -z "$response" ]]; then
    printf "${RED}%-28s %-20s${RESET}\n" "$name" "FAILED / no response"
  else
    result=$(extract "$response")
    ip="${result%% |*}"
    country="${result##*| }"
    printf "${GREEN}%-28s${RESET} %-20s ${CYAN}%s${RESET}\n" "$name" "$ip" "$country"
  fi
done

echo ""
echo -e "${BOLD}${YELLOW}── Plain-text Endpoints ────────────────────────${RESET}"
printf "%-28s %-20s\n" "Service" "IP"
printf "%-28s %-20s\n" "-------" "--"

for name in "${!PLAIN_ENDPOINTS[@]}"; do
  url="${PLAIN_ENDPOINTS[$name]}"
  response=$(curl -sf --max-time "$TIMEOUT" "$url" 2>/dev/null | tr -d '[:space:]')
  if [[ -z "$response" ]]; then
    printf "${RED}%-28s %-20s${RESET}\n" "$name" "FAILED / no response"
  else
    printf "${GREEN}%-28s${RESET} %s\n" "$name" "$response"
  fi
done

echo ""
echo -e "${BOLD}${CYAN}══════════════════════════════════════════════${RESET}"
echo -e "Done. Timeout per request: ${TIMEOUT}s"
echo ""
