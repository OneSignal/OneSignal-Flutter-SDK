#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/demo"

ids=()
names=()

while IFS='|' read -r id name; do
  ids+=("$id")
  names+=("$name")
done < <(xcrun simctl list devices booted -j \
  | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devs in data.get('devices', {}).items():
    for d in devs:
        if d.get('state') == 'Booted':
            print(d['udid'] + '|' + d['name'])
")

if [ ${#ids[@]} -eq 0 ]; then
  echo "No booted iOS simulators found."
  exit 1
fi

if [ ${#ids[@]} -eq 1 ]; then
  echo "Using ${names[0]} (${ids[0]})"
  flutter run -d "${ids[0]}"
  exit 0
fi

echo "Booted iOS simulators:"
for i in "${!ids[@]}"; do
  echo "  [$((i + 1))] ${names[$i]} (${ids[$i]})"
done

printf "Choose [1-%d]: " "${#ids[@]}"
read -r choice

if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#ids[@]} ]; then
  echo "Invalid choice."
  exit 1
fi

idx=$((choice - 1))
echo "Using ${names[$idx]} (${ids[$idx]})"
flutter run -d "${ids[$idx]}"
