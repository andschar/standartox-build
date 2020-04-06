# script runs queries against 3rd party data bases for data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# scripts -----------------------------------------------------------------
scripts_chem = c('qu_aw_dwld.R', # NOTE doesn't have IDs query with CAS directly
                 'qu_chebi_dwld.R',
                 'qu_eurostat_dwld.R',
                 'qu_epa_chem_dwld.R',
                 'qu_pan_dwld.R',
                 'qu_pc_prop_dwld.R',
                 'qu_wiki_dwld.R')
scripts_taxa = c('qu_epa_taxa_dwld.R',
                 'qu_epa_habi_dwld.R',
                 'qu_gbif_dwld.R',
                 'qu_worms_dwld.R')
scripts = c(scripts_chem, scripts_taxa)

time = Sys.time()
n_cores = length(scripts)
cl = parallel::makeCluster(n_cores, type = 'FORK')
doParallel::registerDoParallel(cl)

foreach::foreach(
  i = scripts,
  .errorhandling = 'pass',
  .verbose = TRUE) %dopar% {
    source(file.path(src, i),
           local = TRUE,
           max.deparse.length = mdl)
    }

parallel::stopCluster(cl)
Sys.time() - time

# log ---------------------------------------------------------------------
log_msg('QUERY: download scripts run.')

# cleaning ----------------------------------------------------------------
clean_workspace()





