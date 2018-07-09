#### function to extract psm type form PPDB output ----
ppdb_name = function(ppdb_list) {
  names_list = lapply(ppdb_list, function(x) lapply(x, '[')$names)
  cas = names(names_list)
  nam = as.character(lapply(names_list, '[', 1, 2))
  nam[ nam == 'NULL' ] = NA
  dt = data.table(cas = cas,
                  subst_name = nam)
  return(dt)
}
  
# from herem, same as in: /home/andreas/Documents/Projects/webchem
ppdb_psm_type = function(ppdb_list) {
  # extract the general list within the PPDB list for each cas
  general_list = lapply(ppdb_list, function(x) lapply(x, '[')$general)
  # extract the value for each cas
  pest_list = lapply(general_list, '[', 1, 2)
  # convert NULL to NA
  psm_raw = unlist(lapply(pest_list, function(x) if (is.null(x)) NA else x))
  psm_type = ifelse(grepl('inse', psm_raw, ignore.case = TRUE), 'insecticide',
                    ifelse(grepl('herb', psm_raw, ignore.case = TRUE), 'herbicide',
                           ifelse(grepl('fung', psm_raw, ignore.case = TRUE), 'fungicide', NA)))
  dt = data.table(cas = names(ppdb_list),
                  psm_type = psm_type)
  return(dt)
}

## grep all numeric strings/vlaues
# https://stackoverflow.com/questions/19252663/extracting-decimal-numbers-from-a-string
# lapply(x, `[[`, 1) also takes 1st list element, hence ignores structures such as mg/L-1
grep_dec = function(str) {
  x = regmatches(str,gregexpr("(?>-)*[[:digit:]]+\\.*[[:digit:]]*",str, perl=TRUE))
  as.numeric(unlist(lapply(x, `[[`, 1)))
}

ppdb_etox = function(ppdb_list) {
  # ppdb_list = ppdb_l # debug me!
  etox_list = lapply(ppdb_list, function(x) lapply(x, '[')$etox)
  # etox_list = etox_list['2921-88-2'] # debug me! Chlorpyrifos
  # etox_list = etox_list['135410-20-7'] # debug me! Acetamiprid
  # etox_list = etox_list['60207-90-1'] # debug me! Propiconazole # get's cis-propiconazole instead of propic.
  # etox_list = etox_list['34123-59-6'] # debug me! Isoproturon
  # etox_list = etox_list['140923-17-7'] # debug me! Iprovalicarb
  
  etox_fin_l = list()
  for (i in 1:length(etox_list)) {

    subst = etox_list[[i]]
    subst_cas = names(etox_list)[i]

    if(!is.null(subst)) {
      # change names
      names(subst) = c('property', 'value', 'source_quality', 'interpretation')
      
      subst$cas = names(etox_list)[i]
      subst$source = 'ppdb'
      subst[ subst == '-' ] = NA_character_
      subst = subst[ !is.na(subst$value), ]
      subst = subst[ grep('[0-9]+', subst$value), ] # delete non-digits in value
      
      # qualifier
      subst$qualifier = ifelse(grepl('<|>', subst$value, ignore.case = T),
                               sub('(<|>).*', '\\1', subst$value, ignore.case = T),
                               '=')
      
      # numeric value
      subst$value = grep_dec(subst$value)
      
      # grep units
      subst$unit = ifelse(grepl('mg.l-1', subst$property, ignore.case = TRUE),
                          'mg/L',
                          ifelse(grepl('l kg-1', subst$property, ignore.case = TRUE), 'l/kg',
                                 ifelse(grepl('mg kg-1', subst$property, ignore.case = TRUE), 'mg/kg',
                                        ifelse(grepl('g ha-1', subst$property, ignore.case = TRUE), 'mg/kg', NA_character_))))
      # grep organism group
      subst$ppdb_group = tolower(gsub('(.+)*(algae|aquatic.plants|aquatic.invertebrates|fish|mammals|honeybees|earthworms|Non-target.plants|other.arthropod|BCF|Sediment.dwelling.organisms|aquatic crustaceans|birds)(.+)*', '\\2', subst$property, ignore.case = TRUE))
      # endpoiont
      subst$endpoint = tolower(gsub('(.+)*(EC50|LC50|LD50|LR50|NOEL|NOEC|BCF|Non-target plants)(.+)*', '\\2', subst$property, ignore.case = TRUE))
      # Acute or chronic
      subst$test_type = gsub('(.+)\\s(acute|chronic|Bio-concentration factor BCF|Short term dietary)\\s(.+)*', '\\2', subst$property, ignore.case = TRUE)
      # grep taxon
      #! REGEX needs improvement!
      # 1) grep pattern like Daphnia magna (firs is capital letter)
      # 2) remove leadind pattern like K3, and all trailing vlaues
      subst$latin_BIname = gsub('([A-Z]{1}[0-9]{1}\\s)([A-z]+)(.+)*', '\\2',
                                gsub('(.+)\\s([A-Z]{1}[a-z]+\\s[a-z]+)(.+)*', '\\2',
                                     subst$source_quality))
      # grep duration
      subst$duration = as.numeric(gsub('(.+)\\s([0-9]{1,2})(.+)', '\\2', subst$property, ignore.case = TRUE))
      # grep duration unit
      subst$duration_unit = tolower(gsub('(.+)(hour|day)(.+)', '\\2', subst$property, ignore.case = TRUE))
      
      # quality
      subst$quality = substr(subst$source_quality,1,2)
      
      # fin
      subst = subst[ subst$ppdb_group %in% c('fish', 'algae', 'aquatic plants', 'aquatic invertebrates', 'sediment dwelling organisms', 'aquatic crustaceans'), ]

    } else {
      subst = NA
    }

    etox_fin_l[[i]] = subst
    names(etox_fin_l)[i] = subst_cas
  }

  etox_fin_l = etox_fin_l[ !is.na(etox_fin_l) ]
  ppdb_dt = rbindlist(etox_fin_l)

  return(ppdb_dt)
}
