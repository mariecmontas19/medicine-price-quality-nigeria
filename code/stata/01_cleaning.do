****************************************************************************************
*Cleaning dofile for 1,500 words price & quality paper 
****************************************************************************************
* CREATED: Marie Montás, 7th October 2024

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
 
(1) Cleaning of variables - LAB SAMPLE
(2) LAB MATCHED - LAB SAMPLE
(3) Failing drugs - heterogeinity
*/


import excel "${data}/data_sample_selection.xls", sheet("Sheet1") firstrow case(lower) clear
save "${dta}/data_sample_selection.dta", replace

use "${laboratory}/Lab Results_Merged_101023.dta", clear
drop if samplecode=="L10Y" | samplecode==""
save "${dta}/Lab Results_Merged_101023_246.dta", replace
*save "{$dta}/Lab Results_Merged_101023_246.dta", replace
tab _index if samplecode=="L11S" | samplecode=="L1R"
// 246
// 470


use "${dta}/data_sample_selection.dta", clear //1296
//drop mergenew
merge 1:1 _index using "${dta}/Lab Results_Merged_101023_246.dta", force gen(mergenew)

keep if mergenew==3 

*1. Cleaning of variables**  *** LAB SAMPLE 

gen ln_price = ln(price)

gen city_drug = city if drug_found == "1. Yes"
gen geotype_drugs = geotype if drug_found == "1. Yes"

gen no_floor = 1 if obs_floor == "No"
replace no_floor = 0 if obs_floor == "Yes"
tab no_floor

gen yes_floor = (no_floor==0)

gen yes_shelf = 1 if obs_shelf == "Yes"
replace yes_shelf = 0 if obs_shelf == "No"
tab yes_shelf

*flipped shelf sign 
gen no_shelf = 1 - yes_shelf

gen yes_organized = 1 if obs_drugsorganized == "Yes"
replace yes_organized = 0 if obs_drugsorganized == "No" | obs_drugsorganized == "Not able to observe"
tab yes_organized

gen yes_AC = 1 if obs_ac == "Yes"
replace yes_AC = 0 if obs_ac == "No" 
tab yes_AC

gen no_odor = 0 if odor == "Other (please specify)"
replace no_odor= 1 if odor == "None"
tab no_odor

gen no_sun = 1 if obs_sun == "No"
replace no_sun = 0 if obs_sun == "Yes" | obs_sun == "Not able to observe"
tab no_sun

gen yes_sun = (no_sun==0)

gen normal_package = 1 if packagecondition=="Normal" 
replace normal_package = 0 if packagecondition != "Normal" 
tab normal_package

gen complete_pills = 1 if complete_yes=="1. Yes"
replace complete_pills = 0 if complete_yes == "2. No"
tab complete_pills

gen not_broken = 1 if brokenpills_yes == "2. No"
replace not_broken = 0 if brokenpills_yes == "1. Yes"
tab not_broken

gen not_expired = 1 if manuinfo_expdate > date("2023-01-01", "YMD")
replace not_expired = 0 if manuinfo_expdate <= date("2022-12-31", "YMD") 
tab not_expired

gen yes_coolchain = 1 if drugs_coolchain=="1. Yes"
replace yes_coolchain = 0 if drugs_coolchain == "2. No"
tab yes_coolchain 


***Expiration date****

gen expdate = . 
replace expdate = 1 if manuinfo_expdate <= date("2022-12-31", "YMD") //at time of collection 
replace expdate = 2 if manuinfo_expdate >= date("2023-01-01", "YMD") & manuinfo_expdate <= date("2023-06-30", "YMD") //6 months after
replace expdate = 3 if manuinfo_expdate >= date("2023-07-01", "YMD") & manuinfo_expdate <= date("2023-12-31", "YMD") //year after
replace expdate = 4 if manuinfo_expdate > date("2023-12-31", "YMD")
replace expdate = . if drug_found == "2. No"

***Not expired at time of collection***

gen not_expired_collection = . 
replace not_expired_collection = 0 if expdate == 1
replace not_expired_collection = 1 if expdate == 2 | expdate == 3 | expdate == 4
tab not_expired_collection

***Correct quantity of pills****
encode selected_drug, gen (selected_drug_d)
sort selected_drug_d
by selected_drug_d: egen drug_median = median(sample_number_d)
gen correct_pills = (sample_number_d == drug_median)
replace correct_pills = . if drug_found == "2. No"
tab correct_pills

***Correct dosage*** WON'T ADD IT TO INDEX*****

