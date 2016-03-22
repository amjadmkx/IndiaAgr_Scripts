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
*** Employment file 
*******************************************

local files: dir "`datadir'" files "emp1_emp*.dta"
local files: subinstr local files ".dta" "", all
di `files'

	
foreach filename in `files' {
	di "`filename'"
	preserve 
		use `datadir'/`filename'.dta, clear
		qui tostring *, replace
		
		if "`filename'"=="emp1_emp_eastindia_2012"{
			tostring own_farm_h, replace force
			}
			
		if regexm("`filename'","_satindia_2010"){
			gen dt_int=.
			}
		else {
			local tp : type dt_int
			di "`tp'"
			if "`tp'"=="str13" {
				replace dt_int = strtrim(dt_int)
				compress dt_int
				local tp : type dt_int
				}
			if "`tp'"=="str5" {
				destring dt_int, gen(dateint)
				}
			if "`tp'"=="str10" {
				* the MDYs: are there any?
				gen dateint=date(strtrim(dt_int), "DMY")
				}
			if "`tp'"=="double" | "`tp'"=="double" {
				gen dateint = dt_int
				}	
			if "`tp'"=="str6" | "`tp'"=="str7"{
				destring(dt_int), gen(dateint)
				}	
			if "`tp'"!="str10" & "`tp'"!="str6" & "`tp'"!="str7"& "`tp'"!="str5" & "`tp'"!="double" {
				di "error"
				pause
				}
				
			drop dt_int
			ren dateint dt_int
			format dt_int %td
			}
		*/
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

replace own_farm = "" if own_farm=="."

replace own_farm_d = own_farm if region=="SATINDIA"
replace own_dome_d = own_dome if region=="SATINDIA"
replace own_lst_d = own_lst if region=="SATINDIA"
replace own_ot_d = own_ot if region=="SATINDIA"
drop own_farm own_dome own_lst own_lst

*** qm stands for question mark, as in I don't know what units are being used
* to measure time use in bangladesh. Is it hours per month? per week? what???
gen own_farm_qm = own_farm_h if region=="BANGLADESH"
replace own_farm_h = "" if region=="BANGLADESH"

gen own_dome_qm = own_dome_h if region=="BANGLADESH"
replace own_dome_h = "" if region=="BANGLADESH"

gen own_lst_qm = own_lst_h if region=="BANGLADESH"
replace own_lst_h = "" if region=="BANGLADESH"

gen own_ot_qm = own_ot_h if region=="BANGLADESH"
replace own_ot_h = "" if region=="BANGLADESH"



replace vds_id=strtrim(vds_id)

*** Fixing up the messed up village ID component of vds_id s for SATIndia2014 (see excel file)
replace vds_id=subinstr(vds_id,"ITS","IAP",1) if substr(vds_id,1,3)=="ITS"

*** extracting a village code from vds_id
gen vill_code=substr(vds_id,1,3)+substr(vds_id,6,1)

*** extracting a hh/unit/cult if from vds_id
gen hh_id=substr(vds_id,1,3)+substr(vds_id,6,5)

drop state

destring, replace
compress

order vds_id region vill_code hh_id year sur_mon_yr round_no 
sort vds_id region vill_code hh_id year sur_mon_yr round_no



local datadir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_compile
local outdir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_out
save `outdir'/emp1_employment.dta, replace
