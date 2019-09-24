# script to copy NORMAN data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# copy --------------------------------------------------------------------
file.copy(from = normandir,
          to = cloud,
          recursive = TRUE,
          overwrite = TRUE)

# log ---------------------------------------------------------------------
log_msg('Copy: NORMAN export copied to cloud.')

# cleaning ----------------------------------------------------------------
clean_workspace()
