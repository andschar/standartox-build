# script to query chemical identifiers

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
l = readRDS(file.path(cachedir, 'cir_l.rds'))

# preparation -------------------------------------------------------------
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
log_msg('CIR preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()