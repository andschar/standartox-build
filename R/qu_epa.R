# script to query the EPA data base for toxicity test results

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
online = online
online = FALSE
local = TRUE

# data --------------------------------------------------------------------
psm = readRDS(file.path(cachedir, 'psm.rds')) ## DEPR?

# query -------------------------------------------------------------------

if (online) {
  todo_cas = unique(psm$casnr) # CASNR
  #todo_cas = todo_cas[1:10] # debug me!
  
  drv = dbDriver("PostgreSQL")
  if (local) {
    con = dbConnect(drv, user = DBuserL, dbname = DBnameL, host = DBhostL, port = DBportL, password = DBpasswordL) # local  
  } else {
    con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword) # on server  
  }
  
  #epa1 <- data.table()
  epa1_l <- list()
  for (i in seq_along(todo_cas)) {
    casnr <- todo_cas[i]
    d <- dbGetQuery(con, paste0("
                                SELECT
                            -- substances
                                tests.test_cas::varchar AS casnr,
                                chemicals.chemical_name,
                                chemicals.ecotox_group AS chemical_group,
                            -- concentration + unit conversion	
                                CASE
                                  WHEN unit_convert.conv = 'yes'
                                    THEN cast_to_num(results.conc1_mean) * unit_convert.multiplier
                                  WHEN unit_convert.conv = 'no'
                                    THEN cast_to_num(results.conc1_mean) -- same cast as above
                                  ELSE cast_to_num(results.conc1_mean) 
                                END AS conc1_mean_conv,
                                conc1_mean,
                                CASE
                                  WHEN unit_convert.conv = 'yes'
                                    THEN unit_convert.unit_conv
                                  WHEN unit_convert.conv = 'no'
                                    THEN results.conc1_unit
                                  ELSE results.conc1_unit
                                END AS conc1_unit_conv,
                                results.conc1_type,
                            -- test duration
                                CASE
                                  WHEN duration_convert_as.conv = 'yes'
                                    THEN cast_to_num(results.obs_duration_mean) * duration_convert_as.multiplier
                                  WHEN duration_convert_as.conv = 'no'
                                    THEN cast_to_num(results.obs_duration_mean)
                                  ELSE cast_to_num(results.obs_duration_mean)
                                END AS obs_duration_conv,
                                CASE
                                  WHEN duration_convert_as.conv = 'yes'
                                    THEN duration_convert_as.unit_conv
                                  WHEN duration_convert_as.conv = 'no'
                                    THEN results.obs_duration_unit
                                  ELSE results.obs_duration_unit
                                END AS obs_duration_unit_conv,
                            -- result types
                                results.endpoint,
                                results.effect,
                            -- species
                                species.latin_name,
                                --species.variety,
                                --species.subspecies,
                                --species.species,
                                species.genus,
                                species.family,
                                --species.tax_order,
                                --species.class,
                                --species.superclass,
                                --species.subphylum_div,
                                --species.phylum_division,
                                --species.kingdom,
                                tests.organism_habitat AS habitat, -- ('soil')
                                tests.subhabitat, -- ('P', 'R', 'L', 'E', 'D', 'F', 'G', 'M') -- Palustrine, Riverine, Lacustrine, Estuarine
                            -- references
                                tests.reference_number,
                                refs.author,
                                refs.title,
                                refs.publication_year
                                FROM ecotox.tests
                                LEFT JOIN ecotox.results ON tests.test_id = results.test_id
                                RIGHT JOIN ecotox.species ON tests.species_number = species.species_number
                                LEFT JOIN ecotox.chemicals ON tests.test_cas = chemicals.cas_number
                                LEFT JOIN ecotox.refs ON tests.reference_number = refs.reference_number
                                LEFT JOIN lookup.unit_convert ON results.conc1_unit = unit_convert.unit
                                LEFT JOIN lookup.duration_convert_as ON results.obs_duration_unit = duration_convert_as.unit
                                --LEFT JOIN lookup.ecotox_group_convert ON species.ecotox_group = ecotox_group_convert.ecotox_group
                                WHERE tests.test_cas = ", casnr, "
                            -- endpoints:
                                AND results.endpoint IN ('EC50', 'EC50/', 'EC50*', 'EC50*/', 'LC50', 'LC50/', 'LC50*', 'LC50*/')
                            -- empty result cell? 
                                AND results.conc1_mean != 'NR'
                                AND coalesce(species.genus, '') <> '' -- same as !=
                                ;"))
    
    message('Returning ', '(', i, '/', length(todo_cas), '): ', casnr, ' (n = ', nrow(d), ')')
    
    epa1_l[[i]] <- d
    names(epa1_l)[i] <- casnr
    
  }
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  ## cleaning
  rm(d, con, drv) # larger objects
  rm(casnr, todo_cas) # vectors
  
  ## save
  saveRDS(epa1_l, file.path(cachedir, 'source_epa1_list.rds'))
  
} else {
  epa1_l = readRDS(file.path(cachedir, 'source_epa1_list.rds'))
}

epa1 = rbindlist(epa1_l)

# clean and add -----------------------------------------------------------
# Clean effect column
epa1[ , effect := gsub('~|/|*', '', effect) ] # remove ~, /, or * from effect column
# Add qualifier column
epa1[ , qualifier := trimws(gsub('[0-9\\.]+|E\\+|E\\-', '', conc1_mean_conv)) ] # ading qualifier column
epa1[ qualifier == '', qualifier := '=' ]
epa1[ , conc1_mean := NULL ] # this column was only needed for the qualifier column
# 'NC', 'NR', '--' to NA
for (i in names(epa1)) {
  epa1[get(i) %in% c('NC', 'NR', '--'), (i) := NA ]
}
# Species columns
epa1[ , latin_BIname := gsub('\\sx\\s', ' X ', latin_name, ignore.case = TRUE) ] # transform all Hybrid X to capital letters => they aren't seen as species-names in the next REGEX
epa1[ , latin_BIname := gsub('([A-z]+)\\s([a-z]+\\s)(.+)*', '\\1 \\2', latin_BIname) ]
epa1[ , latin_BIname := sub('\\s+$', '', latin_BIname) ] # delete trailing \\s
epa1[ , latin_short :=
        paste0(substr(latin_name,1,1),
               '. ',
               gsub('([a-z]+)\\s([a-z]+)', '\\2', latin_BIname, ignore.case = TRUE)) ]
# Endpoint
epa1[ , endpoint := gsub('/|\\*|(\\*/)', '', endpoint) ]
# CAS
epa1[ , cas := casconv(casnr) ]
# Source column
epa1[ , source := 'epa_ecotox' ]
# set all "" to NA
for (i in names(epa1)) {
  epa1[get(i) == "", (i) := NA]
}

# subseting ---------------------------------------------------------------
# Effect measure
epa1 = epa1[ effect %like% '(?i)MOR|POP|ITX|GRO' ] # see help [deletes: 8% of entries]
# Endpoint
# epa1[ , .N, endpoint] only EC50 (is done in SQL query)
epa1 = epa1[ qualifier != '+' ] # delete + qualifier entries [deletes: 0.5% of entries]
#! TODO !!!!!!!!!!!!!!!1
# (1) # unit conversions
epa1 = epa1[ conc1_unit_conv %in% c('ug/L', 'ul/L') ] #! [deletes: 12% of entries] have a look at this soon! #! Maybe include the conversion in R
# (2) refine to a certain concentraion type? A - Active ingredient, F = formulation
epa1[ , .N, conc1_type] #! TODO

names(epa1)
fwrite(epa1, '/tmp/epa1.csv')

# final columns -----------------------------------------------------------
setcolorder(epa1, c('casnr', 'cas', 'chemical_name', 'chemical_group', 'conc1_mean_conv', 'qualifier', 'conc1_unit_conv', 'obs_duration_conv', 'obs_duration_unit_conv', 'conc1_type', 'endpoint', 'effect', 'habitat', 'subhabitat',  'latin_BIname', 'latin_name', 'latin_short', 'genus', 'family', 'source', 'reference_number', 'title', 'author', 'publication_year'))

# change names
setnames(epa1, c('casnr', 'cas', 'chemical_name', 'chemical_group', 'value', 'qualifier', 'unit', 'duration', 'duration_unit', 'subst_type', 'endpoint', 'effect', 'habitat', 'subhabitat',  'latin_BIname', 'latin_name', 'latin_short', 'genus', 'family_epa', 'source', 'ref_num', 'title', 'author', 'publication_year'))

# checks ------------------------------------------------------------------
cas_check = 
  epa1[ is.na(casnr) | casnr == '' |
        is.na(cas) | cas == '' ]

if (nrow(cas_check) != 0) {
  warning(nrow(cas_check), ' missing CAS or CASNR.')
}


# saving ------------------------------------------------------------------
saveRDS(epa1, file.path(cachedir, 'epa.rds'))
taxa = epa1[ , .SD, .SDcols = c('latin_BIname', 'family_epa')]
saveRDS(taxa, file.path(cachedir, 'epa_taxa.rds'))


# cleaning ----------------------------------------------------------------
rm(cas_check, local, taxa, psm)


# help --------------------------------------------------------------------
# https://cfpub.epa.gov/ecotox/help.cfm?help_id=CONTENTFAQ&help_type=define&help_back=1#asterisk
# ~ (leading tilde) - 
# / (trailing slash) - denotes that a comment is associated with the data
# * means that this value is calculated 'cause it didn't meet epa standards (22 cases). This is not done anymore 
# + probably stands for more than (16 cases)
# MOR - mortality; POP - population; ITX - Intoxication; GRO - Growth; BEH - Behaviour
# NOC - Multiple or undefined; MPH - Morphology; PHY - Physiology; DVP - Development
# REP - Reproduction; BCM - Biochemistry; ENZ - Enzyme; FDB - Feeding behaviour;
# AVO - Avoidance; HIS - Histology; INJ - Injury; PRS - Ecosystem Process; CEL- Cell
# Gen - Genetics; IMM - Immunological; NR - Not reported


