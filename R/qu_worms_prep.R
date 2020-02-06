# script to query habitat information from the WORMS marine data base

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
worms_l = readRDS(file.path(cachedir, 'worms', 'worms_l.rds'))

# preparation -------------------------------------------------------------
worms_l = worms_l[ !is.na(worms_l) ]
wo = rbindlist(worms_l, idcol = 'taxon')
wo2 = dcast(wo, taxon ~ ind, value.var = 'values',
            fun.aggregate = function(x) paste0(unique(x), collapse = '; ')) # some are duplicated
# names
setnames(wo2, tolower(names(wo2)))
setnames(wo2,
         c('ismarine', 'isbrackish', 'isfreshwater', 'isterrestrial', 'isextinct'),
         c('marin', 'brack', 'fresh', 'terre', 'extinct'))
setcolorder(wo2, c('taxon', 'aphiaid', 'genus', 'family', 'order', 'class', 'phylum', 'kingdom',
                   'marin', 'brack', 'fresh', 'terre', 'extinct'))
# types
cols = c('marin', 'brack', 'fresh', 'terre', 'extinct')
wo2[ , (cols) := lapply(.SD, as_true), .SDcols = cols ]
wo2 = unique(wo2, by = 'aphiaid') # for safety
wo2 = wo2[ rank %in% c('Family', 'Genus', 'Species') ] # only fm, gn, sp

# check -------------------------------------------------------------------
chck_dupl(wo2, 'aphiaid')

# write -------------------------------------------------------------------
write_tbl(wo2, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'worms', tbl = 'worms_data',
          key = 'taxon',
          comment = 'Results from the WoRMS query')

# log ---------------------------------------------------------------------
log_msg('QUERY: WoRMS: preparation query run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
