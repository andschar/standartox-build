# script to check concentration and duraiton unit converisons
# NOTE use package testthat in the future

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

## CONTINUE HERE!!!!!!!!!!!!!!!!!!!!!!!!!

# data --------------------------------------------------------------------
# units_chck = fread(file.path(lookupdir, 'concentration_unit_lookup_chck.csv'),
#                    na.strings = '')
# cols = c('result_id', 'conc1_mean', 'conc1_unit', 'conc1_mean_manual', 'conc1_unit_manual')
# units_chck = units_chck[ , .SD, .SDcols = cols ]
# units_chck2 = copy(units_chck)
# todo = c('ug/l' = 'g/l',
#          'mg/kg' = 'g/g',
#          'g/m2' = 'g/m2',
#          'ul/l' = 'l/l',
#          'ml/g' = 'l/g',
#          'g/cm' = 'g/m',
#          'Bq/ml' = 'Bq/l',
#          'Bq/mg' = 'Bq/g',
#          'ml/m2' = 'l/m2',
#          'g/d' = 'g/h',
#          'g/d' = 'g/h')
# for (i in seq_along(todo)) {
#   from = names(todo)[i]
#   to = todo[i]
#   units_chck2[ conc1_unit_manual == from, `:=`
#                (conc1_mean_manual = ud.convert(conc1_mean_manual, from, to),
#                  conc1_unit_manual = to) ]
# }
# units_chck2[ , .N, conc1_unit_manual ][ order(-N) ]
# # units_chck2[ , .N, conc1_unit_manual2 ]
# 
# fwrite(units_chck2, file.path(lookupdir, 'concentration_unit_lookup_chck2.csv'))
# 

units_chck = fread(file.path(lookupdir, 'concentration_unit_lookup_chck.csv'),
                   na.strings = '')
units_chck = units_chck[ , .SD,
                         .SDcols = c('result_id',
                                     # 'conc1_mean', 'conc1_unit', 'conc1_mean2', 'conc1_unit2',
                                     'conc1_mean2_manual', 'conc1_unit2_manual',
                                     'conc1_mean4_manual', 'conc1_unit4_manual') ]

# units_chck[ grep('mol', conc1_unit) ][ is.na(conc1_unit2_manual) ]

# chck: all units have a manual check -------------------------------------
# TODO uncomment
# q_distinct = "SELECT DISTINCT ON (conc1_unit) conc1_unit
#               FROM ecotox.results"
# units_ditinct = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
#                            query = q_distinct)
# chck_distinct = units_ditinct[ !conc1_unit %in% units_chck$conc1_unit ]
# # chck
# if (nrow(chck_distinct) != 0) {
#   log_msg(paste0(nrow(chck_distinct), ' units have no manual check unit.'))
# }




# chck: automatic to manual conversions -----------------------------------
result_id = na.omit(unique(units_chck$result_id))

# database
q = paste0(
  "SELECT *
   FROM ecotox.results2
   WHERE result_id IN (", paste0(result_id, collapse = ', '), ")
     AND conc1_remove IS FALSE;"
)

# q = "SELECT conc1_mean, count(*) n
#      FROM ecotox.results
#      GROUP BY conc1_mean
#      ORDER BY n DESC"
# test = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
#                    query = q)

units = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                   query = q)
units[ conc1_unit4 %in% c('g/l', 'g/m2', 'ppb', 'g/g', 'l/l', 'l/m2') ]



units2 = merge(units, units_chck, by = c('result_id'), all.y = TRUE)
units2[ , chck_mean := fifelse(conc1_mean2 == conc1_mean2_manual, TRUE, FALSE) ]
units2[ , chck_unit := fifelse(conc1_unit2 == conc1_unit2_manual, TRUE, FALSE) ]

chck_conc_unit = units2[ is.na(chck_unit) | chck_unit == FALSE ][ conc1_remove == FALSE ]
# chck_equals(nrow(chck_conc_unit), 0,
#             msg = 'Concnetration untis don\'t match manual check units.')
chck_conc_mean = units2[ is.na(chck_mean) | chck_mean == FALSE ]
# chck_equals(nrow(chck_conc_mean), 0,
#             msg = 'Concnetration means don\'t match manual check conversions.')



ud.convert(65,	'umol/kg', 'mol/g') / 24 #2.70833333333334E-09	mol/g/h)

units2[ conc1_unit == 'umol/kg/d']

chck_conc_unit[ conc1_remove != TRUE ]
chck_con
chck_conc_unit[ , .N, conc1_unit2 ][ order(-N) ][1:20]

units2[ grep('time', conc1_unit_type)]

# fwrite(units2, file.path(lookupdir, 'concentration_unit_lookup_chck.csv'))
# fwrite(chck_conc_unit[ conc1_remove != TRUE ], file.path(lookupdir, 'chck_WRONG.csv'))
chck_conc_unit[ , .N, conc1_unit_manual ]
chck_conc_mean

# 
# units2[ chck_unit == FALSE ][
#   , .SD, .SDcols = c('conc1_mean', 'conc1_unit', 'conc1_mean2', 'conc1_unit2',
#                     'conc1_mean3', 'conc1_unit3', 'conc1_mean4', 'conc1_unit4',
#                     'conc1_mean_manual', 'conc1_unit_manual')
# ]
# 
# 









