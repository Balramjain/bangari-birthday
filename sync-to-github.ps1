param(
  [string]$RepoUrl = "https://github.com/Balramjain/bangari-birthday.git",
  [string]$Branch = "main",
  [string]$TargetSubdir = "pengu-birthday",
  [string]$CommitMessage = ""
)

$ErrorActionPreference = "Stop"

function Require-Tool([string]$name) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
    throw "Required tool not found: $name"
  }
}

Require-Tool git
Require-Tool robocopy

function Run-Git {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Args
  )
  & git @Args
  if ($LASTEXITCODE -ne 0) {
    throw "git $($Args -join ' ') failed with exit code $LASTEXITCODE"
  }
}

$sourceDir = (Get-Location).Path
$tempRoot = Join-Path $env:TEMP ("pengu-sync-" + [Guid]::NewGuid().ToString("N"))
$cloneDir = Join-Path $tempRoot "repo"

Write-Host "Cloning $RepoUrl ($Branch) ..."
Run-Git -Args @("clone", "--branch", $Branch, "--single-branch", $RepoUrl, $cloneDir)

$targetDir = Join-Path $cloneDir $TargetSubdir
if (-not (Test-Path $targetDir)) {
  New-Item -ItemType Directory -Path $targetDir | Out-Null
}

Write-Host "Mirroring local folder -> $TargetSubdir ..."
# /MIR keeps add/edit/delete in sync. Exclude local git metadata.
robocopy $sourceDir $targetDir /MIR /XD ".git" | Out-Null
$rc = $LASTEXITCODE
if ($rc -ge 8) {
  throw "robocopy failed with exit code $rc"
}

Push-Location $cloneDir
try {
  Run-Git -Args @("add", "-A")
  $hasChanges = (& git status --porcelain)
  if (-not $hasChanges) {
    Write-Host "No changes to push."
    exit 0
  }

  if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
    $CommitMessage = "Sync pengu-birthday " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
  }

  Run-Git -Args @("commit", "-m", $CommitMessage)
  Write-Host "Pushing to origin/$Branch ..."
  Run-Git -Args @("push", "origin", $Branch)
  Write-Host "Sync complete."
}
finally {
  Pop-Location
}

try {
  Remove-Item -Recurse -Force $tempRoot
}
catch {
  Write-Warning "Could not clean temp folder: $tempRoot"
}
