# function to separate string inputs by commas

# debug
# input = c('Daphnia magna', 'Algae')
# input = 'Daphnia magna,Algae'
# input = NULL

handle_input_multiple = function(input) {
  if (!is.null(input)) {
    input = na.omit(trimws(unlist(strsplit(input, ","))))
    input = input[ input != '' ]
  }
  input
}
