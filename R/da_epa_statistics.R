# script to query statistical parameters from EPA data set

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data base
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))

# (1) query ---------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  sta = dbGetQuery(con, "SELECT result_id,
                                sample_size_mean, sample_size_unit,
                                trend,
                                significance_code, significance_type, significance_level_mean
                         FROM ecotox.results")
  setDT(sta)
  # '' to NA
  for (col in names(sta)) {
    set(sta, i = which(sta[[col]] == ''), j = col, value = NA)
  }; rm(col)
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(sta, file.path(cachedir, 'source_epa_statistics.rds'))
  
} else {
  
  sta = readRDS(file.path(cachedir, 'source_epa_statistics.rds'))
}

