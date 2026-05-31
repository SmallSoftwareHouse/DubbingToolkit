# Architektur und technische Referenz

Dieses Dokument beschreibt die interne Struktur des Projekts, die Hauptmodule, die Entwicklungskonventionen und den Status der Komponenten. Es richtet sich hauptsächlich an Entwickler oder Benutzer, die das interne Funktionsprinzip des Systems verstehen möchten.

---

## Ordnerstruktur

```
DubbingToolkit/
├── Billing/                TTS-Verbrauchsüberwachung und Kosten
├── core/                   Gemeinsam genutzte Python-Hilfsmodule
├── credentials/            API-Anmeldedaten (von Git ausgeschlossen)
├── Installation/           Lokale Python-Laufzeitumgebungen (3.10, 3.11)
├── installer/              Build- und Packaging-System
├── locale/                 Lokalisierung und Sprachverwaltung
│   ├── Active/             Aktive Sprach-JSON-Dateien (it, en, es, de, fr, pt, ru, zh)
│   └── System/             Sprachmetadaten (Whisper, unterstützte Sprachen)
├── Logs/                   Betriebsprotokolle
├── ps/                     PowerShell-Module (Protokollierung, Nachrichtenverwaltung)
├── Repository/             Gemeinsam genutzte Ressourcen und lokale Modelle
├── Scripts/                Operative Skripte und Python-Module
│   └── maintenance/        Wartungsskripte und Lokalisierungspipeline
├── Settings/               Aktive und Referenzkonfiguration
├── Temp/                   Temporäre Dateien
├── Tools/                  Externe Binärdateien (ffmpeg)
├── venv/                   Virtuelle Python-Hauptumgebung
├── voices/                 Verfügbare TTS-Stimmen und Audiobeispiele
└── Workspace/              Projektdaten (automatisch erstellt)
    └── projects/
        └── {projektname}/
            ├── project_info.json                    Projektmetadaten
            ├── audio_extraction/
            │   ├── current/                         Aktuelle Audiospuren
            │   └── archive/                         Archiv früherer Extraktionen
            ├── transcripts/
            │   ├── current/                         Aktuelle SRT-Transkripte
            │   └── archive/                         Archiv früherer Transkripte
            ├── translated/
            │   ├── current/                         Aktuelle SRT-Übersetzungen
            │   └── archive/                         Archiv früherer Übersetzungen
            ├── dubbed/
            │   ├── current/                         Aktuelle TTS-Audiodatei
            │   └── archive/                         Archiv früherer TTS-Ausgaben
            ├── video_input/                         Quellvideo (nie verändert)
            └── audio_input/                         Direkter Audioeingang (optional)
```

---

## Startkette

```
StartDubbing.bat
  └→ Scripts/Launcher.ps1
       Aktiviert venv, UTF-8-Setup, Protokolle, Sprachladung
         └→ Scripts/Regista.py
              Hauptmenü und Pipeline-Orchestrierung
```

Der Launcher verwaltet: Auswahl der lokalen Python-Laufzeitumgebung (`Installation/`), Erstellung/Aktivierung des venv, Einrichtung des Protokollsystems, Laden der Oberflächensprache.

`Regista.py` ist der zentrale Koordinator: Er präsentiert das Menü und delegiert die Ausführung an die spezifischen Module für jede Phase.

---

## Operative Pipeline

| Phase | Modul | Eingabe → Ausgabe |
|---|---|---|
| 1 — Audioextraktion | `Scripts/estrai_tracce.py` | `video_input/` → `audio_extraction/current/` |
| 2 — Transkription | `Scripts/trascrivi_audio.py` | `audio_extraction/current/` oder `audio_input/` → `transcripts/current/` (SRT) |
| 3 — Übersetzung | `Scripts/traduci_testo.py` | `transcripts/current/` → `translated/current/` (SRT) |
| 4 — TTS | `Scripts/tts_menu.py` | `translated/current/` → `dubbed/current/` (MP3/WAV) |

Alle Pfade sind relativ zu `Workspace/projects/{projektname}/`. `tts_menu.py` delegiert an `tts_azure.py` oder `tts_google.py` je nach aktivem Anbieter.

---

## Core-Module (`core/`)

| Modul | Funktion |
|---|---|
| `messages.py` | Zentralisierte lokalisierte Nachrichtenverwaltung — liest `locale/Active/<lang>.json` |
| `credentials_manager.py` | Laden und Validieren der API-Anmeldedaten |
| `api_check.py` | Überprüfung der Anmeldedaten vor dem TTS-Menü-Zugriff |
| `logger.py` | Strukturierter Sitzungs-Logger (INFO/WARN/ERROR) im JSON-Format |
| `error_reporter.py` | Fehlerberichtssystem: ZIP der Protokolle, mailto: Entwickler |
| `update_checker.py` | Überprüfung auf Updates über GitHub Releases |
| `ui_printer.py` + `ui_colors.py` | Konsolenformatierung und Farben |
| `utils_tts.py` | Gemeinsame Hilfsfunktionen für SRT-Parsing |
| `workspace_manager.py` | Verwaltung des aktiven Workspace, Stage-Struktur, Archivrotation |
| `source_importer.py` | Importdialog für externe Dateien in den Workspace |

---

## Lokalisierung

```
locale/
├── Active/              Aktive Sprachdateien (Runtime)
│   ├── it.json, en.json, es.json, de.json, fr.json, pt.json, ru.json, zh.json
└── System/
    ├── languages.json           Konzeptuell unterstützte Sprachen
    └── whisper_languages.json   Von Whisper unterstützte Sprachen
```

- Alle Python-Oberflächenmeldungen verwenden `core/messages.py`.
- Alle Dateien in `locale/Active/` müssen synchronisiert sein.
- Fehlende Schlüssel erzeugen `[MISSING: key]` zur Laufzeit.
- PowerShell verwendet `ps/Messages.psm1`.

---

## Konfiguration (`Settings/settings.json`)

```json
{
  "interface_lang": "de",
  "model": "small",
  "Transcript_Audio_Spoken_Lang": "it",
  "Translation_Target_Lang": "en",
  "Dubbing_Lang": "en"
}
```

---

## Komponentenstatus

| Komponente | Status |
|---|---|
| Audioextraktion | ✅ Betriebsbereit |
| Whisper-Transkription | ✅ Betriebsbereit |
| Helsinki-NLP-Übersetzung | ✅ Betriebsbereit |
| TTS Azure | ✅ Betriebsbereit |
| TTS Google | ✅ Betriebsbereit |
| Mehrsprachige Oberfläche (8 Sprachen) | ✅ Betriebsbereit |
| TTS-Verbrauchsüberwachung | ✅ Betriebsbereit |
| Build-/Packaging-System | ✅ Betriebsbereit |
| Untertitel (Menüoption 5) | ⚠️ Stub — nicht implementiert |
| Erweiterte Segmentierung | ⚠️ Platzhalter — nicht in Pipeline |
| WhisperX | ⚠️ Venv vorbereitet, nicht integriert |
| TTS OpenAI / ElevenLabs | ⚠️ Konfigurationsdateien vorhanden, nicht verbunden |
| Pivot-Übersetzung (Zwischensprache) | 🔲 Geplant |
| Text-Nachbearbeitung | 🔲 Geplant |
| Projektbasiertes Modell (Workspace) | ✅ Betriebsbereit |
