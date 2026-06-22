# Windows Search Repair

> **Testing note:** This was tested by me to be working. User experience may vary.

## One-click use

1. Download and extract the repository.
2. Double-click `Run-OneClick.bat`.
3. Approve the Windows administrator prompt.
4. The launcher restores, restarts and verifies the Windows Search service directly—there is no menu.
5. Review the exit code and logs in `C:\ProgramData\WindowsSearchRepair\Logs`.

Included script: `Repair-WindowsSearch.ps1`

## PowerShell usage

```powershell
.\Repair-WindowsSearch.ps1
.\Repair-WindowsSearch.ps1 -Repair
.\Repair-WindowsSearch.ps1 -Repair -WhatIf
```

The default mode records Windows Search service and process status. Repair mode sets the service to automatic, restores or restarts it, waits for the service to reach `Running`, and records the final state.

Exit codes: `0` success, `1` fatal error, `2` repair or verification warnings.

Indexing can take time to recover after a service restart. MIT License.
