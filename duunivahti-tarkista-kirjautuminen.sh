#!/bin/bash
# Ajetaan usein (systemd-timer). Ei tee mitään jos kirjautuminen on kunnossa.
# Jos merkki rikkinäisestä kirjautumisesta on olemassa ja kirjautuminen toimii taas,
# käynnistää heti täyden duunivahti-tarkistuksen (kattaa koko poikkeaman ajan).

MARKER=~/.duunivahti-auth-broken
[ -f "$MARKER" ] || exit 0

TESTI=$(timeout 30 ~/.local/bin/claude --print "vastaa vain sanalla OK" 2>&1)
if echo "$TESTI" | grep -qiE "Failed to authenticate|Login expired|OAuth session expired|OAuth error"; then
    exit 0
fi

~/skriptit/duunivahti.sh
