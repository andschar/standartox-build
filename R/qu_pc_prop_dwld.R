# script to query the PubChem data base: properties

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
q = "SELECT *
     FROM pubchem.prop"
cid = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                 query = q)
setDT(cid)

# debuging
if (debug_mode) {
  cid = cid[1:10]
}

todo = cid$cid

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

saveRDS(pc_prop_l, file.path(cachedir, 'pc_prop_l.rds'))

# log ---------------------------------------------------------------------
log_msg('PubChem download (properties) script run')

# cleaning ----------------------------------------------------------------
clean_workspace()