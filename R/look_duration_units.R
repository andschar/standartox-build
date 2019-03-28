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
  
  unit = dbGetQuery(
    con,
    "SELECT obs_duration_unit, count(obs_duration_unit) AS n
    FROM ecotox.results
    GROUP BY obs_duration_unit
    ORDER BY n DESC"
  )
  setDT(unit)
  # unit[conc1_unit == '', conc1_unit := NA]
  # unit = unit[!is.na(conc1_unit)]
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(unit, file.path(cachedir, 'epa_units_duration.rds'))
  
} else {
  unit = readRDS(file.path(cachedir, 'epa_units_duration.rds'))
}
## lookup csv
look_dur = fread(file.path(lookupdir, 'lookup_duration.csv'), na.strings = '')

units = merge(unit, look_dur, by.x = 'obs_duration_unit', by.y = 'unit')
units[ is.na(conv_to), conv_to := obs_duration_unit ]
setnames(units,
         c('obs_duration_unit', 'conv_to'),
         c('unit', 'duration'))

# writing -----------------------------------------------------------------
## postgres
write_tbl(units, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'lookup', tbl = 'duration_lookup',
          comment = 'Lookup table for duration units')
# to .csv
fwrite(units, file.path(normandir, 'lookup_result_unit_all.csv'))

# log ---------------------------------------------------------------------
msg = 'LOOK: Duration lookup tables script run.'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()





