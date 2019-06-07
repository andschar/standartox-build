# function to upper-case 1st letter

firstup <- function(x) {
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  
  return(x)
}