# script to convert concentration units and extract additional infos

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
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

dbDisconnect(con)
dbUnloadDriver(drv)

# prepare -----------------------------------------------------------------
unit = merge(unit_test, unit_study, by.x = 'obs_duration_unit', by.y = 'study_duration_unit',
             all = TRUE, suffixes = c('_test', '_study'))
## lookup csv
look_dur = fread(file.path(lookupdir, 'lookup_duration.csv'), na.strings = '')
units = merge(unit, look_dur, by.x = 'obs_duration_unit', by.y = 'unit',
              all = TRUE)
setnames(units, 'obs_duration_unit', 'unit')
units = units[ !is.na(unit) ]

# check -------------------------------------------------------------------
chck_dupl(units, 'unit')

# write -------------------------------------------------------------------
## postgres
write_tbl(units, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'ecotox', tbl = 'duration_lookup',
          key = 'unit',
          comment = 'Lookup table for duration units')

# log ---------------------------------------------------------------------
log_msg('LOOK: Duration lookup tables script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()





