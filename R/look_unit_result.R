# script to convert concentration units and extract additional infos

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
## all units from ECOTOX DB
q = "SELECT conc1_unit, description, count(conc1_unit) AS n
     FROM ecotox.results
     LEFT JOIN ecotox.concentration_unit_codes ON conc1_unit = code 
     WHERE conc1_unit IS NOT NULL
     GROUP BY conc1_unit, description
     ORDER BY n DESC"
unit = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
## result unit conversion table
unit_result = fread(file.path(lookupdir, 'lookup_unit_result.csv'),
                    na.strings = '')
## result unit special symbols table
unit_symbol = fread(file.path(lookupdir, 'lookup_unit_result_symbols.csv'),
                    na.strings = '')

# helper funcitons --------------------------------------------------------
## calc
calc = function(..., fun = '+', na.rm = TRUE) {
  fun = match.arg(fun, c('+', '-', '*', '/'))
  l = list(...)
  if (na.rm)
    l = l[ !is.na(l) ]
  Reduce(fun, l)
}
## function to extract all numeric strings excetp for m2, m3 etc.
extr_numeric = function(x) {
  x = gsub('([A-z]+)([2]{1})', '\\1-square', x) # convert m2, ft2, etc to square
  x = gsub('([A-z]+)([3]{1})', '\\1-cubic', x) # same for cubic
  as.numeric(str_extract(x, '[+-]?([0-9]*[.])?[0-9]+'))
}
## function to extract special unit additions
extr_special = function(x, pattern = NULL) {
  # TODO include optional spaces here?
  pattern = paste0('\\b', pattern, '\\b') # NOTE word boundary anchors
  str_extract(
    x, paste0('(?i)', paste0(pattern, collapse = '|'))
  )
}
## function to extract actual units
extr_unit = function(x, pattern = NULL) {
  # remove all numerics from unit extraction (except m2, m3 etc.)
  # x = c('3.6mg', '5 m2', 'm2', '88m3') # debuging
  x = gsub('([A-z]+)([2]{1})', '\\1-square', x) # convert m2, ft2, etc to square
  x = gsub('([A-z]+)([3]{1})', '\\1-cubic', x) # same for cubic
  x = trimws(gsub('[+-]?([0-9]*[.])?[0-9]+', '', x)) # remove all numeric values
  x = gsub('-square', '2', x) # convert back to m2 notation
  x = gsub('-cubic', '3', x)
  # word boundary anchors (except for some characters)
  pattern[ !pattern %in% c('%', '‰') ] <- paste0('\\b', pattern[ !pattern %in% c('%', '‰') ], '\\b')
  str_extract(x, paste0(pattern, collapse = '|'))
}

# dt = copy(unit) # NOTE debug

## function to convert units
unit_converter = function(dt,
                          dt_lookup,
                          col_unit,
                          col_multiplier,
                          pattern_special = NULL,
                          pattern_unit = NULL) {
  # key
  setkey(dt_lookup, unit)
  # copy
  dt = copy(dt)
  # max cols
  u_max = max(lengths(strsplit(dt[ , get(col_unit)], '/')))
  # split units by /
  cols_all = paste0('all', 1:u_max)
  dt[ , (cols_all) := tstrsplit(get(col_unit), '/') ]  
  # extract numeric constants
  cols_num = paste0('num', 1:u_max)
  dt[ , (cols_num) := lapply(.SD, extr_numeric), .SDcols = cols_all ]
  # fix very special cases
  dt[ grep('0/00', conc1_unit), (4:ncol(dt)) := NA ][ # NOTE error prone: 4:
    grep('0/00', conc1_unit), all1 := '0/00'
    ]
  dt[ grep('mgdryfd/gwetbdwt/d', conc1_unit), (4:ncol(dt)) := NA ][
    grep('mgdryfd/gwetbdwt/d', conc1_unit), `:=`
    (all1 = 'mg dry fd', all2 = 'g wet bdwt', all3 = 'd')
    ]
  dt[ grep('% w/w', conc1_unit),  (4:ncol(dt)) := NA ][
    grep('% w/w', conc1_unit), all1 := '% w/w'
  ]
  dt[ grep('% v/v', conc1_unit),  (4:ncol(dt)) := NA ][
    grep('% v/v', conc1_unit), all1 := '% v/v'
    ]
  dt[ grep('% v/w', conc1_unit),  (4:ncol(dt)) := NA ][
    grep('% v/w', conc1_unit), all1 := '% v/w'
    ]
  # extract special additions
  cols_spe = paste0('spe', 1:u_max)
  dt[ , (cols_spe) := lapply(.SD, extr_special, pattern = pattern_special), .SDcols = cols_all ]
  # actual units
  cols_uni = paste0('uni', 1:u_max)
  dt[ , (cols_uni) := lapply(.SD, extr_unit, pattern = pattern_unit), .SDcols = cols_all ]
  # assign multiplier
  for (j in seq_along(cols_uni)) {
    col = cols_uni[j]
    setkeyv(dt, col)
    dt[dt_lookup, paste0('mul', j) := i.multiplier ]
  }
  # convert units?
  for (j in seq_along(cols_uni)) {
    col = cols_uni[j]
    setkeyv(dt, col)
    dt[dt_lookup, paste0('convl', j) := i.conv ]
  }
  # converted units
  for (j in seq_along(cols_uni)) {
    col = cols_uni[j]
    setkeyv(dt, col)
    dt[dt_lookup, paste0('conv', j) := i.unit_conv ]
  }
  # SI-units
  for (j in seq_along(cols_uni)) {
    col = cols_uni[j]
    setkeyv(dt, col)
    dt[dt_lookup, paste0('si', j) := i.unit_conv_si ]
  }
  # unit type
  for (j in seq_along(cols_uni)) {
    col = cols_uni[j]
    setkeyv(dt, col)
    dt[dt_lookup, paste0('type', j) := i.type ]
  }
  ## combine values
  # TODO make this work to allow a random number of columns to be evaluated
  # dt[ ,
  #     # paste_missing(.SD, collapse = '/'),
  #     paste0(lapply(.SD, function(x) na.omit(c(x))), collapse = '/'),
  #     by = 1:nrow(dt),
  #     .SDcols = grep('conv[0-9]+', names(dt)) ]
  # dt[ ,
  #     paste0(na.omit(c(conv1, conv2, conv3, conv4)), collapse = '/'),
  #     by = 1:nrow(dt) ]
  # dt[ ,
  #     paste0(.)
  #     paste0(na.omit(c(conv1, conv2, conv3, conv4)), collapse = '/'),
  #     by = 1:nrow(dt) ]
  ## END
  dt[ ,
      unit_conv := paste0(na.omit(c(conv1, conv2, conv3, conv4)), collapse = '/'),
      by = 1:nrow(dt) ]
  dt[ ,
      conv := all(na.omit(c(convl1, convl2, convl3, convl4))),
      by = 1:nrow(dt) ]
  # TODO make this dynamic
  dt[ , mulnum1 := apply(.SD, 1, prod, na.rm = TRUE), .SDcols = c('mul1', 'num1') ]
  dt[ , mulnum2 := apply(.SD, 1, prod, na.rm = TRUE), .SDcols = c('mul2', 'num2') ]
  dt[ , mulnum3 := apply(.SD, 1, prod, na.rm = TRUE), .SDcols = c('mul3', 'num3') ]
  dt[ , mulnum4 := apply(.SD, 1, prod, na.rm = TRUE), .SDcols = c('mul4', 'num4') ]
  dt[ , mulnum12 := calc(mulnum1, mulnum2, fun = '/') ]
  dt[ , mulnum34 := calc(mulnum3, mulnum4, fun = '/') ]
  dt[ , multiplier := calc(mulnum12, mulnum34, fun = '/') ]
  dt[ , multiplier_old := calc(mulnum1, mulnum2, mulnum3, mulnum4, fun = '/', na.rm = TRUE) ]
  dt[ ,
      si := all(na.omit(c(si1, si2, si3, si4))),
      by = 1:nrow(dt) ]
  dt[ ,
      type := paste0(na.omit(c(type1, type2, type3, type4)), collapse = '/'),
      by = 1:nrow(dt) ]
  # remove
  dt[ , remove := fifelse(grepl('noscience', type), TRUE, FALSE) ]
  # return
  setorder(dt, -n) # TODO remove once it's finished
  dt
}

