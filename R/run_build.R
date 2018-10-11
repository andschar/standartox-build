# this is the main script that has to be sourced and timed on the platform
# time this script tp run every 2 months
# crontab:
# 00 22 * * * /home/scharmueller/Projects/run_build.sh

# projects directory -------------------------------------------------------
prj = system("locate -b '\\etox-base'", intern = TRUE) # locate prj dir
shinydir = system("locate -b '\\etox-base-shiny'", intern = TRUE) # locate shiny dir

# (0) setup -------------------------------------------------------------------
source(file.path(prj, 'R/setup.R'))

# (1) build data base -----------------------------------------------------
# TODO maybe put in other script OR rename this script coordination_script or similar?
# TODO automate this to be run every 3 months
src_ECOTOX = FALSE # debuging!
if (src_ECOTOX) {
  # TODO does not yet work seamlessly
  source(file.path(src, 'bd_software.sh')) # TODO not yet worked out
  source(file.path(src, 'bd_epa_download.R'))
  source(file.path(src, 'bd_epa_postgres.R'))
}

# (2) queries -------------------------------------------------------------
source(file.path(src, 're_merge.R'))
source(file.path(src, 're_filter.R'))
# filter stats?

# (3) save to DB ----------------------------------------------------------
# saving filter table to data base and as an .rds object
source(file.path(src, 're_write.R'))










