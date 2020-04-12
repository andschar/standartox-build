# script runs queries against 3rd party data bases for identifiers

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# phch --------------------------------------------------------------------
source(file.path(src, 'id_cir_prep.R'), max.deparse.length = mdl)
source(file.path(src, 'id_chebi_prep.R'), max.deparse.length = mdl)
source(file.path(src, 'id_pc_prep.R'), max.deparse.length = mdl)
source(file.path(src, 'id_srs_prep.R'), max.deparse.length = mdl)
source(file.path(src, 'id_wiki_prep.R'), max.deparse.length = mdl)

# taxa --------------------------------------------------------------------
source(file.path(src, 'id_gbif_prep.R'), max.deparse.length = mdl)
source(file.path(src, 'id_worms_prep.R'), max.deparse.length = mdl)

# log ---------------------------------------------------------------------
log_msg('ID: preparation scripts run.')

# cleaning ----------------------------------------------------------------
clean_workspace()



