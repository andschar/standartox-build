# script to convert concentration units and extract additional infos

# functions ---------------------------------------------------------------
source(file.path(src, 'fun_extr_vec.R'))

# data --------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv,
                user = DBuser,
                dbname = DBetox,
                host = DBhost,
                port = DBport,
                password = DBpassword)

unit = dbGetQuery(con, 'select distinct on (conc1_unit) conc1_unit from ecotox.results')
setDT(unit)

dbDisconnect(con)
dbUnloadDriver(drv)

lookup = fread(file.path(lookupdir, 'units_lookup.csv'), na.strings = '')
look_str = paste0(lookup$unit, collapse = '|')

# preparation -------------------------------------------------------------
un2 = unit$conc1_unit
## errata:
# to not confuse mol with meter: uM, nM, etc. are transfered to umol, nmol
un2_cl = gsub('(M)($|/)', 'mol\\2', un2)
# cc to cm2
un2_cl = gsub('cc', 'cm2', un2_cl)

## split
unit_l2 = strsplit(un2_cl, '/')
unit_l2[ lengths(unit_l2) == 0 ] = NA_character_ # otherwise character(0) entries are droped
unit_dt2 = rbindlist(lapply(unit_l2, function(x) as.data.table(t(x))), fill = TRUE)
setnames(unit_dt2, paste0('u', 1:4))
unit_dt2[ , key := un2 ]

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
unit_dt2[ , paste0('u', 1:4, 'num') ] = lapply(unit_dt2[ , paste0('u', 1:4, 'num') ], as.numeric) 
# TODO how does this work with .SD?

# TODO possible job for hiwi - check 1190 entries for any mistake
fwrite(unit_dt2, file.path(tempdir(), 'unit_dt2.csv'))

## add NA count column
unit_dt2[ ,
          nas := length(which(is.na(.SD))),
          by = 1:nrow(unit_dt2),
          .SDcols = paste0('u', 1:4) ]


# conversion --------------------------------------------------------------
#unit_dt2 = unit_dt2[ nas >= 2 ] # deletes 246/1190 entries

## merge cleaned units with lookup data.table
# merge multiplier and multiply it with possible numerical unit additions
# TODO this can be done more eleganlty (in one step)
unit_dt2[lookup, conv := i.conv, on = c(u1cl = 'unit') ]

# match first unit part
# e.g. umol
unit_dt2[lookup, u1multi := i.multiplier %*na% u1num, on = c(u1cl = 'unit') ]
unit_dt2[lookup, u1conv := i.conv_to, on = c(u1cl = 'unit') ]
unit_dt2[lookup, u1type := i.type, on = c(u1cl = 'unit') ]

# match second unit part
# e.g. g/L
unit_dt2[lookup, u2multi := i.multiplier %*na% u2num, on = c(u2cl = 'unit') ]
unit_dt2[lookup, u2conv := i.conv_to, on = c(u2cl = 'unit') ]
unit_dt2[lookup, u2type := i.type, on = c(u2cl = 'unit') ]

# match thirs unit part
# e.g. ug/kg/d
unit_dt2[lookup, u3multi := i.multiplier %*na% u3num, on = c(u3cl = 'unit') ]
unit_dt2[lookup, u3conv := i.conv_to, on = c(u3cl = 'unit') ]
unit_dt2[lookup, u3type := i.type, on = c(u3cl = 'unit') ]

## retrieve final units
unit_dt2[ , multi := u1multi %*na% u2multi %*na% u3multi ]
unit_dt2[ nas == 1, conv_to := paste0(u1conv, '/', u2conv, '/', u3conv)]
unit_dt2[ nas == 1, type := paste0(u1type, '/', u2type, '/', u3type)]
unit_dt2[ nas == 2, conv_to := paste0(u1conv, '/', u2conv) ]
unit_dt2[ nas == 2, type := paste0(u1type, '/', u2type) ]
unit_dt2[ nas == 3, conv_to := u1conv ]
unit_dt2[ nas == 3, type := u1type ]

# classification ----------------------------------------------------------
# TODO is this useful?
unit_dt2[ grep('(?i)ai', key), is_ai := 1 ]
unit_dt2[ grep('bdwt', key), is_bdwt := 1 ]
unit_dt2[ grep('feed|food|fd', key), is_fd := 1 ]
unit_dt2[ grep('ae', key), is_ae := 1 ] # TODO don't know what it is

# output ------------------------------------------------------------------
fwrite(unit_dt2, '/tmp/unit_dt2.csv') # debuging

unit_fin = unit_dt2[ ,
                     .SD,
                     .SDcols = c('key', 'multi', 'conv_to', 'type', 'conv', 'u1num', 'u2num') ]
setnames(unit_fin, paste0('unit_', names(unit_fin)))

# cleaning ----------------------------------------------------------------
rm(unit_l2, unit, unit_dt2)



