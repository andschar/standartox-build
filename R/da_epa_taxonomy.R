# script to query taxonomic entities from the EPA data to retain meaningfull ecotoxicological groups

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# (1) query ---------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

  taxa = dbGetQuery(con, "SELECT DISTINCT ON (latin_name) *
                          FROM ecotox.species")
  setDT(taxa)
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(taxa, file.path(cachedir, 'source_epa_taxa.rds'))
  
} else {
  
  taxa = readRDS(file.path(cachedir, 'source_epa_taxa.rds'))  
}

# (2) preparation ---------------------------------------------------------
taxa[ , c('subspecies', 'variety', 'species',  'ecotox_group') := NULL ]
tax_names = c('common_name', 'genus', 'family', 'class', 'superclass', 'subphylum_div', 'phylum_division', 'kingdom')
setnames(taxa, old = tax_names, paste0('tax_', tax_names))
setkey(taxa, 'latin_name') # use for merge later
# Species columns
taxa[ , taxon := gsub('\\sx\\s', ' X ', latin_name, ignore.case = TRUE) ] # transform all Hybrid X to capital letters => they aren't seen as species-names in the next REGEX
taxa[ , taxon := trimws(gsub('([A-z]+)\\s([a-z]+\\s)(.+)*', '\\1 \\2', taxon)) ]
taxa[ , taxon := trimws(gsub('sp.', '', taxon)) ] # remove sp.

# (3) errata --------------------------------------------------------------
taxa[ tax_phylum_division == 'Cyanophycota', tax_phylum_division := 'Cyanobacteria' ]
taxa[ tax_phylum_division == 'Rhodophycota', tax_phylum_division := 'Rhodophyta' ]

# as the taxonomic classification such as phylum and dividin is subject to changes a convenient variable is introduced
taxa[ tax_phylum_division == 'Pyrrophycophyta', tax_phylum := 'Dinoflagellata' ]


# (4) classification ------------------------------------------------------
# convenience grouping ----------------------------------------------------
taxa[ tax_superclass == 'Osteichthyes', tax_convgroup := 'Fish' ]
taxa[ , tax_convgroup := ifelse(tax_kingdom == 'Plantae', 'Plants', NA) ]
taxa[ , tax_convgroup := ifelse(tax_kingdom == 'Plantae', 'Plants', NA) ]
taxa[ tax_phylum_division == 'Oomycota', tax_convgroup := 'Pseudofungi'] # colorless heterokonts (pseudofungi, bigyra) https://en.wikipedia.org/wiki/Heterokont
taxa[ tax_phylum_division == 'Cyanophycota', tax_convgroup := 'Nematoda']
taxa[ tax_phylum_division == 'Nemata', tax_convgroup := 'Nematoda']
algae = c('Chlorophyta', 'Bacillariophyta', 'Cyanobacteria', 'Rhodophyta', 'Phaeophyta', 'Charophyta', 'Chrysophyta', 'Haptophyta', 'Xanthophyta', 'Cryptophycophyta', 'Prasinophyta', 'Ochrophyta')
taxa[ tax_phylum_division %in% algae, tax_convgroup := 'Algae']
taxa[ tax_phylum == 'Dinoflagellata', tax_convgroup := 'Algae' ] # however they are mixotrophic

# impairments:
# Sarcomastigophora - can also be autotroph - here: Animalia
# Euglenophycota - troph is not clear - here: Plantae

# troph_lvl ---------------------------------------------------------------
taxa[ tax_convgroup %in% c('Algae', 'Plants'), tax_autotroph := 1 ]
taxa[ tax_phylum == 'Dinoflagellata', tax_mixotroph := 1 ]
taxa[ is.na(tax_autotroph) & is.na(tax_mixotroph), tax_heterotroph := 1 ]

