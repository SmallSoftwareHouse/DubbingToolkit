# DubbingToolkit

**DubbingToolkit** is a hybrid Python + PowerShell dubbing pipeline that transcribes, translates and re-synthesizes audio/video content into multiple languages using professional TTS engines (Azure, Google) and local transcription models (Whisper).

> ⚠️ **Note:** Documentation in languages other than Italian and English has been automatically translated and may contain errors or inaccuracies.

---

## What it does

Starting from a video or audio file, DubbingToolkit runs a 4-stage pipeline:

1. **Audio extraction** — Extracts audio tracks from video via ffmpeg
2. **Transcription** — Transcribes audio to SRT format via Whisper (local, no API required)
3. **Translation** — Translates SRT subtitles via Helsinki-NLP models (local, no API required)
4. **TTS synthesis** — Synthesizes dubbed audio segment by segment via Azure or Google TTS, then merges into the final audio file

Each stage is independent and can be run individually. Human review is recommended between transcription and translation, and between translation and synthesis.

---

## Requirements

- Windows 10/11
- Python 3.11 (bundled in the installer)
- ffmpeg (bundled in the installer)
- Azure Cognitive Services Speech API key **and/or** Google Cloud TTS credentials
  (at least one TTS provider is required for the synthesis stage)

---

## Quick start

1. Run `StartDubbing.bat`
2. Create a new project from the project management menu (option `0`)
3. Follow the pipeline: extract → transcribe → translate → synthesize

---

## Interface languages

The application interface is available in 8 languages: Italian, English, Spanish, French, German, Portuguese, Russian, Chinese.

---

## Documentation

Full documentation is available in `Docs/` in all 8 supported languages.

| Language | Folder |
|---|---|
| Italiano | [Docs/it/](Docs/it/README.md) |
| English | [Docs/en/](Docs/en/README.md) |
| Español | [Docs/es/](Docs/es/README.md) |
| Français | [Docs/fr/](Docs/fr/README.md) |
| Deutsch | [Docs/de/](Docs/de/README.md) |
| Português | [Docs/pt/](Docs/pt/README.md) |
| Русский | [Docs/ru/](Docs/ru/README.md) |
| 中文 | [Docs/zh/](Docs/zh/README.md) |

---

## Project status

**Alpha** — Core pipeline is functional end-to-end. Some stages require manual intervention (file review, audio assembly). Advanced features (subtitle export, pivot translation, post-processing) are planned for future releases.

---

## Publisher

[Small Software House](mailto:SmallSoftwareHouse@gmail.com)
