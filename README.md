---
title: "Test"
author: "AS"
date: "August 16, 2018"
output: html_document
---



## Etox Base

Etox Base is a data base that prepares ecotoxicological test data (EC50 values) from the [US EPA ECOTOTX data base](https://cfpub.epa.gov/ecotox/). The whole data base was downloaded and rebuilt localy following [this](https://edild.github.io/localecotox/) guide. The data base was then filtered and refined to plausible EC50 values which are an important measure in ecotoxicology and used for the calculation of [Toxic Units](https://en.wikipedia.org/wiki/Toxic_unit). Although some of the refinement could also be done at the EPA website, crucial information for the classifciation of EC50 values such as habitat information (marien, brackish, freshwater, terrestrial) or taxa occurrence information is lacking. Therefore additional data on chemicals and organisms is queried from other online available sources including the [Alan Wood's Compendium of Pesticide Common Names](http://www.alanwood.net/pesticides/index.html), the [PubChem](https://pubchem.ncbi.nlm.nih.gov/) and the [PHYSPROP Database](https://www.srcinc.com/what-we-do/environmental/scientific-databases.html) data base and worldwide occurrence data from the [Global Biodiversity Information Facility (GBIF)](https://www.gbif.org/), habitat data from the [World Refister of Marine Species (WORMS)](http://marinespecies.org/) respectively. The databases are queried with the help of the following R-packages, [webchem](https://github.com/ropensci/webchem), [taxize](https://github.com/ropensci/taxize/) and [taxizesoap](https://github.com/ropensci/taxizesoap) and [rgbif](https://github.com/ropensci/rgbif). Subsequently the collected EC50 values are aggregated to be able to calculate TUs.



Problem:
Daphnia sp. often used (source? own analysis?). Not that susceptible to Herbicides (source?) and Neonicotinoids (source?). Therefore it is aimed to make toxicity test results easily available. Daphnia in running waters?

### How to use it?