gen sample_mg_real = ""
replace sample_mg_real = "500/65" if selected_drug == "Panadol Extra Tabs x 100"
replace sample_mg_real = "500/25" if selected_drug == "Tuyil Cenpain Night Tabs., x20. " | selected_drug == "Swipha Swidar Sulphadoxine + Pyrimethamine., 500/25mg (3 Tabs)"
replace sample_mg_real = "5/50" if selected_drug == "Nomoretic Tab. 5mg/ 50mg" | selected_drug == "Bonduretic Tabs."
replace sample_mg_real = "500" if selected_drug == "May & Baker Para (Paracetamol) Tabs. (x96)" | selected_drug == "Emzor Paracetamol Tabs., 500mg" | selected_drug == "Fidson Ciprotab (Ciprofloxacin) Tabs., 500mg., x10 Tabs"
replace sample_mg_real = "100" if selected_drug == "Vitamin C (Chemo-Pharma) White Tabs x100"| selected_drug == "Kunimed Ascomed Vitamin Coloured Vitamin C Tabs.,100mg(x1000)" | selected_drug == "Chemo-Pharma Vitamin C Colored Tabs. 100mg, 1X1 Tabs" | selected_drug == "Meyer B Complex Tabs. (x100),."
replace sample_mg_real = "80/480" if selected_drug == "Coartem Artemether Lumefantrine Tabs.,80mg/480mg" | selected_drug == "Lonart-DS Artemether Lumefantrine Tabs.,80mg/480mg"
replace sample_mg_real = "62.5/375" if selected_drug == "Artequick Artemisinin Piperaquine Tabs.,62.5mg/375mg."
replace sample_mg_real = "600/200" if selected_drug == "Swipha Tiniflox Tinidazole + Ofloxacine., 600/200mg (20 Tabs)"
replace sample_mg_real = "400" if selected_drug == "Sanofi Avensis Flagyl Metronidazole Tab.,400mg"
replace sample_mg_real = "125" if selected_drug == "Neimeth Pyrantrin Pyrantel Pamoate Tabs.,125mg."
replace sample_mg_real = "20" if selected_drug == "Nifedin Nifedipine Dexcel Tabs.,20mg"
replace sample_mg_real = "250" if selected_drug == "Bondomet Methyldopa Tabs.,250mg"
replace sample_mg_real = "" if drug_found == "2. No"
tab sample_mg_real

**Cleaning type of drug**
replace drug_type = "Analgesics" if strpos(drug_type, "1. Analgesics/Antirheumatic/Antipyretics")
replace drug_type = "Antibiotics" if strpos(drug_type, "2. Antibiotics + Antibacterial")
replace drug_type = "Antihypertensives" if strpos(drug_type, "3. Antihypertensives")
replace drug_type = "Antimalarials" if strpos(drug_type, "4. Antimalarial Medicines")
replace drug_type = "Multivitamins" if strpos(drug_type, "5. Multivitamin +Hematinic")


****Generate drug number (use for heterogeinity analysis)**

gen drug_number = .
replace drug_number = 1 if selected_drug == "Artequick Artemisinin Piperaquine Tabs.,62.5mg/375mg."
replace drug_number = 2 if selected_drug == "Bondomet Methyldopa Tabs.,250mg"
replace drug_number = 3 if selected_drug == "Bonduretic Tabs."
replace drug_number = 4 if selected_drug == "Chemo-Pharma Vitamin C Colored Tabs. 100mg, 1X1 Tabs"
replace drug_number = 5 if selected_drug == "Coartem Artemether Lumefantrine Tabs.,80mg/480mg"
replace drug_number = 6 if selected_drug == "Emzor Paracetamol Tabs., 500mg"
replace drug_number = 7 if selected_drug == "Fidson Ciprotab (Ciprofloxacin) Tabs., 500mg., x10 Tabs"
replace drug_number = 8 if selected_drug == "Kunimed Ascomed Vitamin Coloured Vitamin C Tabs.,100mg(x1000)"
replace drug_number = 9 if selected_drug == "Lonart-DS Artemether Lumefantrine Tabs.,80mg/480mg"
replace drug_number = 10 if selected_drug == "May & Baker Para (Paracetamol) Tabs. (x96)"
replace drug_number = 11 if selected_drug == "Meyer B Complex Tabs. (x100),."
replace drug_number = 12 if selected_drug == "Neimeth Pyrantrin Pyrantel Pamoate Tabs.,125mg."
replace drug_number = 13 if selected_drug == "Nifedin Nifedipine Dexcel Tabs.,20mg"
replace drug_number = 14 if selected_drug == "Nomoretic Tab. 5mg/ 50mg"
replace drug_number = 15 if selected_drug == "Panadol Extra Tabs x 100"
replace drug_number = 16 if selected_drug == "Sanofi Avensis Flagyl Metronidazole Tab.,400mg"
replace drug_number = 17 if selected_drug == "Swipha Swidar Sulphadoxine + Pyrimethamine., 500/25mg (3 Tabs)"
replace drug_number = 18 if selected_drug == "Swipha Tiniflox Tinidazole + Ofloxacine., 600/200mg (20 Tabs)"
replace drug_number = 19 if selected_drug == "Tuyil Cenpain Night Tabs., x20. "
replace drug_number = 20 if selected_drug == "Vitamin C (Chemo-Pharma) White Tabs x100"
replace drug_number = . if drug_found == "2. No"

