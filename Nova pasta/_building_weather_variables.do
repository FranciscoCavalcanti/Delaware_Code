/*
The objectives of the do file are:

1) average quarterly weather data relate to previous 15 years
2) standard deviation of quarterly weather data relate to previous 15 years
3) dummy variables of quarterly weather data percentiles (5, 10, 30, 50, 70, 90, 95) in the census years in relation to the previous 15 years

*/


local  weather_type $weather_type

* preserve
preserve

	* keep relevant variables
	keep if census_period`1' ==1
	
	* convert from monthly data to quarterly data
	sort munic amc0010 year month
	sum date_monthly
	local max_iten  = r(max) +3 // this will be inportant in the "cut" command
	local min_iten = r(min)	
	egen continuos_quarter = cut(date_monthly), at(`min_iten'(3)`max_iten')		
	
	* collapse on a quarterly basis (sum monthly weather data)
	collapse (sum) monthly_`weather_type' (firstnm) year homogeneous_quarter`1' influence`1' window_weather`1', by(continuos_quarter munic amc0010)	
	sort munic amc0010 continuos_quarter homogeneous_quarter`1'
	rename monthly_`weather_type' quartely_`weather_type'
	
	*	1) average quarterly weather data relate to previous 15 years
	by munic amc0010 homogeneous_quarter`1', sort: egen iten1 = mean(quartely_`weather_type') if window_weather`1'==1
	by munic amc0010 homogeneous_quarter`1', sort: egen av_quarterly_`weather_type'_`1' = mode(iten1)
	drop iten*
	
	*	2) standard deviation of quarterly weather data relate to previous 15 years
	by munic amc0010 homogeneous_quarter`1', sort: egen iten1 = sd(quartely_`weather_type') if window_weather`1'==1
	by munic amc0010 homogeneous_quarter`1', sort: egen sd_quarterly_`weather_type'_`1' = mode(iten1)
	drop iten*
	
	*	3) dummy variables of quarterly weather data percentiles (5, 10, 30, 50, 70, 90, 95) in the census years in relation to the previous 15 years
	
		** a) generate percentile limits
	by munic amc0010 homogeneous_quarter`1', sort: egen iten1 = pctile(quartely_`weather_type') if window_weather`1'==1, p(5)
	by munic amc0010 homogeneous_quarter`1', sort: egen pc5_quarterly_`weather_type'_`1' = mode(iten1)
	drop iten*

	by munic amc0010 homogeneous_quarter`1', sort: egen iten1 = pctile(quartely_`weather_type') if window_weather`1'==1, p(10)
	by munic amc0010 homogeneous_quarter`1', sort: egen pc10_quarterly_`weather_type'_`1' = mode(iten1)
	drop iten*

	by munic amc0010 homogeneous_quarter`1', sort: egen iten1 = pctile(quartely_`weather_type') if window_weather`1'==1, p(30)
	by munic amc0010 homogeneous_quarter`1', sort: egen pc30_quarterly_`weather_type'_`1' = mode(iten1)
	drop iten*
	
	by munic amc0010 homogeneous_quarter`1', sort: egen iten1 = pctile(quartely_`weather_type') if window_weather`1'==1, p(50)
	by munic amc0010 homogeneous_quarter`1', sort: egen pc50_quarterly_`weather_type'_`1' = mode(iten1)
	drop iten*
	
	by munic amc0010 homogeneous_quarter`1', sort: egen iten1 = pctile(quartely_`weather_type') if window_weather`1'==1, p(70)
	by munic amc0010 homogeneous_quarter`1', sort: egen pc70_quarterly_`weather_type'_`1' = mode(iten1)
	drop iten*
	
	by munic amc0010 homogeneous_quarter`1', sort: egen iten1 = pctile(quartely_`weather_type') if window_weather`1'==1, p(90)
	by munic amc0010 homogeneous_quarter`1', sort: egen pc90_quarterly_`weather_type'_`1' = mode(iten1)
	drop iten*
	
	by munic amc0010 homogeneous_quarter`1', sort: egen iten1 = pctile(quartely_`weather_type') if window_weather`1'==1, p(95)
	by munic amc0010 homogeneous_quarter`1', sort: egen pc95_quarterly_`weather_type'_`1' = mode(iten1)
	drop iten*
	
		** b) generate dummy variables
	gen dummy1_`1' =0
	replace dummy1_`1' =1 if quartely_`weather_type' >= 0 & quartely_`weather_type' <=  pc5_quarterly_`weather_type'_`1'
	gen dummy2_`1' =0
	replace dummy2_`1' =1 if quartely_`weather_type' > pc5_quarterly_`weather_type'_`1' & quartely_`weather_type' <=  pc10_quarterly_`weather_type'_`1'
	gen dummy3_`1' =0
	replace dummy3_`1' =1 if quartely_`weather_type' > pc10_quarterly_`weather_type'_`1' & quartely_`weather_type' <=  pc30_quarterly_`weather_type'_`1'
	gen dummy4_`1' =0
	replace dummy4_`1' =1 if quartely_`weather_type' > pc30_quarterly_`weather_type'_`1' & quartely_`weather_type' <=  pc50_quarterly_`weather_type'_`1'
	gen dummy5_`1' =0
	replace dummy5_`1' =1 if quartely_`weather_type' > pc50_quarterly_`weather_type'_`1' & quartely_`weather_type' <=  pc70_quarterly_`weather_type'_`1'
	gen dummy6_`1' =0
	replace dummy6_`1' =1 if quartely_`weather_type' > pc70_quarterly_`weather_type'_`1' & quartely_`weather_type' <=  pc90_quarterly_`weather_type'_`1'
	gen dummy7_`1' =0
	replace dummy7_`1' =1 if quartely_`weather_type' > pc90_quarterly_`weather_type'_`1' & quartely_`weather_type' <=  pc95_quarterly_`weather_type'_`1'
	gen dummy8_`1' =0
	replace dummy8_`1' =1 if quartely_`weather_type' > pc95_quarterly_`weather_type'_`1'

	*	keep and order relevant variables
	keep if influence`1'==1 	// keep data referring to the period of climate influence during the collection of census data
	keep continuos_quarter homogeneous_quarter`1' av_* sd_* dummy* amc0010 munic quartely_`weather_type' 
	sort amc0010 munic continuos_quarter homogeneous_quarter`1'
	order amc0010 munic continuos_quarter homogeneous_quarter`1' quartely_`weather_type' av_* sd_* dummy* 
	
	* Edit final variables
	label variable av_quarterly_`weather_type'_`1' "Average quarterly `weather_type' relate to previous 15 year"
	label variable sd_quarterly_`weather_type'_`1' "Standard deviation of quarterly `weather_type' relate to previous 15 years"
	label variable dummy1_`1' "Quarterly `weather_type' below percentil 5"
	label variable dummy2_`1' "Quarterly `weather_type' between percentiles 5 and 10"
	label variable dummy3_`1' "Quarterly `weather_type' between percentiles 10 and 30"
	label variable dummy4_`1' "Quarterly `weather_type' between percentiles 30 and 50"
	label variable dummy5_`1' "Quarterly `weather_type' between percentiles 50 and 70"
	label variable dummy6_`1' "Quarterly `weather_type' between percentiles 70 and 90"
	label variable dummy7_`1' "Quarterly `weather_type' between percentiles 90 and 95"
	label variable dummy8_`1' "Quarterly `weather_type' above percentil 95"
	
	*save as temporary file
	save "${tmp_dir}/average_quarterly_`weather_type'_`1'.dta", replace	
	
* restore
restore	