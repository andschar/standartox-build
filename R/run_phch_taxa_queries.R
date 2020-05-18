# scripts to download and build chemical and taxa identifiers

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# download ----------------------------------------------------------------
## chemical and biota parameters
if (download) {
  source(file.path(src, 'qu_run_dwld.R'), max.deparse.length = mdl)  
}

# build -------------------------------------------------------------------
if (build) {
  source(file.path(src, 'qu_run_prep.R'), max.deparse.length = mdl)
}

# report ------------------------------------------------------------------
if (report) {
  source(file.path(src, 'rep_query_prep.R'), max.deparse.length = mdl)
}

# log ---------------------------------------------------------------------
log_msg('RUN: identifiers downloaded and built.')

# cleaning ----------------------------------------------------------------
clean_workspace()


