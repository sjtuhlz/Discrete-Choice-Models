/*
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
bysort grp: egen choice_grp = max(y)


ml model d0 myclogit (y = time cost if grp == 0, noconstant) 
ml search
ml max 
capture drop xb
predict xb
sort i grp
egen double xb_expsum = total(exp(xb)), by(i grp)
preserve
collapse choice_grp xb_expsum, by(i grp) 

capture program drop mynlogit
program define mynlogit
	args todo b lnf  
 	tempvar sigma
	mleval `sigma' = `b'
	quietly{
	tempvar nom  denom p
	gen double `nom' = xb_expsum ^ (1- `sigma')
	egen double `denom' = total(`nom'), by(i)
	gen double `p' = `nom' / `denom'
	mlsum `lnf' = ln(`p') if choice_grp  == 1
	}
end

ml model d0 mynlogit  /sigma
ml search
ml max, difficult

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








