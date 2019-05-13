# script aggregates data from 3rd party data bases

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# chemical scripts --------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  ## final chemical schema
  dbSendQuery(con, "DROP SCHEMA IF EXISTS phch_fin CASCADE;")
  dbSendQuery(con, "CREATE SCHEMA phch_fin;")
  
  phch_cols = dbGetQuery(con, "SELECT table_schema, table_name, column_name
                               FROM information_schema.columns
                               WHERE table_schema = 'phch';")
  setDT(phch_cols)
  
  #### chemical classes ----
  cols = c('fungicide', 'herbicide', 'insecticide', 'pesticide', 'metal')
  cols = gsub('(.+)', '^\\1$', cols)
  class_cols = phch_cols[ grep(paste0(cols, collapse = '|'), column_name) ]
  
  # query
  q = q_join(class_cols, schema = 'phch', main_tbl = 'epa', col_join = 'cas',
             fun = 'GREATEST', debug = FALSE)
  q = paste0("CREATE TABLE phch_fin.chem_class AS ( ", q, ")")
  
  dbSendQuery(con, "DROP TABLE IF EXISTS phch_fin.chem_class;")
  dbSendQuery(con, q)
  
  #### chemical names ----
  q = "
    SELECT
      ep.cas,
      COALESCE(NULL, ch.chebiasciiname, pp.cname, aw.cname, ep.cname) cname,
      COALESCE(NULL, NULL, aw.iupac_name) iupacname,
      COALESCE(ci.inchi, ch.inchi, NULL, aw.inchi) inchi,
      COALESCE(ci.inchikey, ch.inchikey, NULL, aw.inchikey) inchikey,
      COALESCE(ci.smiles, ch.smiles, NULL, NULL) smiles,
      ch.definition  
    FROM phch.epa ep
    INNER JOIN phch.cir ci ON ep.cas = ci.cas
    INNER JOIN phch.physprop pp ON ep.cas = pp.cas
    INNER JOIN phch.alanwood aw ON ep.cas = aw.cas
    INNER JOIN phch.chebi ch ON ep.cas = ch.cas"
  q = paste0("CREATE TABLE phch_fin.chem_names AS ( ", q, ")")
  dbSendQuery(con, "DROP TABLE IF EXISTS phch_fin.chem_names;")
  dbSendQuery(con, q)
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
} else {
  
  log_msg('Connect to data base.')
}

# taxa: habitat and region scripts ----------------------------------------
if (online_db) { 
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  dbSendQuery(con, "DROP SCHEMA IF EXISTS taxa_fin CASCADE;")
  dbSendQuery(con, "CREATE SCHEMA taxa_fin;")
  
  taxa_cols = dbGetQuery(con, "SELECT table_schema, table_name, column_name
                               FROM information_schema.columns
                               WHERE table_schema = 'taxa';")
  setDT(taxa_cols)
  
  #### habitat ----
  cols = c('marin', 'brack', 'fresh', 'terre')
  cols = gsub('(.+)', '^\\1$', cols)
  cols_tx = taxa_cols[ grep(paste0(cols, collapse = '|'), column_name) ]
  cols_tx[ !table_name %in% c('worms_fm', 'worms_gn') ]
  
  q = q_join(cols_tx, schema = 'taxa', main_tbl = 'epa', col_join = 'taxon',
             fun = 'GREATEST', debug = FALSE)
  q = paste0("CREATE TABLE taxa_fin.habi AS ( ", q, ")")
  dbSendQuery(con, "DROP TABLE IF EXISTS taxa.habi;")
  dbSendQuery(con, q)
  
  #### continent ----
  cols = c('africa', 'north_america', 'south_america', 'asia', 'europe', 'oceania')
  cols = gsub('(.+)', '^\\1$', cols)
  cols_hb = taxa_cols[ grep(paste0(cols, collapse = '|'), column_name) ]
  
  q = q_join(cols_hb, schema = 'taxa', main_tbl = 'epa', col_join = 'taxon',
             fun = 'GREATEST', debug = FALSE)
  q = paste0("CREATE TABLE taxa_fin.continent AS ( ", q, ")")
  dbSendQuery(con, "DROP TABLE IF EXISTS taxa_fin.continent;")
  dbSendQuery(con, q)
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
} else {
  
  log_msg('Connect to data base.')
}
  
  
  
