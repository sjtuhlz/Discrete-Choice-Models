use upcsdr.dta, clear
gen brand = ""
local brands PEPSI COKE MOUNTAIN RITE PEPPER SPRITE SUNKIST TETLEY TOWNE SLICE OCEAN /*
 */STRBKS SPORT MUG DAD LACROIX SCHWEPPS SPARKLING QUIBELL CANADA BARRELHEAD HAWAIIAN FRUITOPIA /*
 */CROWN UPPER NEHI TYME DOM LIPTON CRUSH COUNTRY TROP TAB MINUTE FRESCA BARQ SELTZ /*
 */ SUNNY SQUIRT SUNDANCE BEACH A&W VERNORS ARTIC COW SEAGRAM ARIZONA FAYGO SNAPPLE /*
*/ WELCH CHAPELLE EVERLAST CORR CANFIELD PENAFIEL EVIAN NESTEA QUEST MISTIC GEYSER 


foreach lc of local brands {
	replace brand = "`lc'" if regexm(descrip,"`lc'")
}


replace brand = "7UP" if regexm(descrip,"7")
replace brand = "7UP" if regexm(descrip,"SEVEN")
replace brand = "NAT90" if regexm(descrip,"90")
replace brand = "RITE" if regexm(descrip,"R.C.")
replace brand = "A&W" if regexm(descrip,"A & W") | regexm(descrip,"A W ")
replace brand = "COKE" if regexm(descrip,"COCA")
replace brand = "SCHWEPPS" if regexm(descrip,"SCHWEPP")
replace brand = "WEST" if regexm(descrip,"WEST")
replace brand = "CELESTIAL" if regexm(descrip,"CELESTIAL")
replace brand = "GENERIC" if regexm(descrip,"GENERIC")
replace brand = "COKE" if regexm(descrip,"CLASSIC CO")
replace brand = "CANADA" if regexm(descrip,"CAN DRY")
replace brand = "TOWNE" if regexm(descrip,"OLD TOWN")
replace brand = "ENDURO" if regexm(descrip,"ENDURO")
replace brand = "TETLEY" if regexm(descrip,"TETELY")
replace brand = "PEPSI" if regexm(descrip,"CHERRY PEP")
replace brand = "MOUNTAIN" if regexm(descrip,"MOUNT") | regexm(descrip,"MT D") | regexm(descrip,"MTN ") | regexm(descrip," DEW") | regexm(descrip,"NT DE")
replace brand = "SCHWEPPS" if regexm(descrip,"SCHWP")
replace brand = "HAWAIIAN" if regexm(descrip,"HAWIIAN")
replace brand = "SLICE" if regexm(descrip," SLIC")
replace brand = "KICK" if regexm(descrip,"KICK")
replace brand = "THORSPRING" if regexm(descrip,"THORSPR")
replace brand = "NESBITT" if regexm(descrip,"NESBITT")
replace brand = "PEPPER" if regexm(descrip,"DR PEP")
replace brand = "GRAYSON" if regexm(descrip,"GRAYSON")
replace brand = "WORLDCLASSIC" if regexm(descrip,"WORLD ") | regexm(descrip,"WRLD CLASS")
replace brand = "SNAPPLE" if regexm(descrip,"SNP") & missing(brand)
replace brand = "RCCOLA" if regexm(descrip,"RC COLA") & missing(brand)
replace brand = "MINUTE" if regexm(descrip," MAID ") & missing(brand)
replace brand = "CANFIELD" if regexm(descrip,"CNFLD ") | regexm(descrip,"CANFILED") & missing(brand)
replace brand = "PERRIER" if regexm(descrip,"PERRIER") & missing(brand)
replace brand = "LACROIX" if regexm(descrip,"LA CROIX") & missing(brand)
replace brand = "CRYSTALGEY" if regexm(descrip,"CRYSTAL GEY ") | regexm(descrip,"C/G") & missing(brand)
replace brand = "COKE" if regexm(descrip," FREE CLASS") | regexm(descrip," FREE DIET C") & missing(brand)
replace brand = "CLEARCANADIAN" if regexm(descrip,"CANADIAN") & missing(brand)
replace brand = "CRYSTAL LIGHT" if regexm(descrip,"CRYSTAL LIGHT") & missing(brand)
replace brand = "IBCBEER" if regexm(descrip,"IBC ") | regexm(descrip,"I.B.C") & missing(brand)
replace brand = "GREENRIVER" if regexm(descrip,"GREEN RIVER") & missing(brand)
replace brand = "COLDSPRING" if regexm(descrip,"COLD SPRING") & missing(brand)
replace brand = "MELLO" if regexm(descrip,"MELLO ") & missing(brand)
replace brand = "POLANDSPR" if regexm(descrip,"POLAND SPRING") | regexm(descrip,"POL SPRING") & missing(brand)
replace brand = "CRYSTALGEY" if regexm(descrip,"CRYSTL G") & missing(brand)
replace brand = "BIGRED" if regexm(descrip,"BIG RED") & missing(brand)


