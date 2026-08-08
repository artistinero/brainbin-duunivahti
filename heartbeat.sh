#!/bin/bash

UPTIME=$(uptime -p | sed 's/up //')
LEVY=$(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')
MUISTI=$(free -h | awk '/^Mem:/{print $3"/"$2}')
NTFY=$(docker inspect --format='{{.State.Status}}' ntfy-ntfy-1 2>/dev/null || echo "ei käynnissä")
DUUNIVAHTI=$(TZ=Europe/Helsinki date -d "$(systemctl --user show duunivahti.service --property=ExecMainStartTimestamp --value)" "+%Y-%m-%d %H:%M" 2>/dev/null)
CPU_LAMPO=$(sensors 2>/dev/null | awk '/CPU Temperature:/{print $3}')
MB_LAMPO=$(sensors 2>/dev/null | awk '/MB Temperature:/{print $3}')
BACKUP=$(cat ~/.last-backup-pcloud 2>/dev/null || echo "ei tiedossa")

VIESTI="Brainbin toimii ✓
Uptime: $UPTIME
Levy: $LEVY
Muisti: $MUISTI
CPU: $CPU_LAMPO  MB: $MB_LAMPO
ntfy: $NTFY
Duunivahti viimeksi: $DUUNIVAHTI
Backup pCloudiin: $BACKUP"

curl -s -d "$VIESTI" \
    -H "Title: Brainbin-heartbeat" \
    -H "Priority: min" \
    https://brainbin.tailf1fe0b.ts.net/duunivahti
