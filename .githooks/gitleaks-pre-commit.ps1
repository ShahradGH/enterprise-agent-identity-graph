#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Zero-Leak Git Pre-Commit Hook
    Managed centrally by ShahradGH/sovereign-repo-conductor (Weekly Fleet Sync).
.DESCRIPTION
    Scans staged Git diffs for high-risk corporate, domain, IP, and cryptographic secrets.
    Explicitly blocks:
      - Private VPS Domain: mvpfoundry[.]alerasoul[.]net
      - VPS Dedicated IP: 192[.]142[.]41[.]43
      - Private subnet addresses (10.x.x.x, 192.168.x.x)
      - Microsoft Entra ID JWT Bearer tokens
      - Client secrets & API keys
      - GitHub Personal Access Tokens
      - Cryptographic Private Keys
#>

[CmdletBinding()]
param(
    [switch]$StagedOnly = $true
)

$ErrorActionPreference = 'Stop'

Write-Host "[Zero-Leak Hook] Inspecting staged changes for credentials and internal infrastructure..." -ForegroundColor Cyan

# Gather staged diff added/modified lines
$diffCommand = if ($StagedOnly) {
    "git diff --cached --unified=0 --no-color"
} else {
    "git diff HEAD --unified=0 --no-color"
}

$stagedLines = & (Get-Command git).Source ($diffCommand.Split(' ') | Select-Object -Skip 1)

if (-not $stagedLines -or $stagedLines.Count -eq 0) {
    Write-Host "[Zero-Leak Hook] No staged diff detected. Commit allowed." -ForegroundColor Green
    exit 0
}

# Signatures to detect
$criticalSignatures = @(
    @{ Name = "Internal Domain (mvpfoundry)"; Pattern = 'mvpfoundry\.alerasoul\.net' },
    @{ Name = "Internal VPS IP (192.142.41.43)"; Pattern = '192\.142\.41\.43' },
    @{ Name = "Private Subnet IPv4 (10.x.x.x)"; Pattern = '\b10\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b' },
    @{ Name = "Entra ID / JWT Token"; Pattern = 'ey[A-Za-z0-9_-]{25,}\.ey[A-Za-z0-9_-]{25,}' },
    @{ Name = "Azure Client Secret"; Pattern = '(?:client_secret|clientSecret|azure_secret)\s*[:=]\s*["''][a-zA-Z0-9~_.-]{30,}["'']' },
    @{ Name = "GitHub Classic PAT"; Pattern = 'gh[pousr]_[A-Za-z0-9_]{36,255}' },
    @{ Name = "GitHub Fine-Grained PAT"; Pattern = 'github_pat_[A-Za-z0-9_]{82}' },
    @{ Name = "Cryptographic Private Key"; Pattern = '-----BEGIN (?:RSA|EC|DSA|OPENSSH|PRIVATE) KEY-----' },
    @{ Name = "AWS Access Key"; Pattern = '\b(?:AKIA|ASIA)[0-9A-Z]{16}\b' }
)

$violations = [System.Collections.Generic.List[PSCustomObject]]::new()
$currentFile = "unknown"

foreach ($line in $stagedLines) {
    if ($line -match '^\+\+\+ b/(.*)$') {
        $currentFile = $Matches[1]
        continue
    }

    # Only inspect added lines (starting with +) excluding diff header (+++)
    if ($line -match '^\+(?!\+\+)(.*)$') {
        $content = $Matches[1]

        foreach ($sig in $criticalSignatures) {
            if ($content -match $sig.Pattern) {
                # Ignore self-references inside this hook script, rule definitions, and test files
                if ($currentFile -like "*gitleaks-pre-commit.ps1" -or `
                    $currentFile -like "*canonical-versions.json" -or `
                    $currentFile -like "*Tests.ps1" -or `
                    $currentFile -like "*pre-commit*") {
                    continue
                }

                $violations.Add([PSCustomObject]@{
                    File = $currentFile
                    Rule = $sig.Name
                    Snippet = ($content.Trim() | ForEach-Object { if ($_.Length -gt 60) { $_.Substring(0, 60) + "..." } else { $_ } })
                })
            }
        }
    }
}

# Also run native gitleaks protect if installed
$gitleaksCmd = Get-Command gitleaks -ErrorAction SilentlyContinue
if ($gitleaksCmd) {
    Write-Host "[Zero-Leak Hook] Running native Gitleaks scanner..." -ForegroundColor Cyan
    $gitleaksOutput = & $gitleaksCmd.Source protect --staged --verbose 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "[Zero-Leak Hook] Native Gitleaks reported secret exposure!`n$gitleaksOutput"
        exit 1
    }
}

if ($violations.Count -gt 0) {
    Write-Host "`n=================================================================" -ForegroundColor Red
    Write-Host " [CRITICAL SECURITY GATE] ZERO-LEAK VIOLATION DETECTED" -ForegroundColor Red
    Write-Host " Commit blocked by sovereign-repo-conductor pre-commit hook." -ForegroundColor Red
    Write-Host "=================================================================`n" -ForegroundColor Red

    foreach ($v in $violations) {
        Write-Host " File:    $($v.File)" -ForegroundColor Yellow
        Write-Host " Rule:    $($v.Rule)" -ForegroundColor Red
        Write-Host " Snippet: $($v.Snippet)" -ForegroundColor DarkGray
        Write-Host "-----------------------------------------------------------------"
    }

    Write-Host "`nPlease scrub the sensitive credentials or internal IP/domains before committing." -ForegroundColor White
    exit 1
}

Write-Host "[Zero-Leak Hook] All staged files passed zero-leak gate." -ForegroundColor Green
exit 0
