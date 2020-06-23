/* 
	Census years:
	
    A) 1985
 	(15 years window)
	Jul 1969 - Jun 1984 
	(Weather influence - 18 months)
	Jul 1984 - Dez 1985 
	
    B) 1995 - 96
	(15 years window)
	Feb 1980 - Jan 1995
	(Weather influence - 18 months)
	Feb 1995 - Jul 1996
	
    C) 2006
	(15 years window)
	Jul 1990 - Jun 2005
	(Weather influence - 18 months)
	Jul 2005 - Dez 2006
	
    D) 2017 - 18
	(15 years window)
	Apr 2001 - Mar 2016
	(Weather influence - 18 months)
	Apr 2016 - Sep 2017
	
*/

* Edit variables
cap drop v1
gen year = substr(date,1,4)
destring year, replace

gen month = substr(date,6,2)
destring month, replace

* sort
sort munic amc0010 year month

* generate variable of monthly date
	tostring year, gen(iten1)
	tostring month, gen(iten2)
	gen iten3 = iten1 + "." + iten2
	gen  date_monthly = monthly(iten3, "YM")
	drop iten*

* Indicate the begin of weather time window
gen yrwindow_begin = .
replace yrwindow_begin =1  if year == 1969 & month == 7 //Jul 1969
replace yrwindow_begin =1 if year == 1980 & month == 2 	//Feb 1980
replace yrwindow_begin =1 if year == 1990 & month == 7 	//Jul 1990
replace yrwindow_begin =1 if year == 2001 & month == 4 	//Apr 2001

* Indicate the end of weather time window
gen yrwindow_end = .
replace yrwindow_end =1 if year == 1984 & month == 6 	//Jun 1984 
replace yrwindow_end =1 if year == 1995 & month == 1 	//Jan 1995
replace yrwindow_end =1 if year == 2005 & month == 6 	//Jun 2005
replace yrwindow_end =1 if year == 2016 & month == 3 	//Mar 2016

* Indicate the begin of weather influence period
gen yrinfluence_begin = .
replace yrinfluence_begin =1  if year == 1984 & month == 7 	//Jul 1984
replace yrinfluence_begin =1 if year == 1995 & month == 2 	//Feb 1995
replace yrinfluence_begin =1 if year == 2005 & month == 7 	//Jul 2005
replace yrinfluence_begin =1 if year == 2016 & month == 4 	//Apr 2016

* Indicate the end of weather influence period
gen yrinfluence_end = .
replace yrinfluence_end =1 if year == 1985 & month == 12 	//Dez 1985 
replace yrinfluence_end =1 if year == 1996 & month == 7 	//Jul 1996
replace yrinfluence_end =1 if year == 2006 & month == 12 	//Dez 2006
replace yrinfluence_end =1 if year == 2017 & month == 9 	//Sep 2017

* determine each census period
/* look here:
tab date_monthly if yrwindow_begin ==1
tab date_monthly if yrinfluence_end ==1
*/
generate census_period1985 = .
replace census_period1985 = 1 if date_monthly >= 114 & date_monthly <= 311

generate census_period1995 = .
replace census_period1995 = 1 if date_monthly >= 241 & date_monthly <= 438

generate census_period2006 = .
replace census_period2006 = 1 if date_monthly >= 366 & date_monthly <= 563

generate census_period2017 = .
replace census_period2017 = 1 if date_monthly >= 495 & date_monthly <= 692

* determine each weather data collection of 15 years window
/* look here:
tab date_monthly if yrwindow_begin ==1
tab date_monthly if yrwindow_end ==1
*/
generate window_weather1985 = .
replace window_weather1985 = 1 if date_monthly >= 114 & date_monthly <= 293

generate window_weather1995 = .
replace window_weather1995 = 1 if date_monthly >= 241 & date_monthly <= 420

generate window_weather2006 = .
replace window_weather2006 = 1 if date_monthly >= 366 & date_monthly <= 545

generate window_weather2017 = .
replace window_weather2017 = 1 if date_monthly >= 495 & date_monthly <= 674

* determine each weather data collection of 15 years window
/* look here:
tab date_monthly if yrinfluence_begin ==1
tab date_monthly if yrinfluence_end ==1
*/
generate influence1985 = .
replace influence1985 = 1 if date_monthly >= 294 & date_monthly <= 311

generate influence1995 = .
replace influence1995 = 1 if date_monthly >= 421 & date_monthly <= 538

generate influence2006 = .
replace influence2006 = 1 if date_monthly >= 546 & date_monthly <= 563

generate influence2017 = .
replace influence2017 = 1 if date_monthly >= 675 & date_monthly <= 692

*********************************************
* generate homogeneous quarterly periods
*********************************************

