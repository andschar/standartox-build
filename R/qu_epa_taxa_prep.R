# script for convenience ecotoxicological taxa grouping

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
tax = readRDS(file.path(cachedir, 'source_epa_taxa.rds'))

# errata ------------------------------------------------------------------
tax[ phylum_division == 'Cyanophycota', phylum_division := 'Cyanobacteria' ]
tax[ phylum_division == 'Rhodophycota', phylum_division := 'Rhodophyta' ]

# algae -------------------------------------------------------------------
tax[ phylum_division == 'Chlorophyta', `:=` (algae = TRUE, autotroph = TRUE, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Bacillariophyta', `:=` (algae = TRUE, autotroph = TRUE, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Cyanobacteria', `:=` (algae = TRUE, autotroph = TRUE, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Rhodophyta', `:=` (algae = TRUE, autotroph = TRUE, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Phaeophyta', `:=` (algae = TRUE, autotroph = TRUE, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Charophyta', `:=` (algae = TRUE, autotroph = TRUE, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Chrysophyta', `:=` (algae = TRUE, autotroph = TRUE, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Haptophyta', `:=` (algae = TRUE, autotroph = TRUE, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Xanthophyta', `:=` (algae = TRUE, autotroph = TRUE, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Cryptophycophyta', `:=` (algae = TRUE, autotroph = TRUE, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Prasinophyta', `:=` (algae = TRUE, autotroph = TRUE, ecotox_group2 = 'Algae') ]
tax[ phylum_division == 'Ochrophyta', `:=` (algae = TRUE, autotroph = TRUE, ecotox_group2 = 'Algae') ]
tax[ class == 'Dinophyceae', `:=` (algae = TRUE, autotroph = TRUE, mixotroph = TRUE, ecotox_group2 = 'Algae') ]
tax[ class == 'Chloromonadophyceae', `:=` (algae = TRUE, autotroph = TRUE, mixotroph = TRUE, ecotox_group2 = 'Algae') ]

# plants ------------------------------------------------------------------
tax[ kingdom == 'Plantae', `:=` (plants = TRUE, autotroph = TRUE, ecotox_group2 = 'Plantae') ]

# mollusca ----------------------------------------------------------------
tax[ phylum_division == 'Annelida', `:=` (annelida = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Annelida') ]

# Brachiopoda -------------------------------------------------------------
tax[ phylum_division == 'Brachiopoda', `:=` (brachiopoda = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Brachiopoda') ]

# mollusca ----------------------------------------------------------------
tax[ phylum_division == 'Mollusca', `:=` (mollusca = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Mollusca') ]

# nemertea ----------------------------------------------------------------
tax[ phylum_division == 'Nemertea', `:=` (nemertea = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Nemertea') ]

# platyhelminthes ---------------------------------------------------------
tax[ phylum_division == 'Platyhelminthes', `:=` (nemertea = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Platyhelminthes') ]

# nematoda ----------------------------------------------------------------
tax[ phylum_division == 'Nematoda', `:=` (nematoda = TRUE, heterotroph = TRUE, invertebrates_mikro = TRUE, ecotox_group2 = 'Nematoda') ]
tax[ phylum_division == 'Nemata', `:=` (nematoda = TRUE, heterotroph = TRUE, invertebrates_mikro = TRUE, ecotox_group2 = 'Nematoda') ]
tax[ class == 'Secernentea', `:=` (nematoda = TRUE, heterotroph = TRUE, invertebrates_mikro = TRUE, ecotox_group2 = 'Nematoda') ]
tax[ class == 'Adenophorea', `:=` (nematoda = TRUE, heterotroph = TRUE, invertebrates_mikro = TRUE, ecotox_group2 = 'Nematoda') ]

# bryozoa -----------------------------------------------------------------
tax[ phylum_division == 'Bryozoa', `:=` (bryozoa = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Bryozoa') ]
tax[ phylum_division == 'Ectoprocta', `:=` (bryozoa = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Bryozoa') ]
tax[ class == 'Phylactolaemata', `:=` (bryozoa = TRUE, heterotroph = TRUE, invertebrates_mikro = TRUE, freshwater = TRUE, ecotox_group2 = 'Bryozoa') ]

# Kamptozoa ---------------------------------------------------------------
tax[ phylum_division == 'Kamptozoa', `:=` (kamptozoa = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Kamptozoa') ]

# Cercozoa ----------------------------------------------------------------
tax[ phylum_division == 'Cercozoa', `:=` (cercozoa = TRUE, heterotroph = TRUE, invertebrates_mikro = TRUE, ecotox_group2 = 'Cercozoa') ]
tax[ class == 'Phytomyxea', `:=` (cercozoa = TRUE, heterotroph = TRUE, invertebrates_mikro = TRUE, parasites = TRUE, ecotox_group2 = 'Cercozoa') ]

# chaetognatha ------------------------------------------------------------
tax[ phylum_division == 'Chaetognatha', `:=` (chaetognatha = TRUE, heterotroph = TRUE, invertebrates_mikro = TRUE, ecotox_group2 = 'Chaetognatha') ]

# ciliophora --------------------------------------------------------------
tax[ phylum_division == 'Ciliophora', `:=` (ciliophora = TRUE, heterotroph = TRUE, invertebrates_mikro = TRUE, ecotox_group2 = 'Ciliophora') ]

# gastrotricha ------------------------------------------------------------
tax[ phylum_division == 'Gastrotricha', `:=` (gastrotricha = TRUE, heterotroph = TRUE, invertebrates_mikro = TRUE, ecotox_group2 = 'Gastrotricha') ]

# rotifera ----------------------------------------------------------------
tax[ phylum_division == 'Rotifera', `:=` (rotifera = TRUE, heterotroph = TRUE, invertebrates_mikro = TRUE, ecotox_group2 = 'Rotifera') ]

# cnidaria ----------------------------------------------------------------
tax[ phylum_division == 'Cnidaria', `:=` (cnidaria = TRUE, heterotroph = TRUE, invertebrates_mikro = TRUE, ecotox_group2 = 'Cnidaria') ]
tax[ class == 'Myxosporea', `:=` (cnidaria = TRUE, heterotroph = TRUE, invertebrates_mikro = TRUE, parasites = TRUE, ecotox_group2 = 'Cnidaria') ]

# Nematomorpha ------------------------------------------------------------
tax[ phylum_division == 'Nematomorpha', `:=` (nematomorpha = TRUE, heterotroph = TRUE, invertebrates_mikro = TRUE, ecotox_group2 = 'Nematomorpha') ]

# echinodermata -----------------------------------------------------------
tax[ phylum_division == 'Echinodermata', `:=` (echinodermata = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Echinodermata') ]

# porifera ----------------------------------------------------------------
tax[ phylum_division == 'Porifera', `:=` (porifera = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Porifera') ]

# mollusca ----------------------------------------------------------------
tax[ phylum_division == 'Mollusca', `:=` (mollusca = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Mollusca') ]

# crustacea ---------------------------------------------------------------
tax[ subphylum_div == 'Crustacea', `:=` (crustacea = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Crustacea') ]

# arachnida ---------------------------------------------------------------
tax[ subphylum_div == 'Myriapoda', `:=` (myriapoda = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, terrestrial = TRUE, ecotox_group2 = 'Myriapoda') ]
tax[ class == 'Merostomata', `:=` (xiphosura = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Xiphosura') ]
tax[ class == 'Arachnida', `:=` (arachnida = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Arachnida') ]
tax[ tax_order == 'Araneae', `:=` (araneae = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Araneae') ]

# Priapulida --------------------------------------------------------------
tax[ class == 'Priapulida', `:=` (priapulida = TRUE, heterotroph = TRUE, marine = TRUE, ecotox_group2 = 'Priapulida') ] # penis worms

# Sipuncula ---------------------------------------------------------------
tax[ class == 'Sipunculidea', `:=` (sipuncula = TRUE, heterotroph = TRUE, invertebrates_mikro = TRUE, marine = TRUE, ecotox_group2 = 'Sipuncula') ]

# diplopoda ---------------------------------------------------------------
tax[ class == 'Diplopoda', `:=` (diplopoda = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Diplopoda') ]

# entognatha---------------------------------------------------------------
tax[ class == 'Entognatha', `:=` (entognatha = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Entognatha') ]

# insecta -----------------------------------------------------------------
tax[ class == 'Insecta', `:=` (insecta = TRUE, heterotroph = TRUE, invertebrates_makro = TRUE, ecotox_group2 = 'Insecta') ]

# fish --------------------------------------------------------------------
tax[ superclass == 'Osteichthyes', `:=` (fish = TRUE, heterotroph = TRUE, ecotox_group2 = 'Fish') ]
tax[ class == 'Chondrichthyes', `:=` (fish = TRUE, heterotroph = TRUE, ecotox_group2 = 'Fish') ]
tax[ class == 'Cephalaspidomorphi', `:=` (fish = TRUE, heterotroph = TRUE, ecotox_group2 = 'Fish') ] # Lampreys (old)
tax[ class == 'Myxini', `:=` (fish = TRUE, heterotroph = TRUE, marine = TRUE, ecotox_group2 = 'Fish') ]

# amphibia ----------------------------------------------------------------
tax[ class == 'Amphibia', `:=` (amphibia = TRUE, heterotroph = TRUE, ecotox_group2 = 'Amphibia') ]

# Reptilia ----------------------------------------------------------------
tax[ class == 'Reptilia', `:=` (reptilia = TRUE, heterotroph = TRUE, ecotox_group2 = 'Reptilia') ]

# Mammalia ----------------------------------------------------------------
tax[ class == 'Mammalia', `:=` (mammalia = TRUE, heterotroph = TRUE, ecotox_group2 = 'Mammalia') ]

# Aves --------------------------------------------------------------------
tax[ class == 'Aves', `:=` (aves = TRUE, heterotroph = TRUE, ecotox_group2 = 'Aves') ]

# protozoa ----------------------------------------------------------------
tax[ phylum_division == 'Protozoa', `:=` (protozoa = TRUE, heterotroph = TRUE, ecotox_group2 = 'Protozoa') ]

# oomycota -----------------------------------------------------------------
tax[ phylum_division == 'Oomycota', `:=` (oomycota = TRUE, heterotroph = TRUE, ecotox_group2 = 'Oomycota') ] # colorless heterokonts (pseudofungi, bigyra) https://en.wikipedia.org/wiki/Heterokont

# Tunicata ----------------------------------------------------------------
tax[ class == 'Ascidiacea', `:=` (tunicata = TRUE, heterotroph = TRUE, marine = TRUE, ecotox_group2 = 'Tunicata') ]
tax[ class == 'Appendicularia', `:=` (tunicata = TRUE, heterotroph = TRUE, marine = TRUE, ecotox_group2 = 'Tunicata') ]
tax[ class == 'Thaliacea', `:=` (tunicata = TRUE, heterotroph = TRUE, marine = TRUE, ecotox_group2 = 'Tunicata') ]

# Zooflagellate -----------------------------------------------------------
tax[ phylum_division == 'Sarcomastigophora', `:=` (sarcomastigophora = TRUE, heterotroph = TRUE, ecotox_group2 = 'Sarcomastigophora') ]

# fungi -------------------------------------------------------------------
tax[ ecotox_group == 'Fungi', `:=` (fungi = TRUE, heterotroph = TRUE, ecotox_group2 = 'Fungi') ]
tax[ class == 'Sordariomycetes', `:=` (fungi = TRUE, heterotroph = TRUE, ecotox_group2 = 'Fungi') ]
tax[ class == 'Pucciniomycetes', `:=` (fungi = TRUE, heterotroph = TRUE, ecotox_group2 = 'Fungi') ]

# Apicomplexa -------------------------------------------------------------
tax[ phylum_division == 'Apicomplexa', `:=` (apicomplexa = TRUE, heterotroph = TRUE, ecotox_group2 = 'Apicomplexa') ]
tax[ class == 'Conoidasida', `:=` (apicomplexa = TRUE, heterotroph = TRUE, ecotox_group2 = 'Apicomplexa') ]

# Ctenophora --------------------------------------------------------------
tax[ phylum_division == 'Ctenophora', `:=` (ctenophora = TRUE, heterotroph = TRUE, marine = TRUE, ecotox_group2 = 'Ctenophora') ]

# Cephalochordata ---------------------------------------------------------
tax[ class == 'Cephalochordata', `:=` (cephalochordata = TRUE, heterotroph = TRUE, marine = TRUE, ecotox_group2 = 'Cephalochordata') ]

# Hemichordata ------------------------------------------------------------
tax[ phylum_division == 'Hemichordata', `:=` (hemichordata = TRUE, heterotroph = TRUE, marine = TRUE, ecotox_group2 = 'Hemichordata') ]

# Myzozoa -----------------------------------------------------------------
tax[ class == 'Perkinsea', `:=` (myzozoa = TRUE, heterotroph = TRUE, parasite = TRUE, ecotox_group2 = 'Myzozoa') ]

# Acanthocephala ----------------------------------------------------------
tax[ class == 'Eoacanthocephala', `:=` (acanthocephala = TRUE, heterotroph = TRUE, parasite = TRUE, ecotox_group2 = 'Acanthocephala') ]
tax[ class == 'Palaeacanthocephala', `:=` (acanthocephala = TRUE, heterotroph = TRUE, parasite = TRUE, ecotox_group2 = 'Acanthocephala') ]

# Microsporea -------------------------------------------------------------
tax[ class == 'Microsporea', `:=` (microsporea = TRUE, heterotroph = TRUE, parasite = TRUE, ecotox_group2 = 'Microsporea') ]

# Tardigrada --------------------------------------------------------------
tax[ class == 'Eutardigrada', `:=` (tardigrada = TRUE, heterotroph = TRUE, freshwater = TRUE, ecotox_group2 = 'Tardigrada') ]

# chck --------------------------------------------------------------------
chck_dupl(tax, 'species_number')

# write -------------------------------------------------------------------
write_tbl(tax, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'epa', tbl = 'epa_taxa',
          key = 'species_number',
          comment = 'EPA ECOTOX taxonomic classification')

# log ---------------------------------------------------------------------
log_msg('QUERY: EPA: taxonomic preparation script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()






