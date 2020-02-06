# script to compile EPA chemical and taxa IDs for identifier and data queries

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
look_taxa_dupl = fread(file.path(lookupdir, 'lookup_duplicated_taxa.csv'))

# chemicals ---------------------------------------------------------------
q = "SELECT DISTINCT ON (cas_number) *
     FROM ecotox.chemicals"
chem = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
## prepare
chem[ , cas := casconv(cas_number, 'tocas') ]
setnames(chem, 'cas_number', 'casnr')
setcolorder(chem, c('casnr', 'cas'))
setorder(chem, casnr)

# taxa --------------------------------------------------------------------
q = "SELECT DISTINCT ON (species_number, latin_name) *
     FROM ecotox.species"
q_n = "SELECT species_number, count(*) n
       FROM ecotox.species
       LEFT JOIN ecotox.tests USING (species_number)
       GROUP BY species_number
       ORDER BY n DESC"
taxa = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                  query = q)
taxa_n = read_query(user = DBuser, host = DBhost, port = DBport, password = DBpassword, dbname = DBetox,
                    query = q_n)
taxa[taxa_n, n_tests := i.n, on = 'species_number' ]
## erros
taxa = taxa[ species_number != 9506 ] # strange variety name (Dts 69-1)
taxa = taxa[ species_number != 49289 ] # exact duplicate to 31086 (Gn: Corymbia)
taxa = taxa[ species_number != 15763 ] # wrong: Holotrichia
taxa = taxa[ species_number != 39535 ] # duplicated: Poduromorpha
taxa = taxa[ species_number != 52661 ] # duplicate to 27829
## taxon column
taxa[ , taxon := trimws(sub('sp\\.', '', latin_name)) ] # remove sp.
taxa[ , taxon := trimws(sub(' X ', '', taxon, ignore.case = TRUE)) ] # remove Genus X species
taxa[ , taxon := trimws(gsub('\\s+', ' ', taxon)) ] # reduce multiple \\s to one
taxa[ , taxon := gsub('([A-z]+\\s[A-z]+)(.+)*', '\\1', taxon) ] # delete
## exclude duplicated taxa (and upload them with manually entered IDs separately)
# TODO what does manual mean here????????
taxa2 = taxa[ !species_number %in% look_taxa_dupl$species_number ]

# chck --------------------------------------------------------------------
## chemicals
chck_dupl(chem, 'cas')
## taxa
# taxa names
l = length(which(lengths(strsplit(taxa$taxon, ' ')) > 2))
if (l > 0) { 
  stop('Taxa entry with more than two words: "Genus species WHATEVER".')
}
# dupl
chck_dupl(taxa, 'species_number')
## taxa manual
chck_dupl(look_taxa_dupl, 'species_number')

# write -------------------------------------------------------------------
# chemicals
write_tbl(chem, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'ecotox', tbl = 'chem_id',
          key = 'cas',
          comment = 'EPA chemical identifiers (cas) for subsequent queries.')
# taxa
write_tbl(taxa2, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'ecotox', tbl = 'taxa_id',
          key = 'species_number',
          comment = 'EPA taxa identifiers (latin name) for subsequent queries.')
# taxa manual
write_tbl(look_taxa_dupl, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'ecotox', tbl = 'taxa_id_manual',
          key = 'species_number',
          comment = 'EPA taxa identifiers (latin name) for subsequent queries.')

# log ---------------------------------------------------------------------
log_msg('BD: EPA: identifiers created.')

# cleaning ----------------------------------------------------------------
clean_workspace()
