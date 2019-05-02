# script to query habitat information from the WORMS marine data base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
worms_l = readRDS(file.path(cachedir, 'worms_l.rds'))

# preparation -------------------------------------------------------------
worms_l = worms_l[ !is.na(worms_l) ]
wo = rbindlist(worms_l, idcol = 'id')
wo2 = dcast(wo, id ~ ind,
            value.var = 'values')[ , id := NULL]
# names
setnames(wo2, tolower(names(wo2)))
setnames(wo2,
         c('scientificname', 'ismarine', 'isbrackish', 'isfreshwater', 'isterrestrial', 'isextinct'),
         c('taxon', 'is_mar', 'is_bra', 'is_fre', 'is_ter', 'is_extinct'))
setcolorder(wo2, c('aphiaid', 'taxon', 'genus', 'family', 'order', 'class', 'phylum', 'kingdom',
                   'is_mar', 'is_bra', 'is_fre', 'is_ter', 'is_extinct'))
# types
cols = c('is_mar', 'is_bra', 'is_fre', 'is_ter', 'is_extinct')
wo2[ , (cols) := lapply(.SD, as.numeric), .SDcols = cols ]

# write -------------------------------------------------------------------
wo2_l = split(wo2, wo2$rank)
names(wo2_l) = c('fm', 'gn', 'sp')

for (i in seq_along(wo2_l)) {
  dat = wo2_l[[i]]
  nam = names(wo2_l)[i]
  write_tbl(dat, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
            dbname = DBetox, schema = 'taxa', tbl = paste0('worms_', nam),
            comment = 'Results from the WoRMS query')
}

# log ---------------------------------------------------------------------
log_msg('WoRMS preparation query run')

# cleaning ----------------------------------------------------------------
clean_workspace()