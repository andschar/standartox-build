# script runs queries against 3rd party data bases

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# chemical scripts --------------------------------------------------------
scripts = c('qu_aw.R',
            'qu_chemspider_scrape.R',
            #'qu_pc.R',
            'qu_pp.R',
            'qu_epa_chem.R',
            'qu_eurostat_chem_class.R')

# slow scripts
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
scripts = c('qu_worms2.R',
            'qu_gbif.R',
            'qu_epa_habitat.R')

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

# merge script ------------------------------------------------------------
# MOVE TO MERGE SCRIPT!!
# source(file.path(src, 're_merge_chem.R'), max.deparse.length = mdl)
# source(file.path(src, 're_merge_taxa.R'), max.deparse.length = mdl)