****** calculate product size 
gen bkupsize = size
gen unit = "OZ" if regexm(size,"O")
replace unit = "LT" if regexm(size,"L") 


* new size is consistently OZ
gen tag = regexm(size,"/")
split size if tag, p("/")
destring size1, replace
destring size2, gen(size2num) i(O Z L)
gen size_new = size1 * size2num if unit == "OZ" & tag
replace size_new = size1 * size2num * 33.814 if unit == "LT" & tag
drop size1* size2*


split size if !tag
replace size1 = "." if size1 == "CANS" | size1 == "EA" | size1 == "EACH" | size1 == "FREE" | size == "MELONB" 
destring size1, gen(size1num) i(O Z L T)
replace size_new = size1num if unit == "OZ" & !tag
replace size_new = size1num * 33.814 if unit == "LT" & !tag
drop size1* size2*




*** characteristics of products
gen diet = 0
replace diet = 1 if regexm(descrip,"DIET")
replace diet = 1 if regexm(descrip," DT ") | regexm(descrip,"SUGAR FREE")
gen free = 0
replace free = 1 if regexm(descrip,"CAFF") | regexm(descrip,"FREE") | regexm(descrip,"C/F") 

gen cola = 0
replace cola = 1 if brand == "PEPSI" | brand == "COKE" | brand == "PEPPER" | brand == "RITE"  //waiting for more....
gen tea = 0
replace tea = 1 if regexm(descrip,"TEA") | brand == "TETELY" | brand == "LIPTON"
gen beer = 0
replace beer = 1 if regexm(descrip,"BEER") | brand == "BARQ"
replace beer = 1 if regexm(descrip,"ROOT") | regexm(descrip," RT ")
gen ale = 0
replace ale = 1 if regexm(descrip,"ALE") | regexm(descrip,"GINGER") | regexm(descrip,"GNGR") | regexm(descrip,"GING")
gen cream = 0
replace cream = 1 if regexm(descrip, "CREAM") //cream soda is just vanila-flavored soda
gen tonic = 0
replace tonic = 1 if regexm(descrip,"TONIC")
gen choc = 0
replace choc = 1 if regexm(descrip,"CHOC")


gen lemon = 0
replace lemon = 1 if regexm(descrip,"LEMON") | regexm(descrip,"LIME") | regexm(descrip,"CITRUS")
replace lemon = 1 if brand == "MOUNTAIN" | brand == "SPRITE"


gen orange = 0
replace orange = 1 if regexm(descrip, "ORANGE") | regexm(descrip," ORG ") | regexm(descrip," ORANG")| brand == "MOUNTAIN" 



//Should just set citrus, which includes both orange and lemon-lime (???)
gen citrus = 0
replace citrus = 1 if lemon | orange



//Should not set "PUNCH" as significantly different from other flavors in consumers' decision making
gen punch = 0
replace punch = 1 if regexm(descrip,"PUNCH") | regexm(descrip,"PNCH")



gen flav_etc = 0
replace flav_etc = 1 if regexm(descrip,"CHERRY") | regexm(descrip,"GRAPE") | regexm(descrip,"BERRY") | regexm(descrip,"FLAVOR")
replace flav_etc = 1 if regexm(descrip," RASP") | regexm(descrip," RSP")
replace flav_etc = 1 if regexm(descrip," GRP ") 
replace flav_etc = 1 if regexm(descrip,"APPLE") | regexm(descrip,"RAINBOW")
replace flav_etc = 1 if regexm(descrip,"CHRY") 
replace flav_etc = 1 if regexm(descrip,"KIWI") | regexm(descrip,"MANGO") | regexm(descrip,"PEACH")

replace flav_etc = 1 if punch == 1 //notice the change!!!


************** 
** (Updated Jun6, 2013)
**  Product characteristics are diet, cola, free, tea, beer, other ** 
gen other = 0
replace other =  1 if flav_etc == 1 | citrus == 1 | ale == 1| cream ==1| tonic == 1 | choc == 1 
**************

