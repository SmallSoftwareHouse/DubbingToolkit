# Installation und Konfiguration

## Systemanforderungen

- **Betriebssystem:** Windows mit PowerShell 5.1
- **Python:** enthalten — Python 3.11 in `Installation/`
- **ffmpeg:** enthalten in `Tools/ffmpeg-7.1.1-full_build/`
- **Internetverbindung:** für TTS-APIs und Modell-Downloads

## TTS-Anmeldedaten

| Datei | Anbieter |
|---|---|
| `azure_speech_credentials.json` | Azure Cognitive Services Speech |
| `google_speech_credentials.json` | Google Cloud TTS |

Vorlagen: `credentials/azure_speech_credentials.template.json` und `credentials/google_speech_credentials.template.json`

## Virtuelle Umgebung und Python-Abhängigkeiten

Der Launcher verwaltet die virtuelle Umgebung und die Abhängigkeiten automatisch. Abhängigkeiten sind in `Config/dependencies.json` aufgeführt.

### Virtuelle Umgebung zurücksetzen

```powershell
Scripts/reset_env.ps1
```

Manuelles Zurücksetzen: `venv/` löschen und `StartDubbing.bat` neu starten.

## Erstkonfiguration

`Settings/`:

| Datei | Zweck |
|---|---|
| `settings.json` | Aktive Konfiguration |
| `settings_default.json` | Referenz (nicht ändern) |
| `reset.json` | Wiederherstellung |

Parameter in `settings.json`: `interface_lang`, TTS-Anbieter, Whisper-Modell.

> **Hinweis:** Einstellungen werden automatisch zwischen Sitzungen gespeichert via `Settings/settings_persistent.json`. Die beim Setup gewählte Sprache wird beim ersten Start automatisch angewendet.

## Automatischer Start

```
StartDubbing.bat
```

1. Aktivierung der lokalen Python-Laufzeitumgebung
2. Erstellen/Aktivieren der virtuellen Umgebung
3. Überprüfung der API-Anmeldedaten
4. Start der Hauptoberfläche

## Verschieben und Deinstallieren

### Deinstallation

Wenn das Projekt über das Distributionspaket installiert wurde, den Windows-Bereich **Apps & Features** oder den Deinstaller im Installationsordner verwenden.

Der Deinstaller ermöglicht die Auswahl, was dauerhaft gelöscht werden soll:
- Anmeldedaten und API-Schlüssel
- Abrechnungsdaten (monatliche TTS-Nutzung)
- Sitzungsprotokolle
- Arbeitsdateien (Projekte, Audio, Video, Transkripte)

Nicht ausgewählte Daten bleiben erhalten. Die virtuelle Umgebung (`venv/`) wird immer automatisch entfernt.

### Verschieben

Obwohl nicht empfohlen, kann das Projekt verschoben werden. Nach dem Verschieben: `venv/` löschen und `StartDubbing.bat` neu starten.
