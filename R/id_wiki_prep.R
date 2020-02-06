# script to prepare wikidata identifiers

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
wdid_l = readRDS(file.path(cachedir, 'wikidata', 'wdid_l.rds'))

# prepare -----------------------------------------------------------------
wdid = rbindlist(wdid_l, idcol = 'cas')
wdid = wdid[ !duplicated(cas) ] # NOTE deletes 116 entries
wdid[ , query := NULL ]

# chck --------------------------------------------------------------------
chck_dupl(wdid, 'cas')

# write -------------------------------------------------------------------
write_tbl(wdid, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'wiki', tbl = 'wiki_wdid',
          key = 'cas',
          comment = 'Results from the wikidata query')

# log ---------------------------------------------------------------------
log_msg('ID: WIKIDATA: preparation script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()


