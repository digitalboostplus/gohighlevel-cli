# GHL CLI PowerShell wrapper
# Loads Brain/.env, maps canonical CLI vars, and forwards all args to ghl.exe.
# Usage: .\ghl.ps1 contacts list --limit 5
# CARIV:  .\ghl.ps1 --location-id ewas9FYYHk4acPyw4taq contacts list (set GHL_API_KEY=$env:CARIV_PIT_KEY first)
param([Parameter(ValueFromRemainingArguments=$true)] $passThrough)

$ghlExe = "$PSScriptRoot\.venv\Scripts\ghl.exe"
$brainEnv = (Resolve-Path "$PSScriptRoot\..\.." -ErrorAction SilentlyContinue)?.Path
if (-not $brainEnv) { $brainEnv = "$PSScriptRoot\..\.." }
$envFile = Join-Path $brainEnv ".env"

if (Test-Path $envFile) {
    Get-Content $envFile | Where-Object { $_ -match '^[A-Za-z_][A-Za-z0-9_]*=' -and $_ -notmatch '^\s*#' } | ForEach-Object {
        $key, $val = $_ -split '=', 2
        [System.Environment]::SetEnvironmentVariable($key.Trim(), $val.Trim(), 'Process')
    }
}

if (-not $env:GHL_API_KEY -and $env:GHL_PIT_API_KEY) { $env:GHL_API_KEY = $env:GHL_PIT_API_KEY }
if (-not $env:GHL_LOCATION_ID -and $env:dtxent_locationID) { $env:GHL_LOCATION_ID = $env:dtxent_locationID }

& $ghlExe @passThrough
