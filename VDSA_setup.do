********************************************************************************
********************************************************************************
***
*** Agriculture in India - v1
*** Amjad Khan 
*** this version: 2016-02-22
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

local datadir  D:/AMK/StataFiles/Data/IndiaVDSA_Data
local scriptdir D:/AMK/StataFiles/Scripts/IndiaAgr_Scripts
local workingdir D:/AMK/StataFiles/wd/IndiaAgr_wd
cd `workingdir'




/*
********************************************************************************
*** This here creates dta files
********************************************************************************

*** get filenames in directory, without the .xlsx extensions
local files: dir "`datadir'/IndiaVDSA_compile" files "*.xlsx"
local files: subinstr local files ".xlsx" "", all
di `files'

cd "`datadir'/IndiaVDSA_compile"
*** save files as .dta so that we can manipulate in Stata.
foreach filename in `files' {
	di "`filename'"
	import excel using `filename'.xlsx, firstrow clear
	save `filename'.dta, replace
	clear
}


********************************************************************************
*** This here adds region and year indicators to each file
********************************************************************************

cd "`datadir'/IndiaVDSA_compile"
*** add year and region indicator to each file. 
foreach filename in `files' {
	di "`filename'"
	use `filename'.dta, clear
	generate region = "SATIndia" if regexm("`filename'", "satindia_")
	replace region = "EastIndia" if regexm("`filename'", "eastindia_")
	replace region = "Bangladesh" if regexm("`filename'", "bang_")
	gen year = substr("`filename'", -4, 4)	
	order region year
	foreach v of varlist _all {
      capture rename `v' `=lower("`v'")'
	  }	
	save `filename'.dta, replace
	}
*/








/*
this here was an earlier attempt
*** merging datasets together
use hcs_1.hcs_gen_info.dta, replace
merge 1:1 CHS_ID using hcs_2.household_info.dta
drop _merge

preserve
tempfile tmpf
use hcs_3.oper_holding.dta, clear
gen landstub=""
replace landstub="_own" if trim(PART_LAND)=="Own land"
replace landstub="_lsin" if trim(PART_LAND)=="Leased/Shared in land"
replace landstub="_lsout" if trim(PART_LAND)=="Leased/Shared out land"
replace landstub="_operated" if trim(PART_LAND)=="Operated land"
tab PART_LAND landstub, mi
reshape wide PART_LAND DRY_LAND DRY_LAND_RATE IRRI_LAND IRRI_LAND_RATE PERM_FALL PERM_FALL_LAND_RATE TOT_LAND, i(CHS_ID) j(landstub) string
save `tmpf'
restore
merge 1:1 CHS_ID using `tmpf'


foreach folder in Bangladesh EastIndia SATIndia{
	foreach year in 
}

*/





*******************************************************************************
*** append files and ensure rough uniforrmity/standardization
*******************************************************************************

*** Cult1 file ***

local datadir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_compile
local outdir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_out
local files: dir "`datadir'" files "cult1_*.dta"
local files: subinstr local files ".dta" "", all
di `files'

use  `datadir'/cult1_plotinfo_satindia_2009.dta, clear
capture destring rent_val, replace
save  `datadir'/cult1_plotinfo_satindia_2009.dta, replace

use  `datadir'/cult1_plotinfo_satindia_2010.dta, clear
capture destring rent_val, replace
save  `datadir'/cult1_plotinfo_satindia_2010.dta, replace

use  `datadir'/cult1_plotinfo_satindia_2012.dta, clear
capture destring rent_val, replace
save  `datadir'/cult1_plotinfo_satindia_2012.dta, replace


clear
foreach filename in `files' {
	di "`filename'"
	append using `datadir'/`filename'.dta
	}

tab year if rent_val!=.
tab year if rent_val==.
tostring *, replace
duplicates drop plot_code vds_id season, force
replace plot_code = strtrim(plot_code)
replace vds_id=strtrim(vds_id)
replace season=strtrim(season)
save `outdir'/cult1_plotinfo.dta, replace


*** Cult2 file ***
local datadir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_compile
local outdir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_out
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
		save `datadir'/`filename'.dta, replace
	restore
	append using `datadir'/`filename'.dta
	}

*** fixing variable displaced
replace plot_code=plot_co if plot_code==""
drop plot_co

replace plot_code = strtrim(plot_code)
replace vds_id=strtrim(vds_id)
replace season=strtrim(season)

merge m:1 vds_id plot_code season using `outdir'/cult1_plotinfo.dta, update
tab _merge 
drop if _merge==2

replace crop_name = crop if crop_name==""
replace vds_id = cult_id if vds_id==""
drop crop cult_id 
drop var_type_ot
order vds_id region year season plot_code
save `outdir'/cult2_cropinfo.dta, replace
