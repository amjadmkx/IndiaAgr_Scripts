********************************************************************************
********************************************************************************
***
*** Agriculture in India - v2
*** Amjad Khan 
*** this version: 2016-03-08
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
*** Cultivation files
*******************************************

//*
******************
*** Cult1 file ***
******************

local files: dir "`datadir'" files "cult1_*.dta"
local files: subinstr local files ".dta" "", all
di `files'
/*
use  `datadir'/cult1_plotinfo_satindia_2009.dta, clear
capture destring rent_val, replace
save  `datadir'/cult1_plotinfo_satindia_2009.dta, replace

use  `datadir'/cult1_plotinfo_satindia_2010.dta, clear
capture destring rent_val, replace
save  `datadir'/cult1_plotinfo_satindia_2010.dta, replace

use  `datadir'/cult1_plotinfo_satindia_2012.dta, clear
capture destring rent_val, replace
save  `datadir'/cult1_plotinfo_satindia_2012.dta, replace
*/

clear
foreach filename in `files' {
	preserve
		use  `datadir'/`filename'.dta, clear
		capture destring rent_val, replace
		save  `intdir'/`filename'.dta, replace
	restore
	di "`filename'"
	append using `intdir'/`filename'.dta
	}

foreach v of varlist _all {
	local tp : type `v'
	if substr("`tp'",1,3)=="str"{
		replace `v' = strtrim(upper(`v'))
		replace `v' = "" if `v' =="."
		}
	}	

tab year if rent_val!=.
tab year if rent_val==.
tostring *, replace
duplicates drop plot_code vds_id season, force

destring, replace
compress

*** Fixing up the messed up village ID component of vds_id s for SATIndia2014 (see excel file)
replace vds_id=subinstr(vds_id,"ITS","IAP",1) if substr(vds_id,1,3)=="ITS"

*** extracting a village code from vds_id
gen vill_code=substr(vds_id,1,3)+substr(vds_id,6,1)

*** extracting a hh/unit/cult if from vds_id
gen hh_id=substr(vds_id,1,3)+substr(vds_id,6,5)


save `outdir'/cult1_plotinfo.dta, replace


******************
*** Cult2 file ***
******************

local files: dir "`datadir'" files "cult2_*.dta"
local files: subinstr local files ".dta" "", all
di `files'
clear
foreach filename in `files' {
	di "`filename'"
	preserve 
		use `datadir'/`filename'.dta, clear
		tostring *, replace
		destring op_main_prod_rate, replace
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

*** fixing variable displaced
replace plot_code=plot_co if plot_code==""
drop plot_co

replace plot_code = strtrim(plot_code)
replace vds_id=strtrim(vds_id)
replace season=strtrim(season)

*** Fixing up the messed up village ID component of vds_id s for SATIndia2014 (see excel file)
replace vds_id=subinstr(vds_id,"ITS","IAP",1) if substr(vds_id,1,3)=="ITS"

*** extracting a village code from vds_id
gen vill_code=substr(vds_id,1,3)+substr(vds_id,6,1)

*** extracting a hh/unit/cult if from vds_id
gen hh_id=substr(vds_id,1,3)+substr(vds_id,6,5)


destring, replace
merge m:1 vds_id plot_code season using `outdir'/cult1_plotinfo.dta, update
tab _merge 
drop if _merge==2

replace crop_name = crop if crop_name==""
replace vds_id = cult_id if vds_id==""


drop crop cult_id 
*drop var_type_ot

destring, replace
compress

order vds_id region vill_code hh_id year season plot_code crop_name 
sort vds_id region vill_code hh_id year season plot_code
save `outdir'/cult2_cropinfo.dta, replace
*/

******************
*** Cult3 file ***
******************

local files: dir "`datadir'" files "cult3_*.dta"
local files: subinstr local files ".dta" "", all
di `files'
clear
foreach filename in `files' {
	di "`filename'"
	preserve 
		use `datadir'/`filename'.dta, clear
		qui tostring *, replace
		
		if regexm("`filename'","cult3_ipmh_satindia_2012") | regexm("`filename'","cult3_ip1_satindia_2014"){
			drop if vds_id==""
			}
		
		/*if !regexm("`filename'","satindia") & !regexm("`filename'","cult3_ipnisha_bang_2013"){
			gen dateoper=date(strtrim(dt_oper), "DMY")
			}
		if regexm("`filename'","cult3_ipnisha_bang_2013"){
			gen dateoper=dt_oper
			}
		*/
		local tp : type dt_oper
		di "`tp'"
		if "`tp'"=="str5" {
			destring dt_oper, gen(dateoper)
			}
		if "`tp'"=="str10" {
			* the MDYs:
			*** cult3_iprsb_bang_2013
			*** cult3_ipgj_satindia_2013	
			if "`filename'"=="cult3_iprsb_bang_2013" | "`filename'"=="cult3_ipgj_satindia_2013" {
				gen dateoper=date(strtrim(dt_oper), "MDY")
				}
			else{
				gen dateoper=date(strtrim(dt_oper), "DMY")
				}
			}
		if "`tp'"=="double" | "`tp'"=="double" {
			gen dateoper = dt_oper
			}	
		if "`tp'"=="str6" | "`tp'"=="str7"{
			destring(dt_oper), gen(dateoper)
			}	
		if "`tp'"!="str10" & "`tp'"!="str6" & "`tp'"!="str7"& "`tp'"!="str5" & "`tp'"!="double" {
			di "error"
			pause
			}
			
		drop dt_oper
		ren dateoper dt_oper
		format dt_oper %td
		
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
	
replace plot_code=plot_co if plot_code==""
drop plot_co

replace plot_code = strtrim(plot_code)
replace vds_id=strtrim(vds_id)
replace season=strtrim(season)


*** Fixing up the messed up village ID component of vds_id s for SATIndia2014 (see excel file)
replace vds_id=subinstr(vds_id,"ITS","IAP",1) if substr(vds_id,1,3)=="ITS"

*** extracting a village code from vds_id
gen vill_code=substr(vds_id,1,3)+substr(vds_id,6,1)

*** extracting a hh/unit/cult if from vds_id
gen hh_id=substr(vds_id,1,3)+substr(vds_id,6,5)


destring, replace

merge m:1 vds_id plot_code season using `outdir'/cult1_plotinfo.dta, update
tab _merge 
drop if _merge==2

replace vds_id = cult_id if vds_id==""



drop cult_id	

destring, replace
compress

order vds_id region vill_code hh_id year season plot_code 
sort vds_id region vill_code hh_id year season plot_code 



local datadir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_compile
local outdir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_out
save `outdir'/cult3_inputs.dta, replace

*/
	
*******************************************
*** Employment file Next
*******************************************
