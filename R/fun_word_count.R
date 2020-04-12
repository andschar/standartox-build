# function to ocunt words

word_count = function(x) {
  lengths(gregexpr("\\W+", x)) + 1
}