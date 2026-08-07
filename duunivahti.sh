#!/bin/bash

GMAIL_TOOLS="mcp__claude_ai_Gmail__search_threads,mcp__claude_ai_Gmail__get_thread,mcp__claude_ai_Gmail__get_message"

TULOS=$(echo "Tsekkaa Gmail-tililtä petrikeitsi@gmail.com uudet viestit viimeisen 24 tunnin ajalta. Karsi pois vahvistuspyynnöt, markkinointiviestit ja jo aiemmin näytetyt duplikaatit.

Karsi myös pois seuraavat, koska eivät sovi hakijan profiiliin:
- Tehtävät jotka vaativat laillistettua erikoispätevyyttä jota hakijalla ei ole: ylilääkäri, erikoislääkäri, asianajaja, psykologi tms.
- Ylimmän tason johtoryhmä-/toimitusjohtajapaikat isoissa organisaatioissa
- Taiteelliset esiintymis-/ammattimuusikkopestit jotka vaativat muodollista konservatorio- tai musiikkikorkeakoulutason koulutusta (esim. orkesterimuusikko, kapellimestari) — HUOM: graafinen suunnittelu, kuvataide ja kirjoittaminen EIVÄT kuulu tähän poissulkuun, ne sopivat hakijalle hyvin
- Puhelinmyynti / telemarkkinointi (kylmäsoitot)

Kaikki muu kelpaa, myös fyysinen työ, palvelutyö, kuljetus, muu myyntityö (ei kylmäsoittoa), esimiestehtävät, hoiva-ala, IT-ala. Jos olet epävarma sopiiko jokin ilmoitus profiiliin, sisällytä se mieluummin kuin karsit pois virheellisesti.

Listaa jäljelle jäävät oikeat työpaikkailmoitukset lyhyesti: työnantaja, nimike, paikkakunta, linkki. Jos ei ole mitään relevanttia, vastaa vain sanalla EI_UUTTA." | ~/.local/bin/claude --print --allowedTools "$GMAIL_TOOLS" 2>&1)

if [ "$TULOS" != "EI_UUTTA" ]; then
    curl -s -d "$TULOS" \
        -H "Title: Duunivahti" \
        -H "Priority: default" \
        https://brainbin.tailf1fe0b.ts.net/duunivahti
fi
