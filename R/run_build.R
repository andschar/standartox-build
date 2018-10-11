# this is the main script that has to be sourced and timed on the platform

# setup -------------------------------------------------------------------
source('R/setup.R')

# (1) build data base -----------------------------------------------------
# TODO maybe put in other script OR rename this script coordination_script or similar?
# TODO automate this to be run every 3 months
src_ECOTOX = FALSE
if (src_ECOTOX) {
  # TODO does not yet work seamlessly
  source('R/bd_software.sh') # TODO not yet worked out
  source('R/bd_epa_download.R')
  source('R/bd_epa_postgres.R')
}


# (2) queries -------------------------------------------------------------
source(file.path(src, 're_merge.R'))
source(file.path(src, 're_filter.R'))
# filter stats?

# (3) save to DB ----------------------------------------------------------
# saving filter table to data base
# TODO load credentials # CONTINUE HERE!!!!

# (4) run app -------------------------------------------------------------
# TODO does not yet work!
system(
  sprintf('sudo su R -e "shiny::runApp(\'%s/.\')"', shinydir),
  intern = FALSE
)




