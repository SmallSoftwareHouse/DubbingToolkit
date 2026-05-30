# Installation et configuration

Ce guide couvre les prérequis système, la structure des identifiants et le processus de mise en route initiale de DubbingToolkit.

---

## Prérequis système

- **Système d'exploitation :** Windows avec PowerShell 5.1
- **Python :** inclus dans le projet — aucune installation système n'est requise
  - Python 3.11 est actuellement utilisé, présent dans le dossier `Installation/` et géré en interne.
- **ffmpeg :** inclus dans `Tools/ffmpeg-7.1.1-full_build/` — aucune installation séparée n'est nécessaire
- **Connexion internet :** requise pour les modules accédant à des ressources externes, notamment les API TTS (Azure, Google) et le téléchargement des modèles de traduction à la première exécution.

---

## Identifiants TTS

Les identifiants pour les fournisseurs TTS doivent être placés dans le dossier `credentials/`. Les fournisseurs actuellement supportés sont Azure et Google, chacun avec son propre fichier JSON.

| Fichier | Fournisseur |
|---|---|
| `azure_speech_credentials.json` | Azure Cognitive Services Speech |
| `google_speech_credentials.json` | Google Cloud TTS |

Pour chaque fournisseur, un fichier template avec la structure requise est disponible :

```
credentials/azure_speech_credentials.template.json
credentials/google_speech_credentials.template.json
```

Copier le fichier template, supprimer l'extension `.template` et renseigner ses propres identifiants dans le fichier résultant.

---

## Environnement virtuel et dépendances Python

Au démarrage du projet, le Launcher gère automatiquement la création et l'activation de l'environnement virtuel ainsi que l'installation des dépendances. Aucune intervention manuelle n'est requise dans des conditions normales.

Les dépendances principales sont listées dans `Config/dependencies.json`.

### Réinitialisation de l'environnement virtuel

**Réinitialisation depuis l'intérieur du projet** (le projet doit être démarrable) :

Sélectionner l'option de réinitialisation depuis l'interface ou exécuter directement :
```powershell
Scripts/reset_env.ps1
```
Ce script recrée le venv et réinstalle les dépendances automatiquement.

**Réinitialisation manuelle complète** (lorsque le projet ne démarre pas) :

Supprimer manuellement le dossier `venv/`. Au prochain démarrage via `StartDubbing.bat`, le Launcher détectera l'absence du venv et le recréera automatiquement.

---

## Configuration initiale

Les paramètres opérationnels du projet se trouvent dans `Settings/` :

| Fichier | Rôle |
|---|---|
| `settings.json` | Configuration active |
| `settings_default.json` | Configuration de référence (ne pas modifier) |
| `reset.json` | Paramètres de réinitialisation |

### Paramètres principaux dans `settings.json`

- **`interface_lang`** — langue de l'interface (ex. `"it"`, `"en"`, `"es"`)
- Paramètres du fournisseur TTS (fournisseur actif, voix sélectionnée, langue cible)
- Paramètres de transcription Whisper (modèle, langue)

> **Remarque :** les paramètres sont automatiquement sauvegardés entre les sessions via `Settings/settings_persistent.json`. La langue de l'interface sélectionnée lors de l'installation est appliquée au premier lancement sans aucune action supplémentaire.

---

## Démarrage et initialisation automatique

L'utilisateur lance le projet via :

```
StartDubbing.bat
```

Le Launcher exécute ensuite automatiquement, sans intervention de l'utilisateur :

1. Vérification et activation du runtime Python local
2. Création ou activation de l'environnement virtuel
3. Vérification des identifiants API
4. Démarrage de l'interface principale

En cas d'identifiants manquants ou invalides, le système le signale dans le menu avant d'autoriser l'accès aux fonctions TTS.
Les autres fonctions — extraction audio, transcription et traduction — ne dépendent pas des identifiants et restent accessibles.

---

## Déplacement du projet et désinstallation

### Désinstallation

Si le projet a été installé via le package de distribution, utiliser le panneau **Applications installées** de Windows ou le désinstalleur présent dans le dossier d'installation.

Le désinstalleur permet de choisir ce que vous souhaitez supprimer définitivement :
- Identifiants et clés API
- Données de facturation (utilisation TTS mensuelle)
- Journaux de session
- Fichiers de travail (projets, audio, vidéo, transcriptions)

Les données non sélectionnées sont préservées. L'environnement virtuel (`venv/`) est toujours supprimé automatiquement.

### Déplacement

Bien que déconseillé, le projet peut être déplacé vers un autre emplacement, mais après chaque déplacement il est nécessaire de recréer l'environnement virtuel. Procédure :

1. Supprimer le dossier `venv/`
2. Lancer `StartDubbing.bat` — le Launcher recréera le venv et réinstallera les dépendances