* census 1985
gen homogeneous_quarter1985 =.

	* what is the number of the month that the time windown begins?
	gen iten1 = month if  yrwindow_begin ==1 &  census_period1985==1
	/*
	tab iten1
	*/
	drop iten*
	
	replace homogeneous_quarter1985 = 1 if census_period1985==1 & month == 7 	// Jul 1969
	replace homogeneous_quarter1985 = 1 if census_period1985==1 & month == 8
	replace homogeneous_quarter1985 = 1 if census_period1985==1 & month == 9
	
	replace homogeneous_quarter1985 = 2 if census_period1985==1 & month == 10
	replace homogeneous_quarter1985 = 2 if census_period1985==1 & month == 11
	replace homogeneous_quarter1985 = 2 if census_period1985==1 & month == 12
	
	replace homogeneous_quarter1985 = 3 if census_period1985==1 & month == 1
	replace homogeneous_quarter1985 = 3 if census_period1985==1 & month == 2
	replace homogeneous_quarter1985 = 3 if census_period1985==1 & month == 3
	
	replace homogeneous_quarter1985 = 4 if census_period1985==1 & month == 4
	replace homogeneous_quarter1985 = 4 if census_period1985==1 & month == 5
	replace homogeneous_quarter1985 = 4 if census_period1985==1 & month == 6
	
* census 1995
gen homogeneous_quarter1995 =.

	* what is the number of the month that the time windown begins?
	gen iten1 = month if  yrwindow_begin ==1 &  census_period1995==1
	/*
	tab iten1
	*/
	drop iten*
	
	replace homogeneous_quarter1995 = 1 if census_period1995==1 & month == 2 	// Feb 1980
	replace homogeneous_quarter1995 = 1 if census_period1995==1 & month == 3
	replace homogeneous_quarter1995 = 1 if census_period1995==1 & month == 4
	
	replace homogeneous_quarter1995 = 2 if census_period1995==1 & month == 5
	replace homogeneous_quarter1995 = 2 if census_period1995==1 & month == 6
	replace homogeneous_quarter1995 = 2 if census_period1995==1 & month == 7
	
	replace homogeneous_quarter1995 = 3 if census_period1995==1 & month == 8
	replace homogeneous_quarter1995 = 3 if census_period1995==1 & month == 9
	replace homogeneous_quarter1995 = 3 if census_period1995==1 & month == 10
	
	replace homogeneous_quarter1995 = 4 if census_period1995==1 & month == 11
	replace homogeneous_quarter1995 = 4 if census_period1995==1 & month == 12
	replace homogeneous_quarter1995 = 4 if census_period1995==1 & month == 1	

* census 2006
gen homogeneous_quarter2006 =.

	* what is the number of the month that the time windown begins?
	gen iten1 = month if  yrwindow_begin ==1 &  census_period2006==1
	/*
	tab iten1
	*/
	drop iten*
	
	replace homogeneous_quarter2006 = 1 if census_period2006==1 & month == 7 	// Jul 1990
	replace homogeneous_quarter2006 = 1 if census_period2006==1 & month == 8
	replace homogeneous_quarter2006 = 1 if census_period2006==1 & month == 9
	
	replace homogeneous_quarter2006 = 2 if census_period2006==1 & month == 10
	replace homogeneous_quarter2006 = 2 if census_period2006==1 & month == 11
	replace homogeneous_quarter2006 = 2 if census_period2006==1 & month == 12
	
	replace homogeneous_quarter2006 = 3 if census_period2006==1 & month == 1
	replace homogeneous_quarter2006 = 3 if census_period2006==1 & month == 2
	replace homogeneous_quarter2006 = 3 if census_period2006==1 & month == 3
	
	replace homogeneous_quarter2006 = 4 if census_period2006==1 & month == 4
	replace homogeneous_quarter2006 = 4 if census_period2006==1 & month == 5
	replace homogeneous_quarter2006 = 4 if census_period2006==1 & month == 6

* census 2017
gen homogeneous_quarter2017 =.

	* what is the number of the month that the time windown begins?
	gen iten1 = month if  yrwindow_begin ==1 &  census_period2017==1
	/*
	tab iten1
	*/
	drop iten*
	
	replace homogeneous_quarter2017 = 1 if census_period2017==1 & month == 4 	// Apr 2001
	replace homogeneous_quarter2017 = 1 if census_period2017==1 & month == 5
	replace homogeneous_quarter2017 = 1 if census_period2017==1 & month == 6
	
	replace homogeneous_quarter2017 = 2 if census_period2017==1 & month == 7
	replace homogeneous_quarter2017 = 2 if census_period2017==1 & month == 8
	replace homogeneous_quarter2017 = 2 if census_period2017==1 & month == 9
	
	replace homogeneous_quarter2017 = 3 if census_period2017==1 & month == 10
	replace homogeneous_quarter2017 = 3 if census_period2017==1 & month == 11
	replace homogeneous_quarter2017 = 3 if census_period2017==1 & month == 12
	
	replace homogeneous_quarter2017 = 4 if census_period2017==1 & month == 1
	replace homogeneous_quarter2017 = 4 if census_period2017==1 & month == 2
	replace homogeneous_quarter2017 = 4 if census_period2017==1 & month == 3