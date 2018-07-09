# function to extract R2 from gam and gamm objects
# model_list = readRDS('/home/andreas/Documents/Projects/species-sensitivity/cache/moTU_sit_l.rds') # debuging
quick_summary = function(model_list) {
  
  quick_summary_l = list()
  for (i in 1:length(model_list)) {
    mo = model_list[[i]]# model output
    
    if (is.null(mo)) {
      rsq = NA_character_
    } else if (anyNA(mo)) {
      rsq = NA_character_
    } else {
      if (inherits(mo, 'gam')) {
        rsq = summary(mo)$r.sq
        rsq = round(rsq,2)  
      } else if (inherits(mo, 'gamm')) {
        rsq = summary(mo$gam)$r.sq
        rsq = round(rsq,2)
      }
    }
    quick_summary_l[[i]] = data.frame(name = names(model_list)[i],
                                      rsq = rsq,
                                      stringsAsFactors = FALSE)
  }
  out = do.call(rbind, quick_summary_l)
  out = out[with(out, order(rsq, decreasing = TRUE)), ]
  return(out)
}
