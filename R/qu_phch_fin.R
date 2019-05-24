# script aggregates physico-chemical data from 3rd party data bases

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

## final chemical schema
dbSendQuery(con, "DROP SCHEMA IF EXISTS phch_fin CASCADE;")
dbSendQuery(con, "CREATE SCHEMA phch_fin;")

phch_cols = dbGetQuery(con, "SELECT table_schema, table_name, column_name
                             FROM information_schema.columns
                             WHERE table_schema = 'phch';")
setDT(phch_cols)

# chemical classes --------------------------------------------------------
cols = c('agrochemical', 'fungicide', 'herbicide', 'insecticide', 'pesticide', 'metal', 'drug')
# TODO elaborate on chemical groups!
cols = gsub('(.+)', '^\\1$', cols)
class_cols = phch_cols[ grep(paste0(cols, collapse = '|'), column_name) ]

# query
q = q_join(class_cols, schema = 'phch', main_tbl = 'epa', col_join = 'cas',
           fun = 'GREATEST', debug = FALSE)
q = paste0("CREATE TABLE phch_fin.chem_class AS ( ", q, ")")

dbSendQuery(con, "DROP TABLE IF EXISTS phch_fin.chem_class;")
dbSendQuery(con, q)

# chemical names ----------------------------------------------------------
q = "
  SELECT
    ep.cas,
    COALESCE(ci.cname, ch.cname, pp.cname, aw.cname, ep.cname) cname,
    COALESCE(ch.iupac_name, pc.iupac_name, aw.iupac_name) iupacname,
    COALESCE(ci.inchi, ch.inchi, pc.inchi, aw.inchi, wi.inchi) inchi,
    COALESCE(ci.inchikey, ch.inchikey, pc.inchikey, aw.inchikey, wi.inchikey) inchikey,
    COALESCE(ci.smiles, ch.smiles, pc.canonicalsmiles, wi.smiles) smiles,
    ch.definition  
  FROM phch.epa ep
  LEFT JOIN phch.cir ci ON ep.cas = ci.cas
  LEFT JOIN phch.physprop pp ON ep.cas = pp.cas
  LEFT JOIN phch.alanwood aw ON ep.cas = aw.cas
  LEFT JOIN phch.chebi ch ON ep.cas = ch.cas
  LEFT JOIN phch.wiki wi ON ep.cas = wi.cas
  LEFT JOIN phch.pubchem pc ON ep.cas = pc.cas"

q = paste0("CREATE TABLE phch_fin.chem_names AS ( ", q, ")")
dbSendQuery(con, "DROP TABLE IF EXISTS phch_fin.chem_names;")
dbSendQuery(con, q)

dbDisconnect(con)
dbUnloadDriver(drv)

# log ---------------------------------------------------------------------
log_msg('Query phch final table')

# cleaning ----------------------------------------------------------------
clean_workspace()
  
  
