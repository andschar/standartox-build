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

  # retrieve data
  gbif_data_l = purrr::map(gbif_l, 'data')
  # bind to data.table
  gbif_data = rbindlist(gbif_data_l, fill = TRUE, idcol = 'taxon')
  
  saveRDS(gbif_data, file.path(cachedir, 'gbif_data.rds'))
  
} else {
  
  if (full_gbif_l) {
    gbif_l = readRDS(file.path(cachedir, 'gbif_l.rds')) # takes time!  
  }
  gbif_data = readRDS(file.path(cachedir, 'gbif_data.rds'))
}

# preparation -------------------------------------------------------------

# country code ------------------------------------------------------------ 
gbif_ccode = gbif_data[ !is.na(countryCode) & countryCode != 'none',
                       .(ccode = unique(countryCode)),
                       taxon]
gbif_ccode_dc = dcast(gbif_ccode, taxon ~ ccode, value.var = 'ccode',
                      fun.aggregate = function(x) as.numeric(length(x) >= 1), fill = NA)

# continent ---------------------------------------------------------------
gbif_continent = gbif_data[ !is.na(continent) & continent != 'none',
                           .(continent = unique(continent)),
                           taxon]
gbif_conti_dc = dcast(gbif_continent, taxon ~ continent, value.var = 'continent',
                      fun.aggregate = function(x) as.numeric(length(x) >= 1), fill = NA)

# habitat -----------------------------------------------------------------
gbif_habitat = gbif_data[ !is.na(habitat) & habitat != 'none',
                         .(habitat = unique(habitat)),
                         taxon]
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
gbif_waterbody = gbif_data[ !is.na(waterBody) & waterBody != 'none',
                            .(waterBody = unique(waterBody)),
                            taxon]
gbif_waterbody_dc = dcast(gbif_waterbody, taxon ~ ., value.var = 'waterBody',
                          fun.aggregate = function(x) paste0(x, collpase = ' '), fill = NA)
setnames(gbif_waterbody_dc, '.', 'waterbody')

# elevation ---------------------------------------------------------------
gbif_elevation = unique(gbif_data[ !is.na(elevation), 
                                   elevation,
                                   by = taxon])

# geo data ----------------------------------------------------------------
gbif_geo = unique(gbif_data[ , .SD, 
                              .SDcols = c('decimalLatitude',
                                          'decimalLongitude',
                                          'geodeticDatum'),
                              by = taxon])

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

# writing -----------------------------------------------------------------
saveRDS(gbif_conti_dc, file.path(cachedir, 'gbif_conti_dc.rds'))
saveRDS(gbif_hab_wat_dc, file.path(cachedir, 'gbif_hab_wat_dc.rds'))

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




