**************************************************************************
*
* Aufbereitung des Immobilienscout24-Datensatzes und Imputation fehlender Werte 
*
**************************************************************************

**************************************************************************
* Log-file und Datensatz öffnen
**************************************************************************

* Log file
log using "${LOG_PATH}prepCF_WK_${campus_version}.txt", text replace

* Datensatz einlesen
use "${DATA_PATH}WK_SUF_ohneText.dta", clear


**************************************************************************
* Vorbereitung
**************************************************************************

* nicht benötigte Variablen droppen
drop  mietekalt mietewarm nebenkosten betreut heizkosten_in_wm_enthalten kategorie_Haus erg_amd gid2015 kid2015 lieferung kid_updated gid_updated uniqueID_gen dupID_gen mieteinnahmenpromonat ferienhaus foerderung kaufvermietet

* Startdatum formen
gen adat = ym(ajahr, amonat)

* Enddatum formen
gen edat = ym(ejahr, emonat)

* Daten formatieren
format edat adat %tm
compress

**************************************************************************
* DEPENDENT VARIABLE
**************************************************************************

* exclusive rent
drop if kaufpreis < 0
drop if wohnflaeche < 0 

*drop extreme outliers
forvalue ejahr = 2007(1)$maxyear {
	_pctile kaufpreis if ejahr == `ejahr', p(1 99)
	drop if (kaufpreis <= r(r1) | kaufpreis > r(r2)) & ejahr == `ejahr' 
}
		
**************************************************************************
* INDEPENDENT VARIABLE
**************************************************************************
// dropping extreme values



* living area
*--------------------

forvalue ejahr = 2007(1)$maxyear {
	_pctile wohnflaeche if ejahr == `ejahr', p(1 99)
	drop if (wohnflaeche <= r(r1) | wohnflaeche > r(r2)) & ejahr == `ejahr' 
}
		
* price per square meter
*--------------------

gen 	price_sqm = kaufpreis / wohnflaeche
replace price_sqm = . if price_sqm < 0

* drop extreme outliers
forvalue ejahr = 2007/$maxyear{
	su		price_sqm if ejahr == `ejahr', d
	drop if  (price_sqm >= `r(p99)' | price_sqm <= `r(p1)') & ejahr == `ejahr'
}
	
* construction year
*--------------------

tab baujahr
replace baujahr = .  if baujahr <1500 // Baujahr 1500 unrealistisch & MIssingss
drop if baujahr > ${maxyear} & baujahr != .  //zukünftig zu vermietene Objekte nicht berücksichtigen


* Temp save
*--------------------
save "${OUTPUT_PATH}Temp/CampusFile_WK_temp.dta", replace


**************************************************************************
* Zeitreihe Großstädte
**************************************************************************

* neuladen der Daten
use "${OUTPUT_PATH}Temp/CampusFile_WK_temp.dta", clear


* drop letztes Jahr falls es nicht vollständig ist
if ${maxyear} != ${maxyear_complete}{
        drop if ajahr == ${maxyear}
}

* nur größte Städte behalten   
keep  if kid2019 == 11000 | kid2019 ==2000 | kid2019 == 5111 | kid2019 == 5113 | kid2019 == 5315 | kid2019 == 6412| kid2019 == 8111 | kid2019 ==  9162 | kid2019 == 14713 | kid2019 == 14612 | kid2019 == 5112 | kid2019 == 5913| gid2019 == 3241001| kid2019 == 4011| kid2019 == 9564

* für den Fall, dass das Enddatum über letztes komplette Jahre hinausreicht
* Annahme: Anzeige endet im letzten verfügbaren Monat/ Jahr
replace edat = ym(${maxyear_complete},12) if edat > ym(${maxyear_complete},12)
replace ejahr = ${maxyear_complete} if ejahr == ${maxyear}

* generiere Sample
egen NOBS = count(obid), by(ejahr kid2019)
bysort gid2019 ejahr: gen random = uniform()
egen NOBS_min = min(NOBS), by(kid2019)	

gen insample = 2000/NOBS <= random if NOBS_min <= 4000
replace insample = 4000/NOBS <= random if NOBS_min >4000 & NOBS_min < 10000
replace insample = 10000/NOBS <= random if NOBS_min >10000 
keep if insample == 0

* drop Hilfsvariablen
drop insample NOBS* ejahr emonat ajahr amonat random
compress

* export
save "${OUTPUT_PATH}panel/CampusFile_WK_cities.dta", replace

* CSV export
export delimited using "${OUTPUT_PATH}panel/CampusFile_WK_cities.csv", replace

**************************************************************************
* Cross-section
**************************************************************************
// letztes vollständige Jahre

* neuladen der Daten
use "${OUTPUT_PATH}Temp/CampusFile_WK_temp.dta", clear

* behalte nur das letzte vollständige Jahr
keep if ajahr == ${maxyear_complete} | ejahr == ${maxyear_complete} | (ajahr < ${maxyear_complete} & ejahr == ${maxyear})

* behalte letzten Spell
egen maxspell = max(spell), by(obid)
keep if spell == maxspell
drop spell maxspell ajahr ejahr amonat emonat

* generiere Sample
bysort gid2019: gen random = uniform()
egen NOBS = count(obid), by(gid2019)	
replace gid2019 = . if NOBS < 50
replace NOBS =. if NOBS <  50
egen NOBS2 = count(obid), by(kid2019)
drop if NOBS2 < 100

gen insample = 50/NOBS <= random if NOBS <= 200
replace insample = 200/NOBS <= random if NOBS>200 & NOBS < 1000
replace insample = 1000/NOBS <= random if NOBS >1000 & NOBS < 5000
replace insample = 5000/NOBS <= random if NOBS >= 5000
replace insample = 100/NOBS2 <=random if NOBS == . 
keep if insample == 0

* drop Hilfsvariablen
drop insample NOBS* random
compress

* export
save "${OUTPUT_PATH}cross_section/CampusFile_WK_${maxyear_complete}.dta", replace

* CSV EXPORT
export delimited using "${OUTPUT_PATH}cross_section/CampusFile_WK_${maxyear_complete}.csv", replace

**************************************************************************
* close log file
log close
exit
