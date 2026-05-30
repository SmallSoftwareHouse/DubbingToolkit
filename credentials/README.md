# Credentials

This folder contains the API credential files required by DubbingToolkit for
Text-to-Speech synthesis. Real credential files are **never** included in the
installer — only template files are shipped.

---

> ⚠️ **SECURITY WARNING**
>
> Credential files are strictly personal and directly tied to your billing account.
> Anyone who obtains them can use the service at your expense.
>
> - Never share credential files with anyone
> - Never upload them to public repositories (GitHub, etc.)
> - Never send them via email or chat
> - If lost or compromised, revoke the key immediately from the provider portal

---

## Supported providers

| Provider | Credential file | Template |
|---|---|---|
| Azure Cognitive Services Speech | `azure_speech_credentials.json` | `azure_speech_credentials.template.json` |
| Google Cloud Text-to-Speech | `google_speech_credentials.json` | `google_speech_credentials.template.json` |

Both providers offer a **free tier** with a monthly character limit, which is
sufficient for testing and moderate use.

---

## Azure Cognitive Services Speech

### Step 1 — Create a Speech resource

1. Go to [portal.azure.com](https://portal.azure.com) and sign in
2. Click **Create a resource** and search for **Speech**
3. Select **Speech** (under Azure AI services) and click **Create**
4. Choose a subscription, resource group, region, and pricing tier (F0 = free)
5. Click **Review + Create**, then **Create**

### Step 2 — Get the credentials

1. Open the resource you just created
2. Go to **Keys and Endpoint** in the left menu
3. Copy **KEY 1** (or KEY 2 — both work)
4. Note the **Location/Region** (e.g. `westeurope`, `eastus`)

### Step 3 — Configure the file

Copy the template and fill it in:

```
credentials/azure_speech_credentials.template.json  →  azure_speech_credentials.json
```

```json
{
  "subscription": "YOUR_KEY_HERE",
  "region": "YOUR_REGION_HERE"
}
```

**Example:**
```json
{
  "subscription": "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4",
  "region": "westeurope"
}
```

> The key is 32 hexadecimal characters. The region must match exactly what
> appears in the Azure portal (lowercase, no spaces).

---

## Google Cloud Text-to-Speech

### Step 1 — Create a Google Cloud project

1. Go to [console.cloud.google.com](https://console.cloud.google.com) and sign in
2. Click the project selector at the top and choose **New Project**
3. Give it a name and click **Create**

### Step 2 — Enable the Text-to-Speech API

1. In the left menu go to **APIs & Services → Library**
2. Search for **Cloud Text-to-Speech API**
3. Click on it and press **Enable**

### Step 3 — Create a Service Account

1. Go to **IAM & Admin → Service Accounts**
2. Click **Create Service Account**
3. Give it a name (e.g. `dubbing-tts`) and click **Create and Continue**
4. Assign the role **Cloud Text-to-Speech Agent** (or **Editor** for simplicity)
5. Click **Done**

### Step 4 — Download the JSON key

1. Click on the service account you just created
2. Go to the **Keys** tab
3. Click **Add Key → Create new key**
4. Select **JSON** and click **Create**
5. A JSON file will be downloaded automatically — this is your credential file

### Step 5 — Configure the file

Rename the downloaded file to `google_speech_credentials.json` and place it
in this `credentials/` folder. The file is already in the correct format and
does not need any modifications.

> Keep the downloaded JSON file in a safe place — the private key cannot be
> recovered after creation. If lost, generate a new key from the Console.

---

## Verifying credentials

On launch, DubbingToolkit automatically checks whether the credential files
are present and valid before allowing access to TTS functions.
If a credential file is missing or invalid, the system will report it in the
menu — other functions (audio extraction, transcription, translation) remain
accessible without credentials.
