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
$warnings=New-Object System.Collections.Generic.List[string]

function Test-Admin{
    $id=[Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

try{
    if($env:OS -ne 'Windows_NT'){throw 'Windows is required.'}
    if($Repair -and -not(Test-Admin)){throw 'Run PowerShell as Administrator for repair mode.'}
    New-Item $runPath -ItemType Directory -Force|Out-Null

    Get-Service WSearch -ErrorAction Stop|Select-Object Name,Status,StartType|
        Export-Csv (Join-Path $runPath 'SearchService-Before.csv') -NoTypeInformation
    Get-Process SearchHost,SearchIndexer -ErrorAction SilentlyContinue|
        Select-Object Name,Id,CPU,WorkingSet,StartTime|
        Export-Csv (Join-Path $runPath 'SearchProcesses-Before.csv') -NoTypeInformation

    if($Repair -and $PSCmdlet.ShouldProcess('Windows Search service','Set automatic start and restore service')){
        Set-Service WSearch -StartupType Automatic -ErrorAction Stop
        $service=Get-Service WSearch -ErrorAction Stop
        if($service.Status -eq 'Running'){
            Restart-Service WSearch -Force -ErrorAction Stop
        }else{
            Start-Service WSearch -ErrorAction Stop
        }
        (Get-Service WSearch -ErrorAction Stop).WaitForStatus('Running',[TimeSpan]::FromSeconds(30))
    }

    $after=Get-Service WSearch -ErrorAction Stop
    $after|Select-Object Name,Status,StartType|
        Export-Csv (Join-Path $runPath 'SearchService-After.csv') -NoTypeInformation
    Get-Process SearchHost,SearchIndexer -ErrorAction SilentlyContinue|
        Select-Object Name,Id,CPU,WorkingSet,StartTime|
        Export-Csv (Join-Path $runPath 'SearchProcesses-After.csv') -NoTypeInformation

    if($Repair -and $after.Status -ne 'Running'){$warnings.Add('Windows Search service is not running after repair.')}
    if($Repair -and $after.StartType -eq 'Disabled'){$warnings.Add('Windows Search service remains disabled after repair.')}

    $warnings|Out-File (Join-Path $runPath 'Warnings.txt') -Encoding UTF8
    if($warnings.Count -gt 0){Write-Host "[WARN] Completed with warnings. Logs: $runPath" -ForegroundColor Yellow;exit 2}
    Write-Host "[OK] Completed. Logs: $runPath" -ForegroundColor Green
    exit 0
}catch{Write-Error $_.Exception.Message;exit 1}
