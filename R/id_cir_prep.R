# script to query chemical identifiers

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
l = readRDS(file.path(cachedir, 'cir_l.rds'))

# preparation -------------------------------------------------------------
# convert list to data.tables
l3 = list()
for (i in seq_along(l)) {
  dt = rbindlist(lapply(l[[i]], data.table), idcol = 'cas')
  nam = names(l)[i]
  setnames(dt, 'V1', nam)
  l3[[i]] = dt
  names(l3)[i] = nam
}

# final table -------------------------------------------------------------
## cir
cir = Reduce(function(...)
  merge(
    ...,
    by = 'cas'
  ),
  l3[ names(l3) %in% c('stdinchi', 'stdinchikey', 'smiles') ])
cir[ , stdinchikey := gsub('InChIKey=', '', stdinchikey) ]
cir[ , casnr := casconv(cas, direction = 'tocasnr') ]
setcolorder(cir, c('cas', 'casnr', 'stdinchi', 'stdinchikey', 'smiles'))
setorder(cir, 'cas')
setnames(cir, c('stdinchi', 'stdinchikey'), c('inchi', 'inchikey'))
## names
nam_all = l3$names
nam_all = nam_all[ !is.na(names) ]
nam_all[ , names := tolower(names) ]
## names clean
nam_cl = l3$names_clean
nam_cl = nam_cl[ , cname := tolower(names_clean) ][ , names_clean := NULL ]
## names unique
nam_uq = nam_cl[ , .(cname = cname[1]), by = 'cas' ]
cir[nam_uq, cname := i.cname, on = 'cas' ]
## Pubchem SID
pub_sid = l3$pubchem_sid
## Chemspider ID
cs_id = l3$chemspider_id
## ChEBIid
chebiid = l3$chebiid # TODO if unique, put into cir[]

# check -------------------------------------------------------------------
chck_dupl(cir, 'cas')

# write -------------------------------------------------------------------
write_tbl(cir, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'cir', tbl = 'prop',
          key = 'cas',
          comment = 'Results from the CIR (cas, inchi, smiles)')
write_tbl(nam_all, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'cir', tbl = 'names',
          comment = 'Results from the CIR (cas, names) - duplicates')
write_tbl(nam_cl, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'cir', tbl = 'names_clean',
          comment = 'Results from the CIR (cas, names - cleaned) - duplicates')
write_tbl(pub_sid, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'cir', tbl = 'sid',
          comment = 'Results from the CIR (cas, PubChem SID) - duplicates')
write_tbl(cs_id, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'cir', tbl = 'csid',
          comment = 'Results from the CIR (cas, ChemSpider ID) - duplicates')
write_tbl(chebiid, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'cir', tbl = 'chebi',
          comment = 'Results from the CIR (cas, ChebiId) - duplicates (?)')

# log ---------------------------------------------------------------------
log_msg('CIR preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()
