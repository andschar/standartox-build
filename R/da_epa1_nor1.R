# script to output NORMAN raw data

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
epa1 = readRDS(file.path(cachedir, 'epa1.rds'))

# NORMAN variables --------------------------------------------------------
look = fread(file.path(lookupdir, 'lookup_variables.csv'))
look = look[ !is.na(no1_variable) & no1_variable != '' ] #! still an issue in data.table_1.11.8
# https://stackoverflow.com/questions/51019041/blank-space-not-recognised-as-na-in-fread
# check 
chck_look_var = nrow( look_var[ ! no1_variable %in% names(epa1) ] )
if (chck_look_var != 0) {
  msg = 'Some NORMAN lookup variables can not be found in names(epa1)'
  log_msg(msg)
  stop(msg)
}; rm(chck_no_look)

# integer column names
cols = look_var$no1_variable
names(cols) = look_var$id1
cols = cols[ cols %in% names(epa1) ]

# NORMAN table
nor1 = epa1[ , .SD, .SDcols = cols ]
setnames(nor1, names(cols))


# writing -----------------------------------------------------------------
# raw export
time = Sys.time()
fwrite(nor1, file.path(share, 'nor1_raw.csv'))
Sys.time() - time
# example (Triclosan) export
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
rm(list = ls()[ !ls() %in% c('src') ] )