**Widely sold soft drink flavors are cola, cherry, lemon-lime, root beer, orange, 
**grape, vanilla, ginger ale, fruit punch, and lemonade.



*** Aggregate UPCs to products *********************
gen prod = ""
local colas PEPSI COKE PEPPER RITE MOUNTAIN SPRITE 7UP CROWN RCCOLA
//local colas RCCOLA 
foreach lc of local colas {
	//if brand == "`lc'" {
		replace prod = "`lc'_diet" if diet & !free & brand == "`lc'"
		replace prod = "`lc'_free" if !diet & free & brand == "`lc'"
		replace prod = "`lc'_diet_free" if diet & free & brand == "`lc'"
		*replace prod = "`lc'_flavor" if flav_etc & brand == "`lc'"
		replace prod = "`lc'_regular" if missing(prod) & brand == "`lc'"
	//}
}

local juicesoda SUNKIST MINUTE HAWAIIAN SLICE SCHWEPPS CRUSH CANFIELD SNAPPLE ARIZONA
//local juicesoda ARIZONA
foreach lc of local juicesoda {
		if diet{
			*replace prod = "`lc'_diet_orange" if orange & brand == "`lc'" 
 			*replace prod = "`lc'_diet_lemon" if lemon & brand == "`lc'" 
			*replace prod = "`lc'_diet_punch" if punch & brand == "`lc'" 
			*replace prod = "`lc'_diet_flavor" if flav_etc & brand == "`lc'" 
			*replace prod =  "`lc'_diet_ginger" if ale & brand == "`lc'"
			replace prod = "`lc'_diet_cola" if cola & brand == "`lc'"
			replace prod = "`lc'_regular" if missing(prod) & brand == "`lc'"
		}
		else {
		*replace prod = "`lc'_orange" if orange & brand == "`lc'" 
		*replace prod = "`lc'_lemon" if lemon & brand == "`lc'" 
		*replace prod = "`lc'_punch" if punch & brand == "`lc'" 
		*replace prod = "`lc'_flavor" if flav_etc & brand == "`lc'" 
		*replace prod =  "`lc'_ginger" if ale & brand == "`lc'"
		replace prod = "`lc'_cola" if cola & brand == "`lc'"
		replace prod = "`lc'_regular" if missing(prod) & brand == "`lc'"
		}
}

local beersoda DAD A&W CANFIELD BARQ
foreach lc of local beersoda {
	*replace prod = "`lc'_cream" if cream & brand == "`lc'"
	replace prod = "`lc'_diet_beer" if diet & beer & brand == "`lc'"
	replace prod = "`lc'_beer" if !diet & beer & brand == "`lc'"
	replace prod = "`lc'_regular" if missing(prod) & brand == "`lc'"
}

local teasoda LIPTON ARIZONA
foreach lc of local teasoda {
	replace prod = "`lc'_tea_diet" if tea & diet & brand == "`lc'"
	replace prod = "`lc'_tea_regular" if tea & !diet & brand == "`lc'"
}


local others BIGRED DAD TETLEY CANADA
foreach lc of local others {
	replace prod = brand if brand == "`lc'"
}
	

	
*replace prod = "CANADA_ALE" if brand == "CANADA" & ale 
*replace prod = "CANADA" if brand == "CANADA" & !ale 


save upcsdr_brand.dta, replace

*** Updated Jun 6, 2013
drop if missing(size_new)
***

save upcsdr_brand.dta, replace




drop if missing(prod)
*keep prod brand diet free cola tea beer ale orange lemon punch flav_etc 
keep prod brand diet free cola tea beer other 
duplicates drop prod, force


save prod.dta, replace




****************************************************

use wsdr.dta, clear
merge m:1 upc using upcsdr_brand.dta, keepusing(upc descrip size_new brand prod)
drop if _merge == 2
** Updated Jun3, 2013 
drop if _merge == 1 
**
drop if ok == 0
drop ok
gen quant = move * size_new
gen price_oz = price / size_new
drop if missing(prod)
preserve



** HW suggests using top 20 PRODUCTS, instead of top 20 brands 
*collapse (sum) quant, by(brand)
collapse (sum) quant, by(prod)
sum quant, meanonly
gen t = r(mean) * r(N)
gen pct = -1 * quant / t
sort pct
// result shows that top 20 products includes only cokes and very popular soda like 7up. No beer or tea drinks

