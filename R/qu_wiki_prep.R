# script to download wikidata

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
wd_l = readRDS(file.path(cachedir, 'wikidata', 'wd_l.rds'))
wd_l = wd_l[ sapply(wd_l, function(x) !inherits(x, 'try-error')) ]
wd_l = lapply(wd_l, `[[`, 1) # TODO error in saving _dwld script
wd = rbindlist(wd_l, fill = TRUE, idcol = 'cas')
wd[ , c('wdid', 'wdid.1') := NULL ]
wd = wd[ !is.na(type) ]
wd = wd[ label != 'cas' ]
# identifiers
wd_id = dcast(wd[ type == 'identifier' ], cas ~ label, value.var = 'value')
wd_id[ , chebi := fifelse(!is.na(chebi), paste0('CHEBI:', chebi), NA_character_) ]
# label
# TODO rethink label classification
wd_label = dcast(wd[ type == 'label' & label == 'label'], cas ~ label, value.var = 'value')
wd_id[wd_label, label := i.label, on = 'cas' ]
# properties
wd_prop = dcast(wd[ type == 'property' ], cas ~ label, value.var = 'value')
wd_prop[ , chemical_formula := chartr("₀₁₂₃₄₅₆₇₈₉", "0123456789", chemical_formula) ]

# check -------------------------------------------------------------------
chck_dupl(wd_id, 'cas')
chck_dupl(wd_prop, 'cas')

# write -------------------------------------------------------------------
# identifiers
write_tbl(wd_id, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'wiki', tbl = 'wiki_id',
          key = 'cas',
          comment = 'Results from Wikidata query (identifiers)')
# properties
write_tbl(wd_prop, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'wiki', tbl = 'wiki_prop',
          key = 'cas',
          comment = 'Results from Wikidata (properties)')

# log ---------------------------------------------------------------------
log_msg('PREP: WIKIDATA: preparation script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()