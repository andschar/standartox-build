# script to download wikidata

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
source(file.path(src, 'wikidata2.R')) # TODO intermediate

# data --------------------------------------------------------------------
q = "SELECT *
     FROM phch.phch_id"
phch = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
# debuging
if (debug_mode) {
  phch = phch[1:10]
}
todo = phch$wdid
names(todo) = phch$cas
todo = na.omit(todo)

# query -------------------------------------------------------------------
wd_l = list()
for (i in seq_along(todo)) {
  id = todo[i]
  nam = names(todo)[i]
  wd_l[[i]] = try(wd_data(id, type = c('identifier', 'property')))
  names(wd_l)[i] = nam
}

# write -------------------------------------------------------------------
saveRDS(wd_l, file.path(cachedir, 'wikidata', 'wd_l.rds'))

# log ---------------------------------------------------------------------
log_msg('QUERY: WIKIDATA: download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
