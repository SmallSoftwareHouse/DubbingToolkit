# ==================================================================
# INSTALLDEPENDENCIES.PS1 - DEPENDENCIES INSTALLATION FOR AUTOMATIC DUBBING
# Reads ordered package list from Config/dependencies.json.
# Installs each package one by one in the declared order.
# ==================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$DependenciesFile,   # Path to Config/dependencies.json
    [Parameter(Mandatory=$true)]
    [string]$VenvPath
)


# ==================================================================
#  1  Determine root folder. Load localization messages from settings.json
# ==================================================================

$RootFolder = Split-Path $PSScriptRoot -Parent
$LocaleFolder = Join-Path $RootFolder 'Locale'

$SettingFile = Join-Path $RootFolder 'Settings\settings.json'
$Settings = Get-Content $SettingFile -Encoding UTF8 | ConvertFrom-Json
$interface_langKey = $Settings.interface_lang

$MessagesFile = Join-Path $LocaleFolder ("Active\$interface_langKey.json")
$Messages = Get-Content $MessagesFile -Encoding UTF8 | ConvertFrom-Json

$psDir = Join-Path $RootFolder 'ps'
Import-Module (Join-Path $psDir 'Logging.psm1') -Force
Set-Messages $Messages

Write-Log "InstallDependencies_Starting"


# ==================================================================
#  2  Activate venv and pre-configure pip
# ==================================================================

& "$VenvPath\Scripts\Activate.ps1"
$env:PIP_DISABLE_PIP_VERSION_CHECK = "1"


# ==================================================================
#  3  Read packages already installed in the venv
# ==================================================================

$InstalledNowRaw = & "$VenvPath\Scripts\pip.exe" list --format=freeze
$InstalledNow = @{}
foreach ($line in $InstalledNowRaw) {
    $line = $line.Trim()
    if ($line -match '^(?<name>[^=]+)==(?<ver>.+)$') {
        $pkgNameNorm = $matches.name.ToLower() -replace '[-_]', ''
        $InstalledNow[$pkgNameNorm] = $matches.ver
    }
}


# ==================================================================
#  4  Read ordered package list from JSON
# ==================================================================

if (-not (Test-Path $DependenciesFile)) {
    Write-Log "InstallDependencies_JsonNotFound" "ERROR" @($DependenciesFile)
    exit 1
}

$DepsJson = Get-Content $DependenciesFile -Encoding UTF8 | ConvertFrom-Json


# ==================================================================
#  5  CUDA detection for PyTorch variant selection
# ==================================================================

$cudaPath = "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA"
if (Test-Path $cudaPath) {
    $TorchSuffix = '+cu121'
} else {
    $TorchSuffix = '+cpu'
}

$TorchVersion      = "2.1.0"
$TorchVisionVersion = "0.16.0"
$TorchAudioVersion  = "2.1.0"


# ==================================================================
#  6  Build install list preserving JSON order
# ==================================================================

$ToInstall = [System.Collections.Generic.List[hashtable]]::new()

foreach ($entry in $DepsJson) {

    # Resolve actual package string
    if ($entry.torch_variant) {
        switch -Wildcard ($entry.package) {
            'torch'       { $pkgFull = "torch==$TorchVersion$TorchSuffix" }
            'torchvision' { $pkgFull = "torchvision==$TorchVisionVersion$TorchSuffix" }
            'torchaudio'  { $pkgFull = "torchaudio==$TorchAudioVersion$TorchSuffix" }
            default       { $pkgFull = $entry.package }
        }
    } else {
        $pkgFull = $entry.package
    }

    # Normalize name for comparison with installed list
    $pkgParts    = $pkgFull -split "=="
    $pkgNameNorm = $pkgParts[0].ToLower() -replace '[-_]', ''
    $pkgVer      = if ($pkgParts.Count -ge 2) { $pkgParts[1] } else { $null }

    # Skip if already installed at the correct version.
    # Packages without a pinned version are always installed (no version to compare).
    if ($pkgVer -and $InstalledNow.ContainsKey($pkgNameNorm) -and $InstalledNow[$pkgNameNorm] -eq $pkgVer) {
        continue
    }

    $ToInstall.Add(@{
        Package    = $pkgFull
        Flags      = $entry.flags
        ExtraIndex = $entry.extra_index
    })
}


# ==================================================================
#  7  Install packages one by one in order
# ==================================================================

$Total = $ToInstall.Count

if ($Total -eq 0) {
    Write-Log "InstallDependencies_AllDependenciesAlreadyInstalled" "OK"
    exit 0
}

$Index = 0
foreach ($item in $ToInstall) {
    $Index++
    Write-Log "InstallingPackage" "HIGHLIGHT" @($Index, $Total, $item.Package)

    $InstallArgs = @("--disable-pip-version-check")

    # Add any per-package flags declared in JSON (e.g. --no-build-isolation)
    foreach ($flag in $item.Flags) {
        $InstallArgs += $flag
    }

    # Add extra index if declared
    if ($item.ExtraIndex) {
        $InstallArgs += "-f"
        $InstallArgs += $item.ExtraIndex
    }

    $InstallArgs += $item.Package

    & "$VenvPath\Scripts\pip.exe" install @InstallArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Log "PackageFailed" "ERROR" @($item.Package)
        exit 1
    }
}

Write-Log "DependenciesFinished" "OK"
