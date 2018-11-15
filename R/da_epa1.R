# script to prepare EPA ECOTOX data
# raw data appart from some preparation steps (for use with NORMAN)

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
source(file.path(src, 'da_epa_query.R'))

# data base
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))

# merge: addition
source(file.path(src, 'da_epa_taxonomy.R'))
source(file.path(src, 'da_epa_media.R'))
source(file.path(src, 'da_epa_endpoints.R'))
source(file.path(src, 'da_epa_doses.R'))
source(file.path(src, 'da_epa_statistics.R'))

# query -------------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  res = dbGetQuery(con, "SELECT DISTINCT ON (test_cas) test_cas
                   FROM ecotox.tests
                   ORDER BY test_cas ASC")
  todo_cas = sort(res$test_cas) # all the CAS in the EPA ECOTOX database
  # todo_cas = todo_cas[1:10] # debug me!
  
  epa1_l <- list()
  for (i in seq_along(todo_cas)) {
    casnr <- todo_cas[i]
    d <- dbGetQuery(con, sprintf(q, casnr))
    
    message('Returning ', '(', i, '/', length(todo_cas), '): ', casnr, ' (n = ', nrow(d), ')')
    
    epa1_l[[i]] <- d
    names(epa1_l)[i] <- casnr
    
  }
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  ## cleaning
  rm(d, con, drv, i) # larger objects
  rm(casnr, todo_cas) # vectors
  
  ## save
  saveRDS(epa1_l, file.path(cachedir, 'source_epa1_list.rds'))
  
} else {
  epa1_l = readRDS(file.path(cachedir, 'source_epa1_list.rds'))
}

epa1 = rbindlist(epa1_l)

# remove empty results ----------------------------------------------------
# rm conc (only very little!)
epa1 = epa1[ !conc1_mean %in% c('', '+ NR', 'NR') ]
epa1 = epa1[ -grep('ca|x|~', conc1_mean) ]
# repare eonc
epa1[ , conc1_mean := gsub(',', '.', conc1_mean) ]
# new cols
epa1[ grep('\\*', conc1_mean) , conc1_mean_calc := 1L ] # '*' - indicates recalculated values (to ug/L)
epa1[ , qualifier := str_extract(conc1_mean, '<|>') ]
epa1[ is.na(qualifier), qualifier := '=' ]
# clean concentration column
epa1[ , conc1_mean := trimws(gsub('^\\+|<|>|\\*|=', '', conc1_mean)) ] # remove '*' and '+' (TODO don't know '+')
epa1[ , conc1_mean := as.numeric(conc1_mean) ]

# merges: additional ------------------------------------------------------
# merge taxonomy ----------------------------------------------------------
epa1 = merge(epa1, tax, by = 'latin_name'); rm(tax)

# merge media characteristics ---------------------------------------------
epa1 = merge(epa1, med, by = 'result_id'); rm(med)

# merge entpoints ---------------------------------------------------------
epa1 = merge(epa1, epts, by = 'endpoint', all.x = TRUE); rm(epts)
# cleaning
cols_rm = c('endpoint', 'n') 
epa1[ , (cols_rm) := NULL ]; rm(cols_rm)
setnames(epa1, 'endpoint_cl', 'endpoint')

# merge doses -------------------------------------------------------------
epa1 = merge(epa1, dose_dc, by = 'test_id', all.x = TRUE); rm(dose_dc)

# merge statistics --------------------------------------------------------
epa1 = merge(epa1, sta, by = 'result_id', all.x = TRUE); rm(sta)

# preparation -------------------------------------------------------------
# CAS
epa1[ , cas := casconv(casnr) ]
# Source column
epa1[ , source := 'EPA ecotox' ]
# Clean effect column
epa1[ , effect := gsub('~|/|*', '', effect) ] # remove ~, /, or * from effect column
# measurement (more detailed effect description)
epa1[ , res_measurement := gsub('\\/', '', measurement) ]
# Endpoint
epa1[ , endpoint := gsub('/|\\*|(\\*/)', '', endpoint) ]
# Exposure typpe
epa1[ , exposure_type := gsub('/|\\*|(\\*/)', '', exposure_type) ]
# Media type
epa1[ , media_type := gsub('/|\\*|(\\*/)', '', media_type) ]
# Test location
# FIELD (A-artificial, N-natural, U-undeterminable), LAB, NR
epa1[ , test_location := gsub('/|\\*|(\\*/)', '', test_location) ]

# set all "" to NA
for (i in names(epa1)) {
  epa1[get(i) == "", (i) := NA]
}

# writing -----------------------------------------------------------------
#### Etox-Base ----
time = Sys.time()
saveRDS(epa1, file.path(cachedir, 'epa1.rds'))
Sys.time() - time
# taxa
taxa = unique(epa1[ , .SD, .SDcols = c('taxon', 'tax_genus', 'tax_family') ])
saveRDS(taxa, file.path(cachedir, 'epa_taxa.rds'))
# chemical data
chem = unique(epa1[ , .SD, .SDcols = c('casnr', 'cas', 'chemical_name')])
saveRDS(chem, file.path(cachedir, 'epa_chem.rds'))

# NORMAN variables --------------------------------------------------------
no_look = fread(file.path(norman, 'norman_lookup.csv'),
                na.strings = 'NA')
# check 
chck_no_look = nrow( no_look[ status == 'ok' & ! key %in% names(epa1) ] )
if (chck_no_look != 0) {
  msg = 'Some NORMAN lookup variables can not be found in names(epa1)'
  log_msg(msg)
  stop(msg)
}; rm(chck_no_look)

# integer column names
cols = no_look$key
names(cols) = no_look$id1

# NORMAN table
epa1_norman = epa1[ , .SD, .SDcols = cols ]
setnames(epa1_norman, names(cols))

# epa ecotox_raw data for sharing
time = Sys.time()
fwrite(epa1_norman, file.path(share, 'epa1_raw.csv'))
Sys.time() - time
# epa ecotox raw data example for sharing
time = Sys.time()
set.seed(1234)
# idx = sample(1:nrow(epa1_norman), 1000)
idx = epa1_norman[ `21` == '3380345' ] # triclosan
# idx = epa1[ cas == 'TODO-CAS' ] # TODO find CAS from Triclosan
fwrite(epa1_norman[ idx ], file.path(share, 'epa1_raw_sample.csv'))
Sys.time() - time
# meta data
epa1_norman_meta = ln_na(epa1_norman)
setnames(epa1_norman_meta, 'variable', 'id')
epa1_norman_meta[ , variable := cols[ match(epa1_norman_meta$id, names(cols)) ] ] # named v update
setcolorder(epa1_norman_meta, c('id', 'variable'))
fwrite(epa1_norman_meta,
       file.path(share, 'epa1_raw_variables.csv'))

# log ---------------------------------------------------------------------
msg = 'EPA: raw script run'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
rm(q, epa1_l, epa1, epa1_norman, epa1_norman_meta, no_look)
rm(taxa, chem)
rm(idx, i)



