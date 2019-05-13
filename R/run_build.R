#!/usr/bin/Rscript

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
if (nodename == 'scharmueller-t460s') {
  prj = '/home/scharmueller/Projects/etox-base'
} else if (nodename == 'uwigis') {
  prj = '/home/scharmueller/Projects/etox-base'
} else {
  stop('New system. Define prj and shinydir variables.')
}

# (0) setup ---------------------------------------------------------------
source(file.path(prj, 'R/setup.R'), max.deparse.length = mdl)

# (0a) console log ---------------------------------------------------------
if (sink_console) {
  con = file(file.path(prj, 'console.log'))
  sink(con, append = TRUE)
  sink(con, append = TRUE, type = 'message')
}


# build scripts -----------------------------------------------------------

if (build) {
  # download
  source(file.path(src, 'bd_epa_download.R'), max.deparse.length = mdl)
  # build
  source(file.path(src, 'bd_epa_postgres.R'), max.deparse.length = mdl)
  # lookup
  source(file.path(src, 'bd_epa_lookup.R'), max.deparse.length = mdl)
  # errata
  source(file.path(src, 'bd_epa_errata.R'), max.deparse.length = mdl)
  # meta files
  source(file.path(src, 'bd_epa_meta.R'), max.deparse.length = mdl) # user guide + codeappendix
  # bd CIR (chemical identifier resolver)
  source(file.path(src, 'bd_cir_dwld.R'), max.deparse.length = mld)
  source(file.path(src, 'bd_cir_prep.R'), max.deparse.length = mld)
}
  
# identifiers -------------------------------------------------------------
source(file.path(src, 'da_epa_chemicals.R'), max.deparse.length = mdl) # extracts identifiers
source(file.path(src, 'da_epa_taxonomy.R'), max.deparse.length = mdl) # extracts identifiers

# queries + results -------------------------------------------------------
# query additional data
if (online) {
  source(file.path(src, 'qu_run_dwld.R'), max.deparse.length = mdl)  
}

source(file.path(src, 'qu_run_prep.R'), max.deparse.length = mdl)
# merge information from additional data



# CONTINUE HERE!

# source(file.path(src, 'qu_merge.R'), max.deparse.length = mdl)
# # or in scripts ????
# 're_merge_chem.R'
# 're_merge_taxa.R'





# (4) prepare data --------------------------------------------------------
# EPA data scripts
# source(file.path(src, 'da_epa_run.R'), max.deparse.length = mdl)
# NORMAN export scripts
# source(file.path(src, 'da_norman_run.R'), max.deparse.length = mdl)

# file copies -------------------------------------------------------------
# copy README.md to shiny repo
# file.copy('README.md', file.path(shinydir, 'README.md'),
#           overwrite = TRUE)
# if (nodename == 'scharmueller') {
#   source(file.path(src, 'no_share.R'))
# }

# end ---------------------------------------------------------------------
source(file.path(src, 'end.R'))

# # (0b) console log 2 --------------------------------------------------------
if (sink_console) {
  # Restore output to console
  sink()
  sink(type="message")
}








