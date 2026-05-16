# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Reference

The structural reference document for this project is **RecapDubbing.txt**, located in the project root.
It contains:
- Section 1: full project structure
- Section 2: coding conventions, naming rules, script structure rules, messaging and localization standards
- Section 3: current operational state
- Section 4: script overview guidelines
- Section 5: to-do list and planned improvements
- Section 6: official script structure template (mandatory for all new scripts)

Always read RecapDubbing.txt before making structural decisions or creating new files.

## Project Overview

DubbingToolkit is a Windows desktop automation tool for dubbing tutorial videos. It chains together video extraction, speech-to-text (OpenAI Whisper), neural machine translation (Helsinki-NLP MarianMT), and text-to-speech (Google Cloud TTS / Azure Cognitive Services) into a single CLI workflow.

Python 3.11 runs inside `venv/`. The full app is launched via `StartDubbing.bat`, which calls `Scripts/Launcher.ps1`, which activates the venv and calls `Scripts/Regista.py`.

## Running the Application

```bat
StartDubbing.bat
```

Or directly from PowerShell:
```powershell
Scripts/Launcher.ps1
```

Or activate the venv manually and run the Python entry point:
```bash
venv/Scripts/python.exe Scripts/Regista.py
```

## Environment Setup

```powershell
# Create/validate venv and install all dependencies
Scripts/VenvManager.ps1
Scripts/InstallDependencies.ps1

# Reset environment entirely
Scripts/reset_env.ps1
```

Dependencies are declared in **`Config/dependencies.json`** — an ordered list of packages, each with pinned version, per-package pip flags, and notes. `InstallDependencies.ps1` reads this file and installs packages one by one in the declared order. PyTorch variant (+cpu or +cu121) is resolved at runtime by CUDA detection. ffmpeg 7.1.1 is bundled in `Tools/` and must be on PATH for audio/video operations.

> `Scripts/requirements.txt` is kept for historical reference only and is no longer used by the installer.

## Testing

Ad-hoc test scripts live in `Test/`. There is no unified test runner. Run individual scripts directly:

```bash
venv/Scripts/python.exe Test/test_model.py
venv/Scripts/python.exe Test/self_test_script_usage.py
```

## Installer Build

```powershell
installer/build.ps1
```

Include/exclude rules are in `installer/build_include.json` and `installer/build_exclude.json`. The build output goes to `installer/build_payload/`. Real credential files are **never** included in the build — only `*.template.json` files ship.

## Architecture

### Startup Chain

```
StartDubbing.bat
  → Scripts/Launcher.ps1   (UTF-8, venv activation, log setup, language load)
    → Scripts/Regista.py   (main menu coordinator)
```

### Pipeline (menu options in Regista.py)

| Step | Module | Input → Output |
|------|--------|----------------|
| 1 — Extract audio | `Scripts/estrai_tracce.py` | `Video_Input/` → `Audio_Extracted/<ts>/` |
| 2 — Transcribe | `Scripts/trascrivi_audio.py` | `Audio_Extracted/` or `Audio_Input/` → `Transcripts/<ts>/` (SRT) |
| 3 — Translate | `Scripts/traduci_testo.py` | `Transcripts/` → `Translated/<ts>/` (SRT) |
| 4 — TTS | `Scripts/tts_menu.py` | `Translated/` → `Dubbed/` (MP3/WAV) |

`Scripts/tts_menu.py` delegates to `Scripts/tts_google.py` or `Scripts/tts_azure.py` depending on the active provider.

### Core Infrastructure (`core/`)

- **`messages.py`** — all UI strings. Reads `Settings/settings.json` → `interface_lang` → loads the matching `locale/Active/<lang>.json`. Call `_(key)` to get a translated string. Missing keys surface as `[MISSING: key]`.
- **`credentials_manager.py`** — loads and validates `credentials/*.json` for each provider. Never read credential files directly elsewhere.
- **`api_check.py`** — checks whether Google/Azure credentials are valid before allowing TTS. Called at TTS menu entry.
- **`logger.py`** — structured session logger. Writes events (INFO/WARN/ERROR) to `Logs/*_session*.json`. `close_session(exit_reason=...)` writes the final exit reason (`normal`/`window_closed`/`crash`).
- **`error_reporter.py`** — error reporting system. Creates a ZIP with recent session logs, opens Explorer on it, then opens `mailto:` to the developer. Three modes: manual (R key), automatic at exit if errors exist, silent on crash.
- **`update_checker.py`** — checks for updates against GitHub Releases. Compares local version from `settings.json` with latest release tag.
- **`ui_printer.py`** + **`ui_colors.py`** — console formatting; use these instead of raw `print` for consistent output.
- **`utils_tts.py`** — shared SRT parsing utilities used by both TTS backends.

