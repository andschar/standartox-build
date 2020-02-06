# script to prepare PubChem identifiers (synonyms)

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# function ----------------------------------------------------------------
grep_id = function(l, pattern) {
  l2 = lapply(l, function(x) grep(pattern, x, ignore.case = TRUE, value = TRUE))
  out = rbindlist(lapply(l2, as.data.table), fill  = TRUE, idcol = 'cas')
  
  return(out)
}

# data --------------------------------------------------------------------
pc_syn_l = readRDS(file.path(cachedir, 'pubchem', 'pc_syn_l.rds'))

# prepare -----------------------------------------------------------------
## cid
cid = rbindlist(lapply(lapply(pc_syn_l, `[[`, 1), as.list), idcol = 'cas')
setnames(cid, 'V1', 'cid')
## name
name = rbindlist(lapply(lapply(pc_syn_l[ !is.na(pc_syn_l) ], `[[`, 2), as.list), idcol = 'cas')
name[ , V1 := tolower(V1) ]
setnames(name, 'V1', 'name')
## chebi
chebi = grep_id(pc_syn_l, 'chebi')
setnames(chebi, 'V1', 'chebiid')
chebi = chebi[ !duplicated(cas) ] # NOTE lose some entries - hard to determine anyway
## chembl
chembl = grep_id(pc_syn_l, 'chembl')
chembl[ , V1 := sub('S', '', V1) ] # NOTE SCHEMBL seems to be an error
chembl2 = chembl[ !duplicated(cas) ]
setnames(chembl2, 'V1', 'chembl')
## dsstox
dsstox = grep_id(pc_syn_l, 'dsstox')
dsstox[ , c('dsstox', 'id', 'value') := tstrsplit(V1, '_') ]
dsstox[ , dsstox := NULL ]
dsstox = dsstox[ , .(value = head(value, 1)), .(cas, id) ] # NOTES lose some entries
dsstox2 = dcast(dsstox, cas ~ id, value.var = 'value')
setnames(dsstox2, 2:4, paste0('dsstox_', tolower(names(dsstox2)[2:4])))
## einecs
einec = grep_id(pc_syn_l, 'einec')
einec[ , V1 := trimws(sub('EINECS', '', V1)) ]
einec = einec[ !duplicated(cas) ]
setnames(einec, 'V1', 'einec')

# merge -------------------------------------------------------------------
id = Reduce(function(...) merge(..., all = TRUE), list(cid,
                                                   name,
                                                   chebi,
                                                   chembl2,
                                                   dsstox2,
                                                   einec))

# chck --------------------------------------------------------------------
chck_dupl(id, 'cas')

# write -------------------------------------------------------------------
write_tbl(id, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'pubchem', tbl = 'pubchem_id',
          key = 'cas',
          comment = 'Results from PubChem (synonyms)\nno quality guaranteed')

# log ---------------------------------------------------------------------
log_msg('ID: PubChem: preparation (synonyms) script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()
