# Create infrastruture items to Azure Automation and shceduled start and stop script
# ============================================================================================
Write-Host ":: STARTING..." -ForegroundColor Yellow

# Változók beállítása
$azureTenantId = "8875ae16-2b24-4357-95a4-62e9df84fe06"
$subscriptionId = "702fab27-7b08-4bcd-a29e-4c15e902dca2"
$resourceGroupName = "mplastwebtest"
$automationAccountName = "mplastwebtest-AutomationAccount-20250317" # "mplastwebtest-AutomationAccount-20250318"
$startRunbookName = "mplastwebtest_start_automation_job"
$startRunBookDescription = "mplastwebtest start automation job"
$startRunBookFilePath = "..\common\mplastwebtest_start.ps1"
$stopRunbookName = "mplastwebtest_stop_automation_job"
$stopRunBookDescription = "mplastwebtest stop automation job"
$stopRunBookFilePath = "..\common\mplastwebtest_stop.ps1"
$location = "southcentralus" # Az Azure régió - westeurope

$environment = "Production"
$appServicePlanName = "mplastwebtestappserviceplan"
$startScalingTierName = "Basic"
$startScalingWorkerSize = "Small"
$stopScalingTierName = "Free"
$stopScalingWorkerSize = "Small"

$startRunBookScheduleName = "mplastwebtest_Daily_Start_Mon-Fri_at_08h_HU"
$startRunBookStartTime = (Get-Date "08:00:00").AddDays(1)
$timeZone = "Europe/Budapest"
[System.DayOfWeek[]]$weekDays = @([System.DayOfWeek]::Monday..[System.DayOfWeek]::Friday)
$startRunBookAutomationScheduleDescription = "Runs runbook from Mon-Fri at 08:00 - start mplastwebtest"
$stopRunBookScheduleName = "mplastwebtest_Daily_Stop_Mon-Fri_at_20h_HU"
$stopRunBookStartTime = (Get-Date "20:0:00").AddDays(1)
$stopRunBookAutomationScheduleDescription = "Runs runbook from Mon-Fri at 20:00 - stop mplastwebtest"

# A webapp adatai
$webAppName = "mplastwebtest"
# ##########################################################################################################
Connect-AzAccount #-TenantId $azureTenantId -Subscription $subscriptionId
# Set the subscription context
Set-AzContext -SubscriptionId $subscriptionId
Write-Host ":: Success login to Azure: tenant: $azureTenantId, subscription: $SubscriptionId" -ForegroundColor Yellow

# 2. Hozzuk létre az Automation Account-ot
$automationAccount = Get-AzAutomationAccount -ResourceGroupName $resourceGroupName -Name $automationAccountName -ErrorAction SilentlyContinue
if (-not $automationAccount) {
    New-AzAutomationAccount -ResourceGroupName $resourceGroupName -Name $automationAccountName -Location $location -AssignSystemIdentity
    Write-Host ":: Automation Account created: $automationAccountName" -ForegroundColor Yellow
}

