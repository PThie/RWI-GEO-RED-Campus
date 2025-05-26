*** Aufbereitung des Immobilienscout24-Datensatzes und Imputation fehlender Werte 


* --------------------------------------------------------------------------------------------------
* Anpassen der Pfadangaben für erzeugten Datensatz und logfile
* --------------------------------------------------------------------------------------------------

capture            clear
capture            log close
set more off

* --------------------------------------------------------------------------------------------------
* Log-file und Datensatz öffnen
* --------------------------------------------------------------------------------------------------

log using "${LOG_PATH}prepCF_WK.txt", text replace


use "M:\_FDZ\RWI-GEO\RWI-GEO-RED\daten\SUF\v3\WK_SUF_ohneText.dta", clear

drop  mietekalt mietewarm nebenkosten  betreut heizkosten_in_wm_enthalten kategorie_Haus erg_amd gid2015 kid2015 lieferung r1_id blid kid_updated gid_updated uniqueID_gen ags plz dupID_gen mieteinnahmenpromonat ferienhaus foerderung kaufvermietet
gen adat = ym(ajahr, amonat)
rename jahr ejahr
gen edat=ym(ejahr, emonat)

format edat adat %tm
compress



 **DEPENDENT VARIABLE
*--------------------
* exclusive rent
drop if kaufpreis < 0
drop if wohnflaeche < 0 

 
*drop extreme outliers
forvalue ejahr = 2007(1)2020 {

	_pctile kaufpreis if ejahr == `ejahr', p(1 99)
	drop if (kaufpreis <= r(r1) | kaufpreis > r(r2)) & ejahr == `ejahr' 
	}
		



* living area

forvalue ejahr = 2007(1)2020 {

	_pctile wohnflaeche if ejahr == `ejahr', p(1 99)
	drop if (wohnflaeche <= r(r1) | wohnflaeche > r(r2)) & ejahr == `ejahr' 
	}
		
	gen 	price_sqm = kaufpreis / wohnflaeche
	replace price_sqm = . if price_sqm < 0
	forvalue ejahr = 2007/2020 {
	su		price_sqm if ejahr == `ejahr', d
	drop if  (price_sqm >= `r(p99)' | price_sqm <= `r(p1)') & ejahr == `ejahr'
	}
	
	
	*--------------------


 *Baujahr
 tab baujahr
	replace baujahr = .  if baujahr <1500 // Baujahr 1500 unrealistisch & MIssingss
	drop if baujahr > 2020 & baujahr != .  //zukünftig zu vermietene Objekte nicht berücksichtigen

	save "M:\_FDZ\RWI-GEO\RWI-GEO-RED\daten\PUF\v3\PUF_WK_zwischen.dta", replace
	
	use "M:\_FDZ\RWI-GEO\RWI-GEO-RED\daten\PUF\v3\PUF_WK_zwischen.dta", clear
	*****************
	*Zeitreihe nur grösste Städte
	
	drop if ajahr==2020
	
keep  if kid2019 == 11000 |kid2019 ==2000 |kid2019 == 5111 |kid2019 == 5113 |kid2019 == 5315 |kid2019 == 6412|kid2019 == 8111 |kid2019 ==  9162 |kid2019 == 14713 | kid2019 == 14612 |kid2019 == 5112 |kid2019 == 5913|ags2019 == 3241001|kid2019 == 4011|kid2019 == 9564

replace edat = ym(2019,12) if edat > ym(2019,12)
replace ejahr = 2019 if ejahr == 2020
egen NOBS = count(obid), by(ejahr kid2019)
bysort ags2019 ejahr: gen random = uniform()
egen NOBS_min = min(NOBS), by(kid2019)	
*su NOBS, d	

gen insample = 2000/NOBS <= random if NOBS_min <= 4000
replace insample = 4000/NOBS <= random if NOBS_min >4000 & NOBS_min < 10000
replace insample = 10000/NOBS <= random if NOBS_min >10000 
keep if insample == 0
drop insample NOBS* ejahr emonat ajahr amonat random
compress
save "M:\_FDZ\RWI-GEO\RWI-GEO-RED\daten\PUF\v3\PUF_WK_cities.dta", replace

use "M:\_FDZ\RWI-GEO\RWI-GEO-RED\daten\PUF\v3\PUF_WK_zwischen.dta", clear
	*NUR 2019
	keep if ajahr == 2019 | ejahr == 2019 | (ajahr < 2019 & ejahr == 2020)
	egen maxspell = max(spell), by(obid)
	keep if spell == maxspell
	drop spell maxspell ajahr ejahr amonat emonat


bysort ags2019: gen random = uniform()
egen NOBS = count(obid), by(ags2019)	
replace ags2019 = . if NOBS < 50
replace NOBS =. if NOBS <  50
egen NOBS2 = count(obid), by(kid2019)
drop if NOBS2 < 100
gen insample = 50/NOBS <= random if NOBS <= 200
replace insample = 200/NOBS <= random if NOBS>200 & NOBS < 1000
replace insample = 1000/NOBS <= random if NOBS >1000 & NOBS < 5000
replace insample = 5000/NOBS <= random if NOBS >= 5000
replace insample = 100/NOBS2 <=random if NOBS == . 
keep if insample == 0
drop insample NOBS* edat random
compress
save "M:\_FDZ\RWI-GEO\RWI-GEO-RED\daten\PUF\v3\PUF_WK_2019.dta", replace
