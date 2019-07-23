# script to copy files to shiny directory

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))
dir = gsub('etox', '', DBetox)

# copy --------------------------------------------------------------------
files = list.files(file.path(export, dir),
                   full.names = TRUE)
to = file.path(shinydata, dir)

file_cpy(files, to)

# log ---------------------------------------------------------------------
log_msg(paste0('Export: application data copied to: ', to))

# cleaning ----------------------------------------------------------------
clean_workspace()