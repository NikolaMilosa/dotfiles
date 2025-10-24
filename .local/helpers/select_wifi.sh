#!/usr/bin/env bash
set -euo pipefail

# Check dependencies
for cmd in nmcli fzf; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is required but not installed."
    exit 1
  fi
done

echo "🔍 Scanning for available networks..."
nmcli device wifi rescan &>/dev/null

# List networks and select one with fzf
network=$(nmcli --terse --fields SSID,SIGNAL,SECURITY device wifi list | \
  awk -F: '!seen[$1]++ {printf "%-30s | %3s%% | %s\n", $1, $2, $3}' | \
  fzf --prompt="Select Wi-Fi network: " --height=20 --border)

[[ -z "$network" ]] && echo "Cancelled." && exit 0
ssid=$(echo "$network" | awk -F'|' '{print $1}' | xargs)

echo "Selected network: '$ssid'"
echo

# Ask for connection type
echo "Connection type:"
echo "1) Username + password"
echo "2) Email + password (corporate/EAP)"
echo "3) Just password (standard Wi-Fi)"
read -rp "Choose [1-3]: " conn_type

username=""
email=""
password=""

case "$conn_type" in
  1)
    read -rp "Username: " username
    read -srp "Password: " password
    echo
    ;;
  2)
    read -rp "Email: " email
    read -srp "Password: " password
    echo
    ;;
  3)
    read -srp "Password: " password
    echo
    ;;
  *)
    echo "Invalid selection."
    exit 1
    ;;
esac

# Ask if user wants to remember password for all users
echo
read -rp "Remember password for all users? (y/N): " remember_all
remember_all=${remember_all,,}  # to lowercase

echo "🔗 Connecting to '$ssid'..."

if [[ "$conn_type" == "3" ]]; then
  # Standard WPA2/WPA3
  if [[ "$remember_all" == "y" ]]; then
    echo "$password" | sudo nmcli device wifi connect "$ssid" password "$password" \
      ifname "$(nmcli -t -f DEVICE,TYPE device | awk -F: '$2=="wifi"{print $1; exit}')" \
      --ask
    sudo nmcli connection modify "$ssid" connection.permissions ""
  else
    nmcli device wifi connect "$ssid" password "$password"
  fi
else
  # Enterprise/EAP networks
  identity="${username:-$email}"
  if [[ "$remember_all" == "y" ]]; then
    sudo nmcli connection add \
      type wifi ifname "$(nmcli -t -f DEVICE,TYPE device | awk -F: '$2=="wifi"{print $1; exit}')" \
      con-name "$ssid" ssid "$ssid" \
      wifi-sec.key-mgmt wpa-eap \
      802-1x.identity "$identity" 802-1x.password "$password"
    sudo nmcli connection modify "$ssid" connection.permissions ""
  else
    nmcli device wifi connect "$ssid" --ask
  fi
fi

echo "✅ Connected successfully to $ssid!"

