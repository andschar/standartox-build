# functions ---------------------------------------------------------------
source(file.path(src, 'fun_extr_vec.R'))

# data --------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv,
                user = DBuser,
                dbname = DBetox,
                host = DBhost,
                port = DBport,
                password = DBpassword)

dur = dbGetQuery(con, 'select distinct on (obs_duration_unit) obs_duration_unit from ecotox.results')
setDT(dur)
dur[ obs_duration_unit %like% 'NR|--', obs_duration_unit := NA_character_ ]
dur = dur[ !is.na(obs_duration_unit) ]

dbDisconnect(con)
dbUnloadDriver(drv)

lookup = fread(file.path(lookupdir, 'units_lookup.csv'), na.strings = '')
look_str = paste0(lookup$unit, collapse = '|')

# preparation -------------------------------------------------------------
dur2 = merge(dur, lookup, by.x = 'obs_duration_unit', by.y = 'unit', all = TRUE)
setnames(dur2, old = 'obs_duration_unit', new = 'key')
dur2 = dur2[ type == 'time' ]

# output ------------------------------------------------------------------
cols_dur_fin = c('key', 'multiplier', 'conv', 'conv_to')
duration_fin = dur2[ , .SD, .SDcols = cols_dur_fin]; rm(cols_dur_fin)
setnames(duration_fin, paste0('dur_', names(duration_fin)))

# cleaning ----------------------------------------------------------------
rm(dur, dur2)
