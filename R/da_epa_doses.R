# script to retrieve single doses used in the test

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data base
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))

# query -------------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  dose = dbGetQuery(con, "SELECT *
                          FROM ecotox.doses")
  setDT(dose)
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(dose, file.path(cachedir, 'dose.rds'))
  
} else {
  
  dose = readRDS(file.path(cachedir, 'dose.rds'))
}

# preparation -------------------------------------------------------------
# remove duplicated entries
dose = dose[ !duplicated(dose, by = c('test_id', 'dose_number')) ]
# dcast
dose_dc = dcast(dose, test_id ~ dose_number,
                value.var = 'dose1_mean')
setnames(dose_dc, paste0('dose', names(dose_dc)))
setnames(dose_dc, 'dosetest_id', 'test_id')

# cleaning ----------------------------------------------------------------
rm(dose)



