
local scheme `1'

if "`scheme'" == "" {
	di in red "scheme required"
	exit 198
}

capture mkdir `scheme'
cd `scheme'

* scatter
sysuse auto
sc mpg price, scheme(`scheme')
graph export `scheme'_1.svg, replace

sc mpg price weight, scheme(`scheme')
graph export `scheme'_2.svg, replace

sc mpg price || mband mpg price, scheme(`scheme')
graph export `scheme'_3.svg, replace

sysuse sandstone, clear
sc depth northing if collection == 1 || 	/// 
	sc depth northing if collection == 2, scheme(`scheme')
graph export `scheme'_4.svg, replace

* line
sysuse uslifeexp, clear
line le_wfemale year || line le_bfemale year, 	/// 
	legend(label(1 "White females") 			/// 
	label(2 "Black females")) 					/// 
	title("Life expectancy") 					/// 
	note("U.S. life expectancy for females, 1900-1999") 	/// 
	scheme(`scheme')
graph export `scheme'_5.svg, replace

* bar
sysuse sp500, clear
twoway bar open date in 1/20, scheme(`scheme')
graph export `scheme'_6.svg, replace

twoway bar open date in 1/50, scheme(`scheme')
graph export `scheme'_7.svg, replace

use https://www.stata-press.com/data/r18/nlsw88, clear
graph bar wage, over(smsa) over(married) over(collgrad) scheme(`scheme')
graph export `scheme'_8.svg, replace

use https://stats.oarc.ucla.edu/stat/stata/notes/hsb2.dta, clear
collapse (mean) meanwrite= write (sd) sdwrite=write (count) n=write, by(race ses)
generate hiwrite = meanwrite + invttail(n-1,0.025)*(sdwrite / sqrt(n))
generate lowrite = meanwrite - invttail(n-1,0.025)*(sdwrite / sqrt(n))
graph bar meanwrite, over(race) over(ses) asyvars scheme(`scheme')
graph export `scheme'_9.svg, replace

* lfitci
sysuse auto, clear
twoway lfitci mpg weight || scatter mpg weight, scheme(`scheme')
graph export `scheme'_a1.svg, replace

* box
use https://www.stata-press.com/data/r17/bplong, clear
graph box bp, over(when) over(sex)		///
	ytitle("Systolic blood pressure")	///
	title("Response to Treatment, by Sex")		///
	subtitle("(120 Preoperative Patients)" " ")	///
	note("Source: Fictional Drug Trial, StataCorp, 2003")	///
	scheme(`scheme')
graph export `scheme'_a2.svg, replace

use https://www.stata-press.com/data/r17/bpwide, clear
graph box bp_before bp_after, over(sex) scheme(`scheme')
graph export `scheme'_a3.svg, replace


sysuse pop2000, clear
list agegrp maletotal femtotal
replace maletotal = -maletotal/1e+6
replace femtotal = femtotal/1e+6
twoway bar maletotal agegrp, horizontal xvarlab(Males)		/// 
	|| bar  femtotal agegrp, horizontal xvarlab(Females)	///
    || , ylabel(1(1)17, angle(horizontal) valuelabel labsize(*.8))	///
         xtitle("Population in millions") ytitle("")	///
         xlabel(-10 "10" -7.5 "7.5" -5 "5" -2.5 "2.5" 2.5 5 7.5 10)	///
         legend(label(1 Males) label(2 Females))	///
         title("US Male and Female Population by Age")	///
         subtitle("Year 2000")	///
         note("Source: U.S. Census Bureau, Census 2000, Tables 1, 2 and 3", span)	///
		 scheme(`scheme')
graph export `scheme'_a4.svg, replace

sysuse auto, clear
sc mpg price || mband mpg price, xline(1500) yline(25) scheme(`scheme')
graph export `scheme'_a5.svg, replace

sysuse sandstone, clear
sc depth northing if collection == 1 || 	/// 
	sc depth northing if collection == 2, xline(75000) yline(7820) scheme(`scheme')
graph export `scheme'_a6.svg, replace

sysuse uslifeexp, clear
line le_wfemale year || line le_bfemale year, 	/// 
	legend(label(1 "White females") 			/// 
	label(2 "Black females")) 					/// 
	title("Life expectancy") 					/// 
	note("U.S. life expectancy for females, 1900-1999")	///
	xline(1950) yline(55) scheme(`scheme')
graph export `scheme'_a7.svg, replace
	
	
clear
* marginsplot
webuse nhanes2, clear
qui {
	regress bpsystol agegrp##sex##c.bmi
	margins agegrp, over(sex) at(bmi=(10(10)60))
}
marginsplot, scheme(`scheme')
graph export `scheme'_a8.svg, replace

sysuse nlsw88, clear
graph bar wage if occ<9, over(occ) asyvars over(union) scheme(`scheme')
graph export `scheme'_a9.svg, replace

* eample from Germán Rodríguez's https://data.princeton.edu/stata/graphics
clear
infile str14 country setting effort change using https://data.princeton.edu/wws509/datasets/effort.raw, clear
gen pos=3
replace pos = 11 if country == "TrinidadTobago"
replace pos = 9 if country == "CostaRica"
replace pos = 2 if country == "Panama" | country == "Nicaragua"

graph twoway (lfitci change setting) ///
          (scatter change setting, mlabel(country) mlabv(pos) ) ///
        , title("Fertility Decline by Social Setting") ///
          ytitle("Fertility Decline") ///
          legend(ring(0) pos(5) order(2 "linear fit" 1 "95% CI")) 		  
graph export `scheme'_b1.svg, replace

* example from https://github.com/graykimbrough/uncluttered-stata-graphs/blob/master/examples/sample_labeled_uncluttered_graph.do
clear
do 3dos/sample
graph twoway (connected pct_lfp year if sex==1, `label_opts')	///
  (connected pct_lfp year if sex==2, `label_opts'),	///
    name(lfp_year_gender, replace)	///
    xlabel(1970 (5) 2015)	///
    xscale(r(1970 2023))	///
    ytitle("")		///
    ylabel(,value)	///
    xtitle("")		///
    subtitle("Percentage of 21-30 year olds in the labor force",	///
      justification(left) margin(b+1 t-1) bexpand)		///
    note("Excludes armed forces. Source: 1968-2017 ASEC samples from IPUMS-CPS (cps.ipums.org), @graykimbrough",	///
      margin(l-8 t+2 b-2))
graph export `scheme'_b2.svg, replace

cd ..
di "all is well" 