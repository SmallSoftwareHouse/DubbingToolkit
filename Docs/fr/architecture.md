# Architecture et référence technique

Ce document décrit la structure interne du projet, les modules principaux, les conventions de développement et l'état des composants. Il est destiné principalement à ceux qui contribuent au développement ou souhaitent comprendre le fonctionnement interne du système.

---

## Structure des dossiers

```
DubbingToolkit/
├── Billing/                Suivi de la consommation et des coûts TTS
├── core/                   Modules de support Python partagés
├── credentials/            Identifiants API (exclus de Git)
├── Installation/           Runtimes Python locaux (3.10, 3.11)
├── installer/              Système de build et de packaging
├── locale/                 Localisation et gestion des langues
│   ├── Active/             Fichiers JSON de langue actifs (it, en, es, de, fr, pt, ru, zh)
│   └── System/             Métadonnées des langues (Whisper, langues supportées)
├── Logs/                   Journaux opérationnels
├── ps/                     Modules PowerShell (journalisation, messagerie)
├── Repository/             Ressources partagées et modèles locaux
├── Scripts/                Scripts opérationnels et modules Python
│   └── maintenance/        Scripts de maintenance et pipeline de localisation
├── Settings/               Configuration active et de référence
├── Temp/                   Fichiers temporaires
├── Tools/                  Binaires externes (ffmpeg)
├── venv/                   Environnement virtuel Python principal
├── voices/                 Voix TTS disponibles et échantillons audio
└── Workspace/              Données des projets (créé automatiquement)
    └── projects/
        └── {nom_projet}/
            ├── project_info.json                    Métadonnées du projet
            ├── audio_extraction/
            │   ├── current/                         Pistes audio actuelles
            │   └── archive/                         Historique des extractions
            ├── transcripts/
            │   ├── current/                         Transcriptions SRT actuelles
            │   └── archive/                         Historique des transcriptions
            ├── translated/
            │   ├── current/                         Traductions SRT actuelles
            │   └── archive/                         Historique des traductions
            ├── dubbed/
            │   ├── current/                         Audio TTS actuel
            │   └── archive/                         Historique audio TTS
            ├── video_input/                         Vidéo source (jamais modifiée)
            └── audio_input/                         Audio d'entrée direct (optionnel)
```

---

## Chaîne de démarrage

```
StartDubbing.bat
  └→ Scripts/Launcher.ps1
       Active le venv, configuration UTF-8, journaux, chargement de la langue
         └→ Scripts/Regista.py
              Menu principal et orchestration du pipeline
```

Le Launcher gère : la sélection du runtime Python local (`Installation/`), la création/activation du venv, la configuration du système de journaux, le chargement de la langue de l'interface.

`Regista.py` est le coordinateur central : il présente le menu à l'utilisateur et délègue l'exécution aux modules spécifiques pour chaque phase.

---

## Pipeline opérationnel

| Phase | Module | Entrée → Sortie |
|---|---|---|
| 1 — Extraction audio | `Scripts/estrai_tracce.py` | `video_input/` → `audio_extraction/current/` |
| 2 — Transcription | `Scripts/trascrivi_audio.py` | `audio_extraction/current/` ou `audio_input/` → `transcripts/current/` (SRT) |
| 3 — Traduction | `Scripts/traduci_testo.py` | `transcripts/current/` → `translated/current/` (SRT) |
| 4 — TTS | `Scripts/tts_menu.py` | `translated/current/` → `dubbed/current/` (MP3/WAV) |

Tous les chemins sont relatifs à `Workspace/projects/{nom_projet}/`. `tts_menu.py` délègue à `tts_azure.py` ou `tts_google.py` selon le fournisseur actif.

---

## Modules core (`core/`)

| Module | Fonction |
|---|---|
| `messages.py` | Messagerie localisée centralisée — lit `locale/Active/<lang>.json` |
| `credentials_manager.py` | Chargement et validation des identifiants API |
| `api_check.py` | Vérification des identifiants avant l'accès au menu TTS |
| `logger.py` | Logger de session structuré (INFO/WARN/ERROR) en JSON |
| `error_reporter.py` | Système de rapport d'erreurs : ZIP des logs, mailto: développeur |
| `update_checker.py` | Vérification des mises à jour sur GitHub Releases |
| `ui_printer.py` + `ui_colors.py` | Formatage et couleurs de la console |
| `utils_tts.py` | Utilitaires partagés pour le parsing SRT |
| `workspace_manager.py` | Gestion du workspace actif, structure des stages, rotation des archives |
| `source_importer.py` | Dialogue d'importation des fichiers externes dans le workspace |

---

## Localisation

```
locale/
├── Active/              Fichiers de langue actifs (runtime)
│   ├── it.json, en.json, es.json, de.json, fr.json, pt.json, ru.json, zh.json
└── System/
    ├── languages.json           Langues conceptuellement supportées
    └── whisper_languages.json   Langues supportées par Whisper
```

- Tous les messages de l'interface Python utilisent `core/messages.py`.
- Tous les fichiers dans `locale/Active/` doivent être synchronisés — une clé présente dans `it.json` doit exister dans tous les autres fichiers de langue.
- Les clés manquantes produisent `[MISSING: key]` au runtime.
- PowerShell utilise `ps/Messages.psm1`.

---

## Configuration (`Settings/settings.json`)

```json
{
  "interface_lang": "fr",
  "model": "small",
  "Transcript_Audio_Spoken_Lang": "it",
  "Translation_Target_Lang": "en",
  "Dubbing_Lang": "en"
}
```

---

## État des composants

| Composant | État |
|---|---|
| Extraction audio | ✅ Opérationnel |
| Transcription Whisper | ✅ Opérationnel |
| Traduction Helsinki-NLP | ✅ Opérationnel |
| TTS Azure | ✅ Opérationnel |
| TTS Google | ✅ Opérationnel |
| Interface multilingue (8 langues) | ✅ Opérationnel |
| Surveillance consommation TTS | ✅ Opérationnel |
| Système de build/packaging | ✅ Opérationnel |
| Sous-titres (option menu 5) | ⚠️ Stub — non implémenté |
| Segmentation avancée | ⚠️ Placeholder — hors pipeline |
| WhisperX | ⚠️ Venv préparé, non intégré |
| TTS OpenAI / ElevenLabs | ⚠️ Fichiers de configuration présents, non connectés |
| Traduction pivot (langue intermédiaire) | 🔲 Planifié |
| Post-traitement texte | 🔲 Planifié |
| Modèle basé sur les projets (Workspace) | ✅ Opérationnel |
