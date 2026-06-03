#!/usr/bin/env bash
#
# Send a non-OneSignal push directly through the FCM HTTP v1 API, to exercise
# the FlutterFire path in examples/demo_fm (onMessage / onBackgroundMessage /
# onMessageOpenedApp / getInitialMessage). See examples/demo_fm/README.md.
#
# Usage:
#   FCM_TOKEN=<device-token> ./send_fcm.sh notif      # notification message
#   FCM_TOKEN=<device-token> ./send_fcm.sh data       # data-only message
#   FCM_TOKEN=<device-token> ./send_fcm.sh both       # notification + data
#   ./send_fcm.sh notif <device-token>                # token as 2nd arg
#
# Modes: notif (alert), data (silent/background; unreliable on iOS), both
# (alert + data payload; use to test the data path on iOS).
#
# Auth (first that works wins):
#   1. $ACCESS_TOKEN if already exported
#   2. service-account.json next to this script -> minted via oauth2l/gcloud
#   3. gcloud auth print-access-token
#
# Project id is read from android/app/google-services.json.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
gs="$here/../android/app/google-services.json"

mode="${1:-notif}"
token="${2:-${FCM_TOKEN:-}}"

if [[ -z "$token" ]]; then
  echo "ERROR: no device token. Pass as 2nd arg or set FCM_TOKEN." >&2
  echo "Grab it from logs: adb logcat | rg '\\[FCM token\\]'" >&2
  exit 1
fi

if [[ ! -f "$gs" ]]; then
  echo "ERROR: $gs not found (drop your google-services.json there)." >&2
  exit 1
fi

project_id="$(grep -o '"project_id": *"[^"]*"' "$gs" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"
if [[ -z "$project_id" ]]; then
  echo "ERROR: could not read project_id from $gs" >&2
  exit 1
fi

# Mint an OAuth access token straight from the service account (scope:
# firebase.messaging) using only openssl + python3. This authenticates as the
# project's service account regardless of any ambient gcloud/ADC credentials,
# which is what FCM HTTP v1 requires (a personal/ADC token gets rejected with
# THIRD_PARTY_AUTH_ERROR).
mint_sa_token() {
  local sa="$1" email aud now exp hdr claim body sig jwt
  email="$(python3 -c "import json;print(json.load(open('$sa'))['client_email'])")"
  aud="$(python3 -c "import json;print(json.load(open('$sa')).get('token_uri','https://oauth2.googleapis.com/token'))")"
  now="$(date +%s)"
  exp="$((now + 3600))"
  b64url() { openssl base64 -e -A | tr '+/' '-_' | tr -d '='; }
  hdr="$(printf '{"alg":"RS256","typ":"JWT"}' | b64url)"
  claim="$(printf '{"iss":"%s","scope":"https://www.googleapis.com/auth/firebase.messaging","aud":"%s","iat":%s,"exp":%s}' "$email" "$aud" "$now" "$exp" | b64url)"
  body="$hdr.$claim"
  sig="$(printf '%s' "$body" | openssl dgst -sha256 -sign <(python3 -c "import json;print(json.load(open('$sa'))['private_key'])") | b64url)"
  jwt="$body.$sig"
  curl -sS -X POST "$aud" \
    -d grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer \
    --data-urlencode "assertion=$jwt" \
    | python3 -c "import sys,json;print(json.load(sys.stdin).get('access_token',''))"
}

# Resolve an OAuth access token (first that works wins):
#   1. $ACCESS_TOKEN if exported
#   2. service-account.json next to this script (preferred)
#   3. gcloud's active credentials
access_token="${ACCESS_TOKEN:-}"
sa="$here/service-account.json"
if [[ -z "$access_token" && -f "$sa" ]]; then
  access_token="$(mint_sa_token "$sa" 2>/dev/null || true)"
fi
if [[ -z "$access_token" ]]; then
  access_token="$(gcloud auth print-access-token 2>/dev/null || true)"
fi
if [[ -z "$access_token" ]]; then
  echo "ERROR: no access token. Export ACCESS_TOKEN, drop a service-account.json" >&2
  echo "next to this script, or run 'gcloud auth login'." >&2
  exit 1
fi

case "$mode" in
  notif)
    # Visible notification on both platforms (iOS shows an alert via APNs).
    payload='{"message":{"token":"'"$token"'","notification":{"title":"FCM direct","body":"non-OneSignal push"},"apns":{"payload":{"aps":{"sound":"default"}}}}}'
    ;;
  data)
    # Data-only message. android.priority=high + apns content-available=1 so the
    # app is woken in the background/killed state on both platforms.
    # NOTE: on iOS this is a silent push and is throttled/unreliable, especially
    # on the simulator and in the foreground. Use 'both' to test data on iOS, or
    # test 'data' on Android where data-only delivery is reliable.
    payload='{"message":{"token":"'"$token"'","android":{"priority":"high"},"apns":{"headers":{"apns-priority":"5"},"payload":{"aps":{"content-available":1}}},"data":{"alert":"data only","source":"fcm-direct"}}}'
    ;;
  both)
    # Notification + data. Delivered as a normal alert (reliable on iOS) while
    # still carrying a data payload, so onMessage/onMessageOpenedApp fire with
    # data populated. Use this to exercise the data path on iOS.
    payload='{"message":{"token":"'"$token"'","notification":{"title":"FCM direct","body":"notification + data"},"android":{"priority":"high"},"apns":{"payload":{"aps":{"sound":"default"}}},"data":{"alert":"hello","source":"fcm-direct"}}}'
    ;;
  *)
    echo "ERROR: unknown mode '$mode' (use 'notif', 'data', or 'both')." >&2
    exit 1
    ;;
esac

echo "Sending '$mode' message via project $project_id ..." >&2
curl -sS -X POST \
  "https://fcm.googleapis.com/v1/projects/$project_id/messages:send" \
  -H "Authorization: Bearer $access_token" \
  -H "Content-Type: application/json" \
  -d "$payload"
echo
