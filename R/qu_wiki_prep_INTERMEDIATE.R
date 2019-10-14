# script to prepare WIKIMEDIA download
# TODO fix this together with R/qu_wiki_dwld_INTERMEDIATE.R

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
l = readRDS(file.path(cachedir, 'wikidata2.rds'))

# prepare -----------------------------------------------------------------
wd = rbindlist(l, fill = TRUE, idcol = 'id')
cols = c("id", "chembl", "chemical_formula", "cid", "csid", "echa_infocard_id", 
         "einecs", "inchi", "inchikey", "label", "smiles", "unii", "zvg", 
         "drugbank", "name_who")
wd2 = wd[ , .SD, .SDcols = cols ]
wd2[ , chemical_formula := chartr("₀₁₂₃₄₅₆₇₈₉", "0123456789", chemical_formula) ]

setnames(wd2, c('id', 'label'), c('cas', 'cname'))

# check -------------------------------------------------------------------
chck_dupl(wd2, 'cas')

# write -------------------------------------------------------------------
write_tbl(wd2, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'wiki2',
          key = 'cas',
          comment = 'Results from Wikidata INTERMEDIATE')

# log ---------------------------------------------------------------------
log_msg('WIKIDATA2 (INTERMEDIATE!): preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()
