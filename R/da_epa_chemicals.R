# script to clean cas numbers

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
epa1 = readRDS(file.path(cachedir, 'epa1.rds'))

chem = unique(epa1[ , .SD, .SDcols = c('casnr', 'cas', 'chemical_name')])
setorder(chem, casnr)

# writing -----------------------------------------------------------------
saveRDS(chem, file.path(cachedir, 'epa_chem.rds'))

# log ---------------------------------------------------------------------
msg = 'EPA1: chemicals cleaning script run'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()