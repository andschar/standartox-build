# script to query taxonomic entities from the EPA data to retain meaningfull ecotoxicological groups

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
## EPA
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

## lookup
look_taxgrp = fread(file.path(lookupdir, 'lookup_ecotox_habitat_group.csv'))

# preparation -------------------------------------------------------------
# set all "" to NA
for (i in names(taxa)) {
  taxa[get(i) == "", (i) := NA]
}

taxa[ , c('subspecies', 'variety', 'ecotox_group') := NULL ]
# Species columns
taxa[ , taxon := gsub('\\sx\\s', ' X ', latin_name, ignore.case = TRUE) ] # transform all Hybrid X to capital letters => they aren't seen as species-names in the next REGEX
taxa[ , taxon := trimws(gsub('([A-z]+)\\s([a-z]+\\s)(.+)*', '\\1 \\2', taxon)) ]
taxa[ , taxon := trimws(gsub('sp.', '', taxon)) ] # remove sp.

# errata ------------------------------------------------------------------
taxa[ phylum_division == 'Cyanophycota', phylum_division := 'Cyanobacteria' ]
taxa[ phylum_division == 'Rhodophycota', phylum_division := 'Rhodophyta' ]

# Ecotox group ------------------------------------------------------------
# column for convenient ecotox grouping
# assign first the big groups, then smaller ones
## Fungi
taxa[ phylum_division %in% 
        c('Ascomycota', 'Ascomycetes', 'Basidiomycota', 'Chytridiomycota',
          'Deuteromycotina', 'Glomeromycota', 'Myxomycota', 'Zygomycota'),
      ecotox_grp := 'Fungi' ]
taxa[ kingdom == 'Fungi',
      ecotox_grp := 'Fungi' ]
taxa[ phylum_division %in%
        c('Bacillariophyta', 'Charophyta', 'Chlorophyta', 'Chrysophyta', 
          'Cryptophycophyta', 'Cyanophycota', 'Euglenophycota',
          'Haptophyta', 'Ochrophyta', 'Phaeophyta', 'Prasinophyta', 'Pyrrophycophyta', 
          'Xanthophyta'),
      ecotox_grp := 'Algae' ]
taxa[ class == 'Insecta',
      ecotox_grp := 'Insecta' ]
taxa[ class == 'Entognatha',
      ecotox_grp := 'Entognatha' ]
taxa[ class == 'Arachnida',
      ecotox_grp := 'Arachnida' ]
taxa[ class %in% c('Bryopsida', 'Magnoliopsida', 'Liliopsida', 'Pinopsida'),
      ecotox_grp := 'Plantae' ]
taxa[ kingdom == 'Plantae',
      ecotox_grp := 'Plantae' ]
taxa[ superclass %in% c('Agnatha', 'Osteichthyes'),
      ecotox_grp := 'Fish' ]
taxa[ phylum_division == 'Cyanobacteria',
      ecotox_grp := 'Cyanobacteria' ]
taxa[ class == 'Aves',
      ecotox_grp := 'Aves' ]
taxa[ class == 'Amphibia',
      ecotox_grp := 'Amphibia' ]
taxa[ phylum_division %in% c('Annelida', 'Echiura'),
      ecotox_grp := 'Annelida' ]
taxa[ phylum_division == 'Echinodermata',
      ecotox_grp := 'Echinodermata' ]
taxa[ class == 'Mammalia',
      ecotox_grp := 'Mammalia' ]
taxa[ class == 'Reptilia',
      ecotox_grp := 'Reptilia' ]
taxa[ phylum_division == 'Mollusca',
      ecotox_grp := 'Mollusca' ]
taxa[ phylum_division == 'Nemata',
      ecotox_grp := 'Nematoda' ]
taxa[ phylum_division == 'Protozoa',
      ecotox_grp := 'Protozoa' ]
taxa[ phylum_division == 'Rotifera',
      ecotox_grp := 'Rotifera' ]
taxa[ genus %in% c('Lemna', 'Myriophyllum'),
      ecotox_grp := 'Makrophytes' ]
# Crustacea
taxa[ subphylum_div == 'Crustacea',
      ecotox_grp := 'Crustacea' ]
taxa[ genus == 'Daphnia',
      ecotox_grp := 'Daphnia' ]
taxa[ family == 'Chironomidae',
      ecotox_grp := 'Chrionomidae' ]
# Nesseltiere (viel im Meer, auch Süßwasser - Süßwasserpolyp)
taxa[ phylum_division == 'Cnidaria',
      ecotox_grp := 'Cnidaria' ]
# Plattwürmer
taxa[ phylum_division == 'Platyhelminthes',
      ecotox_grp := 'Platyhelminthes' ]
