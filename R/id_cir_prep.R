# script to query chemical identifiers

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
l = readRDS(file.path(cachedir, 'cir', 'cir_l.rds'))

# prepare -----------------------------------------------------------------
inchikey = rbindlist(lapply(l$stdinchikey, as.list), idcol = 'cas')
inchikey[ , V1 := sub('InChIKey=', '', V1) ]
setnames(inchikey, 'V1', 'inchikey')
inchi = rbindlist(lapply(l$stdinchi, as.list), idcol = 'cas')
inchi[ , V1 := sub('InChI=', '', V1) ]
setnames(inchi, 'V1', 'inchi')
smiles = rbindlist(lapply(l$smiles, as.list), idcol = 'cas')
setnames(smiles, 'V1', 'smiles')
## merge
cir = Reduce(function(...) merge(..., all = TRUE),
             list(inchikey,
                  inchi,
                  smiles))

# check -------------------------------------------------------------------
chck_dupl(cir, 'cas')

# write -------------------------------------------------------------------
write_tbl(cir, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'cir', tbl = 'cir_id',
          key = 'cas',
          comment = 'Results from the CIR (cas, inchi, smiles)')

# log ---------------------------------------------------------------------
log_msg('ID: CIR: preparation script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
