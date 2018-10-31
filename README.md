---
title: "Etox-Base"
author: "Andras Scharmüller"
date: "31 October, 2018"
output:
  html_document:
    keep_md: true
editor_options: 
  chunk_output_type: console
---



## Etox Base

Etox Base is a tool that aggregates ecotoxicological test data (EC50 values, NOEC etc.) from the [US EPA ECOTOTX data base](https://cfpub.epa.gov/ecotox/). Each new version of the EPA ECOTOX database which is released on a quarterly basis is downloaded and rebuilt locally. Besides the ecotoxicological test data therein, other databases on chemicals and organism parameters are then queried to extend and fill data gaps of the EPA ECOTOX database in order to allow for more adequat filter steps according to ecotoxicological needs. Chemical parameters on for example the classification of chemicals, water solubility of compounds amongst others are obtained through databases such as [Alan Wood's Compendium of Pesticide Common Names](http://www.alanwood.net/pesticides/index.html), the [PubChem](https://pubchem.ncbi.nlm.nih.gov/) database, the [PHYSPROP Database](https://www.srcinc.com/what-we-do/environmental/scientific-databases.html) and the [chemspider Database](http://www.chemspider.com/), all of which have publically available programming interfaces (APIs). Likewise databases on organisms such as the [World Refister of Marine Species (WORMS)](http://marinespecies.org/) and the [Global Biodiversity Information Facility (GBIF)](https://www.gbif.org/) are queried to obtain information on habitat preferences and organisms occurrence patterns. CAS-Numbers are used to retrieve the additional chemical inforamtion whereas taxa names are used to query organism parameters. These queries largely rely on R-packages such as [webchem](https://github.com/ropensci/webchem), [taxize](https://github.com/ropensci/taxize/) and [rgbif](https://github.com/ropensci/rgbif) besides some self-written functions that can be accesed in the two project repositories: [etox-base](https://github.com/andreasLD/etox-base) and [etox-base-shiny](https://github.com/andreasLD/etox-base). 

The compiled data is than accessed through the Etox-Base application which filters it according to the users inputs. In the end the tool aggregates the many filtered test data to obtain a single value for a given set of test parameters.

An article on the project can be accessed [here]().