### Scripts/

- **`info_manager.py`** — reads/writes `project_info.json` inside each timestamped folder for state persistence.

### Localization

UI language is set in `Settings/settings.json` → `interface_lang`. Default is `en`. Add or edit strings in `locale/Active/<lang>.json`. All 8 supported languages (`en`, `it`, `fr`, `de`, `es`, `pt`, `ru`, `zh`) must stay in sync. The PowerShell side uses `ps/Messages.psm1` + `ps/Logging.psm1` (`Write-Log`).

### PowerShell Logging

All PowerShell runtime scripts use `ps/Logging.psm1` for console output:
```powershell
Import-Module (Join-Path $RootFolder 'ps\Logging.psm1') -Force
Set-Messages $Messages   # must be called after $Messages is loaded
Write-Log "LocaleKey"                        # INFO (gray)
Write-Log "LocaleKey" "WARN"                 # WARN (yellow)
Write-Log "LocaleKey" "ERROR"                # ERROR (red)
Write-Log "LocaleKey" "HIGHLIGHT"            # HIGHLIGHT (cyan)
Write-Log "LocaleKey" "OK"                   # OK (green)
Write-Log "LocaleKey" "INFO" @($param1, $param2)
```
Aligned scripts: `Launcher.ps1`, `VenvManager.ps1`, `InstallDependencies.ps1`.

### Credentials

Real credential files live in `credentials/` and are gitignored. Templates (`*.template.json`) document the required keys:
- **Azure**: `azure_speech_credentials.json` needs `subscription` and `region`
- **Google**: `google_speech_credentials.json` is a full GCP service account JSON

### Settings

`Settings/settings.json` is the live config; `Settings/settings_default.json` is the reference. Key fields:

```json
{
  "interface_lang": "en",
  "model": "small",
  "Transcript_Audio_Spoken_Lang": "it",
  "Translation_Target_Lang": "en",
  "Dubbing_Lang": "en"
}
```

### Billing Tracking

`Billing/consumo_tts.json` tracks monthly character usage per engine. Access via `Scripts/monitoraggio_consumo.py` only — writes are thread-safe.

## Runtime Dependencies

`Scripts/RuntimeDependencies.ps1` is implemented and tested. It runs automatically at startup via `Launcher.ps1` (dot-sourced before `Start-Launcher`).

Checks run in this order on every launch (skipped silently if already satisfied):

1. **Windows Long Paths** — enables `LongPathsEnabled=1` in registry (required for pip install of deeply nested packages). Direct write if admin; UAC elevation otherwise. Non-fatal (WARN).
2. **Visual C++ Redistributable 2015-2022 x64** — required by PyTorch. Downloaded from `https://aka.ms/vs/17/release/vc_redist.x64.exe`, installed silently with UAC. Fatal if missing and cannot install.
3. **ffmpeg 7.1.1** — downloaded from GitHub Releases (GyanD/codexffmpeg) and extracted to `Tools/`. Fatal.
4. **voices_output** — downloaded from GitHub Releases (SmallSoftwareHouse/DubbingToolkit, tag `v0.1.0-alpha`) and extracted to `voices/`. Non-fatal (WARN).

Verified end-to-end on clean Windows 10 and Windows 11 VMs.

## Known Incomplete Areas

- **Subtitles** (menu option 5) — disabled, `Scripts/Sottotitoli.py` is a stub.
- **segmentazione_avanzata.py** — placeholder, excluded from main pipeline, not production-ready.
- **WhisperX** — `venv_whisperX/` is prepared but not integrated into the pipeline.
- **OpenAI / HuggingFace TTS** — credential files exist but providers are not wired into `tts_menu.py`.