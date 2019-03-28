# script to convert concentration units and extract additional infos

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
## postgres
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(
    drv,
    user = DBuser,
    dbname = DBetox,
    host = DBhost,
    port = DBport,
    password = DBpassword
  )
  
  unit = dbGetQuery(
    con,
    "SELECT conc1_unit, count(conc1_unit) AS n
    FROM ecotox.results
    GROUP BY conc1_unit
    ORDER BY n DESC"
  )
  setDT(unit)
  unit[conc1_unit == '', conc1_unit := NA]
  unit = unit[!is.na(conc1_unit)]
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(unit, file.path(cachedir, 'epa_units_concentration.rds'))
  
} else {
  unit = readRDS(file.path(cachedir, 'epa_units_concentration.rds'))
}
## lookup
look_unit = fread(file.path(lookupdir, 'lookup_result_unit.csv'), na.strings = '')
look_str = paste0(look_unit$unit, collapse = '|')

# checks ------------------------------------------------------------------
if (!nrow(look_unit) == nrow(unique(look_unit))) {
  stop('Duplicates!')
}

# preparation -------------------------------------------------------------
# info (p.48 code appendix)
info = c(
  'diet',
  'fd',
  'feed',
  'food',
  'dryfd',
  height = 'ht',
  'wet',
  'dry',
  weight = '\\swt',
  'bdwt',
  'wetbdwt',
  'soil',
  'ai\\s',
  acid_equivalent = 'ae',
  water_soluble_fraction = 'wsf',
  'media',
  bait = 'bt',
  pellet = 'plt',
  'caliper',
  'canopy',
  '\\segg'
)

## vector
un2 = unit$conc1_unit
# info variables
un2_cl = trimws(gsub(paste0('(?i)', info, collapse = '|'), '', un2))
## errata
# ac to acres
un2_cl = gsub('ac$', 'acre', un2_cl)
# males ML
un2_cl = gsub('ML', 'males', un2_cl)
# to not confuse mol with meter: uM, nM, etc. are transfered to umol, nmol
un2_cl = gsub('moles', 'mol', un2_cl)
mol = '(M)($|/)'
un2_cl = gsub(paste0(mol, collapse = '|'), 'mol/l\\2', un2_cl)
# unbelievably stupid units
un2_cl = gsub('ppm for 36hr', 'ppm/36h', un2_cl)
# cc to cm2
un2_cl = gsub('cc', 'cm2', un2_cl)
# eu to enzymeunit (to not confuse it with g/eu i.e. experimental unit)
un2_cl = gsub('^eu$', 'enzymeunit', un2_cl)
# 0/00 to ‰
un2_cl = gsub('0/00', '‰', un2_cl)
# tolower
un2_cl = tolower(un2_cl)

## split
unit_l2 = strsplit(un2_cl, '/')
unit_l2[lengths(unit_l2) == 0] = NA_character_ # otherwise character(0) entries are droped
units = rbindlist(lapply(unit_l2, function(x)
  as.data.table(t(x))), fill = TRUE)
setnames(units, paste0('u', 1:4))
units[, conc1_unit := un2]
setcolorder(units, 'conc1_unit')

## count
units[unit, n := i.n, on = 'conc1_unit']

## clean units
units[,
      (paste0('u', 1:4, 'cl')) :=
        lapply(.SD, extr_vec, ig.case = TRUE,
               pattern = look_str),
      .SDcols = paste0('u', 1:4)]
## retrieve numerical values
units[,
      (paste0('u', 1:4, 'num')) :=
        lapply(.SD, extr_vec, ig.case = TRUE,
               pattern = '[[:digit:]]+\\.*[[:digit:]]+|^[[:digit:]]+(\\.+)*'),
      .SDcols = paste0('u', 1:4)]
# type conversion
units[, paste0('u', 1:4, 'num')] = lapply(units[, paste0('u', 1:4, 'num')],
                                          as.numeric)

## add NA count column
units[,
      nas := length(which(is.na(.SD))),
      by = 1:nrow(units),
      .SDcols = paste0('u', 1:4)]
## additional information
units[, conc1_info := str_extract(conc1_unit, paste0(info, collapse = '|'))]

