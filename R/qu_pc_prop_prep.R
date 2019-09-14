# script to prepare the PubChem data base

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
# Pubchem
pc_prop_l = readRDS(file.path(cachedir, 'pc_prop_l.rds'))
# CIR

drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

q = "SELECT inchikey, cas
     FROM phch.cir"

cir = dbGetQuery(con, q)
setDT(cir)

dbDisconnect(con)
dbUnloadDriver(drv)

# preparation -------------------------------------------------------------
pc_prop_l[ is.na(pc_prop_l) ] = lapply(pc_prop_l[ is.na(pc_prop_l) ], data.table)
pc_prop = rbindlist(pc_prop_l, fill = TRUE)
pc_prop[ , V1 := NULL ]

clean_names(pc_prop)
setnames(pc_prop, 'iupacname', 'iupac_name')
pc_prop = pc_prop[ !duplicated(inchikey) & !is.na(inchikey) ] #! maybe loss of data

# merge -------------------------------------------------------------------
# merge with CIR to get cas
pc_prop[cir, cas := i.cas, on = 'inchikey']
setcolorder(pc_prop, 'cas')

# check -------------------------------------------------------------------
chck_dupl(pc_prop, 'cas')

# write -------------------------------------------------------------------
write_tbl(pc_prop, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'pubchem',
          key = 'cas',
          comment = 'Results from the PubChem query')

# log ---------------------------------------------------------------------
log_msg('PubChem (properties) preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()
