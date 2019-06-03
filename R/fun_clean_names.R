# function to clean names

clean_names = function(dt) {
  x = names(dt)
  x = tolower(x)
  x = gsub('\\s+', '_', x)
  x = gsub('\\\'', '', x) # e.g. for: henry's law
  x = gsub('/', '', x)
  
  setnames(dt, x)
}

