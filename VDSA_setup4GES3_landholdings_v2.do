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
*** Landholding File     ***
*****************************

local files: dir "`datadir'" files "gesb_landholding*.dta"
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

replace sou_irri_1 = sou_irri if sou_irri_1 == ""
replace sou_irri_1 = sou_irri1 if sou_irri_1 == ""

replace sou_irri_2 = sou_irri2 if sou_irri_2 == ""
replace dist_sou_irri = dist_irri_sou if dist_sou_irri==""

replace dist_from_house = dist_fr_ho if dist_from_house == "" 

drop sou_irri1 sou_irri2 sou_irri dist_irri_sou dist_fr_ho


replace remark = remark_b if remark == ""
drop remark_b ah ag sur_yr


replace vds_id = vdsid if vds_id==""
drop vdsid
replace vds_id=strtrim(vds_id)

replace sr_no = sl_no if sr_no==""
drop sl_no

*** dropping empty observation
drop if vds_id==""

*** Fixing up the messed up village ID component of vds_id s for SATIndia2014 (see excel file)
replace vds_id=subinstr(vds_id,"ITS","IAP",1) if substr(vds_id,1,3)=="ITS"

*** extracting a village code from vds_id
gen vill_code=substr(vds_id,1,3)+substr(vds_id,6,1)

*** extracting a hh/unit/cult if from vds_id
gen hh_id=substr(vds_id,1,3)+substr(vds_id,6,5)



destring, replace
compress

order vds_id region vill_code hh_id year sr_no plot_code plot_*
sort vds_id region vill_code hh_id year sr_no plot_code 

local datadir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_compile
local outdir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_out
save `outdir'/ges3_landholdings.dta, replace


/*

	
