use rust.dta

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

********************************************************************
** Step 2: Run logit on deltas
********************************************************************

  ******************************
  * Contraction Mapping Program
  ******************************
  capture program drop cmap
  program cmap
    args alpha1 alpha2 RC

    **************************************
    **Iterates while differnce is above tolerance
      while $dif>$tol {
        mat deltasold=deltas

        **Computes new detlas given old deta mat
          forvalues j=1(1)10 {
	    **?????
	    local k1=`alpha1'
	    local k2=`alpha2'
	    local k3=`RC'

	    mat deltas[`j',1]=`k1'*(`j'-1)+`k2'*(`j'-1)^2+ ///
		        .95*trans[`j'+1,1]    *(ln(exp(deltasold[`j'+1,1])+exp(deltasold[`j'+1,2])))+ ///
		        .95*(1-trans[`j'+1,1])*(ln(exp(deltasold[`j',1])+exp(deltasold[`j',2])))

	    mat deltas[`j',2]=`k3'+ ///
	    	        .95*trans[1,1]*(ln(exp(deltasold[2,1])+exp(deltasold[2,2])))+ ///
		        .95*(1-trans[1,1])*(ln(exp(deltasold[1,1])+exp(deltasold[1,2])))
          }
	  mat deltas[11,1]=deltas[10,1]
	  mat deltas[11,2]=deltas[10,2]

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
      mat deltas=J(11,2,0)    

      cmap `alpha1' `alpha2' `RC'

    **Finds probability of action given deltas
      quietly {
        gen     `lj'=exp(deltas[x,2])/(exp(deltas[x,1])+exp(deltas[x,2]))  if i==1
	replace `lj'=exp(deltas[x,1])/(exp(deltas[x,1])+ exp(deltas[x,2] ))   if i==0
	mlsum `lnf'=ln(`lj')
      }
   end
   *************************

  **************************************
  * Sets up data and calls binary logit
  **************************************
  gen i=replace
  gen x=mileage
  gen x2=x*x
  global tol=.01
  global dif=.02

  ml model d0 myLogit /alpha1 /alpha2 /RC
  ml max

********************************************************************
