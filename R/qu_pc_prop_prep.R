# script to prepare the PubChem data base

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
# Pubchem
pc_prop_l = readRDS(file.path(cachedir, 'pubchem', 'pc_prop_l.rds'))
# ID
q = "SELECT *
     FROM standartox.chem_id"
chem = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)

# preparation -------------------------------------------------------------
pc_prop_l[ is.na(pc_prop_l) ] = lapply(pc_prop_l[ is.na(pc_prop_l) ], data.table)
pc_prop = rbindlist(pc_prop_l, fill = TRUE)
pc_prop[ , V1 := NULL ]
clean_names(pc_prop)
setnames(pc_prop, 'iupacname', 'iupac_name')

# merge -------------------------------------------------------------------
# merge with CIR to get cas
pc_prop[chem, cas := i.cas, on = 'inchikey']
pc_prop = pc_prop[ !is.na(cas) & !duplicated(cas) ]
setcolorder(pc_prop, 'cas')

# check -------------------------------------------------------------------
chck_dupl(pc_prop, 'cas')

# write -------------------------------------------------------------------
write_tbl(pc_prop, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'pubchem', tbl = 'pubchem_prop',
          key = 'cas',
          comment = 'Results from the PubChem query')

# log ---------------------------------------------------------------------
log_msg('PREP: PubChem: (properties) preparation script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
