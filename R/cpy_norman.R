# script to copy NORMAN data

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# copy --------------------------------------------------------------------
if (nodename == 'scharmueller-t460s') {
  file.copy(from = normandir,
            to = cloud,
            recursive = TRUE,
            overwrite = TRUE)
  msg = 'Copy: NORMAN export copied to cloud.'
} else {
  # TODO install Nextcloud on server for automatic cloud update
  msg = 'Copy: NORMAN - copy by hand to cloud (TODO) !!!'
}
  
# log ---------------------------------------------------------------------
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()
