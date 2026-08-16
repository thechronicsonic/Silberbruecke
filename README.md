# Silberbrücke

**[▶ Im Browser spielen](https://thechronicsonic.github.io/Silberbruecke/)**

Ein Walking Simulator in WebGL2. Hollow Ridge, West Virginia, 26. November 1966 —
neunzehn Tage vor dem Einsturz der Silver Bridge. E. Marsh nimmt für eine Behörde
auf, was die Leute gesehen haben. Fünf Nächte, vierzig Aussagen.

Eine einzige HTML-Datei, keine Abhängigkeiten, kein Netzverkehr. Sie lässt sich
auch herunterladen und lokal öffnen — dann läuft sie ohne jede Einschränkung.

## Steuerung

| | |
|---|---|
| `W A S D` | Gehen. Langsam; es gibt keinen Grund zu rennen. |
| Maus | Umsehen. Der Punkt in der Bildmitte ist das Werkzeug. |
| `E` | Nachsehen, wenn etwas dasteht. Nichts kommt von selbst. |
| `Tab` | Lauschen. Die nächste Stimme antwortet aus ihrer Richtung. |
| `J` | Die Akte. Alles Gelesene bleibt nachlesbar. |
| `M` | Die Karte. Standort und was schon aufgenommen ist. |
| `F` | Taschenlampe. |
| `Q` | Auf die Uhr sehen. |
| `V` | Vollbild. |
| `Esc` | Anhalten. |

## Für Testerinnen und Tester

Worauf ich besonders Rückmeldung brauche:

1. **Fängt die Maus?** Nach dem Klick auf „Die Straße betreten" sollte sich die
   Kamera bewegen, ohne dass ein Zeiger übers Bild wandert. Falls nicht: Ziehen
   mit gedrückter Maustaste funktioniert als Rückfall — bitte melden, wenn nur
   das geht.
2. **Vollbild auf `V`?**
3. **Findet man die Aussagen?** Sie leuchten erst aus etwa dreißig Metern
   schwach auf. Wer nichts sieht: `Tab` drücken — das ist das Suchwerkzeug.
4. Ruckelt es? Unter „Angehalten" (`Esc`) lässt sich die Bildqualität senken.

Bekannte Grenze: In eingebetteten Ansichten (fremde Seiten, die das Spiel in
einen Rahmen setzen) sind Mauszeiger-Fang und Vollbild erlaubnispflichtig und
funktionieren dort meist nicht. Über die Adresse oben oder als lokale Datei
läuft beides.

## Was wo liegt

| Datei | |
|---|---|
| `silberbruecke.html` | Das Spiel. Alles darin. |
| `index.html` | Einstieg für die Web-Adresse; leitet auf das Spiel. |
| `werkzeuge/serve.ps1` | Lokaler Server auf Port 8731, liefert ohne Cache aus. |
| `werkzeuge/seam.ps1`, `step.ps1` | Prüfstände für die Biquad-Filter des Klangs. |

Die Story-Bibel (`docs/`) und die alten Stände (`archiv/`) bleiben bewusst
außerhalb des Repositorys — siehe `.gitignore`.

## Entwickeln

Doppelklick auf `silberbruecke.html` genügt. Wer zuverlässig den neuen Stand
sehen will — Browser cachen die Datei hartnäckig —, nimmt lieber:

```bash
powershell -ExecutionPolicy Bypass -File werkzeuge/serve.ps1
```

und öffnet `http://localhost:8731/`.

Das Spiel legt unter `window.__SB` einen Zugang für Messungen an: `terrainH`,
`roadX`, `boxes`, `ECHOES`/`DOCS`, `P`, `VERKEHR` sowie `gotoChapter(i, seiten)`.
`__SB.errors` sammelt Laufzeitfehler. Das ist der Weg, Dinge nachzumessen statt
sie zu schätzen — die meisten Fehler in diesem Projekt sind so gefunden worden
und nicht durch Hinsehen.
