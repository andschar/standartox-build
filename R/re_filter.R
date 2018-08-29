# script to clean the EPA ECOTOX data base test results

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
online = online
online = FALSE

# data --------------------------------------------------------------------
if (online) {
  source('R/re_merge.R')
} else {
  tests = readRDS(file.path(cachedir, 'tests.rds'))
}

# varaibles ---------------------------------------------------------------

# (1) compound name ----
tests[ , comp_name := NA ]
tests[ , comp_name := ifelse(!is.na(pp_cname), pp_cname,
                      ifelse(is.na(comp_name) & !is.na(aw_cname), aw_cname,
                      ifelse(is.na(comp_name) & !is.na(fr_cname), fr_cname,
                      ifelse(is.na(comp_name) & !is.na(pc_iupacname), pc_iupacname, NA)))) ]

# checking
na_name = tests[ is.na(comp_name), .N, by = c('casnr', 'comp_name') ][ , N := NULL]
if (length(na_name$casnr) > 0 ) {
  message('For the following cas, compound names are missing:\n',
          paste0(na_name$casnr, collapse = ', '))
}

# (2) compound type ----
tests[ , comp_type := NA ]
tests[ , comp_type := ifelse(!is.na(aw_pest_type), aw_pest_type,
                      ifelse(is.na(comp_type) & !is.na(ep_chemical_group), ep_chemical_group,
                      ifelse(is.na(comp_type) & !is.na(fr_cname), fr_cname, NA))) ]

na_type = tests[ is.na(comp_type), .N, by = c('casnr', 'comp_name', 'comp_type') ][ , N := NULL]
if (length(na_type$casnr) > 0 ) {
  message('For the following cas, compound types are missing:\n',
          paste0(na_type$casnr, collapse = ', '))
}

# (3) water solubility ----
tests[ , comp_solub := ifelse(!is.na(pp_solubility_water), pp_solubility_water, NA)]
# TODO add more resources to the solub_wat_fin creation
tests[ , comp_solub_chck := ifelse(ep_value < comp_solub, TRUE, FALSE)] # TODO check: unit of solubility concentrations

# checking
na_solub = tests[ is.na(comp_solub), .N, by = c('casnr', 'comp_name', 'comp_solub') ][ , N := NULL]
if (length(na_solub$casnr) > 0 ) {
  message('For the following cas, water solubility values are missing:\n',
          paste0(na_solub$casnr, collapse = ', '))
}

# (4) habitat column ----
tests[ , isFre_fin := ifelse(ep_habitat == 'Water' | ep_media_type == 'FW' | wo_isfre == 1 | ma_isfre == 1, '1', NA)] # TODO Water probably incl marine (in ep_habitat)
tests[ , isBra_fin := ifelse(wo_isbra == 1, '1', NA)]
tests[ , isMar_fin := ifelse(ep_media_type == 'SW' | wo_ismar == 1 | ma_ismar == 1, '1', NA)]
tests[ , isTer_fin := ifelse(ep_habitat == 'Soil' | wo_ister == 1 | ma_ister == 1, '1', NA)]

# checking
na_habi = tests[ is.na(isFre_fin) & is.na(isBra_fin) & is.na(isMar_fin) & is.na(isTer_fin),
                 .N,
                 by = c('casnr', 'comp_name', 'isFre_fin', 'isBra_fin', 'isMar_fin', 'isTer_fin') ][ , N := NULL]
if (length(na_habi$casnr) > 0 ) {
  message('For the following taxa, habitat entries are missing:\n',
          paste0(na_habi$casnr, collapse = ', '))
}

# (5) invertebrate classification ----
inv_makro_phylum = c('Annelida', 'Echinodermata', 'Mollusca', 'Nemertea', 'Platyhelminthes', 'Porifera')
inv_mikro_phylum = c('Bryozoa', 'Chaetognatha', 'Ciliophora', 'Cnidaria', 'Gastrotricha', 'Nematoda', 'Rotifera')
inv_makro_subphylum = c('Crustacea')
inv_makro_class = c('Arachnida', 'Diplopoda', 'Entognatha', 'Insecta') # phylum: Arthropoda
invertebrates_makro = c(inv_makro_phylum, inv_makro_subphylum, inv_makro_class)
invertebrates_mikro = inv_mikro_phylum
tests[ , ma_supgroup2 := ifelse(ma_supgroup %in% invertebrates_makro, 'Makro_Inv',
                                   ifelse(ma_supgroup %in% invertebrates_mikro, 'Mikro_Inv', ma_supgroup)) ]
# trophic level
autotrophs = c('Plants', 'Algae', 'Bryophyta')
tests[ , trophic_lvl := ifelse(ma_supgroup2 %in% autotrophs, 'autotrophic', 'heterotrophic') ]

# TODO create checking column

# save data ---------------------------------------------------------------
tests_fl = copy(tests)
# TODO rm after presentation and change it in the right place
tests_fl[comp_name == 'glyphosphate', comp_name := 'glyphosate']
saveRDS(tests_fl, file.path(cachedir, 'tests_fl.rds'))


# save missing values -----------------------------------------------------
missing_l = list(na_name = na_name, na_type = na_type, na_solub = na_solub, na_habi = na_habi)
for (i in 1:length(missing_l)) {
    file = missing_l[[i]]
    name = names(missing_l)[i]
  
  if (nrow(file) > 0) {
    fwrite(file, file.path(missingdir, paste0(name, '.csv')))
    message('Writing file with missing data: ', name)
  }
}

# cleaning ----------------------------------------------------------------
# TODO 

# plot --------------------------------------------------------------------
# TODO: DEPR and put into function
clean_stats = tests[ ,
                     .(N_tot = .N,
                       N_subt_type = .SD[ !ep_conc_type %in% c('F'), .N ],
                       N_solu = .SD[ chck_solub != FALSE, .N ]),
                     ]
clean_stats = melt(clean_stats, value.name = 'N')
clean_stats[ , perc := N / clean_stats[variable == 'N_tot', N] * 100 ]


gg_clean_stats = ggplot(clean_stats, aes(y = N, x = reorder(variable, N))) +
  geom_bar(stat = 'identity') +
  coord_flip() +
  labs(x = NULL, y = 'N tests') +
  theme_bw()

ggsave(gg_clean_stats, filename = file.path(plotdir, 'gg_clean_stats.png'),
       width = 8, height = 5)










