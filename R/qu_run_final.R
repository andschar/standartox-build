# script prepares data downloaded from 3rd party data bases

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# chemical scripts --------------------------------------------------------
scripts_chem = c('qu_phch_fin.R',
                 'qu_taxa_fin.R')

mapply(source,
       file = file.path(src, scripts_chem),
       MoreArgs = list(max.deparse.length = mdl),
       SIMPLIFY = FALSE)

# log ---------------------------------------------------------------------
log_msg('QUERY: final tables script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
