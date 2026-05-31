# Guide d'utilisation

Ce guide décrit le flux opérationnel de DubbingToolkit, de la préparation des fichiers d'entrée à l'audio doublé final.

---

## Démarrage du projet

Double-cliquez sur `StartDubbing.bat`. Le projet se lance et présente le menu de gestion des projets.

---

## Création et sélection d'un projet

Depuis l'écran principal, sélectionnez "Gestion des projets" (option 0) et créez un nouveau projet. Chaque projet est un espace de travail isolé pour une vidéo spécifique.

Une fois créé, le projet est défini comme actif et reste disponible pour les opérations ultérieures.

---

## Flux opérationnel

Le processus comprend 4 étapes. Chaque étape peut être exécutée individuellement ou dans le cadre du flux complet.

| Étape | Opération | Dossier de sortie |
|---|---|---|
| 1 | Extraction audio | `Workspace/projects/{nom}/audio_extraction/current/` |
| 2 | Transcription | `Workspace/projects/{nom}/transcripts/current/` |
| 3 | Traduction | `Workspace/projects/{nom}/translated/current/` |
| 4 | Synthèse TTS | `Workspace/projects/{nom}/dubbed/current/` |

> **Important :** une révision manuelle est recommandée après la transcription et après la traduction. Les corrections permettent d'améliorer la qualité de l'audio final et de gérer les éventuelles incohérences avec le rythme du discours original.

---

## Préparation des fichiers d'entrée

### Entrée vidéo

Lors de l'extraction audio, le système présente un dialogue d'importation qui permet de :
1. Utiliser la vidéo depuis un emplacement externe (maintient le chemin original)
2. Copier la vidéo dans le projet (`Workspace/projects/{nom}/video_input/`)
3. Déplacer la vidéo dans le projet

Formats supportés : ceux traités par ffmpeg (mp4, mkv, avi, mov, etc.).

### Audio direct

Si vous avez déjà de l'audio extrait, lors de la transcription vous pouvez sélectionner manuellement un fichier audio depuis le dossier `Workspace/projects/{nom}/audio_input/` ou depuis un emplacement externe. Dans ce cas, l'Étape 1 peut être omise.

---

## Étape 1 — Extraction audio

Le système extrait les pistes audio de la vidéo via ffmpeg. Tous les fichiers audio extraits sont enregistrés dans `Workspace/projects/{nom}/audio_extraction/current/` avec les noms `track_01.wav`, `track_02.wav`, etc.

Pour chaque piste, un fichier de métadonnées est généré automatiquement (`track_XX_metadata.json`) contenant des informations sur le codec, la fréquence d'échantillonnage, la durée et autres propriétés.

---

## Étape 2 — Transcription

L'audio est transcrit au format SRT. La langue parlée est détectée automatiquement et peut être modifiée depuis le menu avant de démarrer la transcription. Le résultat est enregistré dans `Workspace/projects/{nom}/transcripts/current/`.

> **Conseil :** avant de procéder à la traduction, examinez et corrigez le texte transcrit. Les erreurs à ce stade se propagent à toutes les étapes ultérieures.

---

## Étape 3 — Traduction

Le fichier SRT transcrit est traduit dans la langue cible. La traduction se fait entièrement en local. Les modèles nécessaires sont téléchargés automatiquement à la première exécution pour chaque paire de langues. Le résultat est enregistré dans `Workspace/projects/{nom}/translated/current/`.

Si la paire de langues directe n'est pas disponible, la traduction pivot via l'anglais comme langue intermédiaire est prévue pour l'avenir.

> **Conseil :** examinez le texte traduit avant de démarrer la synthèse. Les corrections manuelles permettent de gérer les désaccords de synchronisation.

---

## Étape 4 — Synthèse vocale (TTS)

Le texte traduit est synthétisé segment par segment via le fournisseur TTS sélectionné. Les segments sont ensuite fusionnés dans le fichier audio final, enregistré dans `Workspace/projects/{nom}/dubbed/current/`.

### Fournisseurs TTS

Le système supporte actuellement deux fournisseurs :

- **Azure Cognitive Services Speech** — service TTS cloud de Microsoft
- **Google Cloud Text-to-Speech** — service TTS cloud de Google

Le fournisseur et la voix sont sélectionnés directement depuis le menu TTS. Le système inclut une fonction dédiée pour écouter des échantillons de voix disponibles avant de démarrer la synthèse.

### Surveillance des coûts

Lorsque le module TTS démarre, une estimation de l'utilisation est automatiquement affichée. Pour vérifier la consommation réelle, consultez directement le panneau de contrôle de votre fournisseur.

---

## Langue de l'interface

La langue de l'interface est sélectionnée au démarrage et peut être modifiée à tout moment depuis le menu des paramètres sans redémarrer le projet.

---

## Gestion des projets

### Duplication

Vous pouvez dupliquer un projet existant pour créer une copie avec un nouveau nom. Utile pour tester des variantes de la même source.

### Renommer

Un projet peut être renommé à tout moment depuis la gestion des projets. Si le projet est actif, le pointeur actif est mis à jour automatiquement.

### Suppression

Un projet peut être supprimé. Si le paramètre `use_trash` est activé, le projet est déplacé à la Corbeille ; sinon il est supprimé définitivement.

### Ouvrir le dossier

Vous pouvez ouvrir le dossier d'un projet directement dans l'Explorateur pour inspecter manuellement les fichiers générés.

---

## Conseils opérationnels

- Utilisez des noms de projet et de fichier courts sans espaces ni caractères spéciaux pour éviter les problèmes de chemins.
- Les fichiers dans `Workspace/projects/{nom}/video_input/` ne sont jamais modifiés par le système.
- Chaque étape génère des métadonnées (fichiers `.json`) : utiles pour suivre la progression ou diagnostiquer les problèmes.
- Si le processus est interrompu, vous pouvez reprendre à partir de l'étape suivante en utilisant les fichiers dans les dossiers de sortie intermédiaires.
- Les fichiers traités à chaque étape sont automatiquement archivés dans le dossier `archive/` de cette étape pour préserver l'historique.

---

## Signalement d'erreurs

En cas de problème, vous pouvez envoyer un rapport d'erreurs au développeur directement depuis l'application.

### Rapport manuel

Depuis le menu principal, appuyez sur **R** à tout moment pour lancer la procédure de signalement.

### Invite automatique à la fermeture

Si des erreurs se sont produites pendant la session, l'application demandera à la fermeture :

> *« Cette session contient des erreurs. Envoyer un rapport au développeur ? (o/n) : »*

### Fonctionnement

1. Un fichier ZIP est créé dans `Logs/reports/` contenant les journaux des sessions récentes
2. Le dossier `Logs/reports/` s'ouvre dans l'Explorateur avec le fichier mis en évidence
3. Le client de messagerie par défaut s'ouvre avec l'objet et le corps pré-remplis
4. Joindre le fichier ZIP à l'e-mail avant de l'envoyer

Le rapport contient des informations système (OS, version de l'app, CPU, RAM) et les détails des erreurs avec les traces. Aucune donnée personnelle ni fichier de projet n'est inclus.
