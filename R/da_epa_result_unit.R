# script to convert concentration units and extract additional infos

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
## postgres
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv,
                  user = DBuser,
                  dbname = DBetox,
                  host = DBhost,
                  port = DBport,
                  password = DBpassword)
  
  unit = dbGetQuery(con, 'SELECT distinct on (conc1_unit) conc1_unit
                          FROM ecotox.results')
  setDT(unit)
  unit[ conc1_unit == '', conc1_unit := NA ]
  unit = unit[ !is.na(conc1_unit) ]
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(unit, file.path(cachedir, 'epa_units.rds'))
  
} else {
  
  unit = readRDS(file.path(cachedir, 'epa_units.rds'))
}
## lookup
look_unit = fread(file.path(lookupdir, 'lookup_result_unit.csv'), na.strings = '')
look_str = paste0(look_unit$unit, collapse = '|')

# checks ------------------------------------------------------------------
if (!nrow(look_unit) == nrow(unique(look_unit))) {
  stop('Duplicates!')
}

# preparation -------------------------------------------------------------
# info
info = c('diet', 'fd', 'feed', 'food', seed = 'sd', height = 'ht', 'wet', 'dry',
         weight = '\\swt', 'bdwt', 'soil', 'ai\\s', acid_equivalent = 'ae',
         water_soluble_fraction = 'wsf', 'media', bait = 'bt', pellet = 'plt',
         'caliper', 'canopy')

## vector
un2 = unit$conc1_unit
# info variables
un2_cl = trimws(gsub(paste0(info, collapse = '|'), '', un2))
## errata
# to not confuse mol with meter: uM, nM, etc. are transfered to umol, nmol
un2_cl = gsub('(M)($|/)', 'mol\\2', un2_cl)
# cc to cm2
un2_cl = gsub('cc', 'cm2', un2_cl)
# 0/00 to ‰
un2_cl = gsub('0/00', '‰', un2_cl)

un2_cl = tolower(un2_cl)

## split
unit_l2 = strsplit(un2_cl, '/')
unit_l2[ lengths(unit_l2) == 0 ] = NA_character_ # otherwise character(0) entries are droped
unit_dt2 = rbindlist(lapply(unit_l2, function(x) as.data.table(t(x))), fill = TRUE)
setnames(unit_dt2, paste0('u', 1:4))
unit_dt2[ , conc1_unit := un2 ]
setcolorder(unit_dt2, 'conc1_unit')

## clean units
unit_dt2[ ,
          (paste0('u', 1:4, 'cl')) :=
            lapply(.SD, extr_vec, ig.case = TRUE,
                   pattern = look_str),
          .SDcols = paste0('u', 1:4) ]
## retrieve numerical values
unit_dt2[ ,
          (paste0('u', 1:4, 'num')) :=
            lapply(.SD, extr_vec, ig.case = TRUE,
                     pattern = '[[:digit:]]+\\.*[[:digit:]]+|^[[:digit:]]+(\\.+)*'),
          .SDcols = paste0('u', 1:4) ]
# type conversion
unit_dt2[ , paste0('u', 1:4, 'num') ] = lapply(unit_dt2[ , paste0('u', 1:4, 'num') ],
                                               as.numeric)

## add NA count column
unit_dt2[ ,
          nas := length(which(is.na(.SD))),
          by = 1:nrow(unit_dt2),
          .SDcols = paste0('u', 1:4) ]
## additional information
unit_dt2[ , conc1_info := str_extract(conc1_unit, paste0(info, collapse = '|')) ]


# TODO possible job for hiwi - check 1190 entries for any mistake
fwrite(unit_dt2, file.path(tempdir(), 'unit_dt2.csv'))

# conversion --------------------------------------------------------------
#unit_dt2 = unit_dt2[ nas >= 2 ] # deletes 246/1190 entries

## merge cleaned units with look_unit data.table
# merge multiplier and multiply it with possible numerical unit additions
# TODO this can be done more eleganlty (in one step)

