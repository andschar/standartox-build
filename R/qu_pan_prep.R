# script to prepare PAN data

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
pan_l = readRDS(file.path(cachedir, 'pan_l2.rds'))
pan_l = test



# prepare -----------------------------------------------------------------
pan = rbindlist(pan_l, fill = TRUE)
setnames(pan, 'CAS Number', 'cas')
setnames(pan, clean_names(pan))


######################### OLD ###############################################
# 
# 
# 
# # prepare -----------------------------------------------------------------
# # convert all entries to data.tables
# for (i in seq_along(pan_l)) {
#   if (!is.list(pan_l[[i]])) {
#     pan_l[[i]] = data.table(pan_l[[i]])
#   } else if (is.list(pan_l[[i]])) {
#     pan_l[[i]] = rbindlist(pan_l[i])
#   }
# }
# 
# pan = rbindlist(pan_l, fill = TRUE, idcol = 'cas')
# pan[ , V1 := NULL ]
# pan = pan[!is.na(cas)] # TODO why are NAs created in the first place?
# 
# # names -------------------------------------------------------------------
# setnames(pan, 'Chemical Class', 'chemical_class')
# 
# # final dt ----------------------------------------------------------------
# cols_pan_fin = c('cas', 'chemical_class')
# pan2 = pan[ , .SD, .SDcols = cols_pan_fin ]
# 
# setnames(pan2, c('cas', paste0('pa_', tolower(names(pan2[ ,2:length(names(pan2))])))))

############################### END #############################################


# check -------------------------------------------------------------------
chck_dupl(pan, 'cas')

# write -------------------------------------------------------------------
write_tbl(pan, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'pan',
          key = 'cas',
          comment = 'Results from PAN - Pesticide Action Network')

# log ---------------------------------------------------------------------
log_msg('PAN preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()