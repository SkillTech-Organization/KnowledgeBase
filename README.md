# SkillTech - Organization

## Azure Landing Governance

### Naming convention
* The names of the resources following the next rules
	* every resource name is in lowercase
	* all resource use only alphanumerical characters
	* we use _sktc_ prefix fro all resources
	* we use short codes for
		- ENVIRONMENT
		> TEST: tst
		> PROD: prd
		- RESOURCE TYPE
		> RESOURCE GROUP: rsgrp
		> WEB APP: wbpp
		> APP SERVICE PLAN: ppsrvpln
		> STORAGE: strg
		> DATABASE: dtbs
		
{sktc}{client}{projectcode}{system/component}{environment short code}{resource type short code}{counter}

**Examples:**
* _sktchpratixpvrpcloudpvrpwebapitstrgrp_ - Resource group to the PVRPCloud project at PRATIX Client
* _AXEGAZ_AXERP_AXERPDATABASE_TEST_SQLDATABASE_ - (MS) SQL Database of the AXERP project at AXEGAZ client
