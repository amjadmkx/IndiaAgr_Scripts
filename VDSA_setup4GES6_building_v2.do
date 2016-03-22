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
*** Building File     ***
*****************************

local files: dir "`datadir'" files "gese_building*.dta"
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

replace item_building = item_buil if item_buil!=""
replace id_who_owns = who_owns_buil if who_owns_buil != ""
replace val_pre = val_buil if val_buil!= ""
ren val_pre present_val
drop item_buil who_owns_buil val_buil remarks_e_buil sur_yr

destring, replace
compress

order vds_id region vill_code hh_id year 
sort vds_id region vill_code hh_id year 

local datadir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_compile
local outdir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_out
save `outdir'/ges6_building.dta, replace


/*clean item building */


	
