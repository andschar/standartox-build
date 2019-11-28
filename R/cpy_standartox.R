# script to copy files to shiny directory

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# copy --------------------------------------------------------------------
files = list.files(file.path(exportdir),
                   full.names = TRUE)
to = file.path(appdata, vers)

file_cpy(files, to)

# log ---------------------------------------------------------------------
log_msg(paste0('EXPORT: application data copied to: ', to))

# cleaning ----------------------------------------------------------------
clean_workspace()