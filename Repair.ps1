#requires -Version 5.1
<# Created by Dewald Pretorius. Guarded Viva Insights repair companion. #>
[CmdletBinding()]param(
 [ValidateSet('Diagnose','ResetCache','FlushDns')][string]$Action='Diagnose',[switch]$DryRun,[switch]$Yes,
 [string]$OutputPath=(Join-Path ([Environment]::GetFolderPath('Desktop')) 'Viva_Insights_Repair'))
$ErrorActionPreference='Stop';$ExitCancelled=4;$ExitAction=5;$ExitVerify=6
$processes=@('msedge','ms-teams','OUTLOOK');$caches=@("$env:APPDATA\Microsoft\Teams\Cache","$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache")
$endpoints=@('insights.viva.office.com','outlook.office.com','login.microsoftonline.com','graph.microsoft.com')
New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null;$stamp=Get-Date -Format yyyyMMdd_HHmmss;$log=Join-Path $OutputPath "Repair_$stamp.log"
function Log($m){$l='{0:u} {1}'-f(Get-Date),$m;Write-Host $l;Add-Content $log $l}
function Confirm($m){if($Yes){$true}else{(Read-Host "$m [y/N]")-match'^(?i)y(es)?$'}}
$state=[ordered]@{Tool='Viva Insights';Action=$Action;Processes=@($processes|%{Get-Process $_ -ErrorAction SilentlyContinue|select Name,Id,Path});Caches=@($caches|%{[pscustomobject]@{Path=$_;Exists=Test-Path $_}});Endpoints=@($endpoints|%{[pscustomobject]@{Host=$_;DNS=[bool](Resolve-DnsName $_ -ErrorAction SilentlyContinue);HTTPS443=Test-NetConnection $_ -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue}})}
$state|ConvertTo-Json -Depth 6|Set-Content (Join-Path $OutputPath "PreRepair_$stamp.json") -Encoding UTF8
if($Action-eq'Diagnose'){Log '[COMPLETE] Read-only snapshot saved.';exit 0}
if($DryRun){Log "[DRY-RUN] Would perform $Action.";exit 0};if(-not(Confirm "Perform $Action for Viva Insights?")){Log '[CANCELLED] No changes made.';exit $ExitCancelled}
try{
 if($Action-eq'ResetCache'){foreach($p in $processes){Get-Process $p -ErrorAction SilentlyContinue|Stop-Process -Force};foreach($c in $caches){if(Test-Path $c){$b="$c.backup-$stamp";Move-Item $c $b -Force;New-Item -ItemType Directory $c -Force|Out-Null;Log "[BACKUP] $b"}}}
 elseif($Action-eq'FlushDns'){Clear-DnsClientCache}
}catch{Log "[FAILED] $($_.Exception.Message)";exit $ExitAction}
if($Action-eq'ResetCache' -and @($caches|?{-not(Test-Path $_)}).Count){Log '[VERIFY-FAILED] A cache folder was not recreated.';exit $ExitVerify}
Log '[COMPLETE] Repair and verification completed.';exit 0
