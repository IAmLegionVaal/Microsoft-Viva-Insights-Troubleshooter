# Microsoft Viva Insights Troubleshooter

PowerShell 5.1 diagnostics and guarded local repair tooling created by **Dewald Pretorius**.

`Troubleshooter.ps1` collects the original application evidence. `Repair.ps1` adds `Diagnose`, `ResetCache`, and `FlushDns` actions. Diagnosis is read-only. Cache repair stops Outlook, Teams, and Edge processes, moves the relevant caches to timestamped backup folders, recreates clean cache paths, logs all work, and verifies the result.

```powershell
.\Troubleshooter.ps1
.\Repair.ps1 -Action Diagnose
.\Repair.ps1 -Action ResetCache -DryRun
.\Repair.ps1 -Action ResetCache -Yes
```

Mutating actions require confirmation unless `-Yes` is supplied. Exit codes are `0` success, `4` cancelled, `5` action failure, and `6` verification failure. The workflow is source-reviewed but has not been runtime-tested against every Microsoft 365 tenant or client build.
