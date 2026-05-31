# Arquitectura y referencia técnica

Este documento describe la estructura interna del proyecto, los módulos principales, las convenciones de desarrollo y el estado de los componentes. Está destinado principalmente a quienes contribuyen al desarrollo o desean comprender el funcionamiento interno del sistema.

---

## Estructura de carpetas

```
DubbingToolkit/
├── Billing/                Seguimiento de consumo y costos TTS
├── core/                   Módulos de soporte Python compartidos
├── credentials/            Credenciales API (excluidas de Git)
├── Installation/           Runtimes Python locales (3.10, 3.11)
├── installer/              Sistema de build y packaging
├── locale/                 Localización y gestión de idiomas
│   ├── Active/             Archivos JSON de idioma activos (it, en, es, de, fr, pt, ru, zh)
│   └── System/             Metadatos de idiomas (Whisper, idiomas soportados)
├── Logs/                   Registros operativos
├── ps/                     Módulos PowerShell (registro, mensajería)
├── Repository/             Recursos compartidos y modelos locales
├── Scripts/                Scripts operativos y módulos Python
│   └── maintenance/        Scripts de mantenimiento y pipeline de localización
├── Settings/               Configuración activa y de referencia
├── Temp/                   Archivos temporales
├── Tools/                  Binarios externos (ffmpeg)
├── venv/                   Entorno virtual Python principal
├── voices/                 Voces TTS disponibles y muestras de audio
└── Workspace/              Datos de proyectos (creado automáticamente)
    └── projects/
        └── {nombre_proyecto}/
            ├── project_info.json                    Metadatos del proyecto
            ├── audio_extraction/
            │   ├── current/                         Pistas de audio actuales
            │   └── archive/                         Historial de extracciones
            ├── transcripts/
            │   ├── current/                         Transcripciones SRT actuales
            │   └── archive/                         Historial de transcripciones
            ├── translated/
            │   ├── current/                         Traducciones SRT actuales
            │   └── archive/                         Historial de traducciones
            ├── dubbed/
            │   ├── current/                         Audio TTS actual
            │   └── archive/                         Historial de audio TTS
            ├── video_input/                         Video fuente (nunca modificado)
            └── audio_input/                         Audio de entrada directo (opcional)
```

---

## Cadena de inicio

```
StartDubbing.bat
  └→ Scripts/Launcher.ps1
       Activa venv, configuración UTF-8, registros, carga de idioma
         └→ Scripts/Regista.py
              Menú principal y orquestación del pipeline
```

El Launcher gestiona: selección del runtime Python local (`Installation/`), creación/activación del venv, configuración del sistema de registros, carga del idioma de la interfaz.

`Regista.py` es el coordinador central: presenta el menú al usuario y delega la ejecución a los módulos específicos para cada fase.

---

## Pipeline operativo

| Fase | Módulo | Entrada → Salida |
|---|---|---|
| 1 — Extracción audio | `Scripts/estrai_tracce.py` | `video_input/` → `audio_extraction/current/` |
| 2 — Transcripción | `Scripts/trascrivi_audio.py` | `audio_extraction/current/` o `audio_input/` → `transcripts/current/` (SRT) |
| 3 — Traducción | `Scripts/traduci_testo.py` | `transcripts/current/` → `translated/current/` (SRT) |
| 4 — TTS | `Scripts/tts_menu.py` | `translated/current/` → `dubbed/current/` (MP3/WAV) |

Todos los caminos son relativos a `Workspace/projects/{nombre_proyecto}/`. `tts_menu.py` delega a `tts_azure.py` o `tts_google.py` según el proveedor activo.

---

## Módulos core (`core/`)

| Módulo | Función |
|---|---|
| `messages.py` | Mensajería localizada centralizada — lee `locale/Active/<lang>.json` |
| `credentials_manager.py` | Carga y validación de credenciales API |
| `api_check.py` | Verificación de credenciales antes del acceso al menú TTS |
| `logger.py` | Logger de sesión estructurado (INFO/WARN/ERROR) en JSON |
| `error_reporter.py` | Sistema de reporte de errores: ZIP de logs, mailto: desarrollador |
| `update_checker.py` | Verificación de actualizaciones en GitHub Releases |
| `ui_printer.py` + `ui_colors.py` | Formateo y colores de la consola |
| `utils_tts.py` | Utilidades compartidas para parseo SRT |
| `workspace_manager.py` | Gestión del workspace activo, estructura de stages, rotación de archivos |
| `source_importer.py` | Diálogo de importación de archivos externos al workspace |

---

## Localización

```
locale/
├── Active/              Archivos de idioma activos (runtime)
│   ├── it.json, en.json, es.json, de.json, fr.json, pt.json, ru.json, zh.json
└── System/
    ├── languages.json           Idiomas conceptualmente soportados
    └── whisper_languages.json   Idiomas soportados por Whisper
```

- Todos los mensajes de la interfaz Python usan `core/messages.py`.
- Todos los archivos en `locale/Active/` deben estar sincronizados.
- Las claves faltantes producen `[MISSING: key]` en tiempo de ejecución.
- PowerShell usa `ps/Messages.psm1`.

---

## Configuración (`Settings/settings.json`)

```json
{
  "interface_lang": "es",
  "model": "small",
  "Transcript_Audio_Spoken_Lang": "it",
  "Translation_Target_Lang": "en",
  "Dubbing_Lang": "en"
}
```

---

## Estado de los componentes

| Componente | Estado |
|---|---|
| Extracción de audio | ✅ Operativo |
| Transcripción Whisper | ✅ Operativo |
| Traducción Helsinki-NLP | ✅ Operativo |
| TTS Azure | ✅ Operativo |
| TTS Google | ✅ Operativo |
| Interfaz multilingüe (8 idiomas) | ✅ Operativo |
| Monitoreo de consumo TTS | ✅ Operativo |
| Sistema de build/packaging | ✅ Operativo |
| Subtítulos (opción menú 5) | ⚠️ Stub — no implementado |
| Segmentación avanzada | ⚠️ Placeholder — fuera del pipeline |
| WhisperX | ⚠️ Venv preparado, no integrado |
| TTS OpenAI / ElevenLabs | ⚠️ Archivos de configuración presentes, no conectados |
| Traducción pivot (idioma intermedio) | 🔲 Planificado |
| Post-procesamiento de texto | 🔲 Planificado |
| Modelo basado en proyectos (Workspace) | ✅ Operativo |
