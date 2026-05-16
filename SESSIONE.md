# Riepilogo sessione — 2026-05-16

## Cosa è stato fatto oggi

### UX: antivirus checkpoint box
- Checkpoint 0 in `Launcher.ps1` riscritto: tono trasparente e costruttivo invece di allarmistico
- Testo riorganizzato in 3 punti (Python/PowerShell legittimi, code signing non ancora presente, eccezione antivirus)
- Renderizzazione a box con asterischi (60 char) e titolo centrato per migliorare leggibilità
- Cursore rimane sulla stessa riga del prompt INVIO (nessuna riga vuota dopo)
- Tutte le 8 lingue aggiornate: rimossi `Checkpoint0Warning/Step1/Step2/Step3`, aggiunti `Checkpoint0Title`, `Checkpoint0Body`, `Checkpoint0Step4`

### UX: menu principale senza progetto attivo
- `Regista.py` — titolo menu mostra `RegistaNoProjectHint` quando nessun progetto è attivo (invece del nome progetto)
- `mostra_info_workspace`: aggiunto guard `if ws is None: return` per evitare crash
- Chiave `RegistaNoProjectHint` aggiunta in tutte le 8 lingue

### UX: welcome box al primo avvio
- `Regista.py`: al primo avvio (flag `first_run` in `settings_persistent.json`) mostra un box di benvenuto ciano
- `BootstrapSettings.py`: aggiunto `"first_run"` a `PERSISTENT_FIELDS`
- `Settings/settings_persistent_default.json`: aggiunto `"first_run": true`
- `Settings/InnoSetup/DubbingToolkit_setup.iss` → `WritePersistentSettings`: aggiunto `"first_run": true`

### Fix: lock file PID reuse
- `Launcher.ps1` → `Test-LockAlive`: confronta `proc.StartTime` con il timestamp del lock file
- Se il processo trovato è partito dopo la scrittura del lock → è un riuso PID → non è bloccante
- Elimina falsi positivi su sistemi con rotazione rapida dei PID

### InnoSetup: ReadyToUpdate con avviso re-download
- Tutti e 7 i messaggi `ReadyToUpdate` aggiornati per avvisare che le dipendenze Python verranno riscaricate (~8-10 GB, connessione richiesta)

### Fix: finestra installer bloccata durante cancellazione venv (upgrade)
- **Tentativo fallito**: codice Pascal con `DeleteFolderWithProgress` + `WizardForm.Refresh` non risolve il freeze perché il Code section non ha message pump
- **Fix definitivo**: `venv` spostata in sezione `[InstallDelete]` di InnoSetup → motore nativo gestisce la cancellazione con message pump attiva, finestra rimane reattiva
- `FillAppFolders` aggiornata: `venv` rimossa (gestita da `[InstallDelete]`); le altre cartelle leggere ancora via `DelTree`

### RuntimeDependencies: Visual C++ Redistributable auto-install
- `Test-VCRedistPresent`: controlla registro `HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\X64`
- `Invoke-VCRedistSetup`: scarica da `https://aka.ms/vs/17/release/vc_redist.x64.exe`, installa silenzioso con UAC, exit code 3010 (reboot) trattato come successo
- Dipendenza **FATALE** — se non installabile, `$allOk = $false`
- Tutte le 8 lingue: aggiunte 5 chiavi `RD_VCRedist*`

### RuntimeDependencies: Windows Long Paths auto-enable
- `Test-LongPathsEnabled`: controlla `HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled`
- `Invoke-LongPathsEnable`: scrittura diretta se admin, altrimenti UAC elevation con `Start-Process powershell -Verb RunAs`
- Dipendenza **NON FATALE** (WARN) — senza long paths, pip install può fallire su pacchetti con percorsi profondi
- Tutte le 8 lingue: aggiunte 4 chiavi `RD_LongPaths*`
- Ordine di esecuzione: Long Paths → VC++ Redist → ffmpeg → voices

### Test su VM Windows 10 e Windows 11
- Installazione testata su due VM pulite (nessun software preinstallato oltre agli antivirus Microsoft)
- Due UAC prompt al primo avvio: Long Paths + VC++ Redistributable → accettati, installati correttamente
- Menu principale raggiunto su entrambe le VM senza errori

---

## Stato al termine della sessione
- Installer robusto su ambienti Windows puliti (Win10 e Win11 verificati)
- RuntimeDependencies gestisce autonomamente tutte le dipendenze di sistema note
- **Prossimi passi**: test pipeline completa con credenziali (doppiaggio) su VM o portatile

