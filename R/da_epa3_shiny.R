# script to write final data to shiny directory

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
te_fin = readRDS(file.path(cachedir, 'epa3.rds'))

# writing -----------------------------------------------------------------
## as .rds
time = Sys.time()
saveRDS(te_fin, file.path(shinydata, 'tests_fin.rds'))
Sys.time() - time
## as feather
time = Sys.time()
write_feather(te_fin, file.path(shinydata, 'tests_fin.feather'))
Sys.time() - time
## copy .feather via scp to server (github only allows 100MB)
#! takes some time
if (nodename == 'scharmueller' & scp_feather) {
  system(
    paste('scp',
          file.path(shinydata, 'tests_fin.feather'),
          shinydir_remote, 'data/tests_fin.feather',
          sep = ' ')
  )
}

# log ---------------------------------------------------------------------
msg = paste0('Final table (tests_fin) written to shiny data dir:\n', shinydata)
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()