# script to manually get habitat information

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
online = online
# online = TRUE

# source scripts ----------------------------------------------------------
# Additional chemical data
source('R/qu_pubchem.R')
source('R/qu_aw.R')
source('R/qu_pan.R')
source('R/qu_pp.R')

# EPA data
source('R/qu_epa.R')

# Taxon scripts
source('R/qu_classification.R')
# Habitat scripts
source('R/qu_worms.R')
# source('R/qu_habitat_self_defined.R') # self defined script
lookup_man_fam = fread(file.path(cachedir, 'family_lookup_list.csv'))

# Region scripts
source('R/qu_gbif.R')

# Chemical Information ----------------------------------------------------
# pubchem ----
# https://pubchemdocs.ncbi.nlm.nih.gov/about
# CID - non-zero integer PubChem ID
# XLogP - Log P calculated Log P
pc2 = pc[ , .SD, .SDcols = c('cas', 'CID', 'InChIKey', 'IUPACName', 'ExactMass')]
setnames(pc2, c('cas', paste0('pc_', tolower(names(pc2[ ,2:length(names(pc2))])))))
pc2 = pc2[!duplicated(cas)] #! easy way out, although pubchem doesn't provide important information
# Alan Wood Compendium ----
aw2 = aw[ , .SD, .SDcols = c('cas', 'cname', 'activity', 'subactivity', paste0('subactivity', 1:3))]
aw2[ , .N, cas][order(-N)] # no duplicates
setnames(aw2, c('cas', paste0('aw_', tolower(names(aw2[ ,2:length(names(aw2))])))))
# Pesticide Action Network ----
pan2 = pan[ , .SD, .SDcols = c('cas', 'Chemical Class')]
pan2[ , .N, cas][order(-N)] # no duplicates
setnames(pan2, c('cas', paste0('pan_', tolower(names(pan2[ ,2:length(names(pan2))])))))
# Physprop Data Base ----
pp2 = pp[ , .SD, .SDcols = c('cas', 'cname', 'Log P (octanol-water)', 'Water Solubility')]
pp2[ , .N, cas][order(-N)] # no duplicates
setnames(pp2, c('cas', paste0('pp2_', tolower(names(pp2[ ,2:length(names(pp2))])))))

# Merge ----
ch_info = Reduce(function(...) merge(..., by = 'cas', all = TRUE), list(pc2, aw2, pan2, pp2)) # id: cas

# Habitat information -----------------------------------------------------
ha_info = merge(lookup_worms_fam, lookup_man_fam, by = 'family', all = TRUE) # id: family

# Region information ------------------------------------------------------
re_info = gbif_conti_dc
setnames(re_info, 'taxon', 'latin_BIname')

# Merge with test data ----------------------------------------------------

# TODO continue here!!

nrow(epa1)
epa1[is.na(latin_BIname)]

tests = merge(epa1, re_info, by = 'latin_BIname', all.x = TRUE) # id: latin_BIname
tests[ , .N, .(latin_BIname, Asia)]$Asia


names(epa1)
re_info = NA # id: taxon (same as latin_BIname)
re_info = gbif_ccode_dc
test = gbif_ccode[ , .(ccode = paste0(ccode, collapse = '-')), taxon]

epa1[test, on = c(latin_BIname = 'taxon'), bgif_ccode := i.ccode]




# EPA ECOTOX information --------------------------------------------------
epa1[ , .N, habitat] # FW: exclude: Soil; TR: exclude: Water
epa1[ , .N, subhabitat] # not helping leave out

anyNA(epa1$cas)
epa1[ , .N, obs_duration_conv]
epa1[ , .N, obs_duration_unit_conv]

toxtest = merge(epa1, ch_info, by = 'cas')



# playing around ----------------------------------------------------------

aw
names(aw)
aw2 = aw[ , .SD, .SDcols = c('cas', 'subactivity', 'subactivity1', 'subactivity2', 'subactivity3')]

aw2$subactivity
aw2$subactivity1

names(pan)
pan$`Use Type` # 
pan$`Chemical name`
length(which(is.na(pan$`Use Type`))) # 404 NAs
length(which(is.na(pan$`Chemical Class`))) # 413 NAs
pan[ , .N, `Ground Water Contaminant`] # not needed
pan[ , .N, `Dirty Dozen`]
length(which(is.na(pan$`Water Solubility (Avg, mg/L)`))) # 428 NAs

# pp
length(which(is.na(pp$`Water Solubility`))) # 247 NAs
names(pp)
pp$cname
# pc
names(pc)
pc$XLogP
pc$InChIKey


setwd('/home/andreas/Documents/Projects/etox-base')
list.files('/R', pattern = 'qu_')
