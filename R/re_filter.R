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
na_name = unique(tests[is.na(tests$comp_name), casnr])
if (length(na_name) > 0 ) {
  message('For the following cas, compound names are missing:\n',
          na_name)
}

# (2) compound type ----
tests[ , comp_type := NA ]
tests[ , comp_type := ifelse(!is.na(aw_pest_type), aw_pest_type,
                      ifelse(is.na(comp_type) & !is.na(ep_chemical_group), ep_chemical_group, NA)) ]
tests[ , comp_type := ifelse(!is.na(fr_cname), 'fungicide', NA) ] # if FRAC, then fungicide

# checking
na_type = unique(tests[ is.na(comp_type), casnr ])
if (length(na_type) > 0 ) {
  message('For the following cas, compound types are missing:\n',
          paste0(na_type, collapse = ', '))
}

# (3) water solubility ----
tests[ , comp_solu := ifelse(!is.na(pp_solubility_water), pp_solubility_water, NA)]
# TODO add more resources to the solub_wat_fin creation
tests[ , comp_solu_chck := ifelse(ep_value < solub_wat_fin, TRUE, FALSE)] # TODO check: unit of solubility concentrations

# checking
na_solub = unique(tests[ is.na(comp_solu), casnr ])
if (length(na_solub) > 0 ) {
  message('For the following cas, water solubility values are missing:\n',
          paste0(na_solub, collapse = ', '))
}

# (4) habitat column ----
tests[ , isFre_fin := ifelse(ep_habitat == 'Water' | ep_media_type == 'FW' | wo_isfre == 1 | ma_isfre == 1, '1', NA)] # TODO Water probably incl marine (in ep_habitat)
tests[ , isBra_fin := ifelse(wo_isbra == 1, '1', NA)]
tests[ , isMar_fin := ifelse(ep_media_type == 'SW' | wo_ismar == 1 | ma_ismar == 1, '1', NA)]
tests[ , isTer_fin := ifelse(ep_habitat == 'Soil' | wo_ister == 1 | ma_ister == 1, '1', NA)]

# checking
na_habi = unique(tests[ is.na(isFre_fin) & is.na(isBra_fin) & is.na(isMar_fin) & is.na(isTer_fin), taxon ])
if (length(na_habi) > 0 ) {
  message('For the following taxa, habitat entries are missing:\n',
          paste0(na_habi, collapse = ', '))
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

# save --------------------------------------------------------------------
tests_fl = copy(tests)
saveRDS(tests_fl, file.path(cachedir, 'tests_fl.rds'))

# cleaning ----------------------------------------------------------------

# DO IN function
tests_cl = tests_cl[ !ep_subst_type %in% c('F')] # F-Formulation, A-Active Ingredient, T-Total (Heavy metals, & single elements; 56 entries) , U-Un-Ionized (1 entry)
tests_cl = tests_cl[ chck_solub != FALSE ]


# plot --------------------------------------------------------------------
# TODO: DEPR and put into function
clean_stats = tests[ ,
                     .(N_tot = .N,
                       N_subt_type = .SD[ !ep_subst_type %in% c('F'), .N ],
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




