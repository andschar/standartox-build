# script to query taxonomic entities from the EPA data to retain meaningfull ecotoxicological groups

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data base
DBetox = readRDS(file.path(cachedir, 'data_base_name_version.rds'))

# (1) query ---------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)

  tax = dbGetQuery(con, "SELECT DISTINCT ON (latin_name) *
                         FROM ecotox.species")
  setDT(tax)
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  saveRDS(tax, file.path(cachedir, 'source_epa_taxa.rds'))
  
} else {
  
  tax = readRDS(file.path(cachedir, 'source_epa_taxa.rds'))  
}

# (2) preparation ---------------------------------------------------------
tax[ , c('subspecies', 'variety', 'species',  'ecotox_group') := NULL ]
tax_names = c('common_name', 'genus', 'family', 'class', 'superclass', 'subphylum_div', 'phylum_division', 'kingdom')
setnames(tax, old = tax_names, paste0('tax_', tax_names))
setkey(tax, 'latin_name') # use for merge later
# Species columns
tax[ , taxon := gsub('\\sx\\s', ' X ', latin_name, ignore.case = TRUE) ] # transform all Hybrid X to capital letters => they aren't seen as species-names in the next REGEX
tax[ , taxon := trimws(gsub('([A-z]+)\\s([a-z]+\\s)(.+)*', '\\1 \\2', taxon)) ]
tax[ , taxon := trimws(gsub('sp.', '', taxon)) ] # remove sp.

# cleaning
rm(tax_names)

# (3) errata --------------------------------------------------------------
tax[ tax_phylum_division == 'Cyanophycota', tax_phylum_division := 'Cyanobacteria' ]
tax[ tax_phylum_division == 'Rhodophycota', tax_phylum_division := 'Rhodophyta' ]

# as the taxonomic classification such as phylum and dividin is subject to changes a convenient variable is introduced
tax[ tax_phylum_division == 'Pyrrophycophyta', tax_phylum := 'Dinoflagellata' ]


# (4) classification ------------------------------------------------------
# convenience grouping ----------------------------------------------------
tax[ tax_superclass == 'Osteichthyes', tax_convgroup := 'Fish' ]
tax[ , tax_convgroup := ifelse(tax_kingdom == 'Plantae', 'Plants', NA) ]
tax[ , tax_convgroup := ifelse(tax_kingdom == 'Plantae', 'Plants', NA) ]
tax[ tax_phylum_division == 'Oomycota', tax_convgroup := 'Pseudofungi'] # colorless heterokonts (pseudofungi, bigyra) https://en.wikipedia.org/wiki/Heterokont
tax[ tax_phylum_division == 'Cyanophycota', tax_convgroup := 'Nematoda']
tax[ tax_phylum_division == 'Nemata', tax_convgroup := 'Nematoda']
algae = c('Chlorophyta', 'Bacillariophyta', 'Cyanobacteria', 'Rhodophyta', 'Phaeophyta', 'Charophyta', 'Chrysophyta', 'Haptophyta', 'Xanthophyta', 'Cryptophycophyta', 'Prasinophyta', 'Ochrophyta')
tax[ tax_phylum_division %in% algae, tax_convgroup := 'Algae']
tax[ tax_phylum == 'Dinoflagellata', tax_convgroup := 'Algae' ] # however they are mixotrophic

# impairments:
# Sarcomastigophora - can also be autotroph - here: Animalia
# Euglenophycota - troph is not clear - here: Plantae

# cleaning
rm(algae)

# troph_lvl ---------------------------------------------------------------
tax[ , tax_troph_lvl := 'heterotroph' ]
tax[ tax_convgroup %in% c('Algae', 'Plants'), tax_troph_lvl := 'autotroph' ]
tax[ tax_phylum == 'Dinoflagellata', tax_troph_lvl := 'mixotroph' ]


# Makro and Mikro Invertebrates -------------------------------------------
cols = grep('tax_', names(tax), ignore.case = TRUE, value = TRUE)
#### out-commented for now -> maybe this column will again be needed
# freshwater_info_inv = c('Porifera',	'Coelenterata',	'Turbellaria',	'Nematomorpha', 'Nemertini',	'Gastropoda',	'Bivalvia',	'Polychaeta', 'Oligochaeta',	'Hirudinea',	'Branchiobdellida',	'Araneae', 'Hydrachnidia',	'Crustacea',	'Ephemeroptera',	'Odonata', 'Plecoptera',	'Heteroptera',	'Megaloptera',	'Planipennia', 'Coleoptera',	'Hymenoptera',	'Trichoptera', 'Lepidoptera', 'Diptera',	'Chironomidae',	'Bryozoa')
# tax[tax[ , Reduce(`|`, lapply(.SD, `%like%`,
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
tax[tax[ , Reduce(`|`, lapply(.SD, `%like%`,
                              paste0('(?i)', invertebrates_makro, collapse = '|'))),
         .SDcols = cols ], tax_invertebrate := 'Makro Invertebrates' ]
## Mikro Invertebrates
tax[tax[ , Reduce(`|`, lapply(.SD, `%like%`,
                              paste0('(?i)', invertebrates_mikro, collapse = '|'))),
         .SDcols = cols ], tax_invertebrate := 'Mikro Invertebrates' ]

