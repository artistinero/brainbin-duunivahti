#!/bin/bash

GMAIL_TOOLS="mcp__claude_ai_Gmail__search_threads,mcp__claude_ai_Gmail__get_thread,mcp__claude_ai_Gmail__get_message"
LAST_OK_FILE=~/.last-duunivahti-ok
BROKEN_MARKER=~/.duunivahti-auth-broken
NYT=$(date +%s)

# Kuinka monta tuntia taaksepäin katsotaan: normaalisti 24h, mutta jos edellisestä
# onnistuneesta tarkistuksesta on kulunut kauemmin (esim. kirjautuminen oli poikki),
# katsotaan koko poikkeaman ajalta ettei mikään ilmoitus jää väliin. Katto 30 vrk.
TUNTIA=24
if [ -f "$LAST_OK_FILE" ]; then
    VIIME_OK=$(cat "$LAST_OK_FILE")
    ERO_H=$(( (NYT - VIIME_OK) / 3600 + 1 ))
    if [ "$ERO_H" -gt 24 ]; then TUNTIA=$ERO_H; fi
    if [ "$TUNTIA" -gt 720 ]; then TUNTIA=720; fi
fi

TULOS=$(echo "Tsekkaa Gmail-tililtä petrikeitsi@gmail.com uudet viestit viimeisen $TUNTIA tunnin ajalta. Karsi pois vahvistuspyynnöt, markkinointiviestit ja jo aiemmin näytetyt duplikaatit.

Karsi myös pois seuraavat, koska eivät sovi hakijan profiiliin:
- Tehtävät jotka vaativat laillistettua erikoispätevyyttä jota hakijalla ei ole: ylilääkäri, erikoislääkäri, asianajaja, psykologi tms.
- Ylimmän tason johtoryhmä-/toimitusjohtajapaikat isoissa organisaatioissa
- Taiteelliset esiintymis-/ammattimuusikkopestit jotka vaativat muodollista konservatorio- tai musiikkikorkeakoulutason koulutusta (esim. orkesterimuusikko, kapellimestari) — HUOM: graafinen suunnittelu, kuvataide ja kirjoittaminen EIVÄT kuulu tähän poissulkuun, ne sopivat hakijalle hyvin
- Puhelinmyynti / telemarkkinointi (kylmäsoitot)

Kaikki muu kelpaa, myös fyysinen työ, palvelutyö, kuljetus, muu myyntityö (ei kylmäsoittoa), esimiestehtävät, hoiva-ala, IT-ala. Jos olet epävarma sopiiko jokin ilmoitus profiiliin, sisällytä se mieluummin kuin karsit pois virheellisesti.

Listaa jäljelle jäävät oikeat työpaikkailmoitukset lyhyesti: työnantaja, nimike, paikkakunta, linkki. Jos ei ole mitään relevanttia, vastaa vain sanalla EI_UUTTA." | ~/.local/bin/claude --print --allowedTools "$GMAIL_TOOLS" 2>&1)

if echo "$TULOS" | grep -qiE "Failed to authenticate|Login expired|OAuth session expired|OAuth error"; then
    touch "$BROKEN_MARKER"
    curl -s -d "Duunivahti ei pystynyt tarkistamaan Gmailia, koska Claude Coden kirjautuminen brainbinillä on vanhentunut.

Korjaa näin:
1. ssh keitsi@brainbin
2. aja: claude
3. seuraa kirjautumisohjeita (selaimen kautta, browserin näyttämä koodi liitetään terminaaliin)

Kun kirjautuminen on kunnossa, järjestelmä huomaa sen itse ~20 min sisällä ja lähettää heti kootun tilannekatsauksen koko poikkeaman ajalta — ei tarvitse ajaa mitään käsin.

Tekninen virhe: $TULOS" \
        -H "Title: Duunivahti EI TOIMI - kirjaudu uudelleen" \
        -H "Priority: urgent" \
        https://brainbin.tailf1fe0b.ts.net/duunivahti
else
    rm -f "$BROKEN_MARKER"
    echo "$NYT" > "$LAST_OK_FILE"
    if [ "$TULOS" != "EI_UUTTA" ]; then
        curl -s -d "$TULOS" \
            -H "Title: Duunivahti" \
            -H "Priority: default" \
            https://brainbin.tailf1fe0b.ts.net/duunivahti
    fi
fi
