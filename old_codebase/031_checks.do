******************************************************************
* Setup
******************************************************************

cap log close
clear
prog drop _all
set more off

* global version campus file
global version_cf v5

* last complete year
global year 2023

******************************************************************
* Paths
******************************************************************

global dataPath "M:/_FDZ/RWI-GEO/RWI-GEO-RED/daten/"
global checkPath "M:/_FDZ/RWI-GEO/RWI-GEO-RED/aufbereitung/CampusFiles/checks/"

******************************************************************
* load data
******************************************************************
foreach datasets in panel cross_section{
	foreach types in HK WM WK{
		if ("`datasets'" == "panel"){
			* open log file
			log using "${checkPath}${version_cf}/check_CF_cities_`types'_${version_cf}.txt", text replace
	
			* read data
			use "${dataPath}CampusFile/${version_cf}/`datasets'/CampusFile_`types'_cities.dta", clear

			* check labels
			des
			
			* check key variables
			if ("`types'" == "WM") {
				sum mietekalt nebenkosten wohnflaeche etage zimmeranzahl badezimmer laufzeittage einbaukueche gaestewc rent_sqm
			}
			else {
				sum kaufpreis wohnflaeche grundstuecksflaeche zimmeranzahl badezimmer laufzeittage gaestewc keller price_sqm
			}
			
			* plot average price
			if ("`types'" == "WM") {
				bysort edat: egen mean_rent_sqm = mean(rent_sqm)
				twoway line mean_rent_sqm edat
				graph export "${checkPath}${version_cf}/price_over_time_`types'_cities_${version_cf}.png", replace
			}
			else{
				bysort edat: egen mean_price_sqm = mean(price_sqm)
				twoway line mean_price_sqm edat
				graph export "${checkPath}${version_cf}/price_over_time_`types'_cities_${version_cf}.png", replace
			}
			

			log close
		} 
		else {
			* open log file
			log using "${checkPath}${version_cf}/check_CF_${year}_`types'_${version_cf}.txt", text replace
	
			* read data
			use "${dataPath}CampusFile/${version_cf}/`datasets'/CampusFile_`types'_${year}.dta", clear

			* check labels
			des
			
			* check key variables
			if ("`types'" == "WM") {
				sum mietekalt nebenkosten wohnflaeche etage zimmeranzahl badezimmer laufzeittage einbaukueche gaestewc rent_sqm
			}
			else {
				sum kaufpreis wohnflaeche grundstuecksflaeche zimmeranzahl badezimmer laufzeittage gaestewc keller price_sqm
			}
			
			* plot average price
			if ("`types'" == "WM") {
				bysort edat: egen mean_rent_sqm = mean(rent_sqm)
				twoway line mean_rent_sqm edat
				graph export "${checkPath}${version_cf}/price_over_time_`types'_${year}_${version_cf}.png", replace
			}
			else{
				bysort edat: egen mean_price_sqm = mean(price_sqm)
				twoway line mean_price_sqm edat
				graph export "${checkPath}${version_cf}/price_over_time_`types'_${year}_${version_cf}.png", replace
			}
			
			log close
		}
	}
}
