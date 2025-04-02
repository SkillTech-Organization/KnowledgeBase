# SkillTech - Organization

## Azure Landing Governance

### Naming convention
* The names of the resources following the next rules
	* every resource name is in lowercase
	* all resource use only alphanumerical characters
	* with the naming convetion we support the unique resource names
	* 
	* we use **_sktc_** prefix fro all resources
	* we use short codes for
		* CLIENTS
		> * PRATIX: prtx
		> * AXEGAZ: xgz
		> * RELAX: rlx
		
		* PROJECT CODES
		> * BBX: bbx
		> * AXERP: axrp
		> * PRVPCLOUD: pvcld
		> * REPORTCENTER: rpctr
		
		* SYSTEM/COMPONENTS's NAME
		> * create a short name of the curent component
		> * e.g.: PRVPCloudWebAPI: prvpcldapi
		> * e.g.: FTLSupportWebAPI: flspapi
		
		* ENVIRONMENTS
		> * TEST: tst
		> * PROD: prd
		
		* RESOURCE TYPES
		> * RESOURCE GROUP: rsgrp
		> * APP SERVICE: apse
		> * APP SERVICE PLAN: apsp
		> * STORAGE: strg
		> * STORAGE ACCOUNT: stac
		> * BLOB STORAGE: blstrg
		> * SQL MANAGED INSTANCE: sqlm
		> * AZURE SQL SERVER: sqls
		> * AZURE SQL DATABASE: sqld
		> * VIRTUAL MACHINE: vm
		> * AUTOMATION ACCOUNT: auac
		> * RUNBOOK: rubo
		> * PUIBLIC IP ADDRESS: pipa
		> * FUNCTION APP: fapp
		> * LOGIC APP: lapp
		> * KEY VAULT: kvau
		> * LOAD BALANCER: loba
		> * PRIVATE ENDPOINT: prep
		
_{prefix}{client}{projectcode}{system or component}{environment short code}{resource type short code}{counter}_

**If possible use separators (dot (.), undescrore (_), hyphen (-)) on the border ot the named items.**

**Examples:**
* _sktc-prtx-pvcld-prvpcldapi-tst-rsgrp-01_ - Resource group to the PVRPCloud project at PRATIX Client
* _sktc-xgz-axrp-axrpsqld-tst-sqld-02_ - (MS) SQL Database of the AXERP project at AXEGAZ client
* _sktcxgzrpctrvmprdvm01_ - Virtual machine in AWS Cloud environment for Axegaz Reportcenter project

### How to organize components
* all item organize to one resourcegroup per environment
* eg.: all components in AXERP project at TEST environments are under a test resource group

### Use IaC
* all components mandatory create via IaC (infrastructure as code) manner from script
* use the centralized IaC scripts and parametrized them 
* IaC script pushed to separated GitHub repository per project 
* e.g.: [Pratix IaC](https://github.com/SkillTech-Organization/Pratix_IaC)

### Use CI/CD
* all components deliver from CI/CD (GitHub Action scripts) to Azure zones
* these Github actions stored under **.github/workflows** folder in Github repo
* expect if we cannot solved the CI/CD chain currently
* e.g. [AXERP Function app CI/CD](https://github.com/SkillTech-Organization/AXERP_API/actions)

### Before we start a project in Azure/AWS Cloud, pls fil lthe following form
#### You have to define these infos per environments!
#### Main 
| Management items  | Description                                                                           |
| ----------------- | ------------------------------------------------------------------------------------- |
| Account(s)        | set up the Account wihc one contains and the project rely on this                     |
| Management group  | set up the management group                                                           |
| Subscription      | set up the subscription of the project parts. If need use separated subscr. tper envs |
| Resource group    | set up the resource group per environments                                            |
| Tenant ID         | set up the Tenant of the subscription                                                 |

Then you define the resource items for  the project per environments.

| Resource type     | Resource name | Description                                                           |
| ----------------- | ------------- | --------------------------------------------------------------------- |
| resource type     | resource name | goals of the resource item and other params                           |

### Monitoring capabilities
#### We have to define the logging parameters
... *TBD* ...

### Storage account
. LRS, ZRS, GRS: which one redundancy need it?

. azure blob storage
- access tier: hot, cool, cold, archive ?

. azure files

. azure queue storage

. azure table storage

- access levels? 
- TLS
- Secure transfer
- AD authorization

### FinOps - how much?

### EntryID, authn/authz