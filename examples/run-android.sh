#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/demo"

serials=()
names=()

while IFS= read -r serial; do
  name=$(adb -s "$serial" emu avd name 2>/dev/null | head -1 | tr -d '\r')
  [ -z "$name" ] && name="$serial"
  serials+=("$serial")
  names+=("$name")
done < <(adb devices | awk '/emulator-.*device$/ {print $1}')

if [ ${#serials[@]} -eq 0 ]; then
  echo "No running Android emulators found."
  exit 1
fi

if [ ${#serials[@]} -eq 1 ]; then
  echo "Using ${names[0]} (${serials[0]})"
  flutter run -d "${serials[0]}"
  exit 0
fi

echo "Running Android emulators:"
for i in "${!serials[@]}"; do
  echo "  [$((i + 1))] ${names[$i]} (${serials[$i]})"
done

printf "Choose [1-%d]: " "${#serials[@]}"
read -r choice

if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#serials[@]} ]; then
  echo "Invalid choice."
  exit 1
fi

idx=$((choice - 1))
echo "Using ${names[$idx]} (${serials[$idx]})"
flutter run -d "${serials[$idx]}"
