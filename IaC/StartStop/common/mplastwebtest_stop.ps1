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
    [string]$stopScalingTierName,
	
	[Parameter(Mandatory = $false)]
    [string]$stopScalingWorkerSize,
	
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

if ([string]::IsNullOrEmpty($stopScalingTierName)) {
    $stopScalingTierName = Get-AutomationVariable -Name "stopScalingTierName"
}

if ([string]::IsNullOrEmpty($stopScalingWorkerSize)) {
    $stopScalingWorkerSize = Get-AutomationVariable -Name "stopScalingWorkerSize"
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
	
	Stop-AzWebApp -Name $webAppName -ResourceGroupName $resourceGroupName
    Write-Output ":: Stop the WebApp: $webAppName..."
	
	Set-AzWebApp -AppServicePlan $appServicePlanName -AlwaysOn $false -ResourceGroupName $resourceGroupName -Name $webAppName
    Write-Output ":: Set AppServicePlan: $appServicePlanName webapp: $webAppName to AlwaysOn $false..."

    Set-AzAppServicePlan -Name $appServicePlanName -ResourceGroupName $resourceGroupName -Tier $stopScalingTierName -WorkerSize $stopScalingWorkerSize
    Write-Output ":: Set AppServicePlan: $appServicePlanName to $stopScalingTierName..."

    # # Email küldése az adminisztrátornak (opcionális)
    # $adminEmail = Get-AutomationVariable -Name "AdminEmail"
    # # Itt implementálhatod az email küldést (pl. Send-MailMessage vagy egyéb megoldással)
    
} catch {
    Write-Error ":: ERROR during $WebApp starting: $_"
    throw $_
}