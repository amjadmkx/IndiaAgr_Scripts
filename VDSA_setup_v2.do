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


cd `scriptdir'
*do VDSA_setup1Init_v2.do
do VDSA_setup2Cultivation_v2.do
do VDSA_setup3Employment_v2.do
do VDSA_setup4GES1_v2.do
do VDSA_setup4GES2_v2.do
