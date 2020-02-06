# script to query information from the Alan Wood compendium
# NOTE doesn't have IDs query with CAS directly

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT *
     FROM standartox.chem_id"
chem = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
# debuging
if (debug_mode) {
  chem = chem[1:10]
}
todo_aw = sort(chem$cas)
# todo_aw = c(todo_aw, '1071-83-6') # debuging (+ Glyphosate)

# query -------------------------------------------------------------------
aw_l = list()
for (i in seq_along(todo_aw)) {
  qu_cas = todo_aw[i]
  message('Alan Wood: CAS:', qu_cas, ' (', i, '/', length(todo_aw), ')')
  
  aw_res = aw_query(qu_cas, type = 'cas', verbose = FALSE)[[1]]
  
  aw_l[[i]] = aw_res
  names(aw_l)[i] = qu_cas
}

# write -------------------------------------------------------------------
saveRDS(aw_l, file.path(cachedir, 'aw', 'aw_l.rds'))

# log ---------------------------------------------------------------------
log_msg('QUERY: AlanWood: preparation script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()