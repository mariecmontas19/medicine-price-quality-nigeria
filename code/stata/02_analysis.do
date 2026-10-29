****************************************************************************************
*Analysis dofile for paper on quality and price of drugs 
****************************************************************************************
* CREATED: Marie Montás, 15th January 2024
* LAST UPDATE: Marie Montás, 8TH October 2024

clear all
set more off

****************************************************************************************
* SET UP PATHS
****************************************************************************************
* Set NGA_ROOT to the project folder (holds analysis/, tables/, figures/, lab/).
if "$NGA_ROOT" == "" global NGA_ROOT "`c(pwd)'"
global dta        "${NGA_ROOT}/analysis/dta/"
global data       "${NGA_ROOT}/analysis/data/"
global dofile     "${NGA_ROOT}/analysis/dofile/"
global tables     "${NGA_ROOT}/tables/"
global figures    "${NGA_ROOT}/figures/"
global laboratory "${NGA_ROOT}/lab/"

/*Order of the Dofile:
(1) Main analysis 
(2) Robustness checks*/

use "${dta}/data_merge.dta", clear 

eststo clear

*Main analysis: table 1: Summary stats table**TOTAL SAMPLE

**Panel A: Pharma quality
xi, noomit: estpost sum yes_AC yes_shelf yes_coolchain yes_sun yes_floor
eststo m1

**Panel B: Drug quality
xi, noomit: estpost sum normal_package expdate_yes temp_yes yes_organized
eststo m2

**Panel C: Other covariates
xi, noomit: estpost sum i.city_drug i.geotype_drug i.phmcy_type i.drug_type i.phmcy_size price
eststo m3

estpost tabstat price, by(drug_type) statistics(mean sd min max)
eststo m4

esttab m1 m2 m3 m4 using "${tables}/table1_sumstats.rtf", cells("mean(fmt(a4)) sd(fmt(a4)) min max count") noobs nomtitle addnotes() nonumber title(Panel A, B, C and D) replace label 

**Table 1: **LAB SAMPLE
use "${dta}/data_merge_only_246.dta", clear 

eststo clear

**Panel A: Pharma quality
xi, noomit: estpost sum yes_AC yes_shelf yes_coolchain yes_sun yes_floor
eststo m1

**Panel B: Drug quality
xi, noomit: estpost sum normal_package expdate_yes temp_yes yes_organized
eststo m2

**Panel C: Other covariates
xi, noomit: estpost sum i.city_drug i.geotype_drug i.phmcy_type i.drug_type i.phmcy_size price
eststo m3

estpost tabstat price, by(drug_type) statistics(mean sd min max)
eststo m4

esttab m1 m2 m3 m4 using "${tables}/table1_sumstats_lab.rtf", cells("mean(fmt(a4)) sd(fmt(a4)) min max count") noobs nomtitle addnotes() nonumber title(Panel A, B, C and D) replace label 


*Table 2: What are the predictors of true quality (=labsample)? (with flipped sign on display on shelves)

**PROBIT MODEL - MAIN 
probit lab_matched ln_price yes_AC yes_shelf yes_coolchain yes_sun yes_floor cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4, cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/table1_R1.xls", replace label ctitle("1") 
probit lab_matched ln_price normal_package expdate_yes temp_yes yes_organized cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4, cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/table1_R1.xls", append label ctitle("2") 
probit lab_matched ln_price yes_AC yes_shelf yes_coolchain yes_sun yes_floor normal_package expdate_yes temp_yes yes_organized cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4, cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/table1_R1.xls", append label ctitle("3") 
probit lab_matched ln_price cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4, cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/table1_R1.xls", append label ctitle("4") 


***HETEROGEINITY ANALYSES****

*Table 3 - PROBIT MODEL HETEROGEINITY BY FAILING DRUGS - LOW

probit pass_low ln_price yes_AC yes_shelf yes_coolchain yes_sun yes_floor cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4, cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/heterogeinity_low.xls", replace label ctitle("1") 
probit pass_low ln_price normal_package expdate_yes temp_yes yes_organized cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4, cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/heterogeinity_low.xls", append label ctitle("2") 
probit pass_low ln_price yes_AC yes_shelf yes_coolchain yes_sun yes_floor normal_package expdate_yes temp_yes yes_organized cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4, cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/heterogeinity_low.xls", append label ctitle("3") 
probit pass_low ln_price cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4, cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/heterogeinity_low.xls", append label ctitle("4") 


