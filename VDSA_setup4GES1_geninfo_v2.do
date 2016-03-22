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
*** GESn files
*******************************************

//*
************************
*** GES GEneral Info ***
************************

local files: dir "`datadir'" files "ges_geninfo*.dta"
local files: subinstr local files ".dta" "", all
di `files'


	
foreach filename in `files' {
	di "`filename'"
	preserve 
		use `datadir'/`filename'.dta, clear
		qui tostring *, replace
		
		if "`filename'"=="ges_geninfo_eastindia_2011" | "`filename'"=="ges_geninfo_eastindia_2013" | "`filename'"=="ges_geninfo_eastindia_2014" {
			tostring oper_ho, replace force
			}
		
		if regexm("`filename'","_satindia_2010")|regexm("`filename'","_satindia_2009")|regexm("`filename'","_bang_"){
			gen dt_int=.
			}
		else if regexm("`filename'","_satindia_2011"){
			destring dt_int, replace
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


tab region year if cs_hh_no != "" 
tab region year if teh_man  != "" 
tab region year if teh_man_blo  != "" 
tab region year if sou_hh_no  != "" 
tab region year if head_name  != "" 
tab region year if son_wife_of  != "" 
tab region year if inv_name  != "" 
tab region year if name_sup != "" 
	
*** dropping empty/redundant variables
drop lon_* lat_* altitude head_name son_wife_of inv_name name_sup ar vdsid_hhid
drop sur_yr


replace vds_id = vdsid if vds_id==""
drop vdsid

replace teh_man_blo==teh_man if teh_man_blo==""
drop teh_man

gen l = strlen(dt_check)
destring dt_check, g(datcheck) force
replace datcheck=date(strtrim(dt_check), "DMY") if l == 10
drop l dt_check
ren datcheck dt_check
format dt_check dt_int %td

replace vds_id=strtrim(vds_id)

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

order vds_id region vill_code hh_id year village union_taluka_mandal thana_upazila the_man_blo district state country
sort vds_id region vill_code hh_id year 

local datadir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_compile
local outdir  D:/AMK/StataFiles/Data/IndiaVDSA_Data/IndiaVDSA_out
save `outdir'/ges1_geninfo.dta, replace



