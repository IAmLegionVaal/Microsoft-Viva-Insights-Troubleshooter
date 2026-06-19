#requires -Version 5.1
<# Created by Dewald Pretorius #>
param([string]$OutputPath)
if(-not $OutputPath){$OutputPath="$([Environment]::GetFolderPath('Desktop'))\Viva_Insights_Reports"};New-Item $OutputPath -ItemType Directory -Force|Out-Null
$targets='insights.viva.office.com','outlook.office.com','login.microsoftonline.com','graph.microsoft.com';$net=foreach($t in $targets){[pscustomobject]@{Target=$t;HTTPS443=(Test-NetConnection $t -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue)}}
@('MICROSOFT VIVA INSIGHTS TROUBLESHOOTER','Created by Dewald Pretorius',"Generated: $(Get-Date)",($net|Format-Table -AutoSize|Out-String -Width 220),'Guidance: verify licence, mailbox eligibility, privacy settings, add-in deployment, data availability, time zone, organizational policy, and service health.')|Set-Content (Join-Path $OutputPath 'Report.txt') -Encoding UTF8