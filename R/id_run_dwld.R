# script runs queries against 3rd party data bases for identifiers

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# scripts -----------------------------------------------------------------
scripts_chem = c('id_cir_dwld.R',
                 'id_chebi_dwld.R',
                 'id_pc_dwld.R',
                 'id_srs_dwld.R',
                 'id_wiki_dwld.R')
scripts_taxa = c('id_gbif_dwld.R',
                 'id_worms_dwld.R')

scripts = c(scripts_chem, scripts_taxa)

time = Sys.time()
n_cores = length(scripts)
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
log_msg('ID: download scripts run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
