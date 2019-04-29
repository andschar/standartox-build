# script to resolve CAS numbers

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
chem = readRDS(file.path(cachedir, 'epa_chem.rds'))

drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

chem = dbGetQuery(con, "SELECT *
                        FROM ecotox.chemicals")
setDT(chem)
chem[ , cas := casconv(cas_number) ]
setnames(chem, 'cas_number', 'casnr')
setorder(chem, casnr)
setcolorder(chem, c('casnr', 'cas'))

dbDisconnect(con)
dbUnloadDriver(drv)

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
  
  # extract chebi identifier of names
  l$chebiid = lapply(l$names, function(x) grep('chebi', x, ignore.case = TRUE, value = TRUE))
  # clean common names
  l$names_clean = lapply(l$names, function(x) grep('^[A-z]{1}[a-z]+$', x, value = TRUE))
  
  saveRDS(l, file.path(cachedir, 'cir_l.rds'))
  
} else {
  l = readRDS(file.path(cachedir, 'cir_l.rds'))
}

# list results
l2 = l[!names(l) %in% c('names', 'names_clean', 'chebiid', 'pubchem_sid') ]
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

# merge with initial table
cir[chem, `:=`
    (chemical_name = i.chemical_name,
     ecotox_group = i.ecotox_group),
    on = 'cas' ]

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