tab drug_number

**Controls/fixed effects**

tab city, gen(cityfe_)
tab geotype, gen(geotype_)
tab drug_type, gen(drug_typefe_)
gen phmcy_size_small=(phmcy_size=="1. Small (1-2 vendors)")
tab phmcy_size, gen (phmcy_sizefe_)

&&&&&&

***3. LAB MATCH***

* ANTIHYPERTHENSIVES
gen lab_notmatched1=(amiloride_purity<90 & amiloride_purity!=. | amiloride_purity >110 & amiloride_purity!=.)
tab lab_notmatched1  //21
gen lab_notmatched2=(nifedipine_conc_av<90 & nifedipine_conc_av!=. | nifedipine_conc_av>110 & nifedipine_conc_av!=.)
tab lab_notmatched2 //1

* ANTIBIOTICS
gen lab_notmatched3=(pyrantel_av<90 & pyrantel_av!=. |pyrantel_av>110 & pyrantel_av!=.)
tab lab_notmatched3 //12

* Antimalarials PYRIMETHAMINE (25mg) / SULFADOXINE (500mg) TABLETS 		16	13	3
gen lab_notmatched4=(pyrimethamine__purity<90 & pyrimethamine__purity!=.| pyrimethamine__purity>110 & pyrimethamine__purity!=.) 
tab lab_notmatched4  //1
gen lab_notmatched5=(sulfadoxine__purity<90 & sulfadoxine__purity!=.| sulfadoxine__purity>110 & sulfadoxine__purity!=.) 
tab lab_notmatched5  //3
gen lab_notmatched6=(lumefantrine__purity<90 & lumefantrine__purity!=.| lumefantrine__purity>110 & lumefantrine__purity!=.) 
tab lab_notmatched6  //6
gen lab_notmatched7=(artemether__purity<90 & artemether__purity!=.| artemether__purity>110 & artemether__purity!=.) 
tab lab_notmatched7  //0

count if lab_notmatched1==1 | lab_notmatched2==1 | lab_notmatched3==1 | lab_notmatched4==1| lab_notmatched5==1| lab_notmatched6==1 | lab_notmatched7==1 //43

* ANALGESICIS
*PARACETAMOL (500mg) / CAFFEINE (30mg) TABLETS - all failed b/c low caffeine
gen lab_notmatched8=(caffeine_<90 & caffeine_!=. |caffeine_>110 & caffeine_!=.)
tab lab_notmatched8 //3

*PARACETAMOL (500mg) / DIPHENHYDRAMINE HCL (25mg) TABLETS 
gen lab_notmatched9=(diphenhydraminehcl_<90 & diphenhydraminehcl_!=. |diphenhydraminehcl_>110 & diphenhydraminehcl_!=.)
tab lab_notmatched9 // 13 failed only b/c low diph
tab samplecode if lab_notmatched9==1 
*MISSING L11a
tab diphenhydraminehcl_ if samplecode=="L11a" // OK Diphenhydramine HCI, but high paracetamoal
tab paracetamol_ if samplecode=="L11a" // OK Diphenhydramine HCI, but high paracetamoal


*PARACETAMOL TABLETS (500mg) 
gen lab_notmatched10=(paracetamol_<90 & paracetamol_!=. |paracetamol_>110 & paracetamol_!=.)
tab lab_notmatched10 //8 = 1 only paracemtal, 1 L11a (diph),  X?


* ALL
gen lab_notmatched=(lab_notmatched1==1 | lab_notmatched2==1 | lab_notmatched3==1 | lab_notmatched4==1| lab_notmatched5==1| lab_notmatched6==1| lab_notmatched7==1| lab_notmatched8==1| lab_notmatched9==1| lab_notmatched10==1) //62
gen lab_matched=(lab_notmatched==0)
tab lab_matched


**4. HETEROGEINITY OF FAILING DRUGS ***

*One ingredient, low dose
gen fail_oneing_low = 1 if pyrantel_av<90 & pyrantel_av!=. 
replace fail_oneing_low = (fail_oneing_low==1)
tab fail_oneing_low
//10

