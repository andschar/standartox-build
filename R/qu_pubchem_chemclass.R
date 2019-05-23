# script to query taxonomic entities from the EPA data to retain meaningfull ecotoxicological groups

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# functions ---------------------------------------------------------------
source(file.path(src, 'pc_prop_class.R'))

# data --------------------------------------------------------------------
cid = unlist(readRDS(file.path(cachedir, 'cid.rds')))

# query -------------------------------------------------------------------
cid = cid[1:4]

chebi_l = pc_prop_class(cid, src = 'chebi')
cameo_l = pc_prop_class(cid, src = 'cameo')


