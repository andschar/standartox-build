# script to prepare the PubChem data base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------


# preparation -------------------------------------------------------------
# convert all entries to data.tables
# 1 col, 1 row DTs are NAs
# 1 col, >1 row DT are multiple results
pro = rbindlist(pc_pro_l, fill = TRUE, idcol = 'cas')
setnames(pro, names(pro), tolower(names(pro)))

# Synonyms
syn = sapply(pc_syn_l, `[`, 2)
syn = rbindlist(lapply(syn, as.data.frame.list),
                idcol = 'cas')
setnames(syn, 2, 'cname')
syn[ , cname := tolower(cname) ]

# merge synonyms
pc = merge(pro, syn, by = 'cas')
setcolorder(pc, c('cas', 'cid', 'cname', 'iupacname', 'inchi', 'inchikey', 'canonicalsmiles', 'isomericsmiles'))

# writing -----------------------------------------------------------------
write_tbl(pc, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'pubchem',
          comment = 'Results from the PubChem query')

# log ---------------------------------------------------------------------
log_msg('PubChem preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()
