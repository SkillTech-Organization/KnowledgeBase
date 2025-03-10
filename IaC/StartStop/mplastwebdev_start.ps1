$subscriptionId = "702fab27-7b08-4bcd-a29e-4c15e902dca2"
$azureAplicationId ="4c016de3-1c7e-4112-afd4-8431b5a6acf7"
$azureTenantId = "8875ae16-2b24-4357-95a4-62e9df84fe06"
$clientSecret = "."
$resourceGroupName = "mplastwebdev"
$webAppName = "mplastwebdev"
$appServicePlanName = "ASP-mplastwebdev-aa75"
$scalingTierName = "Basic"
$azurePassword = ConvertTo-SecureString $clientSecret -AsPlainText -Force
# ========================================================================= 

Write-Output "STARTING... - 1"

$psCred = New-Object System.Management.Automation.PSCredential($azureAplicationId , $azurePassword)
Write-Output "Set Azure pwd... - 2"

Connect-AzAccount -Credential $psCred -TenantId $azureTenantId -ServicePrincipal -Subscription $subscriptionId
Write-Output "Set credential... - 3"

Set-AzAppServicePlan -Name $appServicePlanName -ResourceGroupName $resourceGroupName -Tier $scalingTierName
Write-Output "Set AppServicePlan to $scalingTierName... - 4"

Set-AzWebApp -AppServicePlan $appServicePlanName -AlwaysOn $true -ResourceGroupName $resourceGroupName -Name $webAppName
Write-Output "Set AppServicePlan WebApp AlwaysOn $true... - 5"

Start-AzWebApp -Name $webAppName -ResourceGroupName $resourceGroupName
Write-Output "Start the WebApp: $webAppName... - 6"

Write-Output "END... - 7"