unit2 = unit_converter(dt = unit,
                       dt_lookup = unit_result,
                       col_unit = 'conc1_unit',
                       col_multiplier = 'multiplier',
                       pattern_special = unit_symbol$symbol,
                       pattern_unit = unit_result$unit)

unit2[ conc1_unit == 'AI cm3/eu' ]

# exposure ----------------------------------------------------------------
# TODO put in function?
# TODOprobably not needed since this is coded in exposure EPA data
unit2[ grep('food|fd', conc1_unit, ignore.case = TRUE), conc1_exposure := 'food' ]
unit2[ grep('seed|sd', conc1_unit, ignore.case = TRUE), conc1_exposure := 'seed' ]
unit2[ grep('bdwt', conc1_unit, ignore.case = TRUE), conc1_exposure := 'bdwt' ]
unit2[ grep('humus', conc1_unit, ignore.case = TRUE), conc1_exposure := 'humus' ]

# CONTINUE HERE 31.3.2020 - 18:39

# 100 mg/kg/d = 100 mg/kg/24h

# very special cases ------------------------------------------------------
# units that are too weird for a computer
# dt2[ conc1_unit == '0/00', (4:ncol(dt2)) := NA ] %>% 
#   .[ , c('all1', 'uni1') := '0/00' ]
# dt2[ conc1_unit == '0/00' ] 
# dt2[ conc1_unit == '0/00', (4:ncol(dt2)) := NA ] %>% 
#   .[ , c('all1', 'uni1') := '0/00' ]
# 
# 'mgdryfd/gwetbdwt/d'
# '% v/v'
# '% v/w'
# 'g/kg*e0.75 bdwt'
# 'ppm for 36hr'
# dt2[545]

# conversion --------------------------------------------------------------
# dt2[unit_result, mul1 := i.multiplier, on = c(conc1_unit = 'unit') ]
# dt2[]
# 
# iris_dt = copy(iris)
# iris_dt = data.table(iris_dt)
# iris_dt[ , test := paste0(c(Sepal.Length, Sepal.Width), collapse = '+'), by = 1:nrow(iris_dt)]
# 
# unit_result$multiplier
# dt2
# grep('L', dt2$conc1_unit, value = TRUE)
# 
# dt2[ conc1_unit == '0/00' ]

# debug -------------------------------------------------------------------
# fwrite(unit2, file.path(lookupdir, 'units_NEW_APPROACH.csv')) # TODO remove

# check -------------------------------------------------------------------
chck_dupl(unit2, 'conc1_unit')

# write -------------------------------------------------------------------
## csv
fwrite(unit2, file.path(summdir, 'lookup_result_summary.csv'))

## postgres
write_tbl(unit2, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'lookup', tbl = 'lookup_unit_result',
          key = 'conc1_unit',
          comment = 'Lookup table for concentration units')

# log ---------------------------------------------------------------------
log_msg('LOOK: Result lookup tables script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()