*One ingredient, high dose 
gen fail_oneing_high = 1 if pyrantel_av>110 & pyrantel_av!=. | nifedipine_conc_av>110 & nifedipine_conc_av!=. | paracetamol_>110 & paracetamol_!=.
replace fail_oneing_high = . if sample_brand1=="Tuyil Cenpain"
replace fail_oneing_high = (fail_oneing_high==1)
tab fail_oneing_high
//5

*Two ingredients**

**High API*

gen fail_twoing_high =1 if sulfadoxine__purity>110 & sulfadoxine__purity!=. | _index == 230
replace fail_twoing_high = (fail_twoing_high==1)
tab fail_twoing_high
//4

*Low API* 

gen fail_twoing_low = 1 if _index==647 | diphenhydraminehcl_<90 & paracetamol_<110 | caffeine_<90
replace fail_twoing_low = (fail_twoing_low==1)
tab fail_twoing_low
//12

*Low/High API* 

gen fail_twoing_both = 1 if (diphenhydraminehcl_<90 & paracetamol_>110) | lumefantrine__purity<90 | amiloride_purity<90 
replace fail_twoing_both = . if _index==647
replace fail_twoing_both = (fail_twoing_both==1)
tab fail_twoing_both
//31

**Totals**
*Total high*
gen fail_high = 1 if fail_oneing_high ==1 | fail_twoing_high ==1 
replace fail_high = 0 if fail_high==.
*Total low*
gen fail_low = 1 if fail_oneing_low == 1 | fail_twoing_low == 1
replace fail_low = 0 if fail_low==.
*Fail atlst one high ingredient*
gen fail_high_both = 1 if fail_high == 1 | fail_twoing_both == 1
replace fail_high_both = 0 if fail_high_both ==.
gen fail_atlst_high = 1 if fail_high ==1 | fail_high_both == 1
replace fail_atlst_high = 0 if fail_atlst_high ==.
*Fail at least one low ingredient*
gen fail_atlst_low = 1 if fail_low == 1 | fail_twoing_both == 1
replace fail_atlst_low = 0 if fail_atlst_low ==.

***For Tuyil Cepain***

 tab samplecode if drug_number==19 & fail_twoing_low

/* Sample Code |      Freq.     Percent        Cum.
------------+-----------------------------------
       L10D |          1       12.50       12.50
       L10E |          1       12.50       25.00
       L10F |          1       12.50       37.50
       L11i |          1       12.50       50.00
        L2K |          1       12.50       62.50
        L4N |          1       12.50       75.00
        L5a |          1       12.50       87.50
        L8H |          1       12.50      100.00
------------+-----------------------------------
      Total |          8      100.00*/
	  
tab samplecode if drug_number==19 & fail_twoing_both

/* Sample Code |      Freq.     Percent        Cum.
------------+-----------------------------------
       L12b |          1       20.00       20.00
         L2 |          1       20.00       40.00
        L5H |          1       20.00       60.00
        L5d |          1       20.00       80.00
        L7F |          1       20.00      100.00
------------+-----------------------------------
      Total |          5      100.00*/

tab samplecode if drug_number==19 & fail_twoing_high

/* Sample Code |      Freq.     Percent        Cum.
------------+-----------------------------------
       L11a |          1      100.00      100.00
------------+-----------------------------------
      Total |          1      100.00*/


**FLIP THE OUTCOME 
gen pass_low = (fail_low==0)
gen pass_atlst_high = (fail_atlst_high==0)
gen pass_atlst_low = (fail_atlst_low==0)


**Table 1 on commentary paper**


. table drug_type, statistic(sum lab_matched lab_notmatched fail_oneing_low fail_oneing_high fail_twoing_both fail_twoing_low fail_twoing_high)

/*
------------------------------------------------------------------------------------------------------------------------------------------------
                    |  lab_matched   lab_notmatched   fail_oneing_low   fail_oneing_high   fail_twoing_both   fail_twoing_low   fail_twoing_high
--------------------+---------------------------------------------------------------------------------------------------------------------------
drug_type           |                                                                                                                           
  Analgesics        |           91               19                 0                  2                  5                11                  1
  Antibiotics       |           26               12                10                  2                  0                 0                  0
  Antihypertensives |            9               22                 0                  1                 21                 0                  0
  Antimalarials     |           58                9                 0                  0                  5                 1                  3
  Total             |          184               62                10                  5                 31                12                  4
------------------------------------------------------------------------------------------------------------------------------------------------

. 

 */




save "${dta}/data_merge_only_246.dta", replace 
