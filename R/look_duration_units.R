# script to convert concentration units and extract additional infos

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
## postgres
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(
    drv,
    user = DBuser,
    dbname = DBetox,
    host = DBhost,
    port = DBport,
    password = DBpassword
  )
  
  unit_test = data.table(dbGetQuery(
    con,
    "SELECT obs_duration_unit, count(obs_duration_unit) AS n
     FROM ecotox.results
     GROUP BY obs_duration_unit
     ORDER BY n DESC"
  ))
  unit_study = data.table(dbGetQuery(
    con,
    "SELECT study_duration_unit, count(study_duration_unit) AS n
     FROM ecotox.tests
     GROUP BY study_duration_unit
     ORDER BY n DESC"
  ))
  
  unit = merge(unit_test, unit_study, by.x = 'obs_duration_unit', by.y = 'study_duration_unit',
               all = TRUE, suffixes = c('_test', '_study'))
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(unit, file.path(cachedir, 'epa_units_duration.rds'))
  
} else {
  unit = readRDS(file.path(cachedir, 'epa_units_duration.rds'))
}
## lookup csv
look_dur = fread(file.path(lookupdir, 'lookup_duration.csv'), na.strings = '')
units = merge(unit, look_dur, by.x = 'obs_duration_unit', by.y = 'unit',
              all = TRUE)
setnames(units, 'obs_duration_unit', 'unit')
units = units[ !is.na(unit) ]

# writing -----------------------------------------------------------------
## postgres
write_tbl(units, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'ecotox', tbl = 'duration_lookup',
          comment = 'Lookup table for duration units')
# to .csv
fwrite(units, file.path(normandir, 'lookup_result_unit_all.csv'))

# log ---------------------------------------------------------------------
msg = 'LOOK: Duration lookup tables script run.'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()





