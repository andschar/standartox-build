# script to query chemical identifiers

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

todo_cir = phch$cas

# query -------------------------------------------------------------------
reps = c('stdinchikey', 'stdinchi', 'smiles')

time = Sys.time()
cir_l = mapply(
  cir_query,
  representation = reps,
  MoreArgs = list(identifier = todo_cir),
  SIMPLIFY = FALSE
)
Sys.time() - time

saveRDS(cir_l, file.path(cachedir, 'cir', 'cir_l.rds'))

# log ---------------------------------------------------------------------
log_msg('ID: CIR: download script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