---
---

# Riepilogo sessione — 2026-05-15 (parte 3)

## Cosa è stato fatto oggi

### Test installer su secondo PC (portatile)
- Installazione completata con successo sul portatile
- Pipeline base funzionante (estrazione, trascrizione, traduzione)
- Doppiaggio non testato (credenziali non caricate sul portatile)

### Migrazione sistema dipendenze: requirements.txt → Config/dependencies.json
- Creata cartella `Config/` con `dependencies.json` — fonte di verità per tutte le dipendenze Python
- Ogni entry ha: package (nome==versione pinned), flags per pacchetto, torch_variant, extra_index, notes
- `InstallDependencies.ps1` riscritto: legge JSON, installa uno per uno in ordine dichiarato
- Rimosso blocco pre-install hardcoded: setuptools e wheel ora gestiti dal loop JSON come tutti gli altri
- `--no-build-isolation` per openai-whisper dichiarato nel JSON (non più hardcoded nello script)
- PyTorch variant (+cpu/+cu121) risolto a runtime da CUDA detection — versioni pinnate nello script
- `Launcher.ps1` aggiornato: punta a `Config/dependencies.json`, parametro rinominato `-DependenciesFile`
- `installer/build_include.json` aggiornato: aggiunta cartella `Config/`
- Tutti e 8 i file locale aggiornati: aggiunta chiave `InstallDependencies_JsonNotFound`
- `Scripts/requirements.txt` mantenuto solo come riferimento storico

### Fix IndexOutOfRangeException in InstallDependencies.ps1
- Pacchetti senza versione pinned (es. `wheel`) causavano crash su `Split("==")[1]`
- Fix: controllo lunghezza array prima di accedere all'indice della versione

### Logging PowerShell — documentazione
- `CLAUDE.md` aggiornato con livelli HIGHLIGHT (ciano) e OK (verde)

---

## Stato al termine della sessione
- Sistema dipendenze JSON funzionante e testato su PC principale (venv ricreato da zero OK)
- **Prossimi passi**: rebuild payload → recompile InnoSetup → aggiornare setup.exe su GitHub Release → test doppiaggio con credenziali

---
---

# Riepilogo sessione — 2026-05-15 (parte 2)

## Cosa è stato fatto oggi

### Pubblicazione release alpha v0.1.0
- Build payload production completata e verificata
- InnoSetup compilato e testato su macchina di produzione e portatile
- Release `v0.1.0-alpha` pubblicata su GitHub Releases con asset: `setup.exe` + `voices_output.7z`
- Gist rinominato da `version.json` a `dubbing_toolkit_version.json`; URL aggiornato in `Regista.py`

### Fix installer e disinstallatore
- `ExtraDiskSpaceRequired=16106127360` aggiunto → spazio disco realistico (~15 GB) mostrato all'utente
- `LaunchDescription` localizzato in 7 lingue (era hardcoded in italiano)
- Disinstallatore: aggiunto 4° checkbox per log di sessione (`Logs/`)
- Disinstallatore: pulsanti "Seleziona tutto" / "Deseleziona tutto" sostituiscono checkbox master
- Disinstallatore: `venv/` eliminata automaticamente (senza checkbox — non è dato utente)
- Conferma eliminazione dati: form custom con testo rosso e doppio bottone Sì/Annulla

### Fix VenvManager — fresh install
- `Test-VenvStructure` ritorna `"Missing"` quando venv assente → ora logga `[WARN]` giallo invece di `[ERROR]` rosso
- Separata la logica: `Missing` → WARN + repair; `Invalid` → ERROR + repair

### Fix installazione dipendenze Python
- `InstallDependencies.ps1`: pre-install `setuptools==67.8.0` + `wheel` prima del loop principale
- `openai-whisper` installato con `--no-build-isolation` per evitare errore `pkg_resources` nell'ambiente isolato temporaneo di pip
- `simpleaudio==1.0.4` commentato in `requirements.txt` (richiede Visual C++ Build Tools, non usato nella pipeline)

### Sistema logging PowerShell — nuovi livelli
- `ps/Logging.psm1`: aggiunti livelli `HIGHLIGHT` (ciano) e `OK` (verde)
- `InstallDependencies.ps1`: ogni pacchetto in installazione usa `[HIGHLIGHT]` ciano
- `DependenciesFinished` usa `[OK]` verde; testo pulito aggiornato in tutte le 8 lingue

