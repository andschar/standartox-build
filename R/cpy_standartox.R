# script to copy files to shiny directory

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# copy --------------------------------------------------------------------
files = list.files(file.path(exportdir, vers),
                   full.names = TRUE)
to = file.path(appdata, dir)

file_cpy(files, to)

# log ---------------------------------------------------------------------
log_msg(paste0('Export: application data copied to: ', to))

# cleaning ----------------------------------------------------------------
clean_workspace()