# lookup ------------------------------------------------------------------
# unit types
units[look_unit, u1type := i.type, on = c(u1cl = 'unit')]
units[look_unit, u2type := i.type, on = c(u2cl = 'unit')]
units[look_unit, u3type := i.type, on = c(u3cl = 'unit')]
units[look_unit, u4type := i.type, on = c(u4cl = 'unit')]

units[nas == 3, conc1_unit_clean := u1cl]
units[nas == 3, type := u1type]
units[nas == 2, conc1_unit_clean := paste0(u1cl, '/', u2cl)]
units[nas == 2, type := paste0(u1type, '/', u2type)]
units[nas == 1, conc1_unit_clean := paste0(u1cl, '/', u2cl, '/', u3cl)]
units[nas == 1, type := paste0(u1type, '/', u2type, '/', u3type)]
units[nas == 0, conc1_unit_clean := paste0(u1cl, '/', u2cl, '/', u3cl, '/', u4cl)]
units[nas == 0, type := paste0(u1type, '/', u2type, '/', u3type, '/', u4type)]

## upper case for Curie and Becquerel
units[, conc1_unit_clean := gsub('ci', 'Ci', conc1_unit_clean)]
units[, conc1_unit_clean := gsub('bq', 'Bq', conc1_unit_clean)]

# classification ----------------------------------------------------------
u1 = c(
  fraction = 'ppm',
  mass = 'g',
  percent = '%',
  volume = 'ml',
  length = 'cm'
)
u2 = c(
  `mass/mass` = 'g/g',
  `mass/volume` = 'ug/l',
  `mass/area` = 'g/m2',
  `volume/volume` = 'ml/l',
  `volume/area` = 'ml/m2',
  `volume/mass` = 'ml/g',
  `mass/length` = 'g/cm',
  `mass/time` = 'g/d',
  `volume/time` = 'ml/d',
  `volume/length` = 'ml/cm',
  `radioactivity/volume` = 'Bq/l',
  `radioactivity/mass` = 'Bq/g',
  `fraction/time` = 'ppm/d',
  `mol/volume` = 'mol/l',
  `mol/mass` = 'mol/g'
)
# u3 = c(`mass/mass/time` = 'mg/kg/d', `volume/mass/time` = 'ml/kg/d', `mass/volume/time` = 'ug/l/d', `mass/volume/area` = 'g/l/m2', `mass/mass/mass` = 'ug/g/kg', `mass/area/time` = 'g/m2/d', `mass/volume/area` = 'g/l/m2', `mass/mass/time` = 'g/g/d') # OUT-COMMENTED because it's hard to convert

# conversion --------------------------------------------------------------
# conversion multiplier
u = c(u1, u2)

for (i in seq_along(u)) {
  unit_type = names(u)[i]
  unit_conv_to = u[i]
  # conversion
  units[type == unit_type, conv := ud.are.convertible.vector(conc1_unit_clean, unit_conv_to)]
  units[type == unit_type & conv == TRUE,
        `:=`
        (multiplier = ud.convert.vector(1, conc1_unit_clean, unit_conv_to),
          unit_conv = unit_conv_to)]
}
# multiply with constant
units[nas == 2 & !is.na(u2num), multiplier := multiplier / u2num]

# unconvertable units -----------------------------------------------------
units[conv == FALSE, .N, .(conc1_unit, conc1_unit_clean)]

# final table -------------------------------------------------------------
units[is.na(conv),
      `:=`
      (conv = FALSE,
        unit_conv = NA) ]

# character class for convert column
units[ , conv := as.character(conv) ]
units[ conv == 'TRUE', conv := 'yes' ]
units[ conv == 'FALSE', conv := 'no' ]

# writing -----------------------------------------------------------------
## postgres
write_tbl(units, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'lookup', tbl = 'concentration_unit_lookup',
          comment = 'Lookup table for concentration units')
# to .csv
fwrite(units, file.path(normandir, 'lookup_concentration_all.csv'))

# log ---------------------------------------------------------------------
msg = 'LOOK: Concentration lookup tables script run.'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()







