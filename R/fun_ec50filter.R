# function to filter EC50 data according to habitat, continent and subst_type
ec50_fil = function(dt, habitat = NULL, continent = NULL, tax = NULL, subst_type = NULL) {
  
  # debug me!
  # dt = tests_fl
  # tax = 'Algae'
  # habitat = 'marine'
  # continent = NULL; tax = NULL
  ### END
  
  # checks
  if (!is.data.frame(dt)) {
    stop('Input object is not a data.frame!')
  }
  # variables
  dt = as.data.table(dt)
  habitat_vars = c('marine', 'brackish', 'freshwater', 'terrestrial')
  continent_vars = c('Africa', 'Americas', 'Antarctica', 'Asia', 'Europe', 'Oceania')
  #taxon_vars = c() # commonly used taxas in Ecotoxicology
  
  ## filters
  # habitat
  if (is.null(habitat)) {
    dt = dt
  } else {
    if (!habitat %in% habitat_vars) {
      stop('Habitat has to be one of: ', paste(habitat_vars, collapse = ', '))
    }
    if (habitat == 'marine') {
      dt = dt[ isMar_fin == '1' ]  
    }
    if (habitat == 'brackish') {
      dt = dt[ isBra_fin == '1' ]  
    }
    if (habitat == 'freshwater') {
      dt = dt[ isFre_fin == '1' ]  
    }
    if (habitat == 'terrestrial') {
      dt = dt[ isFre_fin == '1' ]  
    }
  }
  # continent
  if (is.null(continent)) {
    dt = dt
  } else {
    if (!continent %in% continent_vars) {
      stop('continent has to be one of: ', paste(continent_vars, collapse = ', '))
    }
    if (continent == 'Africa') {
      dt = dt[ gb_Africa == '1' ]
    }
    if (continent == 'Americas') {
      dt = dt[ gb_Americas == '1' ]
    }
    if (continent == 'Antarctica') {
      dt = dt[ gb_Antarctica == '1' ]
    }
    if (continent == 'Asia') {
      dt = dt[ gb_Asia == '1' ]
    }
    if (continent == 'Europe') {
      dt = dt[ gb_Europe == '1' ]
    }
    if (continent == 'Oceania') {
      dt = dt[ gb_Oceania == '1' ]
    }
  }
  # taxon
  # functions to find out the column name of the input taxon  
  if (!is.null(tax)) {
    col = names(which(sapply(dt[ , .SD, .SDcols = grep('family|ma_', names(dt))],
                             function(x) length(grep(tax, x, ignore.case = TRUE))) > 0))
    message(paste0('Columns used for filtering: ', col))
    if (length(col) == 0) {
      stop('Taxon could not be found!')
    } else if (length(col) > 1) {
      warning('Multiple columns have been found. Picking the first one.')
      col = col[1]
    }
    
    dt = dt[get(col) == tax ]
    dt[ , grouping_tax := tax ]
  }
  
  return(dt)
  
}