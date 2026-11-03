# KidsTube

Een kindvriendelijke YouTube-speler: kinderen zien **alleen de video's die een ouder heeft goedgekeurd**.
Geen zoekbalk, geen aanbevelingen, geen reacties en geen doorklikken naar YouTube.

![KidsTube](icon-192.png)

## Wat het doet

**Kinderscherm**
- Grote tegels met thumbnail, categorieën met emoji en kleur, favorieten ⭐
- Eigen bediening (afspelen/pauze, spoelen, geluid, volledig scherm); er kan niet in de YouTube-speler geklikt worden
- Kijktijdlimiet per dag met een vriendelijk "Klaar voor vandaag"-scherm
- Licht/donker thema, volledig Nederlands

**Ouderscherm (achter pincode, standaard `1234`)**
- Video's toevoegen via link, bewerken, volgorde aanpassen, meervoudig verwijderen
- Zoeken op YouTube (beperkte modus) en resultaten afvinken
- Hele playlist importeren of meerdere links tegelijk plakken
- Eigen categorieën, kijktijdinstellingen, pincode wijzigen, back-up maken

## Online gebruiken

De app draait als statische site, bijvoorbeeld op GitHub Pages. Open het webadres,
en op de telefoon: **Toevoegen aan beginscherm** voor een schermvullende app zonder adresbalk.
In het ouderscherm staat onder Instellingen ook een knop **📲 App installeren**
(zichtbaar zodra de browser dat ondersteunt, zoals Chrome op Android).

### Lijst delen tussen apparaten

`videos.json` in deze repo is de **gedeelde lijst en de bron van waarheid**. Standaard staat
elk apparaat op *Leidend*: na het openen van de app is de lijst exact gelijk aan `videos.json`
— ook verwijderde video's, gewijzigde titels en categorieën worden overgenomen.

1. Beheer je lijst in het ouderscherm.
2. Instellingen → **📤 videos.json maken** (landt in je map Downloads).
3. Dubbelklik op **`Lijst publiceren.cmd`**: dat zet het bestand in de repo, commit en pusht.
   (Handmatig mag ook: `videos.json` vervangen en committen.)

Na ongeveer een minuut staat de lijst online. Apparaten halen hem op bij het openen van de
app, zodra de app weer naar voren komt, of direct via **🔄 Nu ophalen** in het ouderscherm.
De app vraagt het bestand met een unieke URL op, zodat GitHub's cache van 10 minuten
je niet in de weg zit.

Video's die je op één apparaat toevoegt blijven daar staan (in het ouderscherm gemarkeerd als
*alleen hier*) totdat je ze via stap 2 en 3 in de repo zet. Favorieten, kijktijd en pincode
blijven altijd per apparaat.

In Instellingen kun je dit per apparaat aanpassen:

| Stand | Gedrag |
|---|---|
| **Leidend** (standaard) | `videos.json` bepaalt de lijst: toevoegen, wijzigen én verwijderen |
| Alleen aanvullen | Nieuwe video's komen erbij, er wordt nooit iets verwijderd |
| Negeren | Dit apparaat houdt zijn eigen lijst |

Het veld `rev` hoort bij elke wijziging omhoog te gaan; de exportknop zet daar automatisch
een tijdstempel in.

### Zoeken online

Zoeken gebruikt normaal het meegeleverde lokale servertje. Op een website is dat er niet,
dus vul eenmalig een **YouTube Data API v3-sleutel** in bij Instellingen
([console.cloud.google.com](https://console.cloud.google.com) → YouTube Data API v3 → Inloggegevens).
Beperk de sleutel tot je eigen webadres. Zonder sleutel werkt alles behalve zoeken.

## Thuis op Windows gebruiken

Dubbelklik op **`KidsTube starten.cmd`**. Dat start een klein lokaal servertje en opent
de app in een venster zonder adresbalk en tabbladen. Zoeken werkt dan zonder API-sleutel.

Dubbelklikken op `index.html` werkt niet goed: YouTube blokkeert afspelen zonder
referrer (Error 153). Gebruik dus altijd het startbestand.

## Bestanden

| Bestand | Waarvoor |
|---|---|
| `index.html` | De hele app (één bestand) |
| `videos.json` | Gedeelde lijst voor alle apparaten |
| `manifest.json`, `sw.js` | Installeerbaar als app, werkt offline |
| `KidsTube starten.cmd`, `kidstube-server.ps1` | Lokaal starten op Windows |
| `Lijst publiceren.cmd`, `kidstube-publiceren.ps1` | Lijst uit Downloads publiceren naar GitHub |
| `icon-*.png`, `kidstube.ico` | Iconen |

## Privacy

Er is geen account en geen backend. De lijst, kijktijd en instellingen staan in
`localStorage` van het apparaat zelf. Video's spelen via `youtube-nocookie.com`.

De pincode houdt kinderen uit het ouderscherm, maar is geen echte beveiliging:
iedereen kan de broncode van een statische site lezen.
