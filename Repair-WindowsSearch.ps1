<#
.SYNOPSIS
Checks and repairs the Windows Search service.
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [switch]$Repair,
    [string]$LogRoot="$env:ProgramData\WindowsSearchRepair\Logs"
)

Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
$runPath=Join-Path $LogRoot (Get-Date -Format 'yyyyMMdd_HHmmss')

function Test-Admin{
    $id=[Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

try{
    if($env:OS -ne 'Windows_NT'){throw 'Windows is required.'}
    if($Repair -and -not(Test-Admin)){throw 'Run PowerShell as Administrator for repair mode.'}
    New-Item $runPath -ItemType Directory -Force|Out-Null

    Get-Service WSearch|Select-Object Name,Status,StartType|
        Export-Csv (Join-Path $runPath 'SearchService-Before.csv') -NoTypeInformation
    Get-Process SearchHost,SearchIndexer -ErrorAction SilentlyContinue|
        Select-Object Name,Id,CPU,WorkingSet,StartTime|
        Export-Csv (Join-Path $runPath 'SearchProcesses.csv') -NoTypeInformation

    if($Repair -and $PSCmdlet.ShouldProcess('Windows Search service','Set automatic start and restart')){
        Set-Service WSearch -StartupType Automatic
        Restart-Service WSearch -Force
    }

    Get-Service WSearch|Select-Object Name,Status,StartType|
        Export-Csv (Join-Path $runPath 'SearchService-After.csv') -NoTypeInformation
    Write-Host "[OK] Completed. Logs: $runPath" -ForegroundColor Green
    exit 0
}catch{Write-Error $_.Exception.Message;exit 1}
