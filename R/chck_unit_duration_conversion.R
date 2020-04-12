# script to check concentration and duration units

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# chck table --------------------------------------------------------------
cols = c('result_id',
         'obs_duration_unit',
         'obs_duration_mean2_manual', 'obs_duration_unit2_manual')
dur_chck = fread(file.path(lookupdir, 'chck_unit_duration_conversion.csv'),
                 select = cols,
                 na.strings = '')

# chck new units ----------------------------------------------------------
q = paste0(
  "SELECT DISTINCT ON (obs_duration_unit) result_id, obs_duration_unit
    FROM ecotox.results2
    WHERE obs_duration_unit NOT IN ('", paste0(dur_chck$obs_duration_unit, collapse = "', '"), "')
      AND obs_duration_unit NOT IN ('', '--', 'NA', 'NC', 'NR');"
)
new = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                 query = q)
# condition
if (nrow(new) != 0) {
  log_msg('New units! Add them to chck_unit_result_conversion.csv')
}

# retrieve specific single result_id s ------------------------------------
q = paste0(
  "SELECT result_id, obs_duration_mean, obs_duration_unit, obs_duration_mean2, obs_duration_unit2
   FROM ecotox.results2
   WHERE result_id IN (", paste0(dur_chck$result_id, collapse = ', '), ");"
)
dur = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                 query = q)

# merge -------------------------------------------------------------------
dur2 = merge(dur, dur_chck, by = c('result_id', 'obs_duration_unit'), all = TRUE)

# prepare -----------------------------------------------------------------
dur2[ , chck_mean2 := fifelse(obs_duration_mean2 == obs_duration_mean2_manual, TRUE, FALSE) ]
dur2[ , chck_unit2 := fifelse(obs_duration_unit2 == obs_duration_unit2_manual, TRUE, FALSE) ]

# manual checking ---------------------------------------------------------
# TODO out-comment this
dur2[ , .N, chck_mean2 ] # NA 0; FALSE 2
# TODO dur2[ chck_mean2 == FALSE ]
dur2[ , .N, chck_unit2 ] # NA 0; FALSE 2
dur2[ chck_unit2 == FALSE, .SD, .SDcols = c('result_id', 'obs_duration_unit') ] # TODO

# write -------------------------------------------------------------------
saveRDS(dur2, file.path(cachedir, 'chck_unit_duration_conversion.rds'))

# chck --------------------------------------------------------------------
chck_equals(nrow(dur2[ is.na(chck_mean2) | chck_mean2 == FALSE ]), 0)
chck_equals(nrow(dur2[ is.na(chck_unit2) | chck_unit2 == FALSE ]), 0)

# log ---------------------------------------------------------------------
log_msg('CHCK: Duration units conversions check script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()

