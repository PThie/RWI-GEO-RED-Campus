# RWI-GEO-RED Campus Files

This repository shows the detailed preparation and generation of the RWI-GEO-RED Campus Files (panel and cross-section) dataset.

## Abstract Data Description (V6)

The FDZ Ruhr provides two campus files on real estate advertisements in Germany: the Panel Campus File (RWI-GEO-RED Panel) and a Cross-Sectional Campus File (RWI-GEO-RED Cross-Section). The datasets are extractions of the Scientific Use Files of RWI-GEO-RED. The Panel File covers the 15 largest cities in Germany over the whole time period, whereas the Cross-Section File covers all of Germany within one year (2024). The RWI-GEO-RED data are based on information from the internet platform ImmobilienScout24 and cover residential advertisements only. The campus files include apartments for sale and for rent and houses for sale. The data are available for lectures, tutorials, seminar thesis, bachelor and master thesis and scientific research. The provided dataset covers detailed regional information and a rich set of housing characteristics. Both datasets are samples drawn and not comprehensive databases like the Scientific Use File. The already implemented data cleaning eases the data work for students. This data report gives a brief overview of the data as well as its limitations and specifics. The data report is addressed to (potential) users of the data as support for their data preparation.

The current version RWI-GEO-RED Campus Files covers data until 2024.

## Access

The data can be obtained as Campus Files (PUF) from the FDZ Ruhr at RWI. The FDZ Ruhr is the research data center of the RWI - Leibniz Institute for Economic Research.

Data access does not require a data use agreement. Interested users should write an email to [fdz@rwi-essen.de](fdz@rwi-essen.de).

Data users shall cite the datasets properly with the respective DOIs. The DOIs of the current version (V6) of the datesets are: 

**Panel Campus File:** [https://doi.org/10.7807/immo:red:panel:v6](https://doi.org/10.7807/immo:red:panel:v6)

**Cross-Section Campus File:** [https://doi.org/10.7807/immo:red:cross:v6](https://doi.org/10.7807/immo:red:cross:v6)

Users must consider the following aspects when using the data:
- The sources mentioned above must be cited correctly.
- The data may only be used within the context of courses and theses. Any further use, especially for commercial purposes, is prohibited.
- Any distribution of the data is strictly prohibited.
- The data must be permanently deleted after the approved use has ended. Deletion must be confirmed via email to [fdz@rwi-essen.de](fdz@rwi-essen.de).
- Users are requested to cite the source correctly.

## More Information

- [General information on RWI-GEO-RED/C/X](https://www.rwi-essen.de/en/research-advice/further/research-data-center-ruhr-fdz/data-sets/rwi-geo-red/x-real-estate-data-and-price-indices)
- [Data report RWI-GEO-RED Campus File V6](https://www.rwi-essen.de/fileadmin/user_upload/RWI/FDZ/Datenbeschreibung-Campus-v6.pdf). Please cite the data report as: Thiel (2025), FDZ Data Description:
Real-Estate Data for Germany Campus Files
(RWI-GEO-RED Panel and RWI-GEO-RED Cross v6) -
Advertisements on the Internet Platform
ImmobilienScout24 for Teaching Purposes, RWI Projektberichte, Essen.

## DOI

- Repository for V1.0: [![DOI:10.5281/zenodo.15592891](http://img.shields.io/badge/DOI-10.5281/zenodo.15592891-048BC0.svg)](https://zenodo.org/account/settings/github/repository/PThie/RWI-GEO-RED-Campus)
- RWI-GEO-RED Campus File V6 (Panel): [https://doi.org/10.7807/immo:red:panel:v6](https://doi.org/10.7807/immo:red:panel:v6)
- RWI-GEO-RED Campus File V6 (Cross-Section): [https://doi.org/10.7807/immo:red:cross:v6](https://doi.org/10.7807/immo:red:cross:v6)

## Contact Person

Please contact [Dr. Patrick Thiel](https://www.rwi-essen.de/rwi/team/person/patrick-thiel) in case of questions.

## Disclaimer

All rights reserved to RWI and the author of the code, [Dr. Patrick Thiel](https://www.rwi-essen.de/rwi/team/person/patrick-thiel). In the case of used libraries, the main file ([_targets.R](https://github.com/PThieRWI-GEO-RED-Campus/blob/main/_targets.R)) should be consulted. For a comprehensive list, including direct dependencies, refer to the [renv.lock file](https://github.com/PThie/RWI-GEO-RED-Campus/blob/main/renv.lock). Please note that the terms of conditions of each library apply.