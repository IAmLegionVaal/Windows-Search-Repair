# Windows Search Repair

> **Testing note:** This was tested by me to be working. User experience may vary.

Included script: `Repair-WindowsSearch.ps1`

```powershell
.\Repair-WindowsSearch.ps1
.\Repair-WindowsSearch.ps1 -Repair
.\Repair-WindowsSearch.ps1 -Repair -WhatIf
```

The default mode records Windows Search service and process status. Repair mode requires administrator rights, sets the Search service to automatic, restores or restarts it, waits for the service to reach `Running`, and records the final service and process state.

Logs: `C:\ProgramData\WindowsSearchRepair\Logs`

Exit codes: `0` success, `1` fatal error, `2` repair or verification warnings.

Use at your own risk. Indexing can take time to recover after a service restart.

MIT License.