# Makro and Mikro Invertebrates -------------------------------------------
cols = grep('tax_', names(taxa), ignore.case = TRUE, value = TRUE)
#### out-commented for now -> maybe this column will again be needed
# freshwater_info_inv = c('Porifera',	'Coelenterata',	'Turbellaria',	'Nematomorpha', 'Nemertini',	'Gastropoda',	'Bivalvia',	'Polychaeta', 'Oligochaeta',	'Hirudinea',	'Branchiobdellida',	'Araneae', 'Hydrachnidia',	'Crustacea',	'Ephemeroptera',	'Odonata', 'Plecoptera',	'Heteroptera',	'Megaloptera',	'Planipennia', 'Coleoptera',	'Hymenoptera',	'Trichoptera', 'Lepidoptera', 'Diptera',	'Chironomidae',	'Bryozoa')
# taxa[axa[ , Reduce(`|`, lapply(.SD, `%like%`,
#                               paste0('(?i)', freshwater_info_inv, collapse = '|'))),
#          .SDcols = cols], tax_aqu_inv := 'yes' ]
### END
## Invertebrat variables
inv_makro_phylum = c('Annelida', 'Echinodermata', 'Mollusca', 'Nemertea', 'Platyhelminthes', 'Porifera')
inv_mikro_phylum = c('Bryozoa', 'Chaetognatha', 'Ciliophora', 'Cnidaria', 'Gastrotricha', 'Nematoda', 'Rotifera')
inv_makro_subphylum = c('Crustacea')
inv_makro_class = c('Arachnida', 'Diplopoda', 'Entognatha', 'Insecta') # phylum: Arthropoda
invertebrates_makro = c(inv_makro_phylum, inv_makro_subphylum, inv_makro_class)
invertebrates_mikro = inv_mikro_phylum
## Makro Invertebrates
taxa[taxa[ , Reduce(`|`, lapply(.SD, `%like%`,
                                paste0('(?i)', invertebrates_makro, collapse = '|'))),
           .SDcols = cols ], tax_invertebrate_makro := 1 ]
## Mikro Invertebrates
taxa[taxa[ , Reduce(`|`, lapply(.SD, `%like%`,
                                paste0('(?i)', invertebrates_mikro, collapse = '|'))),
           .SDcols = cols ], tax_invertebrate_mikro := 1 ]

# Ecotox group ------------------------------------------------------------
# column for convenient ecotox grouping
# sometimes redundant!
# assign first the big groups, then smaller ones
taxa[ tax_phylum_division %in% c('Ascomycota', 'Basidiomycota'),
     tax_ecotox_grp := 'Fungi' ]
taxa[ tax_class == 'Insecta',
     tax_ecotox_grp := 'Insects' ]
taxa[ tax_class == 'Entognatha',
     tax_ecotox_grp := 'Entognatha' ]
taxa[ tax_class == 'Arachnida',
     tax_ecotox_grp := 'Arachnida' ]
taxa[ tax_class %in% c('Bryopsida', 'Magnoliopsida', 'Liliopsida', 'Pinopsida'),
     tax_ecotox_grp := 'Plants' ]
taxa[ tax_superclass == 'Osteichthyes',
     tax_ecotox_grp := 'Fish' ]
taxa[ tax_convgroup == 'Algae',
     tax_ecotox_grp := 'Algae' ]
taxa[ tax_phylum_division == 'Cyanobacteria',
     tax_ecotox_grp := 'Cyanobacteria' ]
taxa[ tax_class == 'Aves',
     tax_ecotox_grp := 'Birds' ]
taxa[ tax_class == 'Amphibia',
     tax_ecotox_grp := 'Amphibia' ]
taxa[ tax_phylum_division == 'Annelida',
     tax_ecotox_grp := 'Annelida' ]
taxa[ tax_phylum_division == 'Echinodermata',
     tax_ecotox_grp := 'Echinodermata' ]
taxa[ tax_class == 'Mammalia',
     tax_ecotox_grp := 'Mammalia' ]
taxa[ tax_class == 'Reptilia',
     tax_ecotox_grp := 'Reptilia' ]
taxa[ tax_phylum_division == 'Mollusca',
     tax_ecotox_grp := 'Mollusca' ]
taxa[ tax_convgroup == 'Nematoda',
     tax_ecotox_grp := 'Nematoda' ]
taxa[ tax_phylum_division == 'Protozoa',
     tax_ecotox_grp := 'Protozoa' ]
taxa[ tax_phylum_division == 'Rotifera',
     tax_ecotox_grp := 'Rotifera' ]
taxa[ tax_genus == 'Daphnia',
     tax_ecotox_grp := 'Daphnia' ]
taxa[ tax_genus %in% c('Lemna', 'Myriophyllum'),
     tax_ecotox_grp := 'Makrophytes' ]
taxa[ tax_genus != 'Daphnia' & tax_subphylum_div == 'Crustacea',
     tax_ecotox_grp := 'Crustacea' ]
taxa[ tax_family == 'Chironomidae',
     tax_ecotox_grp := 'Chrionomidae' ]
taxa[ tax_class == 'Anthozoa',
      tax_ecotox_grp := 'Anthozoa' ]
taxa[ tax_class == 'Ciliatea',
      tax_ecotox_grp := 'Ciliatea' ]
taxa[ tax_class == 'Filicopsida',
      tax_ecotox_grp := 'Filicopsida' ]
