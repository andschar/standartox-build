# script to output NORMAN raw data

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
epa1 = readRDS(file.path(cachedir, 'epa1.rds'))
look = fread(file.path(lookupdir, 'lookup_variables.csv'))

# NORMAN filters ----------------------------------------------------------
# TODO insert filters here! Also in da_epaX_nor2.R

# TODO how to only export new data with every new epa version?
# Maybe find identifier in Postgres for releases
# select to_date(created_date, 'DD/MM/YYYY'), to_date(modified_date
# from ecotox.tests
# order by created_date desc
# limit 100



# NORMAN variables --------------------------------------------------------
time = Sys.time()
nor1 = norman(epa1)
Sys.time() - time

# NORMAN variables numbers ------------------------------------------------
## checks
# unique NORMAN ids
if (any(duplicated(look$id))){
  print(paste0('Duplicates: ', look[ duplicated(look$id), id ]))
}
# all NORMAN variables in nor1 
chck_look = nrow( look[ ! norman1 %in% names(nor1) ] )
if (chck_look != 0) {
  msg = 'Some NORMAN lookup variables can not be found in names(nor1)'
  log_msg(msg)
  stop(msg)
}

## subset
look = look[ nor_variable == 1L ]
cols = look$norman1
names(cols) = look$id
# data
nor1 = nor1[ , .SD, .SDcols = cols ]
setnames(nor1, names(cols))

# writing -----------------------------------------------------------------
## data
# postgres
time = Sys.time()
write_tbl(nor1, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'norman', tbl = 'nor1',
          comment = 'EPA ECOTOX raw export for NORMAN')
Sys.time() - time
# data (rds)
time = Sys.time()
saveRDS(nor1, file.path(cachedir, 'nor1.rds'))
Sys.time() - time
# raw csv export
time = Sys.time()
fwrite(nor1, file.path(share, 'nor1_raw.csv'))
Sys.time() - time
## example
# Triclosan
time = Sys.time()
fwrite(nor1[ `21` == '3380345' ],
       file.path(share, 'nor1_raw_triclosan.csv'))
Sys.time() - time
# meta data
nor1_norman_meta = ln_na(nor1_norman)
setnames(nor1_norman_meta, 'variable', 'id')
nor1_norman_meta[ , variable := cols[ match(nor1_norman_meta$id, names(cols)) ] ] # named v update
setcolorder(nor1_norman_meta, c('id', 'variable'))
setorder(nor1_norman_meta, variable)
fwrite(nor1_norman_meta,
       file.path(share, 'nor1_raw_variables.csv'))

# log ---------------------------------------------------------------------
msg = 'NORMAN: raw script run'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()

