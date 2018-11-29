# script to scrap occurrence data from the Global Biodiversity Information Facility (GBIF)

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
taxa = readRDS(file.path(cachedir, 'epa2_taxa.rds'))
# debuging
if (debug_mode) {
  taxa = taxa[1:10]  
}

# query -------------------------------------------------------------------
todo_gbif = sort(unique(taxa$taxon))
# todo_gbif = todo_gbif[818:820] # debug me!

if (online) {
#! takes 1.7h for 1500 taxa
  time = Sys.time()
  gbif_l = list()
  for (i in seq_along(todo_gbif)) {
    taxon = todo_gbif[i]
    message('GBIF: Querying (', i, '/', length(todo_gbif), '): ', taxon)
    
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
  
  if (full_gbif_l) {
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
gbif_conti_dc[ , 'NA' := NULL]

# habitat -----------------------------------------------------------------
gbif_habitat = rbindlist(gbif_habitat_l, idcol = 'taxon')
setnames(gbif_habitat, 'V1', 'habitat')
gbif_habitat[ , habitat := tolower(habitat) ]
gbif_habitat_dc = dcast(gbif_habitat, taxon ~ ., value.var = 'habitat',
                        fun.aggregate = function(x) paste0(x, collapse=' '), fill = NA)
setnames(gbif_habitat_dc, '.', 'habitat')
# match habitat variables
fresh = c('bach', 'weiher', 'fluss', 'strom', 'teich', 'estanque', 'puddle', 'water body', 'gravel', 'cobble', 'aquarium', 'spring', 'ditch', 'bog','peat', 'swamp', 'myr', 'fresh', 'creek', 'riffle', 'current', 'rapid', 'brook', 'canal', 'channel', 'kanal', 'stream', '^å$', 'river', 'r.', 'reservoir', 'riparian', 'marginal vegetation', 'río', 'rio', 'tributary', 'lago', 'lac', 'lake', 'pool', 'pond', 'freshwater', 'floodplain', 'flood plain', 'wetland', 'humedal', 'sumpskog', 'waterhole', 'damm', 'doce', 'douce', 'vattendrag', 'léntico', 'marsh', 'marais', 'dulce', 'lótico', 'ruisseau', 'fleuve', 'cours', 'epiliton', 'inundable', 'bäck', 'cenote', 'grunt vatten', 'kärr', 'stagnant water',
          'ganges', 'nil', 'danube', 'volga')
brack = c('estuar', 'brackish', 'brackvatten', 'intermareal', 'saumâtre', 'saumatre')
marin = c('sandstrand', 'sea', 'ocean', 'marin', 'litoral', 'littoral', 'pelágico', 'intertidal', 'gulf', 'indian', 'atlantic', 'mediterranean', 'pacific', 'laguna', 'havsstrand', 'cotier', 'coster', 'coast', 'lagoon', 'sand', 'strand', 'playa', 'beach', 'seagrass', 'bay', 'intermareal', 'hällkar', 'manglar', 'mangrov', 'reef', 'tide', 'salée', 'mer', 'meer')
terre = c('terre', 'bush', 'wood', 'palma', 'spruce', 'birch', 'forest', 'foret', 'skog', 'barrskog', 'lövskog', 'hagmark', 'skogsmark', 'skräpmark', 'pasture', 'mud', 'jordhög', 'grassland', 'ruderat', 'ruderatmark', 'trädgård', 'marsh', 'vägkant', 'garden', 'kompost', 'bosque', 'åkerkant', 'roadside', 'meadow', 'culture', 'soil', 'urban', 'dunes', 'epifiton', 'soptipp', 'inomhus', 'åker', 'park', 'jordtipp', 'vägren', 'grustag', 'rock', 'industriavfall', 'tipp', 'farm', 'arboretum', 'greenhouse', 'savan', 'sabana', 'filed', 'grass', 'indoors')

# waterBody ---------------------------------------------------------------
gbif_waterbody = rbindlist(gbif_waterBody_l, idcol = 'taxon')
setnames(gbif_waterbody, 'V1', 'waterbody')
gbif_waterbody_dc = dcast(gbif_waterbody, taxon ~ ., value.var = 'waterbody',
                    fun.aggregate = function(x) paste0(x, collpase = ' '), fill = NA)
setnames(gbif_waterbody_dc, '.', 'waterbody')

# merge + classify --------------------------------------------------------
gbif_hab_wat_dc = merge(gbif_habitat_dc, gbif_waterbody_dc, by = 'taxon', all = TRUE)
gbif_hab_wat_dc[ , isFre := ifelse(tolower(habitat) %like% paste0(fresh, collapse = '|') |
                                   tolower(waterbody) %like% paste0(fresh, collapse = '|'), 1, NA) ]
gbif_hab_wat_dc[ , isBra := ifelse(tolower(habitat) %like% paste0(brack, collapse = '|') |
                                   tolower(waterbody) %like% paste0(brack, collapse = '|'), 1, NA) ]
gbif_hab_wat_dc[ , isMar := ifelse(tolower(habitat) %like% paste0(marin, collapse = '|') |
                                   tolower(waterbody) %like% paste0(marin, collapse = '|'), 1, NA) ]
gbif_hab_wat_dc[ , isTer := ifelse(tolower(habitat) %like% paste0(terre, collapse = '|'), 1, NA) ]

# missing data ------------------------------------------------------------
# continent
cols_conti = grep('taxon', names(gbif_conti_dc), value = TRUE, invert = TRUE)
gbif_conti_dc[ , count := sum(.SD, na.rm = TRUE),
                 .SDcols = cols_conti,
                 by = 1:nrow(gbif_conti_dc) ]
na_conti = gbif_conti_dc[count == 0]
msg = paste0('GBIF: For ', nrow(na_conti), '/', nrow(gbif_conti_dc),
             ' taxa no continent information was found.')
log_msg(msg); rm(msg)
gbif_conti_dc[ , count := NULL]

# habitat
cols_habi = grep('(?i)isfre|isbra|ismar|ister', names(gbif_hab_wat_dc), value = TRUE)
gbif_hab_wat_dc[ , count := sum(.SD, na.rm = TRUE),
                   .SDcols = cols_habi,
                   by = 1:nrow(gbif_hab_wat_dc) ]
na_habi = gbif_hab_wat_dc[ count == 0]
msg = paste0('GBIF: For ', nrow(na_habi), '/', nrow(gbif_hab_wat_dc),
             ' taxa no habitat information was found.')
log_msg(msg); rm(msg)
gbif_hab_wat_dc[ , count := NULL]

# save missing data to .csv
missing_l = list(gbif_na_conti = na_conti, gbif_na_habi = na_habi)
for (i in 1:length(missing_l)) {
  file = missing_l[[i]]
  name = names(missing_l)[i]
  
  if (nrow(file) > 0) {
    fwrite(file, file.path(missingdir, paste0(name, '.csv')))
    message('Writing file with missing data:\n',
            file.path(missingdir, paste0(name, '.csv')))
  }
}

# names -------------------------------------------------------------------
setnames(gbif_conti_dc, paste0('gb_', names(gbif_conti_dc)))
setnames(gbif_conti_dc, 'gb_taxon', 'taxon')

setnames(gbif_hab_wat_dc, paste0('gb_', names(gbif_hab_wat_dc)))
setnames(gbif_hab_wat_dc, 'gb_taxon', 'taxon')

# cleaning ----------------------------------------------------------------
oldw = getOption("warn")
options(warn = -1) # shuts off warnings

rm(epa, i, key, taxon, todo_gbif, time, full_gbif_l, gbif_l,
   na_conti, na_habi, missing_l,
   cols_conti, cols_habi,
   gbif_ccode_l, gbif_ccode, gbif_continent_l, gbif_continent,
   gbif_habitat_l, gbif_habitat, gbif_habitat_dc,
   gbif_waterBody_l, gbif_waterbody, gbif_waterbody_dc)

options(warn = oldw); rm(oldw)




