# script to check concentration and duration unit conversions
# NOTE check the following unit conversions: ('g/l', 'g/m2', 'ppb', 'g/g', 'l/l', 'l/m2')
# NOTE use package testthat in the future
# CONTINUE HERE

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# chck table --------------------------------------------------------------
cols = c('result_id',
         'conc1_unit',
         'conc1_mean2_manual', 'conc1_unit2_manual',
         'conc1_mean4_manual', 'conc1_unit4_manual')
units_chck = fread(file.path(lookupdir, 'chck_unit_result_conversion.csv'),
                   select = cols,
                   na.strings = '')

# chck new units ----------------------------------------------------------
q = paste0(
   "SELECT DISTINCT ON (conc1_unit) result_id, conc1_unit
    FROM ecotox.results2
    WHERE conc1_unit NOT IN ('", paste0(units_chck$conc1_unit, collapse = "', '"), "')
      AND conc1_unit NOT IN ('', '--', 'NA', 'NC', 'NR');"
)
new = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                 query = q)
# condition
if (nrow(new) != 0) {
   log_msg('New units! Add them to chck_unit_result_conversion.csv')
}

# retrieve specific single result_id s ------------------------------------
q = paste0(
  "SELECT result_id,
          test_id,
          test_cas,
          molecularweight,
          conc1_mean,
          conc1_unit,
          conc1_remove,
          conc1_unit_type,
          conc1_mean2,
          conc1_unit2,
          conc1_mean3,
          conc1_unit3,
          conc1_mean4,
          conc1_unit4
   FROM ecotox.results2
   WHERE result_id IN (", paste0(units_chck$result_id, collapse = ', '), ")
     --AND conc1_unit4 IN ('g/l', 'g/m2', 'ppb', 'g/g', 'l/l', 'l/m2') -- NOTE for manual inspection of the most important units
     --AND conc1_remove IS FALSE;  -- NOTE for manual inspection of the most important units"
)
units = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                   query = q)

# merge -------------------------------------------------------------------
units2 = merge(units, units_chck, by = c('result_id', 'conc1_unit'), all = TRUE)
setcolorder(units2, c('result_id', 'test_id',
                      'test_cas', 'molecularweight', 
                      'conc1_mean', 'conc1_unit'))

# prepare -----------------------------------------------------------------
units2[ , chck_mean2 := fifelse(conc1_mean2 == conc1_mean2_manual, TRUE, FALSE) ]
units2[ , chck_unit2 := fifelse(conc1_unit2 == conc1_unit2_manual, TRUE, FALSE) ]
units2[ , chck_mean4 := fifelse(conc1_mean4 == conc1_mean4_manual, TRUE, FALSE) ]
units2[ , chck_unit4 := fifelse(conc1_unit4 == conc1_unit4_manual, TRUE, FALSE) ]

# manual checking ---------------------------------------------------------
# TODO out-comment this
units2[ , .N, chck_mean2 ] # NA 78; FALSE 287
# TODO units2[ chck_mean2 == FALSE ]
units2[ , .N, chck_unit2 ] # NA 78; FALSE 37
units2[ conc1_remove != TRUE & chck_unit2 == FALSE, .SD, .SDcols = c('result_id', 'conc1_unit') ] # TODO
units2[ , .N, chck_mean4 ] # NA 93; FALSE 312
units2[ , .N, chck_unit4 ] # NA 84; FALSE 136
units2[ conc1_remove != TRUE & chck_unit4 == FALSE, .SD, .SDcols = c('result_id', 'conc1_unit') ] # TODO

# write -------------------------------------------------------------------
fwrite(units2, file.path(lookupdir, 'chck_unit_result_conversion.csv'))
saveRDS(units2, file.path(cachedir, 'chck_unit_result_conversion.rds'))

# chck --------------------------------------------------------------------
chck_equals(nrow(units2[ is.na(chck_mean2) | chck_mean2 == FALSE ]), 0)
chck_equals(nrow(units2[ is.na(chck_unit2) | chck_unit2 == FALSE ]), 0)
chck_equals(nrow(units2[ is.na(chck_mean4) | chck_mean4 == FALSE ]), 0)
chck_equals(nrow(units2[ is.na(chck_unit4) | chck_unit4 == FALSE ]), 0)

# log ---------------------------------------------------------------------
log_msg('CHCK: Concentration units conversions check script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()