# Blumentiere (nur im Meer)
taxa[ class == 'Anthozoa',
      ecotox_grp := 'Anthozoa' ]
taxa[ phylum_division == 'Ciliophora',
      ecotox_grp := 'Ciliophora' ]
taxa[ class == 'Filicopsida',
      ecotox_grp := 'Filicopsida' ]
taxa[ class == 'Oomycetes',
      ecotox_grp := 'Oomycetes' ]
taxa[ phylum_division == 'Myzozoa',
      ecotox_grp := 'Myzozoa' ]
taxa[ phylum_division == 'Apicomplexa',
      ecotox_grp := 'Apicomplexa' ]
taxa[ phylum_division == 'Sarcomastigophora',
      ecotox_grp := 'Sarcomastigophora' ]
taxa[ phylum_division == 'Platyhelminthes',
      ecotox_grp := 'Platyhelminthes' ]
taxa[ phylum_division == 'Bryozoa',
      ecotox_grp := 'Bryozoa' ]
taxa[ phylum_division == 'Porifera',
      ecotox_grp := 'Porifera' ]
taxa[ phylum_division == 'Nemertea',
      ecotox_grp := 'Nemertea' ]
taxa[ subphylum_div == 'Tunicata',
      ecotox_grp := 'Tunicata' ]
taxa[ subphylum_div == 'Myriapoda',
      ecotox_grp := 'Myriapoda' ]
taxa[ phylum_division == 'Chaetognatha',
      ecotox_grp := 'Chaetognatha' ] # Pfeilwürmer
taxa[ phylum_division == 'Sipuncula',
      ecotox_grp := 'Sipuncula' ] # Spritzwürmer
taxa[ phylum_division == 'Nematomorpha',
      ecotox_grp := 'Nematomorpha' ] # Saitenwürmer
taxa[ phylum_division == 'Acanthocephala',
      ecotox_grp := 'Acanthocephala' ] # Kratzwürmer
taxa[ phylum_division == 'Ectoprocta',
      ecotox_grp := 'Ectoprocta' ] # Moostierchen
taxa[ phylum_division == 'Gastrotricha',
      ecotox_grp := 'Gastrotricha' ] # Bauchhärlinge
taxa[ phylum_division == 'Ctenophora',
      ecotox_grp := 'Ctenophora' ] # Rippenquallen
taxa[ phylum_division == 'Tardigrada',
      ecotox_grp := 'Tardigrada' ] # Bärtierchen
taxa[ phylum_division == 'Gnathostomulida',
      ecotox_grp := 'Gnathostomulida' ] # Kiefermündchen
taxa[ phylum_division == 'Gnathostomulida',
      ecotox_grp := 'Brachiopoda' ] # Kiefermündchen

# troph_lvl ---------------------------------------------------------------
taxa[ ecotox_grp %in% c('Algae', 'Plants'), autotroph := 1L ]
taxa[ class == 'Dinophyceae', mixotroph := 1L ]
taxa[ is.na(autotroph) & is.na(mixotroph), heterotroph := 1L ]

# Aquatic Makro and Mikro Invertebrates ------------------------------------
cols = grep('tax_', names(taxa), ignore.case = TRUE, value = TRUE)
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
           .SDcols = cols ], tax_invertebrate_makro := 1L ]
## Mikro Invertebrates
taxa[taxa[ , Reduce(`|`, lapply(.SD, `%like%`,
                                paste0('(?i)', invertebrates_mikro, collapse = '|'))),
           .SDcols = cols ], tax_invertebrate_mikro := 1L ]

# caveats -----------------------------------------------------------------
# Sarcomastigophora - can also be autotroph - here: Animalia
# Euglenophycota - troph is not clear - here: Plantae
# sediment dwellers
# worms sind eigentlich Annelida
# aquatic invertebrates is hard to determine

# writing -----------------------------------------------------------------
tax_names = c('common_name', 'species', 'genus', 'family', 'class', 'superclass', 'subphylum_div', 'phylum_division', 'kingdom', 'ecotox_grp')
setnames(taxa, old = tax_names, paste0('tax_', tax_names))
tax_ord = c('taxon', 'latin_name', 'tax_common_name', 'species_number', 'tax_species', 'tax_genus',
            'tax_family', 'tax_order', 'tax_class', 'tax_superclass', 'tax_subphylum_div', 'tax_phylum_division',
            'tax_kingdom', 'tax_ecotox_grp', 'autotroph', 'mixotroph', 'heterotroph', 'tax_invertebrate_makro',
            'tax_invertebrate_mikro')
setcolorder(taxa, tax_ord)

saveRDS(taxa, file.path(cachedir, 'epa_taxa.rds'))

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
