# script to download wikidata

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
wd = readRDS(file.path(cachedir, 'wd.rds'))
wd = data.frame(wd)

# write -------------------------------------------------------------------
write_tbl(wd, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'chem', tbl = 'wiki',
          comment = 'Results from Wikidata')

# log ---------------------------------------------------------------------
log_msg('WIKIDATA preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()