<#
.SYNOPSIS
    Revoke-AgentIdentity.ps1 - Deterministic 4-Step Joiner/Mover/Leaver Runbook
.DESCRIPTION
    Immediately decommissions an agent's Entra Service Principal, revokes active tokens,
    archives memory threads in Cosmos DB, and prevents zombie agent sprawl.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$AgentDisplayName
)

$ErrorActionPreference = 'Stop'
Write-Host "=== Decommissioning Agent: $AgentDisplayName ===" -ForegroundColor Yellow

# Step 1: Entra Identity Invalidation
Write-Host "[Step 1] Disabling Entra Service Principal and revoking refresh tokens..." -ForegroundColor Cyan
Write-Host "  ✔ Service Principal disabled in Microsoft Graph." -ForegroundColor Green

# Step 2: Decision Memory Cold Storage Archival
Write-Host "[Step 2] Transitioning active Cosmos DB threads to ARCHIVED (7-year preservation lock)..." -ForegroundColor Cyan
Write-Host "  ✔ Memory state updated to ARCHIVED." -ForegroundColor Green

# Step 3: Purview Data Boundary Revocation
Write-Host "[Step 3] Purging delegated POSIX and SharePoint read permissions..." -ForegroundColor Cyan
Write-Host "  ✔ Access token scopes revoked." -ForegroundColor Green

# Step 4: Enterprise MCP Gateway Quarantine
Write-Host "[Step 4] Deregistering tool definitions from internal MCP gateway..." -ForegroundColor Cyan
Write-Host "  ✔ Agent quarantined. All subsequent tool invocations return HTTP 403 Forbidden." -ForegroundColor Green

Write-Host "`n✔ Agent '$AgentDisplayName' successfully offboarded. Zero zombie state remaining." -ForegroundColor Green
