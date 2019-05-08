# script runs queries against 3rd party data bases

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# chemical scripts --------------------------------------------------------
scripts = c('qu_wiki_dwld.R',
            'qu_aw_dwld.R',
            'qu_cs_scrape_dwld.R',
            'qu_pc_dwld.R',
            'qu_chebi_dwld.R',
            'qu_pp_dwld.R',
            'qu_epa_chem_dwld.R',
            'qu_eurostat_dwld.R')

time = Sys.time()
n_cores = detectCores() - 1
cl = makeCluster(n_cores, type = 'FORK')
doParallel::registerDoParallel(cl)

foreach(i = scripts,
        .errorhandling = 'pass',
        .verbose = TRUE) %dopar% {
  source(file.path(src, i),
         local = TRUE,
         max.deparse.length = mdl)
}

stopCluster(cl)
Sys.time() - time

# taxa: habitat and region scripts ----------------------------------------
scripts = c('qu_worms_dwld.R',
            'qu_gbif_dwld.R',
            'qu_epa_habi_dwld.R')

time = Sys.time()
n_cores = detectCores() - 1
cl = makeCluster(n_cores, type = 'FORK')
doParallel::registerDoParallel(cl)

foreach(i = scripts,
        .errorhandling = 'pass',
        .verbose = TRUE) %dopar% {
          source(file.path(src, i),
                 local = TRUE,
                 max.deparse.length = mdl)
        }

stopCluster(cl)
Sys.time() - time

# log ---------------------------------------------------------------------
log_msg('Download scripts run')

# cleaning ----------------------------------------------------------------
clean_workspace()





