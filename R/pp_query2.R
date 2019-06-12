pp_query2 = function (cas, encoding = "UTF-8", verbose = TRUE) 
{
  foo <- function(cas, verbose) {
    query <- gsub("-", "", cas)
    baseurl <- "http://esc.syrres.com/fatepointer/webprop.asp?CAS="
    qurl <- paste0(baseurl, query)
    if (verbose) 
      message("Querying ", qurl)
    Sys.sleep(rgamma(1, shape = 5, scale = 1/10))
    ttt <- try(read_html(qurl, encoding = encoding), silent = TRUE)
    if (inherits(ttt, "try-error")) {
      warning("Cannot retrive data from server. \n Returning NA.")
      return(NA)
    }
    if (grepl("No records", xml_text(xml_find_all(ttt, "//p"))[3])) {
      message("Not found! Returning NA.\n")
      return(NA)
    }
    variables <- xml_text(xml_find_all(ttt, "//ul/following-sibling::text()[1]"))
    variables <- gsub(":", "", variables)
    nd <- xml_find_all(ttt, "//ul[@class!=\"ph\"]")
    prop <- data.frame(t(sapply(nd, function(y) {
      value_var <- xml_text(xml_find_all(y, "./li[starts-with(text(),\"Value\")]"))
      value_var <- gsub("Value.:.(.*)", "\\1", value_var)
      value <- gsub("^(\\d*\\.?\\d*).*", "\\1", value_var)
      unit <- gsub("^\\d*\\.?\\d*.(.*)", "\\1", value_var)
      temp <- xml_text(xml_find_all(y, "./li[starts-with(text(),\"Temp\")]"))
      temp <- gsub("Temp.*:.(.*)", "\\1", temp)
      if (length(temp) == 0) {
        temp <- NA
      }
      type <- xml_text(xml_find_all(y, "./li[starts-with(text(),\"Type\")]"))
      type <- gsub("Type.*:.(.*)", "\\1", type)
      if (length(type) == 0) {
        type <- NA
      }
      ref <- xml_text(xml_find_all(y, "./li[starts-with(text(),\"Ref\")]"))
      ref <- gsub("Ref.*:.(.*)", "\\1", ref)
      if (length(ref) == 0) {
        ref <- NA
      }
      c(value, unit, temp, type, ref)
    })), stringsAsFactors = FALSE)
    if (length(prop) == 0) {
      message("No properties found! Returning NA.\n")
      return(NA)
    }
    names(prop) <- c("value", "unit", "temp", "type", "ref")
    prop$variable <- variables
    prop <- prop[, c("variable", "value", "unit", "temp", 
                     "type", "ref")]
    prop[, "value"] <- as.numeric(prop[, "value"])
    cas <- xml_text(xml_find_all(ttt, "//ul[@class=\"ph\"]/li[starts-with(text(),\"CAS\")]"))
    cas <- sub(".*:.", "", cas)
    cas <- sub("^[0]+", "", cas)
    cname <- xml_text(xml_find_all(ttt, "//ul[@class=\"ph\"]/li[starts-with(text(),\"Chem\")]"))
    cname <- sub(".*:.", "", cname)
    mw <- xml_text(xml_find_all(ttt, "//ul[@class='ph']/li[4]"))
    mw <- as.numeric(sub(".*:.", "", mw))
    mp <- xml_text(xml_find_all(ttt, "//ul[@class='ph']/li[5]"))
    prop <- rbind(prop, data.frame(variable = "Melting Point", 
                                   value = extr_num(mp), unit = "deg C", temp = NA, 
                                   type = NA, ref = NA))
    bp <- xml_text(xml_find_all(ttt, "//ul[@class='ph']/li[6]"))
    prop <- rbind(prop, data.frame(variable = "Boiling Point", 
                                   value = extr_num(bp), unit = "deg C", temp = NA, 
                                   type = NA, ref = NA))
    out <- list(cas = cas, cname = cname, mw = mw, prop = prop, 
                source_url = qurl)
    return(out)
  }
  out <- lapply(cas, foo, verbose = verbose)
  out <- setNames(out, cas)
  return(out)
}
