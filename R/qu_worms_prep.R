# script to query habitat information from the WORMS marine data base

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

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
         c('taxon', 'marin', 'brack', 'fresh', 'terre', 'extinct'))
setcolorder(wo2, c('aphiaid', 'taxon', 'genus', 'family', 'order', 'class', 'phylum', 'kingdom',
                   'marin', 'brack', 'fresh', 'terre', 'extinct'))
# types
cols = c('marin', 'brack', 'fresh', 'terre', 'extinct')
wo2[ , (cols) := lapply(.SD, as.numeric), .SDcols = cols ]
wo2 = unique(wo2, by = 'aphiaid') # for safety
wo2 = wo2[ rank %in% c('Family', 'Genus', 'Species') ] # only fm, gn, sp
# 0 to NA
wo2[ marin == 0L, marin := NA_integer_ ]
wo2[ brack == 0L, brack := NA_integer_ ]
wo2[ fresh == 0L, fresh := NA_integer_ ]
wo2[ terre == 0L, terre := NA_integer_ ]
# split
wo2_l = split(wo2, wo2$rank)
names(wo2_l) = c('fm', 'gn', 'sp')

# check -------------------------------------------------------------------
chck_dupl(wo2_l$fm, 'taxon')
chck_dupl(wo2_l$gn, 'taxon')
chck_dupl(wo2_l$sp, 'taxon')

# write -------------------------------------------------------------------
for (i in seq_along(wo2_l)) {
  dat = wo2_l[[i]]
  nam = names(wo2_l)[i]
  write_tbl(dat, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
            dbname = DBetox, schema = 'taxa', tbl = paste0('worms_', nam),
            key = 'taxon',
            comment = 'Results from the WoRMS query')
}

# log ---------------------------------------------------------------------
log_msg('WoRMS preparation query run')

# cleaning ----------------------------------------------------------------
clean_workspace()
