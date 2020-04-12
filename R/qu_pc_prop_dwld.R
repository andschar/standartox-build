# script to query the PubChem data base: properties

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT *
     FROM phch.phch_id"
phch = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
# debuging
if (debug_mode) {
  phch = phch[1:10]
}

todo = na.omit(phch$cid)

# query -------------------------------------------------------------------
time = Sys.time()
pc_prop_l = list()
for (i in seq_along(todo)) {
  
  cid = todo[i]
  message('Pubchem (pc_rop): CID: ', cid, ' (', i, '/', length(todo), ')')
  res = pc_prop(cid, verbose = FALSE)
  pc_prop_l[[i]] = res
  names(pc_prop_l)[i] = names(cid)
}
Sys.time() - time

# write -------------------------------------------------------------------
saveRDS(pc_prop_l, file.path(cachedir, 'pubchem', 'pc_prop_l.rds'))

# log ---------------------------------------------------------------------
log_msg('QUERY: PubChem: download (properties) script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()