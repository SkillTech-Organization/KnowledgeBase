# Beállítások

$subscriptionId = "702fab27-7b08-4bcd-a29e-4c15e902dca2"
$azureAplicationId ="4c016de3-1c7e-4112-afd4-8431b5a6acf7"
$azureTenantId = "8875ae16-2b24-4357-95a4-62e9df84fe06"
$clientSecret = "ms08Q~7COdWlM9Vc~_Cct3cgcU645E-VOvh-XavR"
$resourceGroupName = "mplastwebdev"
$azurePassword = ConvertTo-SecureString $clientSecret -AsPlainText -Force

$location = "westeurope"  # Azure régió
$automationAccount = "mplastwebdevrunbookstart"
$runbookName = "mplastwebdevstartautomation"
$automationRunbookDescription = "mplastwebdevstartrunbook"

$scheduleName = "mplastwebdevDailyStart_Mon-Fri_at_08h"
$StartTime = (Get-Date "08:00:00").AddDays(1)
[System.DayOfWeek[]]$WeekDays = @([System.DayOfWeek]::Monday..[System.DayOfWeek]::Friday)
$automationScheduleDescription = "Runs runbook from Mon-Fri at 08:00 - start mplastwebdev"
$timeZone = "Europe/Budapest"

$psCred = New-Object System.Management.Automation.PSCredential($azureAplicationId , $azurePassword)
Write-Output "Set Azure pwd... - 2"

Connect-AzAccount -Credential $psCred -TenantId $azureTenantId -ServicePrincipal -Subscription $subscriptionId
Write-Output "Set credential... - 3"

# Automation Account létrehozása
New-AzAutomationAccount -ResourceGroupName $resourceGroupName -Name $automationAccount -Location $location -Plan Basic

# upload code
$runbookCode = @"
param(
    [string]`$webAppName,
    [string]`$resourceGroupName,
	[string]`$AppServicePlanName,
	[string]`$scalingTierName,
	
)

Connect-AzAccount -Identity
Stop-AzWebApp -Name `$webAppName -ResourceGroupName `$resourceGroupName
Write-Output "WebApp leállítva: `$webAppName"

Set-AzAppServicePlan -Name $appServicePlanName -ResourceGroupName $resourceGroupName -Tier $scalingTierName
Write-Output "Set AppServicePlan to $scalingTierName... - 4"

Set-AzWebApp -AppServicePlan $appServicePlanName -AlwaysOn $true -ResourceGroupName $resourceGroupName -Name $webAppName
Write-Output "Set AppServicePlan WebApp AlwaysOn $true... - 5"

Start-AzWebApp -Name $webAppName -ResourceGroupName $resourceGroupName
Write-Output "Start the WebApp: $webAppName... - 6"
"@

# Ellenőrzés, hogy létezik-e
$runbook = Get-AzAutomationRunbook -AutomationAccountName $automationAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $runbookName -ErrorAction SilentlyContinue

if ($runbook) {
    Write-Host "Existing runbook: $runbookName" -ForegroundColor Yellow
} else {
    Write-Host "Runbook doesn't exist, creating...: $runbookName" -ForegroundColor Red
	New-AzAutomationRunbook -AutomationAccountName $automationAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $runbookName `
	-Type PowerShell `
	-Description $automationRunbookDescription
}


# # Runbook tartalom feltöltése
Import-AzAutomationRunbook -AutomationAccountName $automationAccount `
       -Name $runbookName `
	   -Path .\mplastwebdev_start.ps1 `
	   -Published `
	   -ResourceGroupName $resourceGroupName `
	   -Type PowerShell `
	   -Force


# define the schedule
# handle safety way
New-AzAutomationSchedule -AutomationAccountName $automationAccount `
    -Name $scheduleName `
	-StartTime $StartTime `
	-WeekInterval 1 `
	-DaysOfWeek $WeekDays `
	-ResourceGroupName $resourceGroupName `
	-Description $automationScheduleDescription `
	-TimeZone $timeZone


# Ütemezés hozzárendelése a Runbook-hoz
Register-AzAutomationScheduledRunbook -AutomationAccountName $automationAccount `
    -ResourceGroupName $resourceGroupName `
    -RunbookName $runbookName `
    -ScheduleName $scheduleName 

