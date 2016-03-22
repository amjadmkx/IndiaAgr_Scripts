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
******************************
*** Gnder ***
********************************

local files: dir "`datadir'" files "gesi1_genddm*.dta"
local files: subinstr local files ".dta" "", all
di `files'


	
foreach filename in `files' {
	di "`filename'"
	preserve 
		use `datadir'/`filename'.dta, clear
		qui tostring *, replace
		capture: tostring tot_val unit_price, replace force
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


drop sur_yr


***Don't know how to deal with the differences in the table below:
tab region year if ownership_f!=ownership_m & ownership_f!="" & ownership_m!=""
tab region year

*** Nonetheles,, replacing the ownership, dm and infl variable with the _m version
replace ownership = ownership_m if ownership_m != ""
replace ownership = "MALE" if ownership == "M" | ownership == "1"
replace ownership = "FEMALE" if ownership == "F" | ownership == "2"
replace ownership = "BOTH" if ownership == "B" | ownership == "3"

replace deci_making = deci_making_m if deci_making_m != ""
replace deci_making = "MALE" if deci_making == "M" | deci_making == "1"
replace deci_making = "FEMALE" if deci_making == "F" | deci_making == "2"
replace deci_making  = "BOTH" if deci_making == "B" | deci_making == "3"

replace who_infl_util = who_infl_util_m if who_infl_util_m != ""
replace who_infl_util = "MALE" if who_infl_util == "M" | who_infl_util == "1"
replace who_infl_util = "FEMALE" if who_infl_util == "F" | who_infl_util == "2"
replace who_infl_util = "BOTH" if who_infl_util == "B" | who_infl_util == "3"
replace who_infl_util = "NA" if who_infl_util == "N"


destring, replace
compress

order vds_id region vill_code hh_id year ownership deci_making who_infl_util
sort vds_id region vill_code hh_id year 

local datadir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_compile
local outdir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_out
save `outdir'/ges10_genddm.dta, replace


/*clean source*/


	