### Update checker
- Gist rinominato `dubbing_toolkit_version.json` — architettura multi-progetto (un Gist per progetto)
- Regista.py: messaggio "aggiornato" ora in verde (`Fore.GREEN`)

### Welcome box nuovo utente
- `Regista.py`: box ciano con testo di benvenuto mostrato quando non esistono progetti
- Chiave `RegistaWelcome` aggiunta in tutte le 8 lingue

### Roadmap aggiornata (RecapDubbing.txt sezione 5)
- Aggiunta voce: versioning venv e dipendenze Python (upgrade safety)
- Aggiunta voce: versioning tool runtime (ffmpeg, voices — skip download se già aggiornati)

---

## Stato al termine della sessione
- Release alpha v0.1.0 pubblicata e testata su macchina di produzione
- Test su portatile: whisper ancora in fase di fix (--no-build-isolation applicato, da verificare)
- Prossimi passi: verificare fix whisper su portatile → rebuild payload → aggiornare setup.exe su GitHub Release

---
---

# Riepilogo sessione — 2026-05-15

## Cosa è stato fatto oggi

### Analisi crash da log sessione 2026-05-14
Letti i log del test fallito del giorno prima. Identificata la catena:
1. Azure TTS fallisce con `ResultReason.Canceled` (2 volte)
2. Azure SDK crea comunque un file MP3 vuoto/corrotto
3. `tts_merge.py` tenta di decodificarlo via pydub/ffmpeg → `CouldntDecodeError` → crash

### Fix crash TTS (`tts_azure.py` + `tts_merge.py`)
- `tts_azure.py`: dopo ogni fallimento sintesi (Canceled o Exception), il file output viene rimosso
- `tts_merge.py`: layer difensivo — file vuoti (size 0) e non decodificabili saltati con WARN

### Retry differenziato per error code Azure (`tts_azure.py`)
- Retry fino a 3 tentativi con backoff differenziato per tipo di errore:
  - `TooManyRequests`: 30/60/120s
  - `ServiceUnavailable` / `ServiceTimeout`: 5/15/30s
  - `ConnectionFailure` / `ServiceError` / `RuntimeError`: 3-20s
  - `AuthenticationFailure` / `BadRequest` / `Forbidden`: nessun retry
- Pausa inter-request 200ms per prevenire auto-rate-limiting
- `azure_error_code` e `azure_error_details` ora loggati nel JSON di sessione

### Contatori avanzamento TTS e merge
- `[N/total] Synthesizing...` aggiunto in `tts_azure.py` e `tts_google.py`
- `[N/total] Merging...` aggiunto in `tts_merge.py`
- Messaggio statico rimosso da `tts_dubbing.py` (sostituito dal contatore)

### UX miglioramenti menu TTS
- Voce mostrata con engine: `A (Neural2)` invece di solo `A`
- `voice_engine` salvato in `config_status` e azzerato al cambio provider
- Archive pruning: mostra il limite effettivamente superato (es. `numero backup: 11/10`)

### Fix Regista.py — workflow menu
- **Estrazione**: `read_stage()` cercava sottocartelle `track_XX/` ma la struttura
  post-refactor è flat (`audio_extraction/current/`). Ora legge `audio_tracce` da
  `project_info.json` direttamente.
- **Video esterno**: `source_mode: "external"` mostrato con etichetta `(esterno)`

### Test end-to-end
- Doppiaggio con Azure (en-GB-MaisieNeural): 182/182 sintesi, 0 errori, merged.mp3 OK
- Doppiaggio con Google (A Neural2): completato senza errori

---

## Stato al termine della sessione
- Pipeline alpha testata e stabile su entrambi i provider TTS
- Tutti i crash noti risolti
- UX migliorata: contatori, messaggi informativi, display voci
- **Prossima priorità**: build payload + InnoSetup

---
---

# Riepilogo sessione — 2026-05-14 (parte 2)

## Cosa è stato fatto oggi

### Sistema error reporter (`core/error_reporter.py`)
Implementato sistema completo di segnalazione errori con apertura client email via `mailto:`:
- `create_silent_exit_report(logger)` — crea ZIP silenzioso su crash non gestito
- `has_errors(logger)` — verifica se la sessione corrente contiene eventi ERROR
- `send_error_report(...)` — crea ZIP, apre Explorer sul file, apre `mailto:`, mostra istruzioni
- ZIP include ultimi 3 log di sessione JSON + report testuale con statistiche
- `_compute_stats()` calcola stats direttamente dagli eventi (funziona anche su sessioni aperte senza summary)
- Email developer: `SmallSoftwareHouse@gmail.com`

