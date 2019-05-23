# script to prepare occurrence data from the Global Biodiversity Information Facility (GBIF)

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
gbif_data = readRDS(file.path(cachedir, 'gbif_data.rds'))

## preparation ------------------------------------------------------------

# country code ------------------------------------------------------------ 
gbif_ccode = gbif_data[ !is.na(countrycode) & countrycode != 'none',
                        .(ccode = unique(countrycode)),
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
gbif_waterbody = gbif_data[ !is.na(waterbody) & waterbody != 'none',
                            .(waterbody = unique(waterbody)),
                            taxon]
gbif_waterbody_dc = dcast(gbif_waterbody, taxon ~ ., value.var = 'waterbody',
                          fun.aggregate = function(x) paste0(x, collpase = ' '), fill = NA)
setnames(gbif_waterbody_dc, '.', 'waterbody')

# elevation ---------------------------------------------------------------
gbif_elevation = unique(gbif_data[ !is.na(elevation), 
                                   elevation,
                                   by = taxon])

# geo data ----------------------------------------------------------------
gbif_geo = unique(gbif_data[ , .SD, 
                             .SDcols = c('decimallatitude',
                                         'decimallongitude',
                                         'geodeticdatum'),
                             by = taxon])

# merge + classify --------------------------------------------------------
gbif_hab_wat_dc = merge(gbif_habitat_dc, gbif_waterbody_dc, by = 'taxon', all = TRUE)
gbif_hab_wat_dc[ , fresh := ifelse(tolower(habitat) %like% paste0(fresh, collapse = '|') |
                                     tolower(waterbody) %like% paste0(fresh, collapse = '|'), 1L, NA) ]
gbif_hab_wat_dc[ , brack := ifelse(tolower(habitat) %like% paste0(brack, collapse = '|') |
                                     tolower(waterbody) %like% paste0(brack, collapse = '|'), 1L, NA) ]
gbif_hab_wat_dc[ , marin := ifelse(tolower(habitat) %like% paste0(marin, collapse = '|') |
                                     tolower(waterbody) %like% paste0(marin, collapse = '|'), 1L, NA) ]
gbif_hab_wat_dc[ , terre := ifelse(tolower(habitat) %like% paste0(terre, collapse = '|'), 1L, NA) ]

# missing data ------------------------------------------------------------
# continent
cols_conti = grep('taxon', names(gbif_conti_dc), value = TRUE, invert = TRUE)
gbif_conti_dc[ , count := sum(.SD, na.rm = TRUE),
               .SDcols = cols_conti,
               by = 1:nrow(gbif_conti_dc) ]
na_conti = gbif_conti_dc[count == 0]
gbif_conti_dc[ , count := NULL ]
setnames(gbif_conti_dc, tolower(names(gbif_conti_dc)))

# habitat
cols_habi = grep('(?i)fresh|brack|marin|terre', names(gbif_hab_wat_dc), value = TRUE)
gbif_hab_wat_dc[ , count := sum(.SD, na.rm = TRUE),
                 .SDcols = cols_habi,
                 by = 1:nrow(gbif_hab_wat_dc) ]
na_habi = gbif_hab_wat_dc[ count == 0]
gbif_hab_wat_dc[ , `:=`
                 (habitat = NULL,
                   waterbody = NULL,
                   count = NULL) ]

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

# types -------------------------------------------------------------------
cols = c('africa', 'asia', 'europe', 'north_america', 'oceania', 'south_america')
gbif_conti_dc[ , (cols) := lapply(.SD, as.numeric), .SDcols = cols ]
cols = c('marin', 'brack', 'fresh', 'terre')
gbif_hab_wat_dc[ , (cols) := lapply(.SD, as.numeric), .SDcols = cols ]

# writing -----------------------------------------------------------------
# continent
write_tbl(gbif_conti_dc, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'taxa', tbl = 'gbif_continent',
          comment = 'Results from the GBIF query (continents)')
# habitat
write_tbl(gbif_hab_wat_dc, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'taxa', tbl = 'gbif_habitat',
          comment = 'Results from the GBIF query (habitat)')
# all
write_tbl(gbif_data, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'taxa', tbl = 'gbif_all',
          comment = 'Results from the GBIF query (all)')

# log ---------------------------------------------------------------------
log_msg('GBIF preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()


