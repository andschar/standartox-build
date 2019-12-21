# script for convenience ecotoxicological taxa grouping

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
tax = readRDS(file.path(cachedir, 'source_epa_taxa.rds'))

# errata ------------------------------------------------------------------
tax[ phylum_division == 'Cyanophycota', phylum_division := 'Cyanobacteria' ]
tax[ phylum_division == 'Rhodophycota', phylum_division := 'Rhodophyta' ]

# algae -------------------------------------------------------------------
tax[ phylum_division == 'Chlorophyta', `:=` (algae = 1L, autotroph = 1L, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Bacillariophyta', `:=` (algae = 1L, autotroph = 1L, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Cyanobacteria', `:=` (algae = 1L, autotroph = 1L, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Rhodophyta', `:=` (algae = 1L, autotroph = 1L, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Phaeophyta', `:=` (algae = 1L, autotroph = 1L, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Charophyta', `:=` (algae = 1L, autotroph = 1L, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Chrysophyta', `:=` (algae = 1L, autotroph = 1L, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Haptophyta', `:=` (algae = 1L, autotroph = 1L, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Xanthophyta', `:=` (algae = 1L, autotroph = 1L, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Cryptophycophyta', `:=` (algae = 1L, autotroph = 1L, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Prasinophyta', `:=` (algae = 1L, autotroph = 1L, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Ochrophyta', `:=` (algae = 1L, autotroph = 1L, ecotox_group2 = 'Algae') ]
tax[ class == 'Dinophyceae', `:=` (algae = 1L, autotroph = 1L, mixotroph = 1L, ecotox_group2 = 'Algae') ]
tax[ class == 'Chloromonadophyceae', `:=` (algae = 1L, autotroph = 1L, mixotroph = 1L, ecotox_group2 = 'Algae') ]

# plants ------------------------------------------------------------------
tax[ kingdom == 'Plantae', `:=` (plants = 1L, autotroph = 1L, ecotox_group2 = 'Plantae') ]

# mollusca ----------------------------------------------------------------
tax[ phylum_division == 'Annelida', `:=` (annelida = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Annelida') ]

# Brachiopoda -------------------------------------------------------------
tax[ phylum_division == 'Brachiopoda', `:=` (brachiopoda = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Brachiopoda') ]

# mollusca ----------------------------------------------------------------
tax[ phylum_division == 'Mollusca', `:=` (mollusca = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Mollusca') ]

# nemertea ----------------------------------------------------------------
tax[ phylum_division == 'Nemertea', `:=` (nemertea = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Nemertea') ]

# platyhelminthes ---------------------------------------------------------
tax[ phylum_division == 'Platyhelminthes', `:=` (nemertea = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Platyhelminthes') ]

# nematoda ----------------------------------------------------------------
tax[ phylum_division == 'Nematoda', `:=` (nematoda = 1L, heterotroph = 1L, invertebrates_mikro = 1L, ecotox_group2 = 'Nematoda') ]
tax[ phylum_division == 'Nemata', `:=` (nematoda = 1L, heterotroph = 1L, invertebrates_mikro = 1L, ecotox_group2 = 'Nematoda') ]
tax[ class == 'Secernentea', `:=` (nematoda = 1L, heterotroph = 1L, invertebrates_mikro = 1L, ecotox_group2 = 'Nematoda') ]
tax[ class == 'Adenophorea', `:=` (nematoda = 1L, heterotroph = 1L, invertebrates_mikro = 1L, ecotox_group2 = 'Nematoda') ]

# bryozoa -----------------------------------------------------------------
tax[ phylum_division == 'Bryozoa', `:=` (bryozoa = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Bryozoa') ]
tax[ phylum_division == 'Ectoprocta', `:=` (bryozoa = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Bryozoa') ]
tax[ class == 'Phylactolaemata', `:=` (bryozoa = 1L, heterotroph = 1L, invertebrates_mikro = 1L, freshwater = 1L, ecotox_group2 = 'Bryozoa') ]

# Kamptozoa ---------------------------------------------------------------
tax[ phylum_division == 'Kamptozoa', `:=` (kamptozoa = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Kamptozoa') ]

# Cercozoa ----------------------------------------------------------------
tax[ phylum_division == 'Cercozoa', `:=` (cercozoa = 1L, heterotroph = 1L, invertebrates_mikro = 1L, ecotox_group2 = 'Cercozoa') ]
tax[ class == 'Phytomyxea', `:=` (cercozoa = 1L, heterotroph = 1L, invertebrates_mikro = 1L, parasites = 1L, ecotox_group2 = 'Cercozoa') ]

# chaetognatha ------------------------------------------------------------
tax[ phylum_division == 'Chaetognatha', `:=` (chaetognatha = 1L, heterotroph = 1L, invertebrates_mikro = 1L, ecotox_group2 = 'Chaetognatha') ]

# ciliophora --------------------------------------------------------------
tax[ phylum_division == 'Ciliophora', `:=` (ciliophora = 1L, heterotroph = 1L, invertebrates_mikro = 1L, ecotox_group2 = 'Ciliophora') ]

# gastrotricha ------------------------------------------------------------
tax[ phylum_division == 'Gastrotricha', `:=` (gastrotricha = 1L, heterotroph = 1L, invertebrates_mikro = 1L, ecotox_group2 = 'Gastrotricha') ]

# rotifera ----------------------------------------------------------------
tax[ phylum_division == 'Rotifera', `:=` (rotifera = 1L, heterotroph = 1L, invertebrates_mikro = 1L, ecotox_group2 = 'Rotifera') ]

# cnidaria ----------------------------------------------------------------
tax[ phylum_division == 'Cnidaria', `:=` (cnidaria = 1L, heterotroph = 1L, invertebrates_mikro = 1L, ecotox_group2 = 'Cnidaria') ]
tax[ class == 'Myxosporea', `:=` (cnidaria = 1L, heterotroph = 1L, invertebrates_mikro = 1L, parasites = 1L, ecotox_group2 = 'Cnidaria') ]

# Nematomorpha ------------------------------------------------------------
tax[ phylum_division == 'Nematomorpha', `:=` (nematomorpha = 1L, heterotroph = 1L, invertebrates_mikro = 1L, ecotox_group2 = 'Nematomorpha') ]

# echinodermata -----------------------------------------------------------
tax[ phylum_division == 'Echinodermata', `:=` (echinodermata = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Echinodermata') ]

# porifera ----------------------------------------------------------------
tax[ phylum_division == 'Porifera', `:=` (porifera = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Porifera') ]

# mollusca ----------------------------------------------------------------
tax[ phylum_division == 'Mollusca', `:=` (mollusca = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Mollusca') ]

# crustacea ---------------------------------------------------------------
tax[ subphylum_div == 'Crustacea', `:=` (crustacea = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Crustacea') ]

# arachnida ---------------------------------------------------------------
tax[ subphylum_div == 'Myriapoda', `:=` (myriapoda = 1L, heterotroph = 1L, invertebrates_makro = 1L, terrestrial = 1L, ecotox_group2 = 'Myriapoda') ]
tax[ class == 'Merostomata', `:=` (xiphosura = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Xiphosura') ]
tax[ class == 'Arachnida', `:=` (arachnida = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Arachnida') ]
tax[ tax_order == 'Araneae', `:=` (araneae = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Araneae') ]

# Priapulida --------------------------------------------------------------
tax[ class == 'Priapulida', `:=` (priapulida = 1L, heterotroph = 1L, marine = 1L, ecotox_group2 = 'Priapulida') ] # penis worms

# Sipuncula ---------------------------------------------------------------
tax[ class == 'Sipunculidea', `:=` (sipuncula = 1L, heterotroph = 1L, invertebrates_mikro = 1L, marine = 1L, ecotox_group2 = 'Sipuncula') ]

# diplopoda ---------------------------------------------------------------
tax[ class == 'Diplopoda', `:=` (diplopoda = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Diplopoda') ]

# entognatha---------------------------------------------------------------
tax[ class == 'Entognatha', `:=` (entognatha = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Entognatha') ]

# insecta -----------------------------------------------------------------
tax[ class == 'Insecta', `:=` (insecta = 1L, heterotroph = 1L, invertebrates_makro = 1L, ecotox_group2 = 'Insecta') ]

# fish --------------------------------------------------------------------
tax[ superclass == 'Osteichthyes', `:=` (fish = 1L, heterotroph = 1L, ecotox_group2 = 'Fish') ]
tax[ class == 'Chondrichthyes', `:=` (fish = 1L, heterotroph = 1L, ecotox_group2 = 'Fish') ]
tax[ class == 'Cephalaspidomorphi', `:=` (fish = 1L, heterotroph = 1L, ecotox_group2 = 'Fish') ] # Lampreys (old)
tax[ class == 'Myxini', `:=` (fish = 1L, heterotroph = 1L, marine = 1L, ecotox_group2 = 'Fish') ]

# amphibia ----------------------------------------------------------------
tax[ class == 'Amphibia', `:=` (amphibia = 1L, heterotroph = 1L, ecotox_group2 = 'Amphibia') ]

# Reptilia ----------------------------------------------------------------
tax[ class == 'Reptilia', `:=` (reptilia = 1L, heterotroph = 1L, ecotox_group2 = 'Reptilia') ]

# Mammalia ----------------------------------------------------------------
tax[ class == 'Mammalia', `:=` (mammalia = 1L, heterotroph = 1L, ecotox_group2 = 'Mammalia') ]

# Aves --------------------------------------------------------------------
tax[ class == 'Aves', `:=` (aves = 1L, heterotroph = 1L, ecotox_group2 = 'Aves') ]

# protozoa ----------------------------------------------------------------
tax[ phylum_division == 'Protozoa', `:=` (protozoa = 1L, heterotroph = 1L, ecotox_group2 = 'Protozoa') ]

# oomycota -----------------------------------------------------------------
tax[ phylum_division == 'Oomycota', `:=` (oomycota = 1L, heterotroph = 1L, ecotox_group2 = 'Oomycota') ] # colorless heterokonts (pseudofungi, bigyra) https://en.wikipedia.org/wiki/Heterokont

# Tunicata ----------------------------------------------------------------
tax[ class == 'Ascidiacea', `:=` (tunicata = 1L, heterotroph = 1L, marine = 1L, ecotox_group2 = 'Tunicata') ]
tax[ class == 'Appendicularia', `:=` (tunicata = 1L, heterotroph = 1L, marine = 1L, ecotox_group2 = 'Tunicata') ]
tax[ class == 'Thaliacea', `:=` (tunicata = 1L, heterotroph = 1L, marine = 1L, ecotox_group2 = 'Tunicata') ]

# Zooflagellate -----------------------------------------------------------
tax[ phylum_division == 'Sarcomastigophora', `:=` (sarcomastigophora = 1L, heterotroph = 1L, ecotox_group2 = 'Sarcomastigophora') ]

# fungi -------------------------------------------------------------------
tax[ ecotox_group == 'Fungi', `:=` (fungi = 1L, heterotroph = 1L, ecotox_group2 = 'Fungi') ]
tax[ class == 'Sordariomycetes', `:=` (fungi = 1L, heterotroph = 1L, ecotox_group2 = 'Fungi') ]
tax[ class == 'Pucciniomycetes', `:=` (fungi = 1L, heterotroph = 1L, ecotox_group2 = 'Fungi') ]

# Apicomplexa -------------------------------------------------------------
tax[ phylum_division == 'Apicomplexa', `:=` (apicomplexa = 1L, heterotroph = 1L, ecotox_group2 = 'Apicomplexa') ]
tax[ class == 'Conoidasida', `:=` (apicomplexa = 1L, heterotroph = 1L, ecotox_group2 = 'Apicomplexa') ]

# Ctenophora --------------------------------------------------------------
tax[ phylum_division == 'Ctenophora', `:=` (ctenophora = 1L, heterotroph = 1L, marine = 1L, ecotox_group2 = 'Ctenophora') ]

# Cephalochordata ---------------------------------------------------------
tax[ class == 'Cephalochordata', `:=` (cephalochordata = 1L, heterotroph = 1L, marine = 1L, ecotox_group2 = 'Cephalochordata') ]

# Hemichordata ------------------------------------------------------------
tax[ phylum_division == 'Hemichordata', `:=` (hemichordata = 1L, heterotroph = 1L, marine = 1L, ecotox_group2 = 'Hemichordata') ]

# Myzozoa -----------------------------------------------------------------
tax[ class == 'Perkinsea', `:=` (myzozoa = 1L, heterotroph = 1L, parasite = 1L, ecotox_group2 = 'Myzozoa') ]

# Acanthocephala ----------------------------------------------------------
tax[ class == 'Eoacanthocephala', `:=` (acanthocephala = 1L, heterotroph = 1L, parasite = 1L, ecotox_group2 = 'Acanthocephala') ]
tax[ class == 'Palaeacanthocephala', `:=` (acanthocephala = 1L, heterotroph = 1L, parasite = 1L, ecotox_group2 = 'Acanthocephala') ]

# Microsporea -------------------------------------------------------------
tax[ class == 'Microsporea', `:=` (microsporea = 1L, heterotroph = 1L, parasite = 1L, ecotox_group2 = 'Microsporea') ]

# Tardigrada --------------------------------------------------------------
tax[ class == 'Eutardigrada', `:=` (tardigrada = 1L, heterotroph = 1L, freshwater = 1L, ecotox_group2 = 'Tardigrada') ]

# others ------------------------------------------------------------------
cols = c("species_number", "common_name", "latin_name", "kingdom", "phylum_division", 
         "subphylum_div", "superclass", "class", "tax_order", "family", 
         "genus", "species", "subspecies", "variety", "ecotox_group")

tax[ , chck_na := apply(.SD, 1, base::min, na.rm = TRUE), .SDcols =! cols ][ chck_na == Inf, chck_na := NA ]

other = dcast(tax[ is.na(chck_na) ],
              species_number ~ phylum_division, value.var = 'phylum_division',
              fun.aggregate = length, fill = NA)
other[ , V1 := NULL ]

tax_fin = merge(tax, other, by = 'species_number', all.x = TRUE)

# faults ------------------------------------------------------------------
# Sarcomastigophora - can also be autotroph - here: Animalia
# Euglenophycota - troph is not clear - here: Plantae

# final table -------------------------------------------------------------
tax_fin[ , taxon := gsub('\\sx\\s', ' X ', latin_name, ignore.case = TRUE) ] # transform all Hybrid X to capital letters => they aren't seen as species-names in the next REGEX
tax_fin[ , taxon := trimws(gsub('([A-z]+)\\s([a-z]+\\s)(.+)*', '\\1 \\2', taxon)) ]
tax_fin[ , taxon := trimws(gsub('sp.', '', taxon)) ] # remove sp.
setcolorder(tax_fin, c('taxon', 'ecotox_group2'))
clean_names(tax_fin)

tax_fin = unique(tax_fin, by = 'taxon')

tax_fin = tax_fin[ , .SD, .SDcols =! cols ]

# chck --------------------------------------------------------------------
chck_dupl(tax_fin, 'taxon')

# write -------------------------------------------------------------------
write_tbl(tax_fin, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'taxa', tbl = 'epa',
          key = 'taxon',
          comment = 'EPA ECOTOX taxonomic classification')

