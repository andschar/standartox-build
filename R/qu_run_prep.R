# script prepares data downloaded from 3rd party data bases

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# chemical scripts --------------------------------------------------------
source(file.path(src, 'qu_aw_prep.R'))
source(file.path(src, 'qu_comptox_webtest_prep.R'))
source(file.path(src, 'qu_chebi_prep.R'))
source(file.path(src, 'qu_eurostat_prep.R'))
source(file.path(src, 'qu_epa_chem_prep.R'))
source(file.path(src, 'qu_pan_prep.R'))
source(file.path(src, 'qu_pc_prop_prep.R'))
source(file.path(src, 'qu_wiki_prep.R'))

# taxa: habitat and region scripts ----------------------------------------
source(file.path(src, 'qu_epa_taxa_prep.R'))
source(file.path(src, 'qu_epa_habi_prep.R'))
source(file.path(src, 'qu_gbif_prep.R'))
source(file.path(src, 'qu_worms_prep.R'))

# log ---------------------------------------------------------------------
log_msg('QUERY: Preparation scripts run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
