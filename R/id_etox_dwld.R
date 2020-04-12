# script to query UBA ETOX identifiers

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT *
     FROM phch.phch_data"
phch = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
# debuging
if (debug_mode) {
  phch = phch[1:10]
}

todo_etox = sort(phch$cas)

# query -------------------------------------------------------------------
time = Sys.time()
etoxid = get_etoxid(todo_etox, from = 'cas')
Sys.time() - time

# write -------------------------------------------------------------------
saveRDS(etoxid, file.path(cachedir, 'etox', 'etoxid.rds'))

# log ---------------------------------------------------------------------
log_msg('ID: ChEBI id script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
