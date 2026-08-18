#!/bin/bash

UPTIME=$(uptime -p | sed 's/up //')
LEVY=$(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')
MUISTI=$(free -h | awk '/^Mem:/{print $3"/"$2}')
NTFY=$(docker inspect --format='{{.State.Status}}' ntfy-ntfy-1 2>/dev/null || echo "ei käynnissä")
DUUNIVAHTI=$(TZ=Europe/Helsinki date -d "$(systemctl --user show duunivahti.service --property=ExecMainStartTimestamp --value)" "+%Y-%m-%d %H:%M" 2>/dev/null)
CPU_LAMPO=$(sensors 2>/dev/null | awk '/CPU Temperature:/{print $3}')
MB_LAMPO=$(sensors 2>/dev/null | awk '/MB Temperature:/{print $3}')
BACKUP=$(cat ~/.last-backup-pcloud 2>/dev/null || echo "ei tiedossa")

PRIORITEETTI="min"

KIRJAUTUMINEN_RAAKA=$(timeout 30 ~/.local/bin/claude --print "vastaa vain sanalla OK" 2>&1)
if echo "$KIRJAUTUMINEN_RAAKA" | grep -qiE "Failed to authenticate|Login expired|OAuth session expired|OAuth error"; then
    KIRJAUTUMINEN="✗ VANHENTUNUT — aja: ssh keitsi@brainbin, sitten \"claude\" ja \"/login\" (järjestelmä lähettää itse kootun katsauksen ~20 min sisällä kun korjaantuu)"
    PRIORITEETTI="high"
else
    KIRJAUTUMINEN_IKA_PV=$(( ( $(date +%s) - $(stat -c %Y ~/.claude/.credentials.json 2>/dev/null || echo $(date +%s)) ) / 86400 ))
    if [ "$KIRJAUTUMINEN_IKA_PV" -ge 8 ]; then
        KIRJAUTUMINEN="✓ toimii, mutta $KIRJAUTUMINEN_IKA_PV pv vanha — uusi ennakkoon: ssh keitsi@brainbin, sitten \"claude\" ja \"/login\""
        PRIORITEETTI="high"
    else
        KIRJAUTUMINEN="✓ toimii ($KIRJAUTUMINEN_IKA_PV pv vanha)"
    fi
fi

VIESTI="Brainbin toimii ✓
Uptime: $UPTIME
Levy: $LEVY
Muisti: $MUISTI
CPU: $CPU_LAMPO  MB: $MB_LAMPO
ntfy: $NTFY
Duunivahti viimeksi: $DUUNIVAHTI
Duunivahti-kirjautuminen: $KIRJAUTUMINEN
Backup pCloudiin: $BACKUP"

curl -s -d "$VIESTI" \
    -H "Title: Brainbin-heartbeat" \
    -H "Priority: $PRIORITEETTI" \
    https://brainbin.tailf1fe0b.ts.net/brainbin-heartbeat
