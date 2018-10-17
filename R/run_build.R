# this is the main script that has to be sourced and timed on the platform
# time this script tp run every 2 months
# crontab:
# 00 22 * * * /home/scharmueller/Projects/run_build.sh

# projects directory -------------------------------------------------------
## find folder name on system - slow, but generic!
# prj = system("find / -name etox-base 2>/dev/null", intern = TRUE)[1] # locate prj dir
# shinydir = system("find / -name etox-base-shiny 2>/dev/null", intern = TRUE)[1] # locate shiny dir

## pre-defined
nodename = Sys.info()[4]
if (nodename == 'scharmueller') {
  prj = '/home/andreas/Documents/Projects/etox-base'
  shinydir = '/home/andreas/Documents/Projects/etox-base-shiny'
} else if (nodename == 'uwigis') {
  prj = '/home/scharmueller/Projects/etox-base'
  shinydir = '/home/scharmueller/Projects/etox-base-shiny'
} else {
  stop('New system. Define prj and shinydir variables.')
}


# (0) setup ---------------------------------------------------------------
source(file.path(prj, 'R/setup.R'))

# (1) build data base -----------------------------------------------------
# download
source(file.path(src, 'bd_epa_download.R'))


# setup ECOTOX variables --------------------------------------------------
etoxdir = grep('ecotox', list.dirs(datadir, recursive = FALSE), value = TRUE)
release = regmatches(etoxdir, regexpr('[0-9]{2}_[0-9]{2}_[0-9]{4}', etoxdir))
release = max(as.Date(release, format = '%m_%d_%Y'))
DBetox = paste0('etox', gsub('-', '', release))

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








