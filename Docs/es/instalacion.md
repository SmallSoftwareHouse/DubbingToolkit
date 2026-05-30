# Instalación y configuración

## Requisitos del sistema

- **SO:** Windows con PowerShell 5.1
- **Python:** incluido — Python 3.11 en `Installation/`
- **ffmpeg:** incluido en `Tools/ffmpeg-7.1.1-full_build/`
- **Internet:** necesario para las APIs TTS y las descargas de modelos en el primer uso

## Credenciales TTS

| Archivo | Proveedor |
|---|---|
| `azure_speech_credentials.json` | Azure Cognitive Services Speech |
| `google_speech_credentials.json` | Google Cloud TTS |

Plantillas: `credentials/azure_speech_credentials.template.json` y `credentials/google_speech_credentials.template.json`

Copia la plantilla, elimina la extensión `.template`, e introduce tus credenciales.

## Entorno virtual y dependencias Python

El Launcher gestiona automáticamente la creación del entorno virtual y la instalación de dependencias. Las dependencias se listan en `Config/dependencies.json`.

### Restablecer el entorno virtual

```powershell
Scripts/reset_env.ps1
```

Restablecimiento manual: elimina la carpeta `venv/` y reinicia `StartDubbing.bat`.

## Configuración inicial

`Settings/`:

| Archivo | Función |
|---|---|
| `settings.json` | Configuración activa |
| `settings_default.json` | Referencia (no modificar) |
| `reset.json` | Parámetros de restablecimiento |

Ajustes clave en `settings.json`: `interface_lang`, proveedor TTS, modelo Whisper.

> **Nota:** los ajustes se guardan automáticamente entre sesiones mediante `Settings/settings_persistent.json`. El idioma seleccionado durante la instalación se aplica en el primer inicio sin ninguna acción adicional.

## Inicio

```
StartDubbing.bat
```

El Launcher realiza automáticamente:
1. Activa el entorno Python local
2. Crea/activa el entorno virtual
3. Verifica las credenciales de la API
4. Lanza la interfaz principal

## Mover y desinstalar

### Desinstalar

Si el proyecto fue instalado con el paquete de distribución, usar el panel **Aplicaciones** de Windows o el desinstalador en la carpeta de instalación.

El desinstalador permite elegir qué eliminar permanentemente:
- Credenciales y claves API
- Datos de facturación (uso TTS mensual)
- Registros de sesión
- Archivos de trabajo (proyectos, audio, vídeo, transcripciones)

Los datos no seleccionados se conservan. El entorno virtual (`venv/`) se elimina siempre automáticamente.

### Mover

Aunque no se recomienda, el proyecto puede moverse. Tras moverlo: elimina `venv/` y reinicia `StartDubbing.bat`.
