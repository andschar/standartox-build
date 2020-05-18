# scripts to download and build a local version of the EPA ECOTOX DB

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# download ----------------------------------------------------------------
if (download_db) {
  ## EPA ECOTOX data base
  source(file.path(src, 'bd_epa_download.R'), max.deparse.length = mdl)
}

# build -------------------------------------------------------------------
if (build_db) {
  # build
  source(file.path(src, 'bd_epa_postgres.R'), max.deparse.length = mdl)
  # DB roles
  # TODO source(file.path(src, 'bd_postgres_roles.R'), max.deparse.length = mdl) # TODO  rethink structure
  # Permissions
  # TODO source(file.path(src, 'bd_postgres_permissions.R', max_deparse.length = mdl)) # TODO rethink structure
  # functions
  source(file.path(src, 'bd_sql_functions.R'), max.deparse.length = mdl)
  # errata
  source(file.path(src, 'bd_epa_errata.R'), max.deparse.length = mdl)
  # correct bad units
  source(file.path(src, 'bd_epa_errata_unit.R'), max.deparse.length = mdl)
  # phch and taxa data tables
  source(file.path(src, 'bd_phch_taxa_schema_table.R'), max.deparse.length = mdl)
  # meta files
  source(file.path(src, 'bd_epa_meta.R'), max.deparse.length = mdl) # user guide + codeappendix
  # PPDB
  source(file.path(src, 'bd_ppdb_prep.R'), max.deparse.length = mdl)
  # freshwaterecology.info
  source(file.path(src, 'bd_freshwaterecologyinfo.R'), max.deparse.length = mdl)
}

# log ---------------------------------------------------------------------
log_msg('RUN: EPA ECOTOX database downloaded and built.')

# cleaning ----------------------------------------------------------------
clean_workspace()


