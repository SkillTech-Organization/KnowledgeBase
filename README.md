# SkillTech - Organization

## Azure Landing Governance

---

## 1. Naming Convention

All resource names must follow these rules:

* All lowercase letters
* Alphanumeric characters only
* Unique resource names per global Azure requirements
* Single separator standard: **hyphen (-)**

### Prefix

All resource names begin with the **sktc** prefix.

### Short Codes

#### Clients

* PRATIX: prtx
* AXEGAZ: xgz
* RELAX: rlx

#### Project Codes

* BBX: bbx
* AXERP: axrp
* PRVPCLOUD: pvcld
* REPORTCENTER: rpctr

#### System/Component Names

* Create a short name based on the component
* Example: PRVPCloudWebAPI: prvpcldapi; FTLSupportWebAPI: flspapi

#### Environments

* TEST: tst
* PROD: prd

#### Resource Types

* Resource Group: rsgrp
* App Service: apse
* App Service Plan: apsp
* Storage: strg
* Storage Account: stac
* Blob Storage: blstrg
* SQL Managed Instance: sqlm
* Azure SQL Server: sqls
* Azure SQL Database: sqld
* Virtual Machine: vm
* Automation Account: auac
* Runbook: rubo
* Public IP Address: pipa
* Function App: fapp
* Logic App: lapp
* Key Vault: kvau
* Load Balancer: loba
* Private Endpoint: prep

### Naming Pattern

`sktc-{client}-{projectcode}-{system/component}-{environment}-{resourcetype}-{counter}`

### Examples

* sktc-prtx-pvcld-prvpcldapi-tst-rsgrp-01 → Resource group for PRATIX PRVPCloud TEST environment
* sktc-xgz-axrp-axrpsqld-tst-sqld-02 → SQL Database for AXEGAZ AXERP TEST
* sktc-xgz-rpctr-vm-prd-vm-01 → Virtual Machine for AXEGAZ Reportcenter PROD

---

## 2. Resource Group Organization

* Each environment must have a dedicated resource group
* Example: All AXERP TEST resources → axrp-tst-rsgrp

---

## 3. Infrastructure as Code (IaC)

* All resources must be deployed via IaC scripts
* Scripts must be centralized and parameterized per project
* Each project has its own GitHub repository

Example: [Pratix IaC Repository](https://github.com/SkillTech-Organization/Pratix_IaC)
**Instead this we have to use [Azure Resource Management (ARM)](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview)**

---

## 4. CI/CD Deployment

* All deployments must use GitHub Actions
* Actions stored under `.github/workflows` in repo
* Exception allowed only if CI/CD not possible

Example: [AXERP Function App Actions](https://github.com/SkillTech-Organization/AXERP_API/actions)

---

## 5. Pre-Project Requirements Form

### Define Per Environment

| Item             | Description                                             |
| ---------------- | ------------------------------------------------------- |
| Account          | Set account for project dependencies                    |
| Management Group | Assign the correct group                                |
| Subscription     | Assign subscription, separate per environment if needed |
| Resource Group   | Define per environment                                  |
| Tenant ID        | Set subscription tenant                                 |

### Resource Items

| Resource Type | Resource Name | Description          |
| ------------- | ------------- | -------------------- |
| Type          | Name          | Purpose & parameters |

---

## 6. Monitoring

TBD → Define mandatory logging, alerting, and diagnostic settings.
[Logging](https://github.com/SkillTech-Organization/KnowledgeBase/tree/develop/Docs)
---

## 7. Storage Account Guidelines

* Redundancy: Default LRS; use ZRS/GRS only if justified
* Blob Storage: hot tier by default, archive only by exception
* Secure transfer: Always enabled
* AD Authorization: Use when available
* TLS Encryption: Mandatory
* Data Location: Always within compliance region

---

## 8. FinOps

* Use Azure Cost Management + Billing
* !IMPORTANT: Tag all resources for ownership, environment, project
* Define budgets and configure alerts per subscription

---

## 9. Security and Compliance

* Apply Azure Policy for governance controls
* Implement role-based access control (RBAC)
* Ensure GDPR and local compliance
* Enforce Azure Blueprints when applicable

---

## 10. Networking

### VNETs

* Use hub-spoke architecture
* Define address ranges: e.g., vnetAddressPrefix: 10.0.0.0/16
* Public IP: static only when justified
* Implement NSGs to control traffic

### Connectivity

* Define VPN and/or ExpressRoute configurations
* Allow VNET peering when needed

---

## 11. Virtual Machines

* Publisher: MicrosoftWindowsServer
* Offer: WindowsServer
* SKU: 2019-Datacenter
* OS Version: latest
* Define approved VM sizes per workload
* Enforce Managed Identities
* Implement patch management via Azure Automation

---

## 12. Data Storage Guidelines

### SQL

* Use recommended edition and pricing tier
* Define SLA and RPO/RTO
* Set DB Collation and size limits

### NoSQL

* Define Cosmos DB or other solution depending on workload
* Apply data retention and partitioning strategy

---

## 13. Certificates and Domains

* Certificates must be managed centrally
* Define expiration monitoring and renewal process
* Define process for Azure DNS and custom domain configuration

---

## 14. Identity and Access Management

* Integrate with Azure Active Directory when justified
* Define central authentication policy
* Implement least-privilege access

---

## 15. Automation

* Use Azure Automation and Logic Apps for operational tasks
* Automate patching, monitoring, backup, and cleanup

---

## 16. Exit Strategy

* Define decommissioning steps
* Create offboarding checklist
* Export backups and configurations
* Ensure data retention policies are followed

---

## 17. Configuration

* All project define own configuration settings in appropiate place
* For that aim: configuration values adjustable on the Azure portal environment variables section.
* Such way, sensitive data don't pushable to the Git repository

#### NET Framework Configuration
In .NET Framework applications, settings are typically stored in:

**Web.config/App.config files:**

* appSettings section for simple key-value pairs
* connectionStrings section for database connections
* Custom configuration sections for more complex settings

To make these adjustable in Azure Portal:
Azure will automatically map environment variables to your configuration
Use App Settings in Azure portal with keys that match your config keys
*For example, if you have <add key="ApiEndpoint" value="https://example.com" /> in your config file, set an App Setting named "ApiEndpoint" in Azure*

#### .NET Core Configuration
.NET Core uses a more flexible configuration system:

**appsettings.json:**

* JSON-based configuration
* Environment-specific files (appsettings.Development.json, etc.)
* Hierarchical settings structure

*Program.cs/Startup.cs:*
Configuration builder pattern
Environment variables automatically loaded with AddEnvironmentVariables()

To make these adjustable in Azure Portal:

* Use App Settings in Azure Portal
* For hierarchical settings, use colon notation
*For example, if you have "Logging": { "LogLevel": { "Default": "Information" } } in appsettings.json, you can override it with an App Setting named "Logging:LogLevel:Default"*