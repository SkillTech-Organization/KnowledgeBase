param(
    [Parameter(Mandatory = $false)]
    [string]$webAppName,
    
    [Parameter(Mandatory = $false)]
    [string]$resourceGroupName,
    
    [Parameter(Mandatory = $false)]
    [string]$environment,
	
	[Parameter(Mandatory = $false)]
    [string]$appServicePlanName,
	
	[Parameter(Mandatory = $false)]
    [string]$startScalingTierName,
	
	[Parameter(Mandatory = $false)]
    [string]$startScalingWorkerSize,
	
	[Parameter(Mandatory = $false)]
    [string]$subscriptionId
)

# Ha nincs megadva paraméter, olvassuk be a változókból
if ([string]::IsNullOrEmpty($webAppName)) {
    $webAppName = Get-AutomationVariable -Name "webAppName"
}

if ([string]::IsNullOrEmpty($resourceGroupName)) {
    $resourceGroupName = Get-AutomationVariable -Name "resourceGroupName"
}

if ([string]::IsNullOrEmpty($environment)) {
    $environment = Get-AutomationVariable -Name "environment"
}

if ([string]::IsNullOrEmpty($appServicePlanName)) {
    $appServicePlanName = Get-AutomationVariable -Name "appServicePlanName"
}

if ([string]::IsNullOrEmpty($startScalingTierName)) {
    $startScalingTierName = Get-AutomationVariable -Name "startScalingTierName"
}

if ([string]::IsNullOrEmpty($startScalingWorkerSize)) {
    $startScalingWorkerSize = Get-AutomationVariable -Name "startScalingWorkerSize"
}

if ([string]::IsNullOrEmpty($subscriptionId)) {
    $subscriptionId = Get-AutomationVariable -Name "subscriptionId"
}

Write-Output "$webAppName"
Write-Output "$subscriptionId"
Write-Output "$appServicePlanName"
Write-Output "$startScalingTierName"
Write-Output "$startScalingWorkerSize"

try {
	Connect-AzAccount -Identity
	Write-Output ":: Success login to Azure: $SubscriptionId"
	
	Write-Output ":: Proceed changes on the $environment environment!"
	
	Set-AzAppServicePlan -Name $appServicePlanName -ResourceGroupName $resourceGroupName -Tier $startScalingTierName -WorkerSize $startScalingWorkerSize
    Write-Output  ":: Set AppServicePlan to $startScalingTierName..."

    Set-AzWebApp -AppServicePlan $appServicePlanName -AlwaysOn $true -ResourceGroupName $resourceGroupName -Name $webAppName
    Write-Output  ":: Set AppServicePlan WebApp AlwaysOn $true..."

    Start-AzWebApp -Name $webAppName -ResourceGroupName $resourceGroupName
    Write-Output  ":: Start the WebApp: $webAppName..."
    
    # # Email küldése az adminisztrátornak (opcionális)
    # $adminEmail = Get-AutomationVariable -Name "AdminEmail"
    # # Itt implementálhatod az email küldést (pl. Send-MailMessage vagy egyéb megoldással)
    
} catch {
    Write-Error ":: ERROR during $WebApp starting: $_"
    throw $_
}