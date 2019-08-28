---
title: "Standartox"
author: "Andras Scharmüller"
date: "31 October, 2018"
output:
  html_document:
    keep_md: true
editor_options: 
  chunk_output_type: console
---



## Standartox

### The data base is in its final stage of construction and about to be released at the end of July 2019.

Standartox is a tool that aggregates ecotoxicological test data (EC50 values, NOEC etc.) from the [US EPA ECOTOTX data base](https://cfpub.epa.gov/ecotox/). On a quarterly basis each new version of the EPA ECOTOX is downloaded and rebuilt locally. Besides the ecotoxicological test data, other databases on chemicals and organisms are queried in order to overcome data gaps of the EPA ECOTOX database, which allows for more adequate filtering. Chemical parameters, such as classifications of chemicals, water solubility of compounds and many more are obtained through databases such as [Alan Wood's Compendium of Pesticide Common Names](http://www.alanwood.net/pesticides/index.html), the [PubChem](https://pubchem.ncbi.nlm.nih.gov/) database, the [PHYSPROP Database](https://www.srcinc.com/what-we-do/environmental/scientific-databases.html) and the [chemspider Database](http://www.chemspider.com/). Likewise databases on organisms such as the [World Refister of Marine Species (WORMS)](http://marinespecies.org/) and the [Global Biodiversity Information Facility (GBIF)](https://www.gbif.org/) are queried to obtain additional information on habitat preferences and organism occurrence patterns. These queries largely rely on R-packages such as [webchem](https://github.com/ropensci/webchem), [taxize](https://github.com/ropensci/taxize/) and [rgbif](https://github.com/ropensci/rgbif) besides some self-written functions that can be accesed in the two project repositories: [etox-base](https://github.com/andreasLD/etox-base) and [etox-base-shiny](https://github.com/andreasLD/etox-base).







