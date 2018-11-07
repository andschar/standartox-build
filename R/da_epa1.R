# script to prepare EPA ECOTOX data
# raw data appart from some preparation steps (for use with NORMAN)

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
source(file.path(src, 'da_epa_query.R'))
# merge: addition
source(file.path(src, 'da_epa_taxonomy.R'))
source(file.path(src, 'da_epa_media.R'))
source(file.path(src, 'da_epa_endpoints.R'))
source(file.path(src, 'da_epa_doses.R'))

# data base
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))

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
epa1 = epa1[ !conc1_mean %in% c('', '+ NR') ]

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

# preparation -------------------------------------------------------------
# CAS
epa1[ , cas := casconv(casnr) ]
# Source column
epa1[ , source := 'epa' ]

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

#### NORMAN ----
# epa ecotox_raw data for sharing
time = Sys.time()
fwrite(epa1, file.path(share, 'epa1_raw.csv'))
Sys.time() - time
# epa ecotox raw data example for sharing
time = Sys.time()
set.seed(1234)
idx = sample(1:nrow(epa1), 1000)
# idx = epa1[ cas == 'TODO-CAS' ] # TODO find CAS from Triclosan
fwrite(epa1[ idx ], file.path(share, 'epa1_raw_sample.csv'))
Sys.time() - time
# meta data
epa1_meta = ln_na(epa1, names(epa1))
fwrite(epa1_meta,
       file.path(share, 'epa1_raw_variables.csv'))

# log ---------------------------------------------------------------------
msg = 'EPA: raw script run'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
rm(q, epa1_l, epa1, epa1_meta)
rm(taxa, chem)
rm(idx)

# MISC --------------------------------------------------------------
# TODO continue here!! manage raw export
# 1) put merges in front of cleaning
# 2) put refinement from this script before cleaning?
# 2) create chemical, organism (habitat, region) as additional postgres tables



