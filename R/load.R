# setup -------------------------------------------------------------------
source('R/setup.R')

# data --------------------------------------------------------------------
## (1) bfg_monitoring pesticides
psm_bfg = readRDS(file.path(cachedir, 'psm1.rds')) # created in EC50sensitivity_data.Rmd
psm_bfg = psm_bfg[ !is.na(casnr) ] # only metabolite and sumed pesticides
psm_bfg = psm_bfg[ !subst_name %in% c('Desethylsimazin') ] # casnr: 1007289; duplicated with Desethylsimazin
psm_bfg[205, cas := '72490-01-8'] # bug (instead of 72490-0-1--8)

## (2) French pesticides
# obtained from Mira
psm_mi = fread(file.path(datadir, 'missingVal.FR.csv'))
psm_mi[ , cas := casconv(casnr)] # convert to CAS
psm_mi = psm_mi[!cas %in% psm_bfg$cas]

# combine data.frame
psm = rbindlist(list(psm_bfg, psm_mi), fill = TRUE)

# checks ------------------------------------------------------------------

# save --------------------------------------------------------------------
saveRDS(psm, file.path(cachedir, 'psm.rds'))

# cleaning ----------------------------------------------------------------
rm(list = ls()[!ls() %in% c('psm')])



# work in progress --------------------------------------------------------
# TODO
#! should this be done here or by webchem queries?
#! tkaen from qu_epa.R - doesn't belong there

psm[ is.na(subst_name) ]$casnr
psm$subst_name

## resolve substance names manualy
# mostly taken from Sigmar Aldrich - careful!
miss = data.table(casnr = c("26002802", "26172554", "26530201", "2814202", "39515407", "39515418", "51036", "54406483", "584792", "72963725", "962583", "134623", "3380345"),
                  subst_name = c('Phenothrin', 'Methylchloroisothiazolinone', 'Octhilinone', 'Pyrimidinol', 'Cyphenothrin', 'Fenpropathrin', 'Piperonylbutoxide', 'Empethrin', 'Allethrin', 'Imiprothrin', 'Diazoxon', 'DEET', 'Triclosan'))

epa1[miss, on = 'casnr',
     subst_name := ifelse(is.na(subst_name), i.subst_name, subst_name)]

