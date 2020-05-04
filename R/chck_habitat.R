# script that check taxa for appropriate habitat classifications
# TODO elaborate on this
# TODO maybe use testthat:: ?

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# freshwater --------------------------------------------------------------
tax_fresh = c('Astacus astacus', 'Elodea canadensis', 'Danio rerio', 'Gammarus fossarum', 'Gammarus pulex')

# marine ------------------------------------------------------------------
tax_marin = c('Cerastoderma edule', 'Homarus americanus', 'Posidonie oceanica')
fam_marin = c('Triglidae')
phylum_division_marin = c('Echinodermata')

# terrestrial -------------------------------------------------------------
tax_terre = c('Apis mellifera', 'Rattus norvegicus', 'Zea mays')

# query -------------------------------------------------------------------
# fresh
q = paste0("SELECT *
            FROM standartox.taxa
            WHERE tax_taxon IN ('",
           paste0(tax_fresh, collapse = "', '"),
           "');")
fresh = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                   query = q)
# marin
q = paste0("SELECT *
            FROM standartox.taxa
            WHERE tax_taxon IN ('",
           paste0(tax_marin, collapse = "', '"),
           "')
           OR tax_family IN ('",
           paste0(fam_marin, collapse = "', '"),
           "')
           OR tax_phylum_division IN ('",
           paste0(phylum_division_marin, collapse = "', '"),
           "');")
marin = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                   query = q)
# terre
q = paste0("SELECT *
            FROM standartox.taxa
            WHERE tax_taxon IN ('",
           paste0(tax_terre, collapse = "', '"),
           "');")
terre = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                   query = q)

# chck --------------------------------------------------------------------
# fresh
chck_equals(all(fresh$hab_freshwater), TRUE)
chck_equals(any(fresh$hab_terrestrial), TRUE)
# marin
chck_equals(all(marin$hab_marine), TRUE)
# terre
chck_equals(any(terre$hab_terrestrial), TRUE)

# log ---------------------------------------------------------------------
log_msg('CHCK: Habitat chck script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()



















