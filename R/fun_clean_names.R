# function to clean names

clean_names = function(x) {
  x = names(x)
  x = tolower(x)
  x = gsub('\\s+', '_', x)
  x = gsub('\\\'', '', x) # e.g. for: henry's law
  
  return(x)
}