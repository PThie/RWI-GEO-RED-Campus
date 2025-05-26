******************************************************************
*
* Aufbereitung der RED Daten für das Campus File
* Autor: PT
*
******************************************************************



******************************************************************
* Setup
******************************************************************

cap log close
clear
prog drop _all
set more off

* Version der originalen Daten
global data_version v10

* Version der zu erstellenden Campus Files
global campus_version v5

******************************************************************
* Pfad
******************************************************************

* directory path
global ROOT "M:/_FDZ/RWI-GEO/RWI-GEO-RED/"
cd "${ROOT}"

* Log path
global LOG_PATH "aufbereitung/AufbereitungLog/" 

* Data path
global DATA_PATH "daten/SUF/${data_version}/"

* Output path
global OUTPUT_PATH "daten/CampusFile/${campus_version}/"

* Code path
global CODE_PATH "aufbereitung/CampusFiles/"


******************************************************************
* Globals
******************************************************************

* letztes Jahr in den Datan
global maxyear 2023

* letztes vollständiges Jahr
global maxyear_complete 2023

******************************************************************
* Aufbereitungen
******************************************************************

* HK
do "${CODE_PATH}011_Aufbereitung_CF_HK.do"

* WK
do "${CODE_PATH}012_Aufbereitung_CF_WK.do"

* WM
do "${CODE_PATH}013_Aufbereitung_CF_WM.do"
