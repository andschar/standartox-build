# script to query chemical identifiers

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(
  drv,
  user = DBuser,
  dbname = DBetox,
  host = DBhost,
  port = DBport,
  password = DBpassword
)

chem = dbGetQuery(con, "SELECT DISTINCT ON (cas_number) *
                        FROM ecotox.chemicals")
setDT(chem)
chem[, cas := casconv(cas_number) ]
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
l$chebiid = lapply(l$names, function(x)
  grep('chebi', x, ignore.case = TRUE, value = TRUE))
# clean common names
l$names_clean = lapply(l$names, function(x)
  grep('^[A-z]{1}[a-z]+$', x, value = TRUE))

saveRDS(l, file.path(cachedir, 'cir_l.rds'))

# log ---------------------------------------------------------------------
log_msg('CIR download script run')

# cleaning ----------------------------------------------------------------
clean_workspace()
