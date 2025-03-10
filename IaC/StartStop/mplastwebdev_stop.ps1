$subscriptionId = "702fab27-7b08-4bcd-a29e-4c15e902dca2"
$azureAplicationId ="4c016de3-1c7e-4112-afd4-8431b5a6acf7"
$azureTenantId = "8875ae16-2b24-4357-95a4-62e9df84fe06"
$clientSecret = "ms08Q~7COdWlM9Vc~_Cct3cgcU645E-VOvh-XavR"
$resourceGroupName = "mplastwebdev"
$webAppName = "mplastwebdev"
$appServicePlanName = "ASP-mplastwebdev-aa75"
$scalingTierName = "Free"
$scalingWorkerSize = "Small"
$azurePassword = ConvertTo-SecureString $clientSecret -AsPlainText -Force
# ========================================================================= 

Write-Output "STARTING... - 1"

$psCred = New-Object System.Management.Automation.PSCredential($azureAplicationId , $azurePassword)
Write-Output "Set Azure pwd... - 2"

Connect-AzAccount -Credential $psCred -TenantId $azureTenantId -ServicePrincipal -Subscription $subscriptionId
Write-Output "Set credential... - 3"

Stop-AzWebApp -Name $webAppName -ResourceGroupName $resourceGroupName
Write-Output "Stop the app... - 4"

Set-AzWebApp -AppServicePlan $appServicePlanName -AlwaysOn $false -ResourceGroupName $resourceGroupName -Name $webAppName
Write-Output "Set AppServicePlan: $appServicePlanName webapp: $webAppName to AlwaysOn $false... - 5"

Set-AzAppServicePlan -Name $appServicePlanName -ResourceGroupName $resourceGroupName -Tier $scalingTierName -WorkerSize $scalingWorkerSize
Write-Output "Set AppServicePlan: $appServicePlanName to $scalingTierName... - 6"

Write-Output "END... - 7"

