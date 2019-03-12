# script to prepare EPA ECOTOX data

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))
# query
source(file.path(src, 'da_epa_query.R'))
# merge: addition
epa_taxa = readRDS(file.path(cachedir, 'epa_taxa.rds'))
source(file.path(src, 'da_epa_doses.R'))
source(file.path(src, 'da_epa_endpoints.R'))
source(file.path(src, 'da_epa_exposure_type.R'))
source(file.path(src, 'da_epa_media.R'))
source(file.path(src, 'da_epa_statistics.R'))

# query -------------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  if (debug_mode) {
    con = dbConnect(drv, user = 'epa_ecotox', dbname = 'etox20181213', host = 'localhost', port = 5432)
  } else {
    con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  }
  
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

# preparation -------------------------------------------------------------
epa1[ grep('\\*', conc1_mean) , conc1_mean_calc := 1L ] # '*' - indicates recalculated values (to ug/L) by EPA
epa1[ , conc1_qualifier := str_extract(conc1_mean, '<|>') ] # qualifier
epa1[ is.na(conc1_qualifier), conc1_qualifier := '=' ]

# merges: additional ------------------------------------------------------
# taxonomic data ----------------------------------------------------------
epa1 = merge(epa1, epa_taxa, by = 'species_number', all.x = TRUE)

# merge doses + control mortality -----------------------------------------
epa1 = merge(epa1, dose_dc, by = 'test_id', all.x = TRUE); rm(dose_dc)
epa1[cm, control_neg_mortality := i.control_neg_mortality, on = 'test_id' ]; rm(cm) # 51
epa1[pm, control_pos_mortality := i.control_pos_mortality, on = 'test_id' ]; rm(pm) # 79
epa1[vm, control_vhc_mortality := i.control_vhc_mortality, on = 'test_id' ]; rm(vm) # 81

# merge entpoints ---------------------------------------------------------
epa1 = merge(epa1, epts, by = 'endpoint', all.x = TRUE); rm(epts)
# cleaning
cols_rm = c('endpoint', 'n') 
epa1[ , (cols_rm) := NULL ]; rm(cols_rm)
setnames(epa1, 'endpoint_cl', 'endpoint')

# exposure type -----------------------------------------------------------
epa1 = merge(epa1, exp_typ, by = 'exposure_type'); rm(exp_typ)

# merge media characteristics ---------------------------------------------
epa1 = merge(epa1, med, by = 'result_id'); rm(med)

# merge statistics --------------------------------------------------------
epa1 = merge(epa1, sta, by = 'result_id', all.x = TRUE); rm(sta)

# preparation -------------------------------------------------------------
# CAS
epa1[ , cas := casconv(casnr) ]
# Clean effect column
epa1[ , effect := gsub('~|/|*', '', effect) ] # remove ~, /, or * from effect column
# measurement (more detailed effect description)
epa1[ , measurement := gsub('\\/', '', measurement) ]
# Endpoint
epa1[ , endpoint := gsub('/|\\*|(\\*/)', '', endpoint) ]
# Exposure typpe
epa1[ , exposure_type := gsub('/|\\*|(\\*/)', '', exposure_type) ]
# Media type
epa1[ , media_type := gsub('/|\\*|(\\*/)', '', media_type) ]
# Test location
# FIELD (A-artificial, N-natural, U-undeterminable), LAB, NR
epa1[ , test_location := gsub('/|\\*|(\\*/)', '', test_location) ]
# Chem analysis method
epa1[ , chem_analysis_method := gsub('\\/', '', chem_analysis_method) ]

# set all "" to NA
for (i in names(epa1)) {
  epa1[get(i) == "", (i) := NA]
}

# checks ------------------------------------------------------------------
## (1) NA CAS or CASNR?
cas_chck = 
  epa1[ is.na(casnr) | casnr == '' |
          is.na(cas) | cas == '' ]
if (nrow(cas_chck) != 0) {
  msg = paste0(nrow(cas_chck), ' missing CAS or CASNR.') 
  log_msg(msg)
  stop(msg)
}

## (2) Does a duplicated result_id s show different values (i.e. results)?
dupl_result_id = epa1[ , .N, result_id][order(-N)][N > 1]$result_id
chck_dupl_res_id = epa1[ result_id %in% dupl_result_id,
                         .(mn = mean(as.numeric(conc1_mean), na.rm = TRUE), # never mind the warnings!
                           sd = sd(conc1_mean, na.rm = TRUE)),
                         by = result_id][sd != 0]

if (nrow(chck_dupl_res_id) > 1) {
  msg = 'Duplicated result_id with differing values.'
  log_msg(msg)
  stop(msg)
}

# duplicated results ------------------------------------------------------
epa1 = epa1[ !result_id %in% dupl_result_id ] # duplicated entries

# writing -----------------------------------------------------------------
# postgres
time = Sys.time()
write_tbl(epa1, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'ecotox_export', tbl = 'epa1',
          comment = 'EPA ECOTOX raw export')
Sys.time() - time
# data (rds)
time = Sys.time()
saveRDS(epa1, file.path(cachedir, 'epa1.rds'))
Sys.time() - time

# log ---------------------------------------------------------------------
msg = 'EPA1: raw script run'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()