# Ecotox group ------------------------------------------------------------
# column for convenient ecotox grouping
# sometimes redundant!
# assign first the big groups, then smaller ones
tax[ tax_phylum_division %in% c('Ascomycota', 'Basidiomycota'),
     tax_ecotox_grp := 'Fungi' ]
tax[ tax_class == 'Insecta',
     tax_ecotox_grp := 'Insects' ]
tax[ tax_class == 'Entognatha',
     tax_ecotox_grp := 'Entognatha' ]
tax[ tax_class == 'Arachnida',
     tax_ecotox_grp := 'Arachnida' ]
tax[ tax_class %in% c('Magnoliopsida', 'Liliopsida', 'Bryopsida'),
     tax_ecotox_grp := 'Plants' ]
tax[ tax_superclass == 'Osteichthyes',
     tax_ecotox_grp := 'Fish' ]
tax[ tax_convgroup == 'Algae',
     tax_ecotox_grp := 'Algae' ]
tax[ tax_phylum_division == 'Cyanobacteria',
     tax_ecotox_grp := 'Cyanobacteria' ]
tax[ tax_class == 'Aves',
     tax_ecotox_grp := 'Birds' ]
tax[ tax_class == 'Amphibia',
     tax_ecotox_grp := 'Amphibia' ]
tax[ tax_phylum_division == 'Annelida',
     tax_ecotox_grp := 'Annelida' ]
tax[ tax_phylum_division == 'Echinodermata',
     tax_ecotox_grp := 'Echinodermata' ]
tax[ tax_class == 'Mammalia',
     tax_ecotox_grp := 'Mammalia' ]
tax[ tax_class == 'Reptilia',
     tax_ecotox_grp := 'Reptilia' ]
tax[ tax_phylum_division == 'Mollusca',
     tax_ecotox_grp := 'Mollusca' ]
tax[ tax_convgroup == 'Nematoda',
     tax_ecotox_grp := 'Nematoda' ]
tax[ tax_phylum_division == 'Protozoa',
     tax_ecotox_grp := 'Protozoa' ]
tax[ tax_phylum_division == 'Rotifera',
     tax_ecotox_grp := 'Rotifera' ]
tax[ tax_genus == 'Daphnia',
     tax_ecotox_grp := 'Daphnia' ]
tax[ tax_genus %in% c('Lemna', 'Myriophyllum'),
     tax_ecotox_grp := 'Makrophytes' ]
tax[ tax_genus != 'Daphnia' & tax_subphylum_div == 'Crustacea',
     tax_ecotox_grp := 'Crustacea' ]
tax[ tax_family == 'Chironomidae',
     tax_ecotox_grp := 'Chrionomidae' ]
# TODO
# sediment dwellers
# worms sind eigentlich Annelida
# aquatic invertebrates is hard to determine

# cleaning ----------------------------------------------------------------
rm(inv_makro_phylum, inv_mikro_phylum, inv_makro_subphylum, inv_makro_class,
   invertebrates_makro, invertebrates_mikro)

# TODO --------------------------------------------------------------------


# 
# source('R/qu_habitat_self_defined.R')
# lookup_man_fam[ , .N, supgroup]
# 
# test = lookup_man_fam$supgroup
# test = freshwater_info_inv
# test_l = list()
# for (i in test) {
#   dt = tax[tax[ , Reduce(`|`, lapply(.SD, `%like%`, paste0('(?i)', i))), .SDcols = cols]] # , ..cols  
#   test_l[[i]] = dt
# 
# }
# 
# # check if taxa could not be found
# which(sapply(test_l, nrow) <= 10)
# 
# taxon_input = 'invertebrate'
# 
# cols = grep('tax_', names(tax), ignore.case = TRUE, value = TRUE)
# tax[tax[ , Reduce(`|`, lapply(.SD, `%like%`, paste0('(?i)', taxon_input))), .SDcols = cols]]
# 
# dt[dt[, Reduce(`|`, lapply(.SD, `==`, 4)),.SDcols = sel.col], ..sel.col]
# 
# 
# grep('mollusca', names(tax), ignore.case = TRUE, value = TRUE)
# 
# 

# # trophic level
# autotrophs = c('Plants', 'Algae', 'Bryophyta')
# tests[ , trophic_lvl := ifelse(ma_supgroup2 %in% autotrophs, 'autotrophic', 'heterotrophic') ]
# 
# 
# 
# sort(names(tax))

# TODO final table should include
# errata
# latin_name
# common_name
# ecotox groups
# ignore subspecies and variety
# maybe do latin_BIname also here?
# create mikro and makroinvertebrate column

# tax[ , .N, kingdom][order(-N)]
# tax[ kingdom == 'Community' | kingdom == '' ]
# tax[ , .N, ecotox_group][order(-N)]
# names(tax[ , .SD, .SDcols =! c('subspecies', 'variety') ])




# final columns -----------------------------------------------------------



# sort(names(tax))
# 

# 
# # errata ------------------------------------------------------------------
# # missing taxonomic classes
# tax[latin_name == 'Photinus pyralis']


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
