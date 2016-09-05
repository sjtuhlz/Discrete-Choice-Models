



***********************************

**PART 1

***********************************


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
 


***********************************

**PART 2

***********************************

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




***********************************

**PART 3

***********************************
capture program drop myclogitprogram define myclogit	args todo b lnf  	tempvar xb denom p	mleval `xb' = `b'	egen double `denom' = total(exp(`xb')), by(i)	quietly {	gen double `p' = exp(`xb')/`denom'	mlsum `lnf' = ln(`p') if $ML_y1 == 1	} end use data.dta, clearml model d0 myclogit (y = time cost, noconstant)ml searchml max** canned clogit & asclogitclogit y time cost, group(i) asclogit y time cost, case(i) alt(j) noconsgen betatime = _b[time]gen betacost = _b[cost]collapse cost time betatime betacost, by(j)gen num = exp(cost*betacost + time*betatime)egen den = sum(num)gen prob = num/dengen ptrain = prob if j == 2egen probtrain = sum(ptrain)gen change = -betatime*prob*probtrain*50gen pair = prob if j == 1egen probair = sum(pair)gen pbus = prob if j == 3egen probbus = sum(pbus)gen groupprob = probtrain + probbus + probairgen cptrain = probtrain/groupprobgen sig = .25 gen change2 = ((sig)*cptrain + (1-sig)*(probtrain))*(-betatime/(1-sig))*prob*50replace change2 = -betatime*probtrain*prob*50 if j==4replace sig =.75gen change3 = ((sig)*cptrain + (1-sig)*(probtrain))*(-betatime/(1-sig))*prob*50replace change3 = -betatime*probtrain*prob*50 if j==4drop if j == 2mkmat change change2 change3, matrix(A)matrix rownames A = Airplane Bus Carmatrix colnames A = CLogit .25 .75outtable using logittable, mat(A) nobox caption ("Estimated Change in P from a 50 minute increase in Train Travel") replace





**********************************

**PART 4

**********************************


use rust.dta, clear

********************************************************************
** Step 1: Trans prob
********************************************************************
qui tab mileage mileagenext,  matcell(markov)

**Find trans probabilities from states 1 to next etc, but not 0 to 1
  mat trans=J(9,1,.)
  forvalues j=1(1)9 {
    mat trans[`j',1]=markov[`j'+1,`j'+2]/(markov[`j'+1,`j'+2]+markov[`j'+1,`j'+1])
  }

**Find trans probabilities from state 0 to state 1
  count if mileagenext<2
  local denom=r(N)

  count if mileagenext==1
  local nom=r(N)

  mat trans=(`nom'/`denom')\trans
  mat trans=trans\trans[10,1]
  //mat trans=trans\0
  
  *************************
  
  /*COMMENT 1: We tried changing the transition matrix (last row) to 0 because
   it did not make sense that something moves to state 11 when this state does
    not exist.  It didn't solve the problem with the likelihood function. */
    
   ************************

********************************************************************
** Step 2: Run logit on deltas
********************************************************************

  ******************************
  * Contraction Mapping Program
  ******************************
  capture program drop cmap
  program cmap
    args k1 k2 k3

    **************************************
    **Iterates while differnce is above tolerance
      while $dif>$tol {
        mat deltasold=deltas

        **Computes new detlas given old deta mat
          forvalues j=1(1)10 {
	    **?????
	    //local k1=`alpha1'
	    //local k2=`alpha2'
	    //local k3=`RC'

	    mat deltas[`j',1]=`k1'*(`j'-1)+`k2'*(`j'-1)^2+ ///
		        .95*trans[`j',1]    *(ln(exp(deltasold[`j'+1,1])+exp(deltasold[`j'+1,2])))+ ///
		        .95*(1-trans[`j',1])*(ln(exp(deltasold[`j',1])+exp(deltasold[`j',2])))

	    mat deltas[`j',2]=`k3'+ ///
	    	        .95*trans[1,1]*(ln(exp(deltasold[2,1])+exp(deltasold[2,2])))+ ///
		        .95*(1-trans[1,1])*(ln(exp(deltasold[1,1])+exp(deltasold[1,2])))
          }
	  //mat deltas[11,1]=deltas[10,1]
	  //mat deltas[11,2]=deltas[10,2]
	  
	  *************************************************************************
	  
	  /*COMMENT 2:
	  
	  Conceptually we think it makes sense that the transition matrix should 
	  start from the zero-th row.  So changing j+1 to j in the transition matrix 
	  makes the delta 0 column vary like we want but the last row does not
	   iterate.  If we don't comment out the previous two lines all the rows in 
	   delta zero were the same. */
	   
	  ************************************************************************* 
	  
	  mat list deltas

	**Calculate the dif
	  mat dif=deltas-deltasold
	  cap drop dif1 dif2
	  svmat dif
	  forvalues j=1(1)2 {
  	    replace dif`j'=abs(dif`j')
	    qui sum dif`j'
	    local dif`j'=r(sum)
	  }
	  global dif=`dif1'+`dif2'
	  mat list deltas
      }
    **************************************

   end
  ******************************

  *************************
  * Binary Logit program
  *************************
  capture program drop myLogit
  program myLogit
    args todo b lnf
    tempvar alpha1 alpha2 RC lj
    mleval `alpha1'=`b', eq(1)
    mleval `alpha2'=`b', eq(2)
    mleval `RC'=`b', eq(3)

    **Creates correct values for delta0 and delta1 (an 11,2 matrix)
      mat deltas=J(11,2,1)    

      local k1=`alpha1'
      local k2=`alpha2'
      local k3=`RC'
      cmap `k1' `k2' `k3'

   *************************************
   
   /*COMMENT 3:
   Since stata didn't like the alpha terms in office hours, we tried changing 
   them here too.  Didn't solve the problem.*/
   
   **************************************
   
    **Finds probability of action given deltas
      quietly {
        gen double `lj'=exp(deltas[x+1,2])/(exp(deltas[x+1,1])+exp(deltas[x+1,2]))  if i==1
	replace `lj'=exp(deltas[x+1,1])/(exp(deltas[x+1,1])+ exp(deltas[x+1,2] ))   if i==0
	mlsum `lnf'=ln(`lj')
      }
   end
   *************************

   ***********************************
   
   /*COMMENT 4:
   
   Again conceptually it makes more sense to change from deltas[x, 2] to 
   deltas[x+1,2] and similarly for all the other applicable parts.  This is due
    to the fact that x can be zero so we need the 'zero row', which is actually
     the first row!*/
     
   ***********************************
   
  **************************************
  * Sets up data and calls binary logit
  **************************************
  gen i=replace
  gen x=mileage
  gen x2=x*x
  global tol=.001
  global dif=.01

  ml model d0 myLogit /alpha1 /alpha2 /RC
  ml search
  ml max, difficult
  
  ******************************************
  
  /*COMMENT 5:
  The problem is that the likelihood function is not maximizing since the 
  derivative cannot be calculated since there are discontinuous regions.  
  We tried doing "difficult", reducing tolerance, and changing the likelihood
   function but none of this helped. */

********************************************************************
