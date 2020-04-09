# script to check concentration and duration unit conversions
# NOTE check the following unit conversions: ('g/l', 'g/m2', 'ppb', 'g/g', 'l/l', 'l/m2')
# NOTE use package testthat in the future

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
# check table
cols = c('result_id',
         'conc1_mean2_manual', 'conc1_unit2_manual',
         'conc1_mean4_manual', 'conc1_unit4_manual')
units_chck = fread(file.path(lookupdir, 'chck_unit_result_conversion.csv'),
                   select = cols,
                   na.strings = '')
result_id = na.omit(unique(units_chck$result_id))
# database
q = paste0(
  "SELECT *
   FROM ecotox.results2
   WHERE result_id IN (", paste0(result_id, collapse = ', '), ")
     AND conc1_unit4 IN ('g/l', 'g/m2', 'ppb', 'g/g', 'l/l', 'l/m2')
     AND conc1_remove IS FALSE;"
)
units = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                   query = q)

# merge -------------------------------------------------------------------
units2 = merge(units, units_chck, by = c('result_id'), all.x = TRUE)
# chck columns
units2[ , chck_mean2 := fifelse(conc1_mean2 == conc1_mean2_manual, TRUE, FALSE) ]
units2[ , chck_unit2 := fifelse(conc1_unit2 == conc1_unit2_manual, TRUE, FALSE) ]
units2[ , chck_mean4 := fifelse(conc1_mean2 == conc1_mean4_manual, TRUE, FALSE) ]
units2[ , chck_unit4 := fifelse(conc1_unit2 == conc1_unit4_manual, TRUE, FALSE) ]
# manual checking
units2[ , .N, chck_mean2 ] # NA 85; FALSE 367
units2[ , .N, chck_unit2 ] # NA 85; FALSE 27
units2[ , .N, chck_mean4 ] # NA 687; FALSE 9
units2[ , .N, chck_unit4 ] # NA 687; FALSE 9

# chck --------------------------------------------------------------------
chck_equals(nrow(units2[ is.na(chck_mean2) | chck_mean2 == FALSE ]), 0)
chck_equals(nrow(units2[ is.na(chck_unit2) | chck_unit2 == FALSE ]), 0)
chck_equals(nrow(units2[ is.na(chck_mean4) | chck_mean4 == FALSE ]), 0)
chck_equals(nrow(units2[ is.na(chck_unit4) | chck_unit4 == FALSE ]), 0)

# log ---------------------------------------------------------------------
log_msg('CHCK: Concentration units conversions check script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()

