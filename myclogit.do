
*** Clogit***************

capture program drop myclogit
program define myclogit
	args todo b lnf  
	tempvar xb denom p
	mleval `xb' = `b'
	egen double `denom' = total(exp(`xb')), by(i)
	quietly {
	gen double `p' = exp(`xb')/`denom'
	mlsum `lnf' = ln(`p') if $ML_y1 == 1
	} 
end
 

/*
use data.dta, clear
ml model d0 myclogit (y = time cost, noconstant)
ml search
ml max
** canned clogit & asclogit
clogit y time cost, group(i) 
asclogit y time cost, case(i) alt(j) nocons
*/

***** Nlogit
use data.dta, clear
capture drop grp
gen grp = j == 4
capture drop choice_grp
bysort grp i: egen choice_grp = max(y)

ml model d0 myclogit (y = time cost if grp == 0, noconstant) 
ml search
ml max 
capture drop xb
predict xb
sort i grp
egen double xb_expsum = total(exp(xb)), by(i grp)

forvalues j=0(1)1 {
  gen temp_sum_`j'=xb_expsum if grp==`j'
  bysort i: egen sum_`j'=max(temp_sum_`j')
}
cap drop *temp* xb_expsum

capture program drop mynlogit
program define mynlogit
	args todo b lnf  
 	tempvar sigma alpha p
	mleval `sigma' = `b'
	quietly{
	  gen double `p'=1
	  replace `p'=(sum_0^(1-`sigma')/(sum_0^(1-`sigma')+sum_1^(1-`sigma')))*(exp(xb)/sum_0) if y==1 & j<4
	  replace `p'=sum_1^(1-`sigma')/(sum_0^(1-`sigma')+sum_1^(1-`sigma')) if y==1 & j==4	  
	  mlsum `lnf' = ln(`p') if choice_grp  == 1
	}
	mat lls[$j,1]=$k
	mat lls[$j,2]=`lnf'

end

/*
**Declare model
  ml model d0 mynlogit  /sigma
  ml search
  ml max, difficult
stop
*/


**Loop over values of sigma between 0 and 1
  ml model d0 mynlogit  /sigma
  mat lls=J(98,2,0)
  global j=1
  forvalues sigma=.01(.01).99 {
    global k=$j/100
    ml init /sigma=`sigma'
    ml report
    global j=$j+1
  }
 
matrix colnames lls = sigma lnf
mat list lls

svmat double lls, names(col)
twoway (line lnf sigma)
graph2tex, epsfile(lnf_sigma) 

stop

ml search
ml max, difficult


**try svmat; moves matrix to variable environment
**then graph twoway (line ll sigma)
**graph2tex, eps(filename)
** ! epstopdf 
** in writeup .tex \includegraphics{filename} (which is a .pdf)
\usepackage{graphicx}
stop

restore
** canned nlogit
nlogit y time cost ||grp: ||j: ,case(i) noconst


/*
*** probabilities
nlogit y time cost ||grp: ||j: ,case(i) noconst
rename time time0 
rename cost cost0
bysort j: egen time = mean(time0)
bysort j: egen cost = mean(cost0)

predict y_predict

* but we don't know how to pull the 'tao'
*/








