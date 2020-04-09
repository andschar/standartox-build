# script to convert concentration units and extract additional infos

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q1 = "SELECT obs_duration_unit, count(obs_duration_unit) AS n
      FROM ecotox.results
      GROUP BY obs_duration_unit
      ORDER BY n DESC"
unit_test = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                       query = q1)
q2 = "SELECT study_duration_unit, count(study_duration_unit) AS n
      FROM ecotox.tests
      GROUP BY study_duration_unit
      ORDER BY n DESC"
unit_study = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                        query = q2)
## lookup csv
look_dur = fread(file.path(lookupdir, 'lookup_unit_duration.csv'), na.strings = '')

# prepare -----------------------------------------------------------------
unit = merge(unit_test, unit_study, by.x = 'obs_duration_unit', by.y = 'study_duration_unit',
             all = TRUE, suffixes = c('_test', '_study'))
units = merge(unit, look_dur, by.x = 'obs_duration_unit', by.y = 'unit',
              all = TRUE)
units = units[ !is.na(obs_duration_unit) ]

# check -------------------------------------------------------------------
chck_dupl(units, 'obs_duration_unit')

# write -------------------------------------------------------------------
write_tbl(units, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'lookup', tbl = 'lookup_unit_duration',
          key = 'obs_duration_unit',
          comment = 'Lookup table for duration units')

# log ---------------------------------------------------------------------
log_msg('LOOKUP: Duration lookup tables script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()





