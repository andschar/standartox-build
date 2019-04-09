# script to resolve CAS numbers

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
chem = readRDS(file.path(cachedir, 'epa_chem.rds'))
# debuging
if (debug_mode) {
  chem = chem[1:10]
}

todo_cir = chem$cas

# query -------------------------------------------------------------------
if (online) {
  reps = c(
    'cas',
    'names',
    'stdinchi',
    'stdinchikey',
    'smiles',
    'chemspider_id',
    'pubchem_sid'
  )
  
  time = Sys.time()
  l = mapply(
    cir_query,
    representation = reps,
    MoreArgs = list(identifier = todo_cir),
    SIMPLIFY = FALSE
  )
  Sys.time() - time
  # res_cas = cir_query(todo_cir, representation = 'cas')
  # res_names = cir_query(todo_cir, 'names')
  # res_formula = cir_query(todo_cir, 'formula')
  # res_stdinchi = cir_query(todo_cir, 'stdinchi')
  # res_stdinchikey = cir_query(todo_cir, 'stdinchikey')
  # res_smiles = cir_query(todo_cir, 'smiles')
  # res_cs = cir_query(todo_cir, 'chemspider_id')
  # res_pc = cir_query(todo_cir, 'pubchem_sid')
  
  saveRDS(l, file.path(cachedir, 'cir_l.rds'))
  
} else {
  l = readRDS(file.path(cachedir, 'cir_l.rds'))
}

# list results
l2 = l[!names(l) %in% 'names']
names(l2)[1] = 'cas_number' # for merge below
# exceptions
chem_names = rbindlist(lapply(l[['names']], data.table), idcol = 'cas')
chem_names = chem_names[, .SD[1], by = cas]
setnames(chem_names, 'V1', 'name')

# convert list to data.tables
l3 = list()
for (i in seq_along(l2)) {
  dt = rbindlist(lapply(l2[[i]], data.table), idcol = 'cas')
  nam = names(l2)[i]
  setnames(dt, 'V1', nam)
  l3[[i]] = dt
  names(l3)[i] = nam
}

# final table -------------------------------------------------------------
cir = Reduce(function(...)
  merge(
    ...,
    by = 'cas',
    all = TRUE,
    allow.cartesian = TRUE
  ),
  l3)
cir[chem_names, name := tolower(i.name), on = 'cas']

# writing -----------------------------------------------------------------
## postgres
write_tbl(cir, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'cir',
          comment = 'Results from the CIR query')

# log ---------------------------------------------------------------------
msg = 'CIR script run'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()













