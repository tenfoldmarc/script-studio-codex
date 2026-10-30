# Script Studio quiet check (Windows). Runs on Creator Studio's own Python; sets it up through the Studio
# when it is missing, then prints the STATUS lines.
$ErrorActionPreference = 'SilentlyContinue'
$SsDir = Split-Path -Parent $PSScriptRoot
$Local = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { Join-Path $HOME 'AppData\Local' }
$StudioState = Join-Path $Local 'video-studio-codex'
if ($env:VIDEO_STUDIO_STATE -and [IO.Path]::IsPathRooted($env:VIDEO_STUDIO_STATE) -and
    ((Split-Path -Leaf $env:VIDEO_STUDIO_STATE) -match '^video-studio-codex(-.*)?$')) { $StudioState = $env:VIDEO_STUDIO_STATE }
$Plat = Join-Path $StudioState '.platform.json'

function Find-Py {
  if (-not (Test-Path $Plat)) { return $null }
  $j = Get-Content $Plat -Raw | ConvertFrom-Json
  if ($j.python -and (Test-Path $j.python)) { return $j.python }
  return $null
}

$Py = Find-Py
if (-not $Py) {
  Write-Output 'STATUS studio SETUP_REQUIRED: run the installed Creator Studio for Codex setup check, then retry.'
  exit 0
}
Write-Output "PY $Py"
& $Py (Join-Path $SsDir 'scripts\ss.py') check