*Table 3 - PROBIT MODEL HETEROGEINITY BY FAILING DRUGS - AT LEAST ONE HIGH 
probit pass_atlst_high ln_price yes_AC yes_shelf yes_coolchain yes_sun yes_floor cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4, cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/heterogeinity_atlsthigh.xls", replace label ctitle("1") 
probit pass_atlst_high ln_price normal_package expdate_yes temp_yes yes_organized cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4, cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/heterogeinity_atlsthigh.xls", append label ctitle("2") 
probit pass_atlst_high ln_price yes_AC yes_shelf yes_coolchain yes_sun yes_floor normal_package expdate_yes temp_yes yes_organized cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4, cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/heterogeinity_atlsthigh.xls", append label ctitle("3") 
probit pass_atlst_high ln_price cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4, cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/heterogeinity_atlsthigh.xls", append label ctitle("4") 

*Table 3 - PROBIT MODEL HETEROGEINITY BY FAILING DRUGS - AT LEAST ONE LOW 
probit pass_atlst_low ln_price yes_AC yes_shelf yes_coolchain yes_sun yes_floor cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4, cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/heterogeinity_atlstlow.xls", replace label ctitle("1") 
probit pass_atlst_low ln_price normal_package expdate_yes temp_yes yes_organized cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4, cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/heterogeinity_atlstlow.xls", append label ctitle("2") 
probit pass_atlst_low ln_price yes_AC yes_shelf yes_coolchain yes_sun yes_floor normal_package expdate_yes temp_yes yes_organized cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4, cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/heterogeinity_atlstlow.xls", append label ctitle("3") 
probit pass_atlst_low ln_price cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4, cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/heterogeinity_atlstlow.xls", append label ctitle("4") 


***BY TYPE OF DRUG**with main analysis indexes
use "${dta}/data_merge_only_246.dta", clear

probit lab_matched ln_price yes_AC yes_shelf yes_coolchain yes_sun yes_floor normal_package expdate_yes temp_yes yes_organized cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4 if drug_type == "Analgesics", cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/appendix_table1_drugtype.xls", replace label ctitle("1") 
probit lab_matched ln_price yes_AC yes_shelf yes_coolchain yes_sun yes_floor normal_package expdate_yes temp_yes yes_organized cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4 if drug_type == "Antibiotics", cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/appendix_table1_drugtype.xls", append label ctitle("2") 
probit lab_matched ln_price yes_AC yes_shelf yes_coolchain yes_sun yes_floor normal_package expdate_yes temp_yes yes_organized cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4 if drug_type == "Antihypertensives", cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/appendix_table1_drugtype.xls", append label ctitle("3") 
probit lab_matched ln_price yes_AC yes_shelf yes_coolchain yes_sun yes_floor normal_package expdate_yes temp_yes yes_organized cityfe_2 - cityfe_6 geotype_1 phmcy_sizefe_2 - phmcy_sizefe_3 drug_typefe_2 - drug_typefe_4 if drug_type == "Antimalarials", cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/appendix_table1_drugtype.xls", append label ctitle("4") 


**BY TYPE of drug** no covariates
probit lab_matched ln_price yes_AC yes_shelf yes_coolchain yes_sun yes_floor normal_package expdate_yes temp_yes yes_organized if drug_type == "Analgesics", cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/appendix_table1_drugtype.xls", append label ctitle("1") 
probit lab_matched ln_price yes_AC yes_shelf yes_coolchain yes_sun yes_floor normal_package expdate_yes temp_yes yes_organized if drug_type == "Antibiotics", cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/appendix_table1_drugtype.xls", append label ctitle("2") 
probit lab_matched ln_price yes_AC yes_shelf yes_coolchain yes_sun yes_floor normal_package expdate_yes temp_yes yes_organized if drug_type == "Antihypertensives", cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/appendix_table1_drugtype.xls", append label ctitle("3") 
probit lab_matched ln_price yes_AC yes_shelf yes_coolchain yes_sun yes_floor normal_package expdate_yes temp_yes yes_organized if drug_type == "Antimalarials", cluster(city)
margins, dydx(_all) post
outreg2 using "${tables}/appendix_table1_drugtype.xls", append label ctitle("4") 


