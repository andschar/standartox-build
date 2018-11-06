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
cols = c('dose1_mean', 'dose2_mean', 'dose3_mean')
for (col in cols) {
  dose[ get(col) == 'NR', (col) := NA ]
  dose[ , (col) := as.numeric(get(col)) ]
}
#! some data has duplicated test_id + dose_number --> mean()
dose_dc = dcast(dose, test_id ~ dose_number,
                value.var = 'dose1_mean',
                fun.aggregate = mean)

setnames(dose_dc, paste0('dose_', names(dose_dc)))
setnames(dose_dc, 'dose_test_id', 'test_id')

cols = names(dose_dc)[2:length(names(dose_dc))]
for (col in cols) {
  dose_dc[ is.nan(get(col)), (col) := NA_real_ ]
}

# cleaning ----------------------------------------------------------------
rm(dose, cols)



