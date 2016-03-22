********************************************************************************
********************************************************************************
***
*** Agriculture in India - v2
*** Amjad Khan 
*** this version: 2016-03-21
***
********************************************************************************
***
*** Setting up the VDSA data
***
********************************************************************************
********************************************************************************




clear all
set more off
pause on
local datadir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_compile
local outdir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_out
local intdir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_out/Interim
tempfile tmp1



*******************************************
*** GES files
*******************************************

//*
*****************************
*** Consumer durables file***
*****************************

local files: dir "`datadir'" files "gese_condurables*.dta"
local files: subinstr local files ".dta" "", all
di `files'


	
foreach filename in `files' {
	di "`filename'"
	preserve 
		use `datadir'/`filename'.dta, clear
		qui tostring *, replace
		save `intdir'/`filename'.dta, replace
	restore
	append using `intdir'/`filename'.dta
	}	

foreach v of varlist _all {
	local tp : type `v'
	if substr("`tp'",1,3)=="str"{
		replace `v' = strtrim(upper(`v'))
		replace `v' = "" if `v' =="."
		}
	}

	
replace vds_id = vdsid if vds_id==""
drop vdsid
replace vds_id=strtrim(vds_id)


*** dropping empty observation
drop if vds_id==""

*** Fixing up the messed up village ID component of vds_id s for SATIndia2014 (see excel file)
replace vds_id=subinstr(vds_id,"ITS","IAP",1) if substr(vds_id,1,3)=="ITS"

*** extracting a village code from vds_id
gen vill_code=substr(vds_id,1,3)+substr(vds_id,6,1)

*** extracting a hh/unit/cult if from vds_id
gen hh_id=substr(vds_id,1,3)+substr(vds_id,6,5)

replace id_who_owns = who_owns if who_owns!=""
replace pre_val = val_con if val_con!=""
rename pre_val present_val 
replace remarks = remarks_e if remarks_e!=""
replace no_durable = no_con_du if no_con!=""
replace item_dur = item_con_du if item_con_du!=""

drop who_owns val_con remarks_e no_con_du sur_yr item_con_du

destring, replace
compress

order vds_id region vill_code hh_id year 
sort vds_id region vill_code hh_id year 

local datadir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_compile
local outdir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_out
save `outdir'/ges7_durables.dta, replace


/*clean item durables */


	
clear 
local files: dir "`datadir'" files "gese_otherdurables*.dta"
local files: subinstr local files ".dta" "", all
di `files'


	
foreach filename in `files' {
	di "`filename'"
	preserve 
		use `datadir'/`filename'.dta, clear
		qui tostring *, replace
		save `intdir'/`filename'.dta, replace
	restore
	append using `intdir'/`filename'.dta
	}	

foreach v of varlist _all {
	local tp : type `v'
	if substr("`tp'",1,3)=="str"{
		replace `v' = strtrim(upper(`v'))
		replace `v' = "" if `v' =="."
		}
	}

	
replace vds_id=strtrim(vds_id)


*** dropping empty observation
drop if vds_id==""

*** Fixing up the messed up village ID component of vds_id s for SATIndia2014 (see excel file)
replace vds_id=subinstr(vds_id,"ITS","IAP",1) if substr(vds_id,1,3)=="ITS"

*** extracting a village code from vds_id
gen vill_code=substr(vds_id,1,3)+substr(vds_id,6,1)

*** extracting a hh/unit/cult if from vds_id
gen hh_id=substr(vds_id,1,3)+substr(vds_id,6,5)

rename item_ot_du item_durable
rename val_ot_du present_val
replace remarks=remarks_e if remarks_e!=""
rename who_owns id_who_owns


destring, replace
compress

order vds_id region vill_code hh_id year 
sort vds_id region vill_code hh_id year 

save `tmp1'.dta, replace
	
use `outdir'/ges7_durables.dta, clear
append using `tmp1'.dta
save `outdir'/ges7_durables.dta, replace
