# this is the main script that has to be sourced and timed on the platform
# time this script tp run every 2 months
# crontab:
# 00 22 * * * /home/scharmueller/Projects/run_build.sh

# projects directory -------------------------------------------------------
prj = system("find / -name etox-base 2>/dev/null", intern = TRUE)[1] # locate prj dir
prj = '/home/andreas/Documents/Projects/etox-base' # debuging
shinydir = system("find / -name etox-base-shiny 2>/dev/null", intern = TRUE)[1] # locate shiny dir

# (0) setup -------------------------------------------------------------------
source(file.path(prj, 'R/setup.R'))

# (1) build data base -----------------------------------------------------
# download
source(file.path(src, 'bd_epa_download.R'))
# build
source(file.path(src, 'bd_epa_postgres.R'))

# # (2) queries -------------------------------------------------------------
# source(file.path(src, 're_merge.R'))
# source(file.path(src, 're_filter.R'))
# # filter stats?
# 
# # (3) save to DB ----------------------------------------------------------
# # saving filter table to data base and as an .rds object
# source(file.path(src, 're_write.R'))
# 
# 








