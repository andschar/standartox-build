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
cols_exact = phch_cols[ table_name == 'chebi_envi' |
                          column_name %in% cols, column_name ]
cols_exact = cols_exact[ ! cols_exact %in% c('cas', 'chebiid') ]
cols_exact = gsub('(.+)', '^\\1$', cols_exact)
class_cols = phch_cols[ grep(paste0(cols_exact, collapse = '|'), column_name) ]

# query
q = q_join(class_cols, schema = 'phch', main_tbl = 'epa', col_join = 'cas',
           fun = 'GREATEST', cast = '::integer::boolean', debug = FALSE)
q = paste0("CREATE TABLE phch_fin.chem_class AS ( ", q, ")")
# TODO intermediate solution - change!
q = gsub('SELECT epa.cas', 'SELECT epa.cas_number, epa.cas', q, fixed = TRUE)

dbSendQuery(con, "DROP TABLE IF EXISTS phch_fin.chem_class;")
dbSendQuery(con, q)
dbSendQuery(con, "ALTER TABLE phch_fin.chem_class ADD PRIMARY KEY (cas);")

# chemical names ----------------------------------------------------------
q = "
  SELECT
    ep.cas_number,
    ep.cas,
    COALESCE(wi2.cname, ch.cname, pp.cname, aw.cname, ep.cname) cname,
    COALESCE(ch.iupac_name, pc.iupac_name, aw.iupac_name) iupacname,
    COALESCE(ci.inchi, ch.inchi, pc.inchi, aw.inchi, wi.inchi) inchi,
    COALESCE(ci.inchikey, ch.inchikey, pc.inchikey, aw.inchikey, wi.inchikey) inchikey,
    COALESCE(ci.smiles, ch.smiles, pc.canonicalsmiles, wi.smiles) smiles,
    COALESCE(pc.molecularweight, ch.mass) molar_mass,
    ch.definition  
  FROM phch.epa ep
  LEFT JOIN phch.cir ci ON ep.cas = ci.cas
  LEFT JOIN phch.physprop pp ON ep.cas = pp.cas
  LEFT JOIN phch.alanwood aw ON ep.cas = aw.cas
  LEFT JOIN phch.chebi ch ON ep.cas = ch.cas
  LEFT JOIN phch.wiki wi ON ep.cas = wi.cas
  LEFT JOIN phch.wiki2 wi2 ON ep.cas = wi2.cas
  LEFT JOIN phch.pubchem pc ON ep.cas = pc.cas"

q = paste0("CREATE TABLE phch_fin.chem_names AS ( ", q, ")")
dbSendQuery(con, "DROP TABLE IF EXISTS phch_fin.chem_names;")
dbSendQuery(con, q)
dbSendQuery(con, "ALTER TABLE phch_fin.chem_names ADD PRIMARY KEY (cas);")

# chemical properties -----------------------------------------------------
# TODO elaborate
q = "
  SELECT
    ep.cas_number,
    ep.cas,
    COALESCE(pc.molecularweight, ch.mass, pp.mw) molecularweight,
    COALESCE(pp.p_log) p_log,
    COALESCE(pp.solubility_water) solubility_water
  FROM phch.epa ep
  LEFT JOIN phch.pubchem pc ON ep.cas = pc.cas
  LEFT JOIN phch.chebi ch ON ep.cas = ch.cas
  LEFT JOIN phch.physprop pp ON ep.cas = pp.cas"

q = paste0("CREATE TABLE phch_fin.chem_prop AS ( ", q, ")")
dbSendQuery(con, "DROP TABLE IF EXISTS phch_fin.chem_prop;")
dbSendQuery(con, q)
dbSendQuery(con, "ALTER TABLE phch_fin.chem_prop ADD PRIMARY KEY (cas);")

dbDisconnect(con)
dbUnloadDriver(drv)


# log ---------------------------------------------------------------------
log_msg('QUERY: phch final table created.')

# cleaning ----------------------------------------------------------------
clean_workspace()
  
  
