# Installazione e configurazione

Questa guida copre i requisiti di sistema, la struttura delle credenziali e il processo di setup iniziale di DubbingToolkit.

---

## Requisiti di sistema

- **Sistema operativo:** Windows con PowerShell 5.1
- **Python:** incluso nel progetto — non è richiesta un'installazione di sistema
  - Attualmente viene utilizzato Python 3.11, presente nella cartella `Installation/` e gestito internamente.
- **ffmpeg:** incluso in `Tools/ffmpeg-7.1.1-full_build/` — non richiede installazione separata
- **Connessione internet:** richiesta per i moduli che accedono a risorse esterne, tra cui le API TTS (Azure, Google) e il download dei modelli di traduzione alla prima esecuzione.

---

## Credenziali TTS

Le credenziali per i provider TTS vanno inserite nella cartella `credentials/`. Attualmente i provider supportati sono Azure e Google, ciascuno con il proprio file JSON.

| File | Provider |
|---|---|
| `azure_speech_credentials.json` | Azure Cognitive Services Speech |
| `google_speech_credentials.json` | Google Cloud TTS |

Per ciascun provider è disponibile un file template con la struttura richiesta:

```
credentials/azure_speech_credentials.template.json
credentials/google_speech_credentials.template.json
```

Copiare il file template, rimuovere l'estensione `.template` e inserire le proprie credenziali nel file risultante.

---

## Ambiente virtuale e dipendenze Python

All'avvio del progetto, il Launcher gestisce automaticamente la creazione e l'attivazione dell'ambiente virtuale e l'installazione delle dipendenze. Non è richiesto alcun intervento manuale in condizioni normali.

Le dipendenze principali sono elencate in `Config/dependencies.json`.

### Reset dell'ambiente virtuale

**Reset dall'interno del progetto** (il progetto deve essere avviabile):

Selezionare l'opzione di reset dall'interfaccia oppure eseguire direttamente:
```powershell
Scripts/reset_env.ps1
```
Questo script ricrea il venv e reinstalla le dipendenze automaticamente.

**Reset manuale completo** (quando il progetto non si avvia):

Eliminare manualmente la cartella `venv/`. Al successivo avvio tramite `StartDubbing.bat`, il Launcher rileverà l'assenza del venv e lo ricreerà automaticamente.

---

## Configurazione iniziale

Le impostazioni operative del progetto sono in `Settings/`:

| File | Scopo |
|---|---|
| `settings.json` | Configurazione attiva |
| `settings_default.json` | Configurazione di riferimento (non modificare) |
| `reset.json` | Parametri di ripristino |

### Parametri principali in `settings.json`

- **`interface_lang`** — lingua dell'interfaccia (es. `"it"`, `"en"`, `"es"`)
- Impostazioni provider TTS (provider attivo, voce selezionata, lingua di destinazione)
- Parametri di trascrizione Whisper (modello, lingua)

> **Nota:** le impostazioni vengono salvate automaticamente tra una sessione e l'altra tramite `Settings/settings_persistent.json`. La lingua dell'interfaccia selezionata durante l'installazione viene applicata al primo avvio senza richiedere ulteriori interventi.

---

## Avvio e inizializzazione automatica

L'utente avvia il progetto tramite:

```
StartDubbing.bat
```

Il Launcher esegue quindi automaticamente, senza intervento dell'utente:

1. Verifica e attivazione del runtime Python locale
2. Creazione o attivazione dell'ambiente virtuale
3. Controllo delle credenziali API
4. Avvio dell'interfaccia principale

In caso di credenziali mancanti o non valide, il sistema lo segnala nel menu prima di consentire l'accesso alle funzioni TTS.
Le altre funzioni — estrazione audio, trascrizione e traduzione — non dipendono dalle credenziali e rimangono accessibili.

---

## Spostamento del progetto e disinstallazione

### Disinstallazione

Se il progetto è stato installato tramite il pacchetto di distribuzione, usare il pannello **Installazione applicazioni** di Windows oppure il disinstaller presente nella cartella di installazione.

Il disinstaller permette di scegliere cosa eliminare definitivamente:
- Credenziali e chiavi API
- Dati di fatturazione (consumo TTS mensile)
- Log di sessione
- File di lavoro (progetti, audio, video, trascrizioni)

I dati non selezionati vengono preservati. L'ambiente virtuale (`venv/`) viene sempre rimosso automaticamente.

### Spostamento

Anche se sconsigliato, il progetto può essere spostato in un'altra posizione, ma dopo ogni spostamento è necessario ricreare l'ambiente virtuale, poiché il venv contiene percorsi assoluti legati alla posizione originale. Procedura:

1. Eliminare la cartella `venv/`
2. Avviare `StartDubbing.bat` — il Launcher ricreerà il venv e reinstallerà le dipendenze