# 3. Hozzuk létre a változókat az Automation Account-ban
# Változók létrehozási függvény
function Create-AutomationVariable {
    param (
        [string]$Name,
        [object]$Value,
        [bool]$Encrypted = $false
    )
    
    $existingVariable = Get-AzAutomationVariable -ResourceGroupName $resourceGroupName `
	                        -AutomationAccountName $automationAccountName `
							-Name $Name `
							-ErrorAction SilentlyContinue
    
    if ($existingVariable) {
        Set-AzAutomationVariable -ResourceGroupName $resourceGroupName `
		    -AutomationAccountName $automationAccountName `
			-Name $Name `
			-Value $Value `
			-Encrypted $Encrypted
        Write-Host ":: Variable updated: $Name" -ForegroundColor Green
    } else {
        New-AzAutomationVariable -ResourceGroupName $resourceGroupName `
			-AutomationAccountName $automationAccountName `
			-Name $Name `
			-Value $Value `
			-Encrypted $Encrypted
        Write-Host ":: Variable created: $Name" -ForegroundColor Yellow
    }
}

# Hozzuk létre a szükséges változókat
Create-AutomationVariable -Name "webAppName" -Value $webAppName -Encrypted $false
Create-AutomationVariable -Name "resourceGroupName" -Value $resourceGroupName -Encrypted $false
Create-AutomationVariable -Name "environment" -Value $environment -Encrypted $false
Create-AutomationVariable -Name "appServicePlanName" -Value $appServicePlanName -Encrypted $false
Create-AutomationVariable -Name "startScalingTierName" -Value $startScalingTierName -Encrypted $false
Create-AutomationVariable -Name "startScalingWorkerSize" -Value $startScalingWorkerSize -Encrypted $false
Create-AutomationVariable -Name "stopScalingTierName" -Value $stopScalingTierName -Encrypted $false
Create-AutomationVariable -Name "stopScalingWorkerSize" -Value $stopScalingWorkerSize -Encrypted $false
Create-AutomationVariable -Name "subscriptionId" -Value $subscriptionId -Encrypted $false

if ([string]::IsNullOrEmpty($subscriptionId)) {
    $subscriptionId = Get-AutomationVariable -Name "subscriptionId"
}

#Create-AutomationVariable -Name "AdminEmail" -Value "admin@contoso.com" -Encrypted $false

# Függvény a Runbook létrehozásához vagy frissítéséhez
function Create-AutomationRunbook {
    param (
        [string]$Name,
        [string]$Path,
        [string]$Description = ""
    )
    
	Write-Host ":: runbookName: $Name" -ForegroundColor Blue
	
    $runbookExists = Get-AzAutomationRunbook -ResourceGroupName $resourceGroupName `
	                     -AutomationAccountName $automationAccountName `
						 -Name $Name `
						 -ErrorAction SilentlyContinue
    
    if ($runbookExists) {
        Write-Host ":: The runbook is existing...: $Name" -ForegroundColor Yellow
    } else {
		New-AzAutomationRunbook -AutomationAccountName $automationAccountName `
			-ResourceGroupName $resourceGroupName `
			-Name $Name `
			-Type PowerShell `
			-Description $automationRunbookDescription
		Write-Host ":: The runbook created: $Name" -ForegroundColor Red
    }
	Import-AzAutomationRunbook -ResourceGroupName $resourceGroupName `
	       -AutomationAccountName $automationAccountName `
		   -Name $Name `
		   -Type PowerShell `
		   -Force `
		   -Path $Path `
		   -Description $Description `
		   -Published
    Write-Host ":: The runbook updated: $Name" -ForegroundColor Green
}

Create-AutomationRunbook -Name $startRunbookName -Path $startRunBookFilePath -Description $startRunBookDescription
Create-AutomationRunbook -Name $stopRunbookName -Path $stopRunBookFilePath -Description $stopRunBookDescription

# TODO: create function
function Create-AutomationRunbookScheduleAndConnect {
    param (
	    [string]$AutomationAccountName,
        [string]$Name,
        [string]$StartTime,
        [string]$Description = "",
		[string]$RunbookName
    )
	
	Write-Host ":: Creating new automation schedule $Name..." -ForegroundColor Green
    New-AzAutomationSchedule -AutomationAccountName $AutomationAccountName `
		-Name $Name `
		-StartTime $StartTime `
		-WeekInterval 1 `
		-DaysOfWeek $weekDays `
		-ResourceGroupName $resourceGroupName `
		-Description $Description `
		-TimeZone $timeZone

# Ütemezés hozzárendelése a Runbook-hoz
# TODO handle safety way
	Write-Host ":: Register automation schedule $Name to $RunbookName" -ForegroundColor Green
	Register-AzAutomationScheduledRunbook -AutomationAccountName $AutomationAccountName `
		-ResourceGroupName $resourceGroupName `
		-RunbookName $RunbookName `
		-ScheduleName $Name 
}

Create-AutomationRunbookScheduleAndConnect -AutomationAccountName $automationAccountName `
	   -Name $startRunBookScheduleName `
       -StartTime $startRunBookStartTime `
	   -Description $startRunBookAutomationScheduleDescription `
	   -RunbookName $startRunbookName
Create-AutomationRunbookScheduleAndConnect -AutomationAccountName $automationAccountName `
	   -Name $stopRunBookScheduleName `
       -StartTime $stopRunBookStartTime `
	   -Description $stopRunBookAutomationScheduleDescription `
	   -RunbookName $stopRunbookName

exit

# TODO handle safety way
Write-Host ":: Creating new automation schedule $startRunBookScheduleName..." -ForegroundColor Green
New-AzAutomationSchedule -AutomationAccountName $automationAccountName `
    -Name $startRunBookScheduleName `
	-StartTime $startRunBookStartTime `
	-WeekInterval 1 `
	-DaysOfWeek $weekDays `
	-ResourceGroupName $resourceGroupName `
	-Description $startRunBookAutomationScheduleDescription `
	-TimeZone $timeZone

# Ütemezés hozzárendelése a Runbook-hoz
# TODO handle safety way
Write-Host ":: Creating new automation schedule $startRunBookScheduleName..." -ForegroundColor Green
Register-AzAutomationScheduledRunbook -AutomationAccountName $automationAccountName `
    -ResourceGroupName $resourceGroupName `
    -RunbookName $startRunbookName `
    -ScheduleName $startRunBookScheduleName 
	
# #####

Write-Host ":: Creating new automation schedule $stopRunBookScheduleName..." -ForegroundColor Green
New-AzAutomationSchedule -AutomationAccountName $automationAccountName `
    -Name $stopRunBookScheduleName `
	-StartTime $stopRunBookStartTime `
	-WeekInterval 1 `
	-DaysOfWeek $weekDays `
	-ResourceGroupName $resourceGroupName `
	-Description $stopRunBookAutomationScheduleDescription `
	-TimeZone $timeZone

# Ütemezés hozzárendelése a Runbook-hoz
# TODO handle safety way
Write-Host ":: Creating new automation schedule $stopRunBookScheduleName..." -ForegroundColor Green
Register-AzAutomationScheduledRunbook -AutomationAccountName $automationAccountName `
    -ResourceGroupName $resourceGroupName `
    -RunbookName $stopRunbookName `
    -ScheduleName $stopRunBookScheduleName 
	
	
exit

# ==========================================
# Parameters to Connect-AzAccount
$subscriptionId = "702fab27-7b08-4bcd-a29e-4c15e902dca2"
$azureAplicationId ="4c016de3-1c7e-4112-afd4-8431b5a6acf7"
$azureTenantId = "8875ae16-2b24-4357-95a4-62e9df84fe06"
$clientSecret = "ms08Q~7COdWlM9Vc~_Cct3cgcU645E-VOvh-XavR"

Write-Host ":: Set Azure pwd... - 2" -ForegroundColor Yellow
$azurepassword = ConvertTo-SecureString $clientSecret -AsPlainText -Force
$resourceGroupName = "mplastwebdev"

# Parameters to Azure automation account
$location = "westeurope"  # Azure region
$automationAccountName = "mplastwebdevrunbookstart"
$runbookName = "mplastwebdevstartautomation"
$automationRunbookDescription = "mplastwebdevstartrunbook"

# Parameters to schedule runbook
$scheduleName = "mplastwebdev_Daily_Start_Mon-Fri_at_08h_HU"
$StartTime = (Get-Date "20:50:00")#.AddDays(1)
$timeZone = "Europe/Budapest"
[System.DayOfWeek[]]$WeekDays = @([System.DayOfWeek]::Monday..[System.DayOfWeek]::Friday)
$automationScheduleDescription = "Runs runbook from Mon-Fri at 08:00 - start mplastwebdev"
# ============================================================================================
Write-Host ":: Set credential... - 3" -ForegroundColor Yellow
$psCred = New-Object System.Management.Automation.PSCredential($azureAplicationId , $azurePassword)

Write-Host ":: Login to Azure... - 4" -ForegroundColor Yellow
Connect-AzAccount -Credential $psCred -TenantId $azureTenantId -ServicePrincipal -Subscription $subscriptionId

# Automation Account létrehozása
Write-Host ":: Creating Automation Account $automationAccountName... - 5" -ForegroundColor Green
New-AzAutomationAccount -ResourceGroupName $resourceGroupName -Name $automationAccountName -Location $location -Plan Basic

# Ellenőrzés, hogy létezik-e
$runbook = Get-AzAutomationRunbook -AutomationAccountName $automationAccountName `
    -ResourceGroupName $resourceGroupName `
    -Name $runbookName -ErrorAction SilentlyContinue

if ($runbook) {
    Write-Host "Existing runbook: $runbookName - 6" -ForegroundColor Yellow
} else {
    Write-Host "Runbook doesn't exist, creating...: $runbookName - 6" -ForegroundColor Green
	New-AzAutomationRunbook -AutomationAccountName $automationAccountName `
    -ResourceGroupName $resourceGroupName `
    -Name $runbookName `
	-Type PowerShell `
	-Description $automationRunbookDescription
}


# # Runbook tartalom feltöltése
# TODO handle safety way
Write-Host ":: Import Automation runbook $runbookName... - 7" -ForegroundColor Green
Import-AzAutomationRunbook -AutomationAccountName $automationAccountName `
       -Name $runbookName `
	   -Path .\mplastwebdev_start.ps1 `
	   -Published `
	   -ResourceGroupName $resourceGroupName `
	   -Type PowerShell `
	   -Force


# define the schedule
# TODO handle safety way
Write-Host ":: Creating new automation schedule $scheduleName... - 8" -ForegroundColor Green
New-AzAutomationSchedule -AutomationAccountName $automationAccountName `
    -Name $scheduleName `
	-StartTime $StartTime `
	-WeekInterval 1 `
	-DaysOfWeek $WeekDays `
	-ResourceGroupName $resourceGroupName `
	-Description $automationScheduleDescription `
	-TimeZone $timeZone


# Ütemezés hozzárendelése a Runbook-hoz
# TODO handle safety way
Write-Host ":: Creating new automation schedule $scheduleName... - 9" -ForegroundColor Green
Register-AzAutomationScheduledRunbook -AutomationAccountName $automationAccountName `
    -ResourceGroupName $resourceGroupName `
    -RunbookName $runbookName `
    -ScheduleName $scheduleName 

Write-Host ":: End... - 10" -ForegroundColor Yellow
