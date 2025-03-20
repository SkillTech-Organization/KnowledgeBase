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
		
{prefix}{client}{projectcode}{system/component}{environment short code}{resource type short code}{counter}

** If possible use separators (dot (.), undescrore (_), hyphen (-)) on the border ot the named items.

**Examples:**
* _sktc-prtx-pvcld-prvpcldapi-tst-rsgrp_ - Resource group to the PVRPCloud project at PRATIX Client
* _sktc-xgz-axrp-axrpsqld-tst-sqld_ - (MS) SQL Database of the AXERP project at AXEGAZ client

### How to organize components
* all item organize to one resourcegroup per environment
* eg.: all components in AXERP project at TEST environments are under a test resource group

### Use IaC
* all components mandatory create via IaC (infrastructure as code) manner from script
* use the centralized IaC scripts and parametrized them 
* IaC script pushed to separated GitHub repository per project 

### Use CI/CD
* all components deliver from CI/CD (GitHub Action scripts) to Azure zones
* expect if we cannot solved the CI/CD chain currently
