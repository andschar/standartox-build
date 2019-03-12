# script to prepare EPA ECOTOX data
# data export for Etox-Base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
epa3 = readRDS(file.path(cachedir, 'epa2.rds'))
look = fread(file.path(lookupdir, 'lookup_variables.csv'))
look = look[ app_variable == 1L ]

# select columns ----------------------------------------------------------
epa3 = epa3[ , .SD, .SDcols = look$epa3_variable ]

# select rows -------------------------------------------------------------
## endpoints
idx_ept_grp = which(epa3$endpoint_grp %in% c('NOEX', 'XX50', 'LOEX', 'XX10'))

## NAs
idx_na_dur = with(epa3, which(!is.na(obs_duration_mean_conv) & !is.na(obs_duration_unit_conv)))
idx_na_conc = with(epa3, which(!is.na(conc1_mean_conv) & !is.na(conc1_unit_conv)))
idx_na_eff = which(!is.na(epa3$effect))
idx_na_ept = which(!is.na(epa3$endpoint))

## subseting
idx_fin = Reduce(intersect, list(idx_ept_grp, idx_na_dur, idx_na_conc, idx_na_eff, idx_na_ept))
epa3 = epa3[ idx_fin ]

# column names ------------------------------------------------------------
setnames(epa3, old = look$epa3_variable, new = look$app_variable_name)

# writing -----------------------------------------------------------------
## postgres
time = Sys.time()
write_tbl(epa3, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'ecotox_export', tbl = 'epa3',
          comment = 'EPA ECOTOX application preparation export')
Sys.time() - time
## data (rds)
time = Sys.time()
saveRDS(epa3, file.path(cachedir, 'epa3.rds'))
Sys.time() - time

# log ---------------------------------------------------------------------
msg = 'EPA3: reduce script run'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()


