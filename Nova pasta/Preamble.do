* ------------------------------------------------------------------------
* STATA VERSION 16
* ------------------------------------------------------------------------

* version of stata
version 16.1

*** FOLDERS PATHWAY

* check what your username is in Stata by typing "di c(username)"
if "`c(username)'" == "Francisco"   {
    global ROOT "C:/Users/Francisco/Dropbox/Consultancy/2020-Steven_Helfand"
}
else if "`c(username)'" == "f.cavalcanti"   {
    global ROOT "C:/Users/Francisco/Dropbox/Consultancy/2020-Steven_Helfand"
}

global in_dir			"${ROOT}/input"
global out_dir			"${ROOT}/output"
global code_dir			"${ROOT}/code"
global tmp_dir			"${ROOT}/tmp"


******************************
** 	Do files for rainfall 	**
******************************

* extract files .csv
clear
cd  "${in_dir}/amc_rainfall_csv"
pwd

* set files
local files : dir . files "*.csv"
display `files'

* loop over files to extract rainfall and save as .dta at the temporary directory
local months 01 02 03 04 05 06 07 08 09 10 11 12

forvalues yr = 1969(1)2017{
	foreach mn in `months' {
		clear
		import delimited "${in_dir}/amc_rainfall_csv/`yr'-`mn'-01_amc_rainfall.csv"
		capture save "${tmp_dir}/`yr'-`mn'-01_amc_rainfall.dta", replace
		clear	
	}	
}

* append data
clear

local months 01 02 03 04 05 06 07 08 09 10 11 12
forvalues yr = 1969(1)2017{
	foreach mn in `months' {	
		append using "${tmp_dir}/`yr'-`mn'-01_amc_rainfall.dta"
	}	
}

* run defintions
do "${code_dir}/_definitions.do"

global weather_type = "rainfall"
*display `weather_type'

* run code to build variables
local censusyr 1985 1995 2006 2017
foreach v in `censusyr' {	
do "${code_dir}/_building_weather_variables.do"	 `v'
}	


**********************************
** 	Do files for temperature 	**
**********************************

* extract files .csv
clear
cd  "${in_dir}/amc_temperature_csv"
pwd

* set files
local files : dir . files "*.csv"
display `files'

* loop over files to extract temperature and save as .dta at the temporary directory
local months 01 02 03 04 05 06 07 08 09 10 11 12

forvalues yr = 1969(1)2017{
	foreach mn in `months' {
		clear
		import delimited "${in_dir}/amc_temperature_csv/`yr'-`mn'-01_amc_temperature.csv"
		capture save "${tmp_dir}/`yr'-`mn'-01_amc_temperature.dta", replace
		clear	
	}	
}

* append data
clear

local months 01 02 03 04 05 06 07 08 09 10 11 12
forvalues yr = 1969(1)2017{
	foreach mn in `months' {	
		append using "${tmp_dir}/`yr'-`mn'-01_amc_temperature.dta"
	}	
}

* run defintions
do "${code_dir}/_definitions.do"

global weather_type = "temperature"
*display `weather_type'

* run code to build variables
local censusyr 1985 1995 2006 2017
foreach v in `censusyr' {	
do "${code_dir}/_building_weather_variables.do"	 `v'
}

/*
* save data in output
save "${out_dir}/inmet.dta", replace
	
* delete temporary files

cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.dta"
foreach datafile of local datafiles {
        rm `datafile'
}

cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.csv"
foreach datafile of local datafiles {
        rm `datafile'
}

cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.txt"
foreach datafile of local datafiles {
        rm "`datafile'"
}


cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.pdf"
foreach datafile of local datafiles {
        rm `datafile'
}

* clear all
clear

					
