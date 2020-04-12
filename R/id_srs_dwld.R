# script to query SRS (US EPA Substance Registry Service) identifiers
# TODO cahnge in webchem

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# query -------------------------------------------------------------------
q = "SELECT *
     FROM phch.phch_data"
phch = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
# debuging
if (debug_mode) {
  phch = phch[1:10]
}

todo_srs = phch$cas

# query -------------------------------------------------------------------
time = Sys.time()
srs_l = list()
for (i in seq_along(todo_srs)) {
  cas = todo_srs[i]
  message('Querying: ', cas)
  srs_l[[i]] = try(srs_query(query = cas, from = 'cas'))
  names(srs_l)[i] = cas
}
Sys.time() - time

# write --------------------------------------------------------------------
saveRDS(srs_l, file.path(cachedir, 'srs', 'srs_l.rds'))

# log ---------------------------------------------------------------------
log_msg('ID: Substance Registry Service (SRS): download script run')

# cleaning ----------------------------------------------------------------
clean_workspace()
