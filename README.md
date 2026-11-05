# KidsTube

Een kindvriendelijke YouTube-speler: kinderen zien **alleen de video's die een ouder heeft goedgekeurd**.
Geen zoekbalk, geen aanbevelingen, geen reacties en geen doorklikken naar YouTube.

![KidsTube](icon-192.png)

## Wat het doet

**Kinderscherm**
- Grote tegels met thumbnail, categorieën met emoji en kleur, favorieten ⭐
- Eigen bediening (afspelen/pauze, spoelen, ondertiteling, geluid, volledig scherm);
  er kan niet in de YouTube-speler geklikt worden
- Video's starten desgewenst in volledig scherm, ondertiteling standaard uit
- Kijktijdlimiet per dag met een vriendelijk "Klaar voor vandaag"-scherm
- Kinderslot: blokkeert de terug-knop en vraagt de pincode bij afsluiten
- Licht/donker thema, volledig Nederlands

> Een web-app kan niet verhinderen dat iemand naar een andere app gaat. Zet het toestel
> echt vast met **Schermvastzetten** (Android) of **Begeleide toegang** (iPhone/iPad).

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
elk apparaat op *Leidend*: de lijst is exact gelijk aan `videos.json` — ook verwijderde
video's, gewijzigde titels en categorieën worden overgenomen.

**Publiceren zonder token** (ook vanaf de telefoon): kies in Instellingen
**⬆️ Publiceren via GitHub**. KidsTube kopieert de lijst en opent de GitHub Actions-pagina.
Log in, klik **Run workflow**, plak de lijst in `videos_json` en start de workflow.
GitHub commit de nieuwe `videos.json` naar de standaardbranch; alle apparaten halen die
lijst vervolgens automatisch op. Dit gebruikt je bestaande GitHub-account en vraagt geen
token of extra hostingaccount. De publicatie vraagt wel een handmatige bevestiging op GitHub.

Er is ook een optionele directe publicatie met een fine-grained token (*Contents: Read and
write* op alleen deze repo). Dat token wordt in de browser bewaard; gebruik het alleen op
het ouderapparaat. De GitHub Actions-route hierboven is veiliger.

**Publiceren via een bestand**: Instellingen → **📤 videos.json maken** → dubbelklik
`Lijst publiceren.cmd`.

Apparaten halen de lijst op bij het openen van de app, bij terugkeren naar de app, elke
5 minuten, en direct via **🔄 Nu ophalen**. De app vraagt het bestand met een unieke URL op,
zodat GitHub's cache van 10 minuten niet in de weg zit.

Video's die je op één apparaat toevoegt blijven daar staan (gemarkeerd als *alleen hier*)
totdat je publiceert. Favorieten, kijktijd en pincode blijven altijd per apparaat.

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
| `.github/workflows/publish-videos.yml` | Publiceert de lijst via GitHub Actions, zonder token in KidsTube |
| `Lijst publiceren.cmd`, `kidstube-publiceren.ps1` | Lijst uit Downloads publiceren naar GitHub |
| `icon-*.png`, `kidstube.ico` | Iconen |

## Privacy

KidsTube heeft geen eigen backend. De lijst wordt alleen naar GitHub geschreven nadat een
ouder de GitHub Actions-workflow handmatig heeft gestart. De lijst, kijktijd en instellingen
staan verder in `localStorage` van het apparaat zelf. Video's spelen via `youtube-nocookie.com`.

De pincode houdt kinderen uit het ouderscherm, maar is geen echte beveiliging:
iedereen kan de broncode van een statische site lezen.