### Intercettazione chiusura finestra (`SetConsoleCtrlHandler`)
- `_register_console_close_handler()` in Regista.py intercetta `CTRL_CLOSE_EVENT` via ctypes
- Tre percorsi di uscita distinti: `normal` (menu X) / `window_closed` (X finestra console) / `crash` (eccezione non gestita)
- `exit_reason` scritto nel JSON di sessione da `logger.close_session(exit_reason=...)`

### Fix crash warning al riavvio
**Problema**: chiudendo con X della finestra, al prossimo avvio compariva erroneamente "crash rilevato".
**Causa**: PowerShell termina Python prima che possa scrivere sul lock file.
**Soluzione**: Launcher.ps1 legge il log di sessione più recente (`*_session*.json`) invece del lock file per determinare se la chiusura era volontaria. Il log viene scritto dall'handler Python prima della terminazione.

### Aggiunta opzione R (segnalazione errori) in Regista.py
- Opzione `R` nel menu principale per invio manuale segnalazione
- All'uscita via `X`: se la sessione contiene errori, viene proposto automaticamente invio report
- Chiavi locale aggiunte in tutti gli 8 JSON: `RegistaMenuOptionR`, `RegistaExitErrorsPrompt`

### Alpha readiness review e fix
Review completa della catena `StartDubbing.bat → Launcher.ps1 → VenvManager.ps1 → InstallDependencies.ps1 → Regista.py`:

| File | Fix |
|---|---|
| `Launcher.ps1` | Rimosso `Author: Daniele` / `Version: 1.0` → `Small Software House` + `v0.1 Alpha` |
| `Launcher.ps1` | `WorkspaceManager.get_active().ensure_structure()` — null guard per fresh install |
| `Launcher.ps1` | Rimossa stampa percorso Python310 (WhisperX disabilitato) |
| `VenvManager.ps1` | `$EnableSafetyPrompt = $false` (era `$true`, prompt "YES" su repair venv) |
| `InstallDependencies.ps1` | Rimossi tutti i messaggi `DEBUG:` visibili a console |
| `InstallDependencies.ps1` | Ridotti messaggi ridondanti a fine install: da 3 a 1 |

### Splash screen aggiornato
- Titolo: `DUBBING TOOLKIT PROJECT` → `DUBBING TOOLKIT`
- Autore: `Small Software House`
- Versione: `v0.1 Alpha` (allineata a `settings_default.json` → `"version": "0.1"`)

### Lingua default cambiata a inglese
- `settings_default.json` e `settings_persistent_default.json`: `interface_lang` → `"en"`

### Allineamento sistema logging PowerShell
`Launcher.ps1` e `InstallDependencies.ps1` allineati al sistema `ps/Logging.psm1`:
- `Import-Module Logging.psm1` + `Set-Messages` aggiunti dopo caricamento lingua
- Tutti i `Write-Host $Messages.*` convertiti in `Write-Log`
- VenvManager.ps1 era già allineato (era il modello di riferimento)

### Documentazione
- `Docs/*/utilizzo.md` (8 lingue): aggiunta sezione "Segnalazione errori"
- `README.md` (root): creato per repository GitHub

---

## Stato al termine della sessione
- Pipeline alpha pronta end-to-end (`StartDubbing.bat` → Regista.py)
- Sistema logging PowerShell uniforme su tutta la catena di avvio
- Sistema error reporting funzionante e testato
- Crash detection vs voluntary close funzionante
- **Prossima priorità**: build payload + InnoSetup (fase finale, deferred)

---
---

# Riepilogo sessione — 2026-05-14

## Cosa è stato fatto oggi

### Completamento test suite (dal 2026-05-12)
Tutti i 4 test elencati in SESSIONE.md sono stati **completati e passati**:

1. **Test 1 — `is_yes` (locale-aware)** ✓ 4/4 OK
   - IT: rispondere `s`/`si` procede; `n` annulla
   - EN: rispondere `y`/`yes` procede; `n` annulla
   - Hard reset in settings_manager: `n` annulla senza procedere

2. **Test 2 — `offer_open_folder` (tutti gli script pipeline)** ✓ OK
   - `estrai_tracce`: apre la cartella estratta (fixato bug doppia "current")
   - `trascrivi_audio`, `traduci_testo`, `tts_menu`: funzionanti
   - Rispondere `s`/`y` apre Explorer; `n` torna al menu

