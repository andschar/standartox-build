# scripts to download and build chemical and taxa identifiers

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# download ----------------------------------------------------------------
if (download) {
  source(file.path(src, 'id_run_dwld.R'), max.deparse.length = mdl)
}

# build -------------------------------------------------------------------
if (build) {
  source(file.path(src, 'id_run_prep.R'), max.deparse.length = mdl)
  source(file.path(src, 'id_compile_table.R'), max.deparse.length = mdl)
}

# report ------------------------------------------------------------------
if (report) {
  source(file.path(src, 'rep_id_prep.R'), max.deparse.length = mdl)
}

# log ---------------------------------------------------------------------
log_msg('RUN: identifiers downloaded and built.')

# cleaning ----------------------------------------------------------------
clean_workspace()