taxa[ tax_class == 'Oomycetes',
      tax_ecotox_grp := 'Oomycetes' ]

# TODO
# sediment dwellers
# worms sind eigentlich Annelida
# aquatic invertebrates is hard to determine

# writing -----------------------------------------------------------------
saveRDS(taxa, file.path(cachedir, 'epa_taxa.rds'))

# missing -----------------------------------------------------------------
# missing (mostly because they were only identified to a certain level)
# sapply(taxa, function(x) length(which(x == '')))
# sapply(taxa, function(x) length(which(is.na(x))))

# log ---------------------------------------------------------------------
msg = 'EPA1: taxonomic cleaning script run'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()






# TODO --------------------------------------------------------------------


# 
# source('R/qu_habitat_self_defined.R')
# lookup_man_fam[ , .N, supgroup]
# 
# test = lookup_man_fam$supgroup
# test = freshwater_info_inv
# test_l = list()
# for (i in test) {
#   dt = taxa[axa[ , Reduce(`|`, lapply(.SD, `%like%`, paste0('(?i)', i))), .SDcols = cols]] # , ..cols  
#   test_l[[i]] = dt
# 
# }
# 
# # check if taxa could not be found
# which(sapply(test_l, nrow) <= 10)
# 
# taxon_input = 'invertebrate'
# 
# cols = grep('tax_', names(taxa), ignore.case = TRUE, value = TRUE)
# taxa[axa[ , Reduce(`|`, lapply(.SD, `%like%`, paste0('(?i)', taxon_input))), .SDcols = cols]]
# 
# dt[dt[, Reduce(`|`, lapply(.SD, `==`, 4)),.SDcols = sel.col], ..sel.col]
# 
# 
# grep('mollusca', names(taxa), ignore.case = TRUE, value = TRUE)
# 
# 

# # trophic level
# autotrophs = c('Plants', 'Algae', 'Bryophyta')
# tests[ , trophic_lvl := ifelse(ma_supgroup2 %in% autotrophs, 'autotrophic', 'heterotrophic') ]
# 
# 
# 
# sort(names(taxa))

# TODO final table should include
# errata
# latin_name
# common_name
# ecotox groups
# ignore subspecies and variety
# maybe do latin_BIname also here?
# create mikro and makroinvertebrate column

# taxa[ , .N, kingdom][order(-N)]
# taxa[ kingdom == 'Community' | kingdom == '' ]
# taxa[ , .N, ecotox_group][order(-N)]
# names(taxa[ , .SD, .SDcols =! c('subspecies', 'variety') ])




# final columns -----------------------------------------------------------



# sort(names(taxa))
# 

# 
# # errata ------------------------------------------------------------------
# # missing taxonomic classes
# taxa[atin_name == 'Photinus pyralis']


# errata ------------------------------------------------------------------
# not accepted (anymore):
# epa1[family == 'Aphidiidae', family := 'Braconidae']
# epa1[family == 'Callitrichaceae', family := 'Plantaginaceae']
# epa1[family == 'Cypridopsidae', family := 'Cypridopsinae']
# epa1[family == 'Filiniidae', family := 'Trochosphaeridae']
# epa1[family == 'Najadaceae', family := 'Hydrocharitaceae']
# epa1[family == 'Platymonadaceae', family := 'Volvocaceae']
# epa1[family == 'Pseudocalanidae', family := 'Clausocalanidae']
# epa1[family == 'Heligmosomatidae', family := 'Trychostrongylidae']
# epa1[family == 'Lymantriidae', family := 'Erebidae']
# 
# # spelling:
# epa1[family == 'Diplostomatidae', family := 'Diplostomidae']
# epa1[family == 'Haliotididae', family := 'Haliotidae']
# 
# # wrong classification:
# epa1[family == 'Tetracneminae', family := 'Encyrtidae'] # is sub-family
# 
# # no family entry:
# epa1[taxon == 'Storeatula major', family := 'Pyrenomonadaceae' ]
# epa1[taxon == 'Pochonia chlamydosporia', family := 'Clavicipitaceae' ]
# epa1[taxon == 'Triaenophorus nodulosus', family := 'Triaenophoridae' ]
# epa1[taxon == 'Bryconamericus iheringii', family := 'Characidae' ]
# epa1[taxon == 'Coenochloris sp.', family := 'Radiococcaceae' ]
# epa1[taxon == 'Girardia tigrina', family := 'Dugesiidae' ]
# epa1[taxon == 'Cenococcum geophilum', family := 'Gloniaceae' ]
# epa1[taxon == 'Acineria uncinata', family := 'Litonotidae' ]



# 
# # old approach ------------------------------------------------------------