3. **Test 3 — Gestione progetti** ✓ OK
   - Opzione 1 Crea: nuovo progetto creato e attivato
   - Opzione 4 Duplica: copia con `nome_progetto` aggiornato in project_info.json
   - Opzione 5 Rinomina: active pointer aggiornato, PermissionError catturato e gestito
   - Opzione 6 Apri cartella: apre Explorer sulla cartella del progetto
   - Opzione 3 Elimina: con `use_trash=true` sposta nel Cestino

4. **Test 4 — `source_importer`** ✓ 7/7 OK + manual test
   - Opzione 1 (keep external): restituisce il path originale
   - Opzione 2 (copy): copia nel workspace, sorgente rimane
   - Opzione 3 (move): sposta nel workspace, sorgente rimosso
   - Cross-project warning: mostra i progetti che usano il file (test automatico)
   - Manual test: move funziona anche con warning assente (file non referenziato da altri progetti)

### Refactor: audio_extraction
**Problema**: estrazione audio salvava file in `audio_extraction/track_XX/current/` separando per traccia.
**Soluzione**: ristrutturato per salvare tutti i file in `audio_extraction/current/` con nomi `track_01.wav`, `track_02.wav`, ecc.

**Cambiamenti**:
- `estrai_tracce.py`: loop estrazione, archive rotation, metadata naming
- `trascrivi_audio.py`: aggiornato `_collect_extracted_tracks()` per leggere dalla nuova struttura
- `info_manager.py`: aggiornata logica derivazione `track_id` (fallback dal nome file)
- Metadata: singolo per traccia (`track_XX_metadata.json`) invece di uno unico
- `offer_open_folder`: apre `audio_extraction/current/` anziché `audio_extraction/`

**Motivazione**: un progetto = un video source. Tutte le tracce dello stesso video devono stare insieme nella stessa cartella, non suddivise.

### Fix: PermissionError in project management
**Problema**: rinominare/eliminare/duplicare un progetto con la cartella aperta in Explorer causava crash.
**Soluzione**: aggiunto try-except per catturare `PermissionError` in Regista.py e mostrare un messaggio amichevole all'utente.

**Ubicazioni**:
- Opzione 3 (Elimina): "Cannot delete: folder is open in Explorer..."
- Opzione 4 (Duplica): "Cannot duplicate: source folder is open..."
- Opzione 5 (Rinomina): "Cannot rename: folder is open..."

### Creato `.claudeignore`
File per escludere cartelle dall'analisi di Claude Code:
- `nppBackup/`, `[Tt]emp*/`, `[Ll]ogs/`
- `venv/` (usabile per esecuzione, escluso da ricerche)
- `Installation/` (Python, escludibile su richiesta)

### Test automatici aggiunti
Creati 4 file di test automatici nel folder `Test/`:
- `test_is_yes_and_offer.py`: 8 test su `is_yes()` e `offer_open_folder()`
- `test_workspace_manager.py`: 13 test su WorkspaceManager
- `test_source_importer.py`: 7 test su `ask_import()`
- `test_locale_and_workspace.py`: (file creato ma non usato nel test manuale)

Tutti i test passano: **28/28 OK**

---

## Cose rimaste aperte

### Alta priorità
- [ ] **Installer**: aggiornare InnoSetup per `settings_persistent.json` con `language_preset_from_installer=true`

### Media priorità
- [ ] Registrazione automatica di file aggiunti manualmente in `project_info.json`
- [ ] `max_backups_per_language` per lo stage `dubbed` (non ancora applicato)

### Bassa priorità
- [ ] Integrazione WhisperX (venv separato già preparato)
- [ ] Provider TTS aggiuntivi (OpenAI / HuggingFace) — credential file esistono ma non cablati

---

## Stato generale
- Pipeline completa funzionante (estrai → trascrivi → traduci → dubba)
- Tutti i test manuali passati (4/4 categorie)
- Refactor `audio_extraction` completato: una cartella per video
- Gestione errori migliorata (PermissionError, cross-project warnings)
- Test automatici: 28/28 OK
- `main` locale contiene 7 commit non pushati su origin (ultimi 5 della sessione + 2 precedenti)
- **Prossima priorità**: aggiornare installer (InnoSetup), poi push su origin

---
---

# Riepilogo sessione — 2026-05-12 (parte 3)

[contenuto precedente mantenuto per traccia storica]
