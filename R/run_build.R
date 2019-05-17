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

# console log -------------------------------------------------------------
if (sink_console) {
  con = file(file.path(prj, 'console.log'))
  sink(con, append = TRUE)
  sink(con, append = TRUE, type = 'message')
}

# build EPA ECOTOX data base ----------------------------------------------
## download
if (download_db) {
  ## EPA ECOTOX data base
  # download
  source(file.path(src, 'bd_epa_download.R'), max.deparse.length = mdl)
}

## build
if (build_db) {
  # build
  source(file.path(src, 'bd_epa_postgres.R'), max.deparse.length = mdl)
  # errata
  source(file.path(src, 'bd_epa_errata.R'), max.deparse.length = mdl)
  # meta files
  source(file.path(src, 'bd_epa_meta.R'), max.deparse.length = mdl) # user guide + codeappendix
  # lookup tables
  source(file.path(src, 'bd_epa_lookup.R'), max.deparse.length = mdl)
}

# identifiers -------------------------------------------------------------
## 1st identifiers
if (download) {
  source(file.path(src, 'id_cir_dwld.R'), max.deparse.length = mdl) # CIR
}

if (build) {
  source(file.path(src, 'id_cir_prep.R'), max.deparse.length = mdl)
}

## 2nd identifiers 
if (download) {
  source(file.path(src, 'id_pc_cid_dwld.R'), max.deparse.length = mld) # PubChem
  source(file.path(src, 'qu_cs_csid_dwld.R'), max.deparse.length = mld) # Chemspider
  source(file.path(src, 'id_epa_tax_dwld.R'), max.deparse.length = mdl) # EPA: extracts identifiers
}

if (build) {
  source(file.path(src, 'id_pc_cid_prep.R'), max.deparse.length = mld)
  source(file.path(src, 'id_epa_tax_prep.R'), max.deparse.length = mdl)
  source(file.path(src, 'id_epa_tax_prep.R'), max.deparse.length = mdl)
}

# queries + results -------------------------------------------------------
## chemical and biota parameters
if (download) {
  source(file.path(src, 'qu_run_dwld.R'), max.deparse.length = mdl)  
}

if (build) {
  source(file.path(src, 'qu_run_prep.R'), max.deparse.length = mdl)
}

# merge tables ------------------------------------------------------------
if (build) {
  source(file.path(src, 'qu_merge.R'), max.deparse.length = mdl)
}

# (4) prepare data --------------------------------------------------------
# TODO
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








