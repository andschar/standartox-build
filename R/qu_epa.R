# script to query the EPA data base for toxicity test results

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
online = online
online = FALSE
local = FALSE

# data --------------------------------------------------------------------
psm = readRDS(file.path(cachedir, 'psm.rds')) ## DEPR?

# query -------------------------------------------------------------------

if (online) {
  todo = unique(psm$casnr) # CASNR for query
  # todo = '122349' # debuging!
  # todo = '15972608' # debuging
  # todo = '15972608' # debug me
  drv = dbDriver("PostgreSQL")
  if (local) {
    con = dbConnect(drv, user = DBuserL, dbname = DBnameL, host = DBhostL, port = DBportL, password = DBpasswordL) # local  
  } else {
    con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword) # on server  
  }
  
  #epa1 <- data.table()
  epa1_list <- list()
  for (i in seq_along(todo)) {
    casnr <- todo[i]
    d <- dbGetQuery(con, paste0("
                                SELECT
                                tests.test_cas::varchar AS casnr,
                                chemicals.chemical_name,
                                tests.test_characteristics, -- how stupid to hide names here
                                chemicals.ecotox_group AS chemical_group,
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
                                tests.organism_habitat,
                                tests.subhabitat,
                                -- concentration + unit conversion	
                                CASE
                                WHEN unit_convert.conv = 'yes'
                                THEN cast_to_num(results.conc1_mean) * unit_convert.multiplier
                                WHEN unit_convert.conv = 'no'
                                THEN cast_to_num(results.conc1_mean) -- same cast as above
                                ELSE cast_to_num(results.conc1_mean) 
                                END AS conc1_conv,
                                CASE
                                WHEN unit_convert.conv = 'yes'
                                THEN unit_convert.unit_conv
                                WHEN unit_convert.conv = 'no'
                                THEN results.conc1_unit
                                ELSE results.conc1_unit
                                END AS conc1_unit_conv,
                                results.conc1_mean, -- fo safety reasons to compare to converted
                                results.conc1_unit, -- fo safety reasons to compare to converted
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
                                results.endpoint,
                                results.effect,
                                -- type of concentration (e.g. ai, formulation etc.)
                                results.conc1_type,
                                tests.reference_number,
                                refs.author,
                                refs.title
                                FROM ecotox.tests
                                LEFT JOIN ecotox.results ON tests.test_id = results.test_id
                                RIGHT JOIN ecotox.species ON tests.species_number = species.species_number
                                LEFT JOIN ecotox.chemicals ON tests.test_cas = chemicals.cas_number
                                LEFT JOIN ecotox.refs ON tests.reference_number = refs.reference_number
                                LEFT JOIN lookup.unit_convert ON results.conc1_unit = unit_convert.unit
                                LEFT JOIN lookup.duration_convert_as ON results.obs_duration_unit = duration_convert_as.unit
                                --LEFT JOIN lookup.ecotox_group_convert ON species.ecotox_group = ecotox_group_convert.ecotox_group
                                WHERE tests.test_cas = ", casnr, "
                                -- 15972608 -- casnr for debuging
                                -- endpoints:
                                AND results.endpoint IN ('EC50', 'EC50/', 'EC50*', 'EC50*/', 'LC50', 'LC50/', 'LC50*', 'LC50*/')
                                -- duration:
                                AND (results.obs_duration_unit = 'h' AND cast_to_num(results.obs_duration_mean) BETWEEN 24 AND 360
                                OR results.obs_duration_unit = 'd' AND cast_to_num(results.obs_duration_mean) BETWEEN 0 AND 15)
                                -- empty result cell? 
                                AND results.conc1_mean != 'NR'
                                -- organism habitat:
                                AND tests.organism_habitat NOT ILIKE 'soil'
                                -- subhabitat:
                                --AND tests.subhabitat IN ('P', 'R', 'L', 'E') -- Palustrine, Riverine, Lacustrine, Estuarine (not enough data provided!)
                                AND tests.subhabitat NOT IN ('D', 'F', 'G', 'M')
                                --AND results.effect IN ('MOR', 'ITX') --?
                                AND coalesce(species.genus, '') <> '' -- same as !=
                                ;"))
    
    ## DEBUGINGN:
    # epa1[ endpoint %in% c('EC50', 'EC50/', 'EC50*', 'EC50*/', 'LC50', 'LC50/', 'LC50*', 'LC50*/'), .N, endpoint ][order(-N)]
    # epa1[ value == 'NR' ]
    # range(epa1$obs_duration_conv)
    # epa1[ duration <= 120 ]
    # epa1[ , .N, duration_unit]
    # epa1[ , .N, subhabitat ]
    # epa1[ ]$
    # epa1[ , .N, genus]
    # epa1[ nchar(genus) < 3 ]
    ##
    
    
    
    ### DEPRECATED?
    # combines EPA data with bfg_monitoring data
    # if (nrow(d) > 0) {
    #   d = merge(d, psm[ ,c('casnr', 'variable_id', 'subst_name', 'psm_type')],
    #             by.x = 'casnr', by.y = 'casnr',
    #             all.x = TRUE)
    # }
    # 
    # message('testing casnr: ', casnr, '\nname: ', d$chemical_name,
    #         '\npsm_type: ', d$psm_type, '\n nobs: ', nrow(d)) # timestamp(quiet = TRUE)
    ### END
    message('Returning ', '(', i, '/', length(todo), '): ', casnr, ' (n = ', nrow(d), ')')
    
    epa1_list[[i]] <- d
    names(epa1_list)[i] <- casnr
    
  }
  
  dbDisconnect(con)
  dbUnloadDriver(drv)
  
  ## save
  saveRDS(epa1_list, file.path(cachedir, 'source_epa1_list.rds'))
  
} else {
  epa1_list = readRDS(file.path(cachedir, 'source_epa1_list.rds'))
}

epa1 = rbindlist(epa1_list)


# preparation -------------------------------------------------------------

## refine effect indices
effect = epa1[ , .N, effect][order(-N)]
effect[ , effect := gsub('~|/', '', effect) ]
effect = effect[ , .(N = sum(N)), effect]
fwrite(effect, file.path(tempdir(), 'effect_endpoints.csv'))

#epa1 = epa1[ effect %like% '(?i)MOR|POP|ITX|GRO' ]
epa1[ , effect := gsub('~|/', '', effect) ]
# https://cfpub.epa.gov/ecotox/help.cfm?help_id=CONTENTFAQ&help_type=define&help_back=1#asterisk
# ~ (leading tilde) - 
# / (trailing slash) - denotes that a comment is associated with the data
# MOR - mortality; POP - population; ITX - Intoxication; GRO - Growth; BEH - Behaviour
# NOC - Multiple or undefined; MPH - Morphology; PHY - Physiology; DVP - Development
# REP - Reproduction; BCM - Biochemistry; ENZ - Enzyme; FDB - Feeding behaviour;
# AVO - Avoidance; HIS - Histology; INJ - Injury; PRS - Ecosystem Process; CEL- Cell
# Gen - Genetics; IMM - Immunological; NR - Not reported

## resolve substance names manualy
# mostly taken from Sigmar Aldrich - careful!
miss = data.table(casnr = c("26002802", "26172554", "26530201", "2814202", "39515407", "39515418", "51036", "54406483", "584792", "72963725", "962583", "134623", "3380345"),
                  subst_name = c('Phenothrin', 'Methylchloroisothiazolinone', 'Octhilinone', 'Pyrimidinol', 'Cyphenothrin', 'Fenpropathrin', 'Piperonylbutoxide', 'Empethrin', 'Allethrin', 'Imiprothrin', 'Diazoxon', 'DEET', 'Triclosan'))

epa1[miss, on = 'casnr',
     subst_name := ifelse(is.na(subst_name), i.subst_name, subst_name)]

# adding qualifier column
# * means that this value is calculated 'cause it didn't meet epa standards (22 cases). This is not done anymore recently. see: https://cfpub.epa.gov/ecotox/help.cfm?help_id=CONTENTFAQ&help_type=define&help_back=1#asterisk
# + probably stands for more than (16 cases)
epa1[ , qualifier := trimws(gsub('[0-9\\.]+|E\\+|E\\-', '', conc1_mean)) ]
epa1[ qualifier == '', qualifier := '=' ]
epa1 = epa1[ qualifier != '+' ] # removing + entries

# delete conc1_mean and conc1_conv as they are only for comparing
epa1[ , c('test_characteristics', 'conc1_mean', 'conc1_unit', 'qualifier') := NULL ]

# delete reference information author and title:
epa1[ ,c('author', 'title') := NULL ]

#### Restrictions ----
#rm(d, epa1_list)
epa1 = epa1[ conc1_unit_conv %in% c('ug/L', 'ul/L') ]

#! check this in future. Which effect types should be included?
# epa1[ , .N, effect]

## CONTINUE HERE!!!!!
# 1) What is fd in ul/L fd??
# 2) Check conversions I added?
# 3) Should the changes be included to Edi's github? No, public
# 4) run all the script! Check every part
# 5) build WORMS query for family AND Species!
# 6) continue at sort(todo_habitat[69:80])


#### Additions ----
# harmonize NAs
epa1[ subhabitat %in% c('NC', '--', 'NR'), subhabitat := NA ]

# transform all Hybrid X to capital letters => they aren't seen as species-names in the next REGEX
epa1[ , latin_BIname := gsub('\\sx\\s', ' X ', latin_name, ignore.case = TRUE) ]
epa1[ , latin_BIname := gsub('([A-z]+)\\s([a-z]+\\s)(.+)*', '\\1 \\2', latin_BIname) ]
epa1[ , latin_BIname := sub('\\s+$', '', latin_BIname) ] # delete trailing \\s
epa1[ , latin_short := paste0(substr(latin_name,1,1),
                              '. ',
                              gsub('([a-z]+)\\s([a-z]+)', '\\2', latin_BIname, ignore.case = TRUE)) ]

# add source column
epa1[ , source := 'epa_ecotox' ]

# cas
epa1[ , cas := casconv(casnr) ]

# set all "" to NA
for (i in names(epa1)) {
  epa1[get(i) == "", (i) := NA]
}

# delete columnms & change order
# 'variable_id', 'psm_type'
setcolorder(epa1, c('casnr', 'cas', 'subst_name', 'chemical_name', 'chemical_group', 'conc1_conv', 'conc1_unit_conv', 'obs_duration_conv', 'obs_duration_unit_conv', 'endpoint', 'effect', 'conc1_type', 'organism_habitat', 'subhabitat',  'latin_name', 'latin_BIname', 'latin_short', 'genus', 'family', 'source', 'reference_number'))

# change names
setnames(epa1, c('casnr', 'cas', 'subst_name', 'chemical_name', 'chemical_group', 'value', 'unit', 'duration', 'duration_unit', 'endpoint', 'effect', 'conc_type', 'habitat', 'subhabitat',  'latin_name', 'latin_BIname', 'latin_short', 'genus', 'family_epa', 'source', 'ref_num'))

# Reduce columns to match PPDB and bfg_monitoring cols:
epa2 = epa1[ , c('subst_name', 'casnr', 'cas', 'value', 'unit', 'source', 'ref_num', 'duration', 'endpoint', 'effect', 'latin_BIname', 'family_epa') ]

# checks
subst_check = 
  epa2[ is.na(casnr) | casnr == '' |
          is.na(cas) | cas == '' |
          is.na(subst_name) | subst_name == '' ]

if (nrow(subst_check) != 0) {
  warning(nrow(subst_check), ' missing CAS, CASNR or substance names.')
}


# saving ------------------------------------------------------------------
saveRDS(epa2, file.path(cachedir, 'epa.rds'))

# cleaning ----------------------------------------------------------------
rm()






