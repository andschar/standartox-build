# script to scrap occurrence data from the Global Biodiversity Information Facility (GBIF)

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
full_list = TRUE # loads the full result list if online=FALSE

# data --------------------------------------------------------------------
todo_gbif = readRDS(file.path(cachedir, 'epa_taxa.rds'))

# query -------------------------------------------------------------------
todo_gbif = sort(unique(todo_gbif$taxon))
# todo_gbif = todo_gbif[818:820] # debug me!

if (online) {
#! takes 1.7h for 1500 taxa
  time = Sys.time()
  gbif_l = list()
  for (i in seq_along(todo_gbif)) {
    taxon = todo_gbif[i]
    message('Querying (', i, '/', length(todo_gbif), '): ', taxon)
    
    key = name_backbone(taxon)$speciesKey
    
    if (!is.null(key)) {
      gbif = tryCatch({
        occ_search(taxonKey = key)
      }, error = function(e) { cat('ERROR: ', conditionMessage(e), '\n'); return(NA) })
    } else {
      gbif = NA
    }
    
    gbif_l[[i]] = gbif
    names(gbif_l)[i] = taxon
  }
  Sys.time() - time
  
  saveRDS(gbif_l, file.path(cachedir, 'gbif_l.rds'))
  
  # some preparation steps are done here and saved locally due to the size of gbif_l
  oldw = getOption("warn")
  options(warn = -1) # shuts off warnings
  # lapply( sapply(gbif_l, '[', 'data'), '[', 'habitat') 
  #! you can't simply do that, 'cause there might be taxa without a habitat column!
  gbif_ccode_l = lapply(gbif_l,
                        function(x) if (length(x) == 1 & is.na(x)) data.table(NA)
                                    else data.table(unique(x$data$countryCode)))
  
  gbif_continent_l = lapply(gbif_l,
                            function(x) if (length(x) == 1 & is.na(x)) data.table(NA)
                            else data.table(unique(x$data$continent)))
  
  gbif_habitat_l = lapply(gbif_l,
                          function(x) if (length(x) == 1 & is.na(x)) data.table(NA)
                                      else data.table(unique(x$data$habitat)))
  
  gbif_waterBody_l = lapply(gbif_l,
                            function(x) if (length(x) == 1 & is.na(x)) data.table(NA)
                            else data.table(unique(x$data$waterBody)))
  
  options(warn = oldw); rm(oldw)
  
  saveRDS(gbif_ccode_l, file.path(cachedir, 'gbif_ccode_l.rds'))
  saveRDS(gbif_continent_l, file.path(cachedir, 'gbif_continent_l.rds'))
  saveRDS(gbif_habitat_l, file.path(cachedir, 'gbif_habitat_l.rds'))
  saveRDS(gbif_waterBody_l, file.path(cachedir, 'gbif_waterBody_l.rds'))
  
} else {
  
  if (full_list) {
    gbif_l = readRDS(file.path(cachedir, 'gbif_l.rds')) # takes time!  
  }
  gbif_ccode_l = readRDS(file.path(cachedir, 'gbif_ccode_l.rds'))
  gbif_continent_l = readRDS(file.path(cachedir, 'gbif_continent_l.rds'))
  gbif_habitat_l = readRDS(file.path(cachedir, 'gbif_habitat_l.rds'))
  gbif_waterBody_l = readRDS(file.path(cachedir, 'gbif_waterBody_l.rds'))
}


# other variables that could possibly be usefull
# # 1 elevation
# head(gbif_l[[1]]$data$elevation)
# head(gbif_l[[1]]$data$elevationAccuracy)
# # 2 Lat Long - maybe intersection with oceanic layer? huge computational effort
# head(gbif_l[[1]]$data$decimalLatitude)
# head(gbif_l[[1]]$data$decimalLongitude)
# head(gbif_l[[1]]$data$coordinateUncertaintyInMeters)
# # 3 ID
# head(gbif_l[[1]]$data$gbifID)
# # 4 life stage (maybe for other projects)
# head(gbif_l[[1]]$data$lifeStage)
# # others
# head(gbif_l[[1]]$datadepth)
# head(gbif_l[[1]]$datadepthAccuracy)
# head(gbif_l[[1]]$dataorganismQuantity)
# head(gbif_l[[1]]$datalocationID)
# head(gbif_l[[1]]$dataisland)

# preparation -------------------------------------------------------------

# country code ------------------------------------------------------------ 
gbif_ccode = rbindlist(gbif_ccode_l, idcol = 'taxon')
setnames(gbif_ccode, old = 'V1', new = 'ccode')
gbif_ccode = gbif_ccode[ ccode != 'none' ] # delete 'none' entries
gbif_ccode_dc = dcast(gbif_ccode, taxon ~ ccode, value.var = 'ccode',
                      fun.aggregate = function(x) as.numeric(length(x) >= 1), fill = NA)

# continent ---------------------------------------------------------------
gbif_continent = rbindlist(gbif_continent_l, idcol = 'taxon')
setnames(gbif_continent, old = 'V1', new = 'continent')
gbif_continent[ , continent := tolower(continent) ]
gbif_conti_dc = dcast(gbif_continent, taxon ~ continent, value.var = 'continent',
                      fun.aggregate = function(x) as.numeric(length(x) >= 1), fill = NA)

# habitat -----------------------------------------------------------------
gbif_habitat = rbindlist(gbif_habitat_l, idcol = 'taxon')
setnames(gbif_habitat, 'V1', 'habitat')
gbif_habitat[ , habitat := tolower(habitat) ]
# match habitat variables
fresh = c('brook', 'stream', 'river', 'tributary', 'lake', 'freshwater')
brack = c('estuary')
marin = c('ocean', 'atlantic', 'pcaific')
#terre = NULL

gbif_habitat[ , isFre_gbif := ifelse(habitat %like% paste0(fresh, collapse = '|'), 1, NA) ]
gbif_habitat[ , isBra_gbif := ifelse(habitat %like% paste0(brack, collapse = '|'), 1, NA) ]
gbif_habitat[ , isMar_gbif := ifelse(habitat %like% paste0(marin, collapse = '|'), 1, NA) ]
#gbif_habitat[ , isTer_gbif := ifelse(habitat %like% paste0(terre, collapse = '|'), 1, NA) ]

# cleaning ----------------------------------------------------------------
oldw = getOption("warn")
options(warn = -1) # shuts off warnings

rm(epa, i, key, taxon, todo_gbif, time, full_list, gbif_l, gbif_ccode_l)

options(warn = oldw); rm(oldw)





