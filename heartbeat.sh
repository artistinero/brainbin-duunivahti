#!/bin/bash

UPTIME=$(uptime -p | sed 's/up //')
LEVY=$(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')
MUISTI=$(free -h | awk '/^Mem:/{print $3"/"$2}')
NTFY=$(docker inspect --format='{{.State.Status}}' ntfy-ntfy-1 2>/dev/null || echo "ei käynnissä")
DUUNIVAHTI=$(systemctl --user show duunivahti.service --property=ExecMainStartTimestamp --value 2>/dev/null | sed 's/ [A-Z]*$//')

VIESTI="Brainbin toimii ✓
Uptime: $UPTIME
Levy: $LEVY
Muisti: $MUISTI
ntfy: $NTFY
Duunivahti viimeksi: $DUUNIVAHTI"

curl -s -d "$VIESTI" \
    -H "Title: Brainbin-heartbeat" \
    -H "Priority: min" \
    https://brainbin.tailf1fe0b.ts.net/duunivahti
