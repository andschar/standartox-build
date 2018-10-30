# script to determine the numer of NAs for each variable (group) + plots

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
# don't read final table 'cause it doesn't contain anymore all variables. Read checked table.
te_st = readRDS(file.path(cachedir, 'tests_ch.rds'))
cols = sort(names(te_st))
cols = grep('src', cols, value = TRUE, invert = TRUE) # remove src columns

#### individual variables -------------------------------------------------
# every variable stands for its own

# media variables ---------------------------------------------------------
cols_media = grep('med', cols, value = TRUE)
cols_media = grep('unit', cols_media, value = TRUE, invert = TRUE)
na_media = te_st[ , sapply(.SD, function(x) length(which(is.na(x)))), .SDcols = cols_media ]

media = data.table(
  variable = names(na_media),
  N_NA = na_media,
  N_tot = nrow(te_st)
)
media[ , NA_perc := round(N_NA / N_tot, 2) * 100 ]
setorder(media, -NA_perc)

gg_media = ggplot(media, aes(y = NA_perc, x = reorder(variable, -NA_perc))) +
  geom_point() +
  labs(y = 'Proportion NA', x = NULL) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# compound variables ------------------------------------------------------
cols_comp = grep('comp', cols, value = TRUE)
cols_comp = grep('chck', cols_comp, value = TRUE, invert = TRUE) # remove chck_column

na_comp = te_st[ , sapply(.SD, function(x) length(which(is.na(x)))), .SDcols = cols_comp ]

comp = data.table(
  variable = names(na_comp),
  N_NA = na_comp,
  N_tot = nrow(te_st)
)
comp[ , NA_perc := round(N_NA / N_tot, 2) * 100 ]
setorder(media, -NA_perc)

#### group variables ------------------------------------------------------
# variables whose NAs should be evaluated together
# (e.g. hab_fresh, hab_marin, ...)
# a single NA is not a problem

# chemical class ----------------------------------------------------------
cols_chcl = grep('cgr', cols, value = TRUE)

te_st[ , N_chcl := rowSums(.SD, na.rm = TRUE), .SDcols = cols_chcl ]
na_chcl = te_st[ , .N, N_chcl ][order(-N)]

chcl = data.table(
  varaible = 'chemical classes (cgr_)',
  N_NA = na_chcl[ N_chcl == 0 ]$N,
  N_tot = nrow(te_st)
)
chcl[ , NA_perc := round(N_NA / N_tot, 2) * 100 ]
setorder(chcl, -NA_perc)

# habitat variables -------------------------------------------------------
cols_habi = grep('hab_', cols, value = TRUE)

te_st[ , N_habi := rowSums(.SD, na.rm = TRUE), .SDcols = cols_habi ]
na_habi = te_st[ , .N, N_habi ][order(-N)]

habi = data.table(
  varaible = 'habitat (hab_)',
  N_NA = na_habi[ N_habi == 0 ]$N,
  N_tot = nrow(te_st)
)
habi[ , NA_perc := round(N_NA / N_tot, 2) * 100 ]
setorder(habi, -NA_perc)

# region ------------------------------------------------------------------
cols_regi = grep('reg_', cols, value = TRUE)

te_st[ , N_regi := rowSums(.SD, na.rm = TRUE), .SDcols = cols_regi ]
na_regi = te_st[ , .N, N_regi ][order(-N)]

regi = data.table(
  varaible = 'regitat (reg_)',
  N_NA = na_regi[ N_regi == 0 ]$N,
  N_tot = nrow(te_st)
)
regi[ , NA_perc := round(N_NA / N_tot, 2) * 100 ]
setorder(regi, -NA_perc)

# missing list ------------------------------------------------------------
na_l = list(media = media,
            comp = comp,
            chcl = chcl,
            habi = habi,
            regi = regi)

na_dt = rbindlist(na_l, idcol = 'varaible_type')

# writing -----------------------------------------------------------------
fwrite(na_dt, file.path(missingdir, 'all_variables_na.csv'))
fwrite(na_dt, file.path(shinydata, 'all_variables_na.csv'))

# log ---------------------------------------------------------------------
msg = 'Summary stats on variables calculated and written'
log_msg(msg); rm(msg)

# cleaning ----------------------------------------------------------------
rm(list = grep('cols', ls(), value = TRUE))
rm(list = grep('comp', ls(), value = TRUE))
rm(list = grep('media', ls(), value = TRUE))
rm(list = grep('chcl', ls(), value = TRUE))
rm(list = grep('habi', ls(), value = TRUE))
rm(list = grep('regi', ls(), value = TRUE))
rm(te_st, na_l, na_dt)




