# script to convert duration units

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
## postgres
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv,
                  user = DBuser,
                  dbname = DBetox,
                  host = DBhost,
                  port = DBport,
                  password = DBpassword)
  
  dur = dbGetQuery(con, 'SELECT distinct on (obs_duration_unit) obs_duration_unit
                         FROM ecotox.results')
  setDT(dur)
  dur[ obs_duration_unit == '', obs_duration_unit := NA ]
  dur = dur[ !is.na(obs_duration_unit) ]
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(dur, file.path(cachedir, 'epa_durations.rds'))
  
} else {
  
  dur = readRDS(file.path(cachedir, 'epa_durations.rds'))
}
## lookup csv
look_dur = fread(file.path(lookupdir, 'lookup_duration.csv'), na.strings = '')

# check -------------------------------------------------------------------
chck_duration = nrow(dur[ !obs_duration_unit %in% look_dur$unit ])
if (chck_duration != 0) {
  log_warn('Not classified duration units.')
}

# preparation -------------------------------------------------------------
setnames(look_dur, paste0('dur_', names(look_dur)))




