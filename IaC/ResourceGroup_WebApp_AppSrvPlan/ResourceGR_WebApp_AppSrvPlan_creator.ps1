# ##### HOW TO USE #######
# .\ResourceGR_WebApp_AppSrvPlan_creator.ps1 -ResourceGroupName "wtracewebtst_ResourceGroup" -Location "westeurope" -AppServicePlanName "wtracewebtest_AppServicePlan" -WebAppName "wtracewebtestenv" -Tier "Basic" -WorkerSize "Small" -SubscriptionId "702fab27-7b08-4bcd-a29e-4c15e902dca2"
# ########################################

# Paraméterek
param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$Location,
    
    [Parameter(Mandatory=$true)]
    [string]$AppServicePlanName,
    
    [Parameter(Mandatory=$true)]
    [string]$WebAppName,
    
    [Parameter(Mandatory=$false)]
    [string]$Tier = "Basic",
    
    [Parameter(Mandatory=$false)]
    [string]$WorkerSize = "Small",
    
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId = ""
)

# Azure-ba való bejelentkezés ellenőrzése és szükség esetén bejelentkezés
$context = Get-AzContext
if (!$context) {
    Write-Host ":: Login to Azure..." -ForegroundColor Yellow
    Connect-AzAccount
}

# Ha meg van adva előfizetés ID, akkor váltunk rá
if ($SubscriptionId -ne "") {
    Write-Host ":: Change subscription..." -ForegroundColor Yellow
    Set-AzContext -SubscriptionId $SubscriptionId  
}

# Erőforráscsoport létezésének ellenőrzése
$resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if ($resourceGroup) {
    Write-Host ":: '$ResourceGroupName' already exists."  -ForegroundColor Green
} else {
    Write-Host ":: Create resourcegroup: $ResourceGroupName"  -ForegroundColor Red
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force
}

# WebApp létezésének ellenőrzése
$existingWebApp = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -ErrorAction SilentlyContinue
if ($existingWebApp) {
    Write-Host ":: '$WebAppName' already exists."  -ForegroundColor Green
    Write-Host ":: Web App URL: https://$WebAppName.azurewebsites.net"  -ForegroundColor Green
} else {
    # App Service Plan létezésének ellenőrzése
    $existingAppServicePlan = Get-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -ErrorAction SilentlyContinue
    
    if (!$existingAppServicePlan) {
        # App Service Plan létrehozása a megadott mérettel
        Write-Host ":: Create App Service Plan: $AppServicePlanName"  -ForegroundColor Red
        $appServicePlan = New-AzAppServicePlan -ResourceGroupName $ResourceGroupName `
            -Name $AppServicePlanName `
            -Location $Location `
            -Tier $Tier `
            -WorkerSize $WorkerSize `
            -NumberofWorkers 1
    } else {
        Write-Host ":: '$AppServicePlanName' already exists."  -ForegroundColor Green
    }

    # Web App létrehozása
    Write-Host ":: Create Web App: $WebAppName"  -ForegroundColor Red
    $webApp = New-AzWebApp -ResourceGroupName $ResourceGroupName `
        -Name $WebAppName `
        -Location $Location `
        -AppServicePlan $AppServicePlanName

    # Eredmények kiírása
    Write-Host ":: Web App create finished!"  -ForegroundColor Green
    Write-Host ":: Web App URL: https://$WebAppName.azurewebsites.net"  -ForegroundColor Green
}

# Összesített információk kiírása
Write-Host "`nSummary:"
Write-Host "----------------"
Write-Host "ResourceGroupName: $ResourceGroupName"
Write-Host "App Service Plan: $AppServicePlanName (Tier: $Tier, Worker Size: $WorkerSize)"
Write-Host "Web App: $WebAppName"
Write-Host "Web App URL: https://$WebAppName.azurewebsites.net" -ForegroundColor Blue