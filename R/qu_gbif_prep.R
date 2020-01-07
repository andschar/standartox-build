# script to prepare occurrence data from the Global Biodiversity Information Facility (GBIF)

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# helper function ---------------------------------------------------------
to_dt = function(vec) {
  vec = na.omit(unique(vec))
  dt = data.table(t(as.logical(gsub('.+', TRUE, vec))))
  setnames(dt, tolower(vec))
  dt
}

# data --------------------------------------------------------------------
l_fl = list.files(file.path(cachedir, 'gbif'),
                  full.names = TRUE)

# variables ---------------------------------------------------------------
fresh = c('bach', 'weiher', 'fluss', 'strom', 'teich', 'estanque', 'puddle', 'water body', 'gravel', 'cobble', 'aquarium', 'spring', 'ditch', 'bog','peat', 'swamp', 'myr', 'fresh', 'creek', 'riffle', 'current', 'rapid', 'brook', 'canal', 'channel', 'kanal', 'stream', '^å$', 'river', 'r.', 'reservoir', 'riparian', 'marginal vegetation', 'río', 'rio', 'tributary', 'lago', 'lac', 'lake', 'pool', 'pond', 'freshwater', 'floodplain', 'flood plain', 'wetland', 'humedal', 'sumpskog', 'waterhole', 'damm', 'doce', 'douce', 'vattendrag', 'léntico', 'marsh', 'marais', 'dulce', 'lótico', 'ruisseau', 'fleuve', 'cours', 'epiliton', 'inundable', 'bäck', 'cenote', 'grunt vatten', 'kärr', 'stagnant water',
          'ganges', 'nil', 'danube', 'volga')
brack = c('estuar', 'brackish', 'brackvatten', 'intermareal', 'saumâtre', 'saumatre')
marin = c('sandstrand', 'sea', 'ocean', 'marin', 'litoral', 'littoral', 'pelágico', 'intertidal', 'gulf', 'indian', 'atlantic', 'mediterranean', 'pacific', 'laguna', 'havsstrand', 'cotier', 'coster', 'coast', 'lagoon', 'sand', 'strand', 'playa', 'beach', 'seagrass', 'bay', 'intermareal', 'hällkar', 'manglar', 'mangrov', 'reef', 'tide', 'salée', 'mer', 'meer')
terre = c('terre', 'bush', 'wood', 'palma', 'spruce', 'birch', 'forest', 'foret', 'skog', 'barrskog', 'lövskog', 'hagmark', 'skogsmark', 'skräpmark', 'pasture', 'mud', 'jordhög', 'grassland', 'ruderat', 'ruderatmark', 'trädgård', 'marsh', 'vägkant', 'garden', 'kompost', 'bosque', 'åkerkant', 'roadside', 'meadow', 'culture', 'soil', 'urban', 'dunes', 'epifiton', 'soptipp', 'inomhus', 'åker', 'park', 'jordtipp', 'vägren', 'grustag', 'rock', 'industriavfall', 'tipp', 'farm', 'arboretum', 'greenhouse', 'savan', 'sabana', 'filed', 'grass', 'indoors')

# extract -----------------------------------------------------------------
l = list()
for (i in seq_along(l_fl)) {
  taxon = from_filename(basename(l_fl[i]))
  message('Reading: ', taxon)
  gbif = readRDS(l_fl[i])
  if (is.list(gbif)) {
    dat = list(taxon = from_filename(basename(l_fl[i])),
               taxonkey = to_dt(gbif$data$taxonKey),
               country = to_dt(gbif$data$country),
               country_code = to_dt(gbif$data$countryCode),
               continent = to_dt(gbif$data$continent),
               habitat = data.table(fresh = as.logical(length(grep(paste0(fresh, collapse = '|'), gbif$data$habitat, ignore.case = TRUE, value = TRUE))),
                                    marin = as.logical(length(grep(paste0(marin, collapse = '|'), gbif$data$habitat, ignore.case = TRUE, value = TRUE))),
                                    brack = as.logical(length(grep(paste0(brack, collapse = '|'), gbif$data$habitat, ignore.case = TRUE, value = TRUE))),
                                    terre = as.logical(length(grep(paste0(terre, collapse = '|'), gbif$data$habitat, ignore.case = TRUE, value = TRUE)))),
               elevation = data.table(min = min(gbif$data$elevation, na.rm = TRUE),
                                      median = median(gbif$data$elevation, na.rm = TRUE),
                                      mean = mean(gbif$data$elevation, na.rn = TRUE),
                                      sd = sd(gbif$data$elevation, na.rm = TRUE),
                                      max = max(gbif$data$elevation, na.rm = TRUE)),
               geo = unique(data.table(lat = gbif$data$decimalLatitude,
                                       lon = gbif$data$decimalLongitude,
                                       geodetic_datum = gbif$data$geodeticDatum)))
  } else {
    dat = list(NA)
  }
  l[[i]] = dat
  names(l)[i] = taxon
}

# prepare -----------------------------------------------------------------
country_code = rbindlist(lapply(l, `[[`, 'country_code'), fill = TRUE, idcol = 'taxon')
setcolorder(country_code, sort_vec(names(country_code), ignore = 'taxon'))
country_code[ , none := NULL ]
country_code_lookup = data.table(code = names(country_code))
country_code_lookup = country_code_lookup[ code != 'taxon' ]
country_code_lookup[ , name := countrycode::countrycode(code, 'iso2c', 'iso.name.en') ]
continent = rbindlist(lapply(l, `[[`, 'continent'), fill = TRUE, idcol = 'taxon')
setcolorder(continent, sort_vec(names(continent), ignore = 'taxon'))
habitat = rbindlist(lapply(l, `[[`, 'habitat'), fill = TRUE, idcol = 'taxon')
setcolorder(habitat, sort_vec(names(habitat), ignore = 'taxon'))
elevation = rbindlist(lapply(l, `[[`, 'elevation'), fill = TRUE, idcol = 'taxon')
for (col in names(elevation)) set(elevation, i = which(is.infinite(elevation[[col]])), j = col, value = NA)
geo = rbindlist(lapply(l, `[[`, 'geo'), fill = TRUE, idcol = 'taxon')

# chck --------------------------------------------------------------------
chck_dupl(country_code, 'taxon')
chck_dupl(country_code_lookup, 'code')
chck_dupl(continent, 'taxon')
chck_dupl(habitat, 'taxon')
chck_dupl(elevation, 'taxon')

# write -------------------------------------------------------------------
# country code
write_tbl(country_code, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'gbif', tbl = 'country_code',
          comment = 'Results from the GBIF query (country_code)')
# country code elookup
write_tbl(country_code, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'lookup', tbl = 'country_code',
          comment = 'Results from the GBIF query (country_code_lookup)')
# continent
write_tbl(continent, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'gbif', tbl = 'continent',
          comment = 'Results from the GBIF query (continent)')
# habitat
write_tbl(habitat, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'gbif', tbl = 'habitat',
          comment = 'Results from the GBIF query (habitat)')
# habitat
write_tbl(elevation, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'gbif', tbl = 'elevation',
          comment = 'Results from the GBIF query (elevation)')
# habitat
write_tbl(geo, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'gbif', tbl = 'geo',
          comment = 'Results from the GBIF query (geo)')

# log ---------------------------------------------------------------------
log_msg('GBIF preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()

