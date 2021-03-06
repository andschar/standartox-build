# script prepares data downloaded from 3rd party data bases

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# chemical scripts --------------------------------------------------------
scripts_chem = c('qu_aw_prep.R',
                 'qu_chebi_prep.R',
                 'qu_eurostat_prep.R',
                 'qu_epa_chem_prep.R',
                 'qu_pan_prep.R',
                 'qu_pc_prop_prep.R',
                 'qu_wiki_prep.R')

mapply(source,
       file = file.path(src, scripts_chem),
       MoreArgs = list(max.deparse.length = mdl),
       SIMPLIFY = FALSE)

# taxa: habitat and region scripts ----------------------------------------
scripts_taxa = c('qu_epa_taxa_prep.R',
                 'qu_epa_habi_prep.R',
                 'qu_gbif_prep.R',
                 'qu_worms_prep.R')

mapply(source,
       file = file.path(src, scripts_taxa),
       MoreArgs = list(max.deparse.length = mdl),
       SIMPLIFY = FALSE)

# log ---------------------------------------------------------------------
log_msg('QUERY: Preparation scripts run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
