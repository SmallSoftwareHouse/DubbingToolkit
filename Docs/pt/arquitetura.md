# Arquitetura e referência técnica

Este documento descreve a estrutura interna do projeto, os módulos principais, as convenções de desenvolvimento e o estado dos componentes. Destina-se principalmente a quem contribui para o desenvolvimento ou quer entender o funcionamento interno do sistema.

---

## Estrutura de pastas

```
DubbingToolkit/
├── Billing/                Monitoramento de consumo e custos TTS
├── core/                   Módulos de suporte Python compartilhados
├── credentials/            Credenciais API (excluídas do Git)
├── Installation/           Runtimes Python locais (3.10, 3.11)
├── installer/              Sistema de build e packaging
├── locale/                 Localização e gestão de idiomas
│   ├── Active/             Arquivos JSON de idioma ativos (it, en, es, de, fr, pt, ru, zh)
│   └── System/             Metadados de idiomas (Whisper, idiomas suportados)
├── Logs/                   Registros operacionais
├── ps/                     Módulos PowerShell (registro, mensagens)
├── Repository/             Recursos compartilhados e modelos locais
├── Scripts/                Scripts operacionais e módulos Python
│   └── maintenance/        Scripts de manutenção e pipeline de localização
├── Settings/               Configuração ativa e de referência
├── Temp/                   Arquivos temporários
├── Tools/                  Binários externos (ffmpeg)
├── venv/                   Ambiente virtual Python principal
├── voices/                 Vozes TTS disponíveis e amostras de áudio
└── Workspace/              Dados dos projetos (criado automaticamente)
    └── projects/
        └── {nome_projeto}/
            ├── project_info.json                    Metadados do projeto
            ├── audio_extraction/
            │   ├── current/                         Faixas de áudio atuais
            │   └── archive/                         Histórico de extrações
            ├── transcripts/
            │   ├── current/                         Transcrições SRT atuais
            │   └── archive/                         Histórico de transcrições
            ├── translated/
            │   ├── current/                         Traduções SRT atuais
            │   └── archive/                         Histórico de traduções
            ├── dubbed/
            │   ├── current/                         Áudio TTS atual
            │   └── archive/                         Histórico de áudio TTS
            ├── video_input/                         Vídeo fonte (nunca modificado)
            └── audio_input/                         Áudio de entrada direto (opcional)
```

---

## Cadeia de inicialização

```
StartDubbing.bat
  └→ Scripts/Launcher.ps1
       Ativa venv, configuração UTF-8, registros, carregamento de idioma
         └→ Scripts/Regista.py
              Menu principal e orquestração do pipeline
```

O Launcher gerencia: seleção do runtime Python local (`Installation/`), criação/ativação do venv, configuração do sistema de registros, carregamento do idioma da interface.

`Regista.py` é o coordenador central: apresenta o menu ao usuário e delega a execução aos módulos específicos para cada fase.

---

## Pipeline operacional

| Fase | Módulo | Entrada → Saída |
|---|---|---|
| 1 — Extração de áudio | `Scripts/estrai_tracce.py` | `video_input/` → `audio_extraction/current/` |
| 2 — Transcrição | `Scripts/trascrivi_audio.py` | `audio_extraction/current/` ou `audio_input/` → `transcripts/current/` (SRT) |
| 3 — Tradução | `Scripts/traduci_testo.py` | `transcripts/current/` → `translated/current/` (SRT) |
| 4 — TTS | `Scripts/tts_menu.py` | `translated/current/` → `dubbed/current/` (MP3/WAV) |

Todos os caminhos são relativos a `Workspace/projects/{nome_projeto}/`. `tts_menu.py` delega a `tts_azure.py` ou `tts_google.py` conforme o provedor ativo.

---

## Módulos core (`core/`)

| Módulo | Função |
|---|---|
| `messages.py` | Mensagens localizadas centralizadas — lê `locale/Active/<lang>.json` |
| `credentials_manager.py` | Carregamento e validação de credenciais API |
| `api_check.py` | Verificação de credenciais antes do acesso ao menu TTS |
| `logger.py` | Logger de sessão estruturado (INFO/WARN/ERROR) em JSON |
| `error_reporter.py` | Sistema de relatório de erros: ZIP dos logs, mailto: desenvolvedor |
| `update_checker.py` | Verificação de atualizações no GitHub Releases |
| `ui_printer.py` + `ui_colors.py` | Formatação e cores do console |
| `utils_tts.py` | Utilitários compartilhados para parsing SRT |
| `workspace_manager.py` | Gestão do workspace ativo, estrutura de stages, rotação de arquivos |
| `source_importer.py` | Diálogo de importação de arquivos externos para o workspace |

---

## Localização

```
locale/
├── Active/              Arquivos de idioma ativos (runtime)
│   ├── it.json, en.json, es.json, de.json, fr.json, pt.json, ru.json, zh.json
└── System/
    ├── languages.json           Idiomas conceitualmente suportados
    └── whisper_languages.json   Idiomas suportados pelo Whisper
```

- Todas as mensagens da interface Python usam `core/messages.py`.
- Todos os arquivos em `locale/Active/` devem estar sincronizados.
- Chaves ausentes produzem `[MISSING: key]` em tempo de execução.
- PowerShell usa `ps/Messages.psm1`.

---

## Configuração (`Settings/settings.json`)

```json
{
  "interface_lang": "pt",
  "model": "small",
  "Transcript_Audio_Spoken_Lang": "it",
  "Translation_Target_Lang": "en",
  "Dubbing_Lang": "en"
}
```

---

## Estado dos componentes

| Componente | Estado |
|---|---|
| Extração de áudio | ✅ Operacional |
| Transcrição Whisper | ✅ Operacional |
| Tradução Helsinki-NLP | ✅ Operacional |
| TTS Azure | ✅ Operacional |
| TTS Google | ✅ Operacional |
| Interface multilíngue (8 idiomas) | ✅ Operacional |
| Monitoramento de consumo TTS | ✅ Operacional |
| Sistema de build/packaging | ✅ Operacional |
| Legendas (opção menu 5) | ⚠️ Stub — não implementado |
| Segmentação avançada | ⚠️ Placeholder — fora do pipeline |
| WhisperX | ⚠️ Venv preparado, não integrado |
| TTS OpenAI / ElevenLabs | ⚠️ Arquivos de configuração presentes, não conectados |
| Tradução pivot (idioma intermediário) | 🔲 Planejado |
| Pós-processamento de texto | 🔲 Planejado |
| Modelo baseado em projetos (Workspace) | ✅ Operacional |
