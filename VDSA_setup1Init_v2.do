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

local datadir  D:/AMK/StataFiles/Data/IndiaVDSA_Data
local scriptdir D:/AMK/StataFiles/Scripts/IndiaAgr_Scripts
local workingdir D:/AMK/StataFiles/wd/IndiaAgr_wd
cd `workingdir'

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





*******************************************************************************
*** next append files and ensure rough uniforrmity/standardization
*******************************************************************************

