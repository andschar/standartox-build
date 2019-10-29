# script to check concentration and duration units

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# query -------------------------------------------------------------------
# NOTE query to retrieve a sample of the top50 units
# q = '
# WITH t1 AS (
#   SELECT obs_duration_unit, count(*) n
#   FROM ecotox.results
#   GROUP BY obs_duration_unit
#   HAVING obs_duration_unit IN ('s', 'mi', 'h', 'd', 'wk', 'mo')
#   ORDER BY n DESC
# )
# SELECT DISTINCT ON (obs_duration_unit) result_id, obs_duration_mean, obs_duration_unit
# FROM ecotox.results
# RIGHT JOIN t1 USING (obs_duration_unit)
# WHERE obs_duration_unit IN ('s', 'mi', 'h', 'd', 'wk', 'mo') AND obs_duration_mean NOT IN ('NR')
# ORDER BY obs_duration_unit;
# '

# sample ------------------------------------------------------------------
# 50 most occurring result_id s
ids = c(2231908L, 2038088L, 717310L, 2369905L, 756251L, 2318654L)

q = paste0("SELECT stx.result_id, stx.casnr, stx.obs_duration_mean, stx.obs_duration_unit, stx.obs_duration_mean2, stx.obs_duration_unit2
            FROM standartox.tests stx
            LEFT JOIN standartox.chemicals che ON stx.casnr = che.casnr
            WHERE stx.result_id IN (", paste0(ids, collapse = ','), ")
              AND conc1_mean != 'NR';")

dur = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                 query = q)

# manual comparison -------------------------------------------------------
dur[ result_id == 717310L, `:=` (obs_duration_mean3 = 3.500007, obs_duration_unit3 = 'h') ] # * 0,0166667
dur[ result_id == 756251L, `:=` (obs_duration_mean3 = 0.0027778, obs_duration_unit3 = 'h') ] # * 0.00027778
dur[ result_id == 2038088L, `:=` (obs_duration_mean3 = 48, obs_duration_unit3 = 'h') ]
dur[ result_id == 2231908L, `:=` (obs_duration_mean3 = 24, obs_duration_unit3 = 'h') ]
dur[ result_id == 2318654L, `:=` (obs_duration_mean3 = 672, obs_duration_unit3 = 'h') ]
dur[ result_id == 2369905L, `:=` (obs_duration_mean3 = 10950.015, obs_duration_unit3 = 'h') ] # * 730.001

# chck --------------------------------------------------------------------
chck_obs_duration_mean2 = dur[ obs_duration_mean2 != obs_duration_mean3 ]
chck_obs_duration_unit2 = dur[ obs_duration_unit2 != obs_duration_unit3 ]

if (nrow(chck_obs_duration_mean2) != 0) {
  msg = 'Concentration conversion (obs_duration_mean2) not valid.'
  warning(msg)
  log_msg(msg)
}
if (nrow(chck_obs_duration_unit2) != 0) {
  msg = 'Concentration conversion (obs_duration_unit2) not valid.'
  warning(msg)
  log_msg(msg)
}

# write -------------------------------------------------------------------
fwrite(dur, file.path(article, 'cache', 'chck-units-duration.csv'))

# log ---------------------------------------------------------------------
log_msg('Check: Concentration conversion check script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()

