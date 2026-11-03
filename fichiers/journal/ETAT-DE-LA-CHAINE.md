# Le Journal des Bonnes Nouvelles — émission

Format journal télévisé / radio : une présentatrice en studio (voix féminine)
et des reporters de terrain (voix masculines), avec bruits d’ambiance naturels
et un générique en ouverture et en clôture. Chaque édition dépasse 11 minutes.

## Organisation du dossier

| Dossier | Contenu |
|---|---|
| `CHAINE/` | Identité de l’émission : description de la chaîne, pochette, cahier des charges |
| `EDITION-1/` | Édition 1 (11 min 22 s) — `audio/`, `description/`, `script/` |
| `EDITION-2/` | Édition 2 (11 min 32 s) — `audio/`, `description/`, `script/` |
| `EDITION-3/` | Édition 3 (12 min 58 s) — ambiances La Sonothèque — `audio/`, `description/`, `script/` |
| `EDITION-4/` | Édition 4 (10 min 56 s) — Nobel chimie (Henri Kagan), aires protégées, Écotrain, SCALA — `audio/`, `description/`, `script/` |
| `PILOTE/` | Ancien épisode pilote (mono-voix, 9 min 22 s) + diapositives |
| `PRODUCTION/` | Outils : générateur d’épisodes, générique, sfx, fichiers techniques |
| `SONS-AMBIANCE.md` | Bibliothèque de sons La Sonothèque (liens, usage) |

## Éditions

| Édition | Durée | Statut |
|---|---|---|
| Édition 1 | 11 min 22 s | Produite |
| Édition 2 | 11 min 32 s | Produite |
| Édition 3 | 12 min 58 s | Produite — fonds sonores La Sonothèque |
| Édition 4 | 10 min 56 s | Produite — prête à publier (fonds La Sonothèque #0905 #0503 #2723 #0504 #0999) |

## Régénérer un épisode

```bash
cd PRODUCTION
python3 produire_journal.py ../EDITION-2/script/episode-2-script-jt.md ../EDITION-2/audio/JOURNAL-BONNES-NOUVELLES-EDITION-2.mp3
```

---

## 📡 État de la chaîne Spotify — à compléter

| | |
|---|---|
| **La chaîne existe** | ✅ (créée sur podcasters.spotify.com) |
| **Lien de la chaîne** | ⬜ *à copier ici :* `https://open.spotify.com/show/…` — **jamais noté jusqu'ici**, c'est ce qui a fait croire à tort que la chaîne n'existait pas |
| **Éditions publiées** | #1 (13/10/2026) · #2 (20/10/2026) · #3 (27/10/2026) |
| **Édition à publier** | #4 —Henri Kagan — instructions : `PUBLIER-EDITION-4.md` |
| **Prochaine** | #5 — à produire (segment « Les bons jeux de la semaine » déjà écrit : `13-JEUX-CONCOURS/SEGMENT-JOURNAL.md`) |

> ⚠️ **À l'avenir** : dès qu'un épisode est publié, noter son lien ici
> (`https://open.spotify.com/episode/…`) **et** le lien de la chaîne. Sans cela,
> on ne peut pas savoir ce qui est réellement en ligne.
