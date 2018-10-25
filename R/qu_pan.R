# script to query information from Pesticide Action Network (PAN)

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
chem = readRDS(file.path(cachedir, 'epa_chem.rds'))

# query -------------------------------------------------------------------
todo_pan = sort(chem$cas)
todo_pan = todo_pan[1:3] # debug me

if (TRUE) {
  pan_l = list()
  for (i in seq_along(todo_pan)) {
    cas = todo_pan[i]
    message('PAN: CAS:', cas, ' (', i, '/', length(todo_pan), ')')
    pan = pan_query(cas, verbose = FALSE)
    
    pan_l[[i]] = unlist(pan)
    names(pan_l)[i] = cas
  }
  
  saveRDS(pan_l, file.path(cachedir, 'pan_l.rds'))
  
} else {
  
  pan_l = readRDS(file.path(cachedir, 'pan_l.rds'))
}

# convert all entries to data.tables
for (i in seq_along(pan_l)) {
  if (!is.list(pan_l[[i]])) {
    pan_l[[i]] = data.table(pan_l[[i]])
  } else if (is.list(pan_l[[i]])) {
    pan_l[[i]] = rbindlist(pan_l[i])
  }
}

pan = rbindlist(pan_l, fill = TRUE, idcol = 'cas')
pan[ , V1 := NULL ]
pan = pan[!is.na(cas)] # TODO why are NAs created in the first place?

# names -------------------------------------------------------------------
setnames(pan, 'Chemical Class', 'chemical_class')

# final dt ----------------------------------------------------------------
cols_pan_fin = c('cas', 'chemical_class')
pan2 = pan[ , .SD, .SDcols = cols_pan_fin ]

setnames(pan2, c('cas', paste0('pa_', tolower(names(pan2[ ,2:length(names(pan2))])))))

# missing entries ---------------------------------------------------------
na_pan2_chem_class = pan2[ is.na(pa_chemical_class) ]
msg = paste0('PAN: For ', nrow(na_pan2_chem_class), '/', nrow(pc2),
             ' CAS no Chem. class entries were found.')
log_msg(msg); rm(msg)

if (nrow(na_pan2_chem_class) > 0) {
  fwrite(na_pan2_chem_class, file.path(missingdir, 'na_pan2_chem_class.csv'))
  message('Writing missing data to:\n',
          file.path(missingdir, 'na_pan2_chem_class.csv'))
}

# cleaning ----------------------------------------------------------------
rm(chem, cols_pan_fin)






