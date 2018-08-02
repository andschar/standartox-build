# script to scrap occurrence data from the Global Biodiversity Information Facility (GBIF)

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
online = online
# online = TRUE
full_list = FALSE # loads the full result list if online=FALSE (900 MB!)

# data --------------------------------------------------------------------
epa = readRDS(file.path(cachedir, 'epa.rds'))

# query -------------------------------------------------------------------
todo_gbif = sort(unique(epa$taxon))
# todo_gbif = todo_gbif[1:5] # debug me!

if (online) {
#! takes 1.7h for 1500 taxa
  time = Sys.time()
  gbif_l = list()
  for (i in seq_along(todo_gbif)) {
    taxon = todo_gbif[i]
    key = name_backbone(taxon)$speciesKey
    message('Querying (', i, '/', length(todo_gbif), '): ', taxon)
    
    if (!is.null(key)) {
      gbif = occ_search(taxonKey = key)
    } else {
      gbif = NA
    }
    
    gbif_l[[i]] = gbif
    names(gbif_l)[i] = taxon
  }
  Sys.time() - time
  
  # some preparation steps are done here and saved locally due to the size of gbif_l
  gbif_ccode_l = lapply(gbif_l, 
                        function(x) if (!is.na(x)) data.table(unique(x$data$countryCode))
                                    else data.table(NA))
  
  saveRDS(gbif_l, file.path(cachedir, 'gbif_l.rds'))
  saveRDS(gbif_ccode_l, file.path(cachedir, 'gbif_ccode_l.rds'))
  
} else {
  if (full_list) {
    gbif_l = readRDS(file.path(cachedir, 'gbif_l.rds')) # takes time!  
  }
  gbif_ccode_l = readRDS(file.path(cachedir, 'gbif_ccode_l.rds'))
}

# preparation -------------------------------------------------------------
gbif_ccode = rbindlist(gbif_ccode_l, idcol = 'taxon')
setnames(gbif_ccode, old = 'V1', new = 'ccode')
gbif_ccode = gbif_ccode[ ccode != 'none' ] # delete 'none' entries

# add continents ----------------------------------------------------------
cciso = as.data.table(countrycode::codelist[ ,c('iso2c', 'iso.name.en', 'region', 'continent')])
missing_ccode = data.table(iso2c = c('AQ', 'ZZ', 'UM', 'IO', 'TF', 'CC', 'XK'),
                           iso.name.en = c('Antarctica', 'Unknown Country', 'United States Minor Outlying Islands', 'Indian Ocean', 'French Southern Territories', 'COCOS (KEELING) ISLANDS', 'Kosovo'),
                           region = rep(NA, 7),
                           continent = c('Antarctica', 'ZZ', 'Pacific', 'Indian Ocean', 'Atlantic', 'Indian Ocean', 'Europe'))
cciso = rbindlist(list(cciso, missing_ccode))

gbif_ccode[cciso, on = c(ccode = 'iso2c'), continent := i.continent]


# preparation 2 -----------------------------------------------------------
gbif_ccode_dc = dcast(gbif_ccode, taxon ~ ccode, value.var = 'ccode',
                      fun.aggregate = function(x) as.numeric(length(x) > 1), fill = NA)
gbif_conti_dc = dcast(gbif_ccode, taxon ~ continent, value.var = 'ccode',
                      fun.aggregate = function(x) as.numeric(length(x) > 1), fill = NA)
gbif_conti_dc[ , c('Atlantic', 'Indian Ocean', 'Pacific', 'ZZ') := NULL ]

# cleaning ----------------------------------------------------------------
oldw = getOption("warn")
options(warn = -1) # shuts off warnings

rm(epa, i, key, taxon, todo_gbif, time, full_list, gbif_l, gbif_ccode_l)

options(warn = oldw); rm(oldw)

# misc --------------------------------------------------------------------


# 
# # Search for many species
# splist <- c('Accipiter sp.', 'Junco', 'Aix sponsa')
# 
# keys = sapply(splist, function(x) name_backbone(name = x)$speciesKey, USE.NAMES = FALSE)
# 
# x = map_fetch(search = 'taxonKey', id = keys[1])
# 
# class(x)
# plot(x)
# mapview::mapview(x)
# 
# 
# key <- name_backbone(name='Helianthus annuus', kingdom='plants')$speciesKey
# res = occ_search(taxonKey=key)
# res_data = as.data.table(res$data)
# View(res_data[10,])
# 
# 
# # Options
# # example: Helianthus annuus
# 
# # (1) Geo-data intersection
# 
# # (2) country code
# dt = res$data
# unique(dt$countryCode)
# unique(dt$country)
# unique(dt$continent)
# 
# names(dt)
# unique(dt$habitat)
# unique(dt$elevation)
# unique(dt$occurrenceStatus)
# 
# 
# 
