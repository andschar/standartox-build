# function to clean names

clean_names = function(dt) {
  x = trimws(names(dt))
  x = tolower(x)
  x = gsub('\\s+', '_', x)
  x = gsub(',', '_', x)
  x = gsub('_+', '_', x)
  x = gsub('\\.', '_', x)
  x = gsub('\\\'', '', x) # e.g. for: henry's law
  x = gsub('/', '', x)
  x = trimws(x)
  
  setnames(dt, x)
}

