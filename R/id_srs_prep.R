# script to prepare SRS (US EPA Substance Registry Service) identifiers

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# prepare -----------------------------------------------------------------
srs_l = readRDS(file.path(cachedir, 'srs', 'srs_l.rds'))
srs_l = lapply(srs_l, `[[`, 1) # TODO change query and list structure once new srs query is online
srs_l = srs_l[ !is.na(srs_l) ]
srs_l = lapply(srs_l, function(x) { x["synonyms"] = NULL; x })

srs = rbindlist(srs_l, fill = TRUE, idcol = 'cas')
srs = srs[ !duplicated(cas) ] # NOTE 4 entries lost
## cleaning
srs[ , inchiNotation := sub('inchi=', '', inchiNotation, ignore.case = TRUE) ]
setnames(srs,
         c('inchiNotation', 'smilesNotation'),
         c('inchi', 'smiles'))
clean_names(srs)

# chck --------------------------------------------------------------------
chck_dupl(srs, 'cas')

# write -------------------------------------------------------------------
write_tbl(srs, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'srs', tbl = 'srs_id',
          key = 'cas',
          comment = 'EPA Substance Registry Service (SRS) identifier')

# log ---------------------------------------------------------------------
log_msg('ID: Substance Registry Service (SRS): preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()