## convert
unit_dt2[look_unit, u1conv := i.conv, on = c(u1cl = 'unit') ]
unit_dt2[look_unit, u2conv := i.conv, on = c(u2cl = 'unit') ]
unit_dt2[look_unit, u3conv := i.conv, on = c(u3cl = 'unit') ]
unit_dt2[look_unit, u4conv := i.conv, on = c(u4cl = 'unit') ]
# paste (conc1_unit_type)
unit_dt2[ , conc1_convert := do.call(paste2, c(.SD, sep = '/')),
          .SDcols = grep('conv', names(unit_dt2))  ]
unit_dt2[ , conc1_convert := gsub('/$', '', conc1_convert) ]
## type
unit_dt2[look_unit, u1type := i.type, on = c(u1cl = 'unit')]
unit_dt2[look_unit, u2type := i.type, on = c(u2cl = 'unit')]
unit_dt2[look_unit, u3type := i.type, on = c(u3cl = 'unit')]
unit_dt2[look_unit, u4type := i.type, on = c(u4cl = 'unit')]
# paste (conc1_unit_type)
unit_dt2[ , conc1_unit_type := do.call(paste2, c(.SD, sep = '/')),
          .SDcols = grep('type', names(unit_dt2))  ]
unit_dt2[ , conc1_unit_type := gsub('/$', '', conc1_unit_type) ]


# match first unit part
# e.g. umol
unit_dt2[look_unit, u1multi := i.multiplier %*na% u1num, on = c(u1cl = 'unit') ]
unit_dt2[look_unit, u1conv := i.conv_to, on = c(u1cl = 'unit') ]
unit_dt2[look_unit, u1type := i.type, on = c(u1cl = 'unit') ]

# match second unit part
# e.g. g/L
unit_dt2[look_unit, u2multi := i.multiplier %*na% u2num, on = c(u2cl = 'unit') ]
unit_dt2[look_unit, u2conv := i.conv_to, on = c(u2cl = 'unit') ]
unit_dt2[look_unit, u2type := i.type, on = c(u2cl = 'unit') ]

# match thirs unit part
# e.g. ug/kg/d
unit_dt2[look_unit, u3multi := i.multiplier %*na% u3num, on = c(u3cl = 'unit') ]
unit_dt2[look_unit, u3conv := i.conv_to, on = c(u3cl = 'unit') ]
unit_dt2[look_unit, u3type := i.type, on = c(u3cl = 'unit') ]

## retrieve final units
unit_dt2[ , multi := u1multi %*na% u2multi %*na% u3multi ]
unit_dt2[ nas == 1, conv_to := paste0(u1conv, '/', u2conv, '/', u3conv)]
unit_dt2[ nas == 1, type := paste0(u1type, '/', u2type, '/', u3type)]
unit_dt2[ nas == 2, conv_to := paste0(u1conv, '/', u2conv) ]
unit_dt2[ nas == 2, type := paste0(u1type, '/', u2type) ]
unit_dt2[ nas == 3, conv_to := u1conv ]
unit_dt2[ nas == 3, type := u1type ]

# noscience column --------------------------------------------------------
unit_dt2[ grepl('noscience', type), noscience := 1L ]
unit_dt2[ ! conc1_convert %like% 'no', convert := 1L ]

# output ------------------------------------------------------------------
unit_fin = unit_dt2[ ,
                     .SD,
                     .SDcols = c('conc1_unit', 'multi', 'conv_to', 'u1num', 'u2num', 
                                 'type', 'convert', 'noscience') ]
setnames(unit_fin, paste0('unit_', names(unit_fin)))
setnames(unit_fin, 'unit_conc1_unit', 'conc1_unit')
# fwrite(unit_dt2, '/tmp/unit_dt2.csv')
# cleaning ----------------------------------------------------------------
#rm(unit_l2, unit, unit_dt2)



if (! length(unique(unit_fin$conc1_unit)) == length(unit_fin$conc1_unit)) {
  stop('Units are not unique')
}








