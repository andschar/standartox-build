# geometric mean function
# https://stackoverflow.com/questions/2602583/geometric-mean-is-there-a-built-in

# 1 -----------------------------------------------------------------------
gm_mean = function(x, na.rm=TRUE, zero.propagate = FALSE){
  if(any(x < 0, na.rm = TRUE)){
    return(NaN)
  }
  if(zero.propagate){
    if(any(x == 0, na.rm = TRUE)){
      return(0)
    }
    exp(mean(log(x), na.rm = na.rm))
  } else {
    exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
  }
}
  
  

# 2 -----------------------------------------------------------------------
gm_mean = function(x) { exp(mean(log(x))) }
  
  