gen share_rank = _n
keep if share_rank < 21
drop share_rank t pct 
save prod_insample.dta, replace

restore

capture drop _merge
merge m:1 prod using prod_insample.dta, force 
drop if _merge == 1










/*
******** market capacity *******
use ccount.dta, clear
collapse (mean) custcoun, by(store)
merge 1:1 store using demo.dta, keepusing(hsizeavg)
gen mktcp_store = hsizeavg * custcoun * 7 * 7 * 12 
//people shop once a week, and one person shop for the whole family
//An average people potentially can consume 1 can (12 oz) of soft drink everyday
save mktcp.dta, replace
*/



** define a market **
*** Option 1: just let store * week be market
*** Option 2: city * week
*** Option 3: city * month/quarter 


capture drop profit brand
capture drop price // 'price_oz' (= price/size_new) is the correct price per oz  
capture drop qty  // 'quant' (= move * size_new) is the correct quantity in terms of oz 
capture drop move 
capture drop size_new 
capture drop descrip


capture drop _merge 
merge m:1 store using mktcp.dta, keepusing(mktcp_store)

gen upc_share = quant / mktcp_store
*bysort prod week store: egen share = total(upc_share)
*save upcresults.dta, replace

collapse (mean) price_oz (sum) share=upc_share, by(prod week store)
bysort week store: egen sharetot = total(share)

gen sharedif = ln(share) - ln(1 - sharetot) // this is the depvar

merge m:1 prod using prod.dta // get prod characteristics
keep if _merge == 3
drop _merge
// tea and beer are not present in the top 20 product chosen, so drop them
drop tea beer 
save finaldata.dta, replace

drop if share == 0  //how come there is 0 share for a product????????????






* local control diet free cola tea beer orange lemon punch flavor_etc //the top 20 is limited to cola and other regular soda 
local control diet free cola other 

*** conditional logit model 





*** Berry's logit *****

** fixed effects 
egen mkt = group(store week)
egen brandnum = group(brand)
*xtset brandnum mkt 
xtset mkt
xtreg sharedif price_oz `control' i.brandnum, fe
estimates save berry_fe, replace
xtreg sharedif price_oz `control', fe
estimates save berry_fe_nobrand, replace


*************************
// own and cross price elasticities are calculated for average price and market share across markets 
collapse (mean) avgprice=price_oz (mean) avgshare=share, by(prod)
estimates use berry_fe
scalar alpha = _b[price_oz]
matrix elast = 
levelsof prod, local(prod)
foreach lc_prod of local prod{
*************************






** IV, 1-product
encode prod, gen(prod_id)
levelsof prod_id, local(prod)
drop IV*
foreach lc_ctr of local control {
	gen IV_`lc_ctr' = .
	foreach lc_prod of local prod {
		gen a = `lc_ctr'
		replace a = 0 if prod_id == `lc_prod'
		bysort mkt: egen b = total(a)
		replace IV_`lc_ctr' = b if prod_id == `lc_prod'
		drop b a 
	}
}	



ivregress 2sls sharedif `control' (price_oz =  IV_*)
estimates save berry_iv_prod, replace


** IV, 2-price

//not finished yet :(


ivregress 2sls sharedif `control' (price_oz =  IV_*)
estimates save berry_iv_price, replace



**** BLP random coefficient ****


blp share `control', endog(price=IV_diet IV_free IV_cola IV_other) stochastic(diet) markets(mkt) 









* simulate indivdiual consumers
* expand 19
	
*forvalues i = 1(1)19 {
*	gen pp`i' = .
*	forvalues j = 1(1)N {//N is the total number of products
*		replace pp`i' = rnormal(0,1) if id == `j'
*	}
*}	


	
	


program blp	version 12	syntax varlist if, at(name)	quietly {		tempvar num denom 
		
		forvalues i = 1(1)20 {
			
					gen `num' = exp(`at'[1,1]*diet + )
		gen `denom' = 		replace `varlist' = y - `mu'*`ybar'/`mubar' `if'	}end





	



simulate , reps(20): share


* for simplicity, so far assume only one characteristic control (diet)
gmm blp, nequations(1) parameters(b alfa sigma) instruments(diet price_oz , noconstant) 



//Jun 9, 2013
* Export finaldata.dta to matlab 
drop brand
encode prod, gen(prod_id)
drop sharetot sharedif 
** Note IV-product were calculated 
save finaldata_IV.dta, replace


