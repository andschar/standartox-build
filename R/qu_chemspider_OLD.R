# script to query the PubChem data base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

token = readLines(file.path(cred, 'chemspider_token.txt')) # from webchem github
# token = '39221bdb-21d7-45b0-aa71-892b07f6b111' # my token. doesn't work currently..

# data --------------------------------------------------------------------
chem = readRDS(file.path(cachedir, 'epa_chem.rds'))
todo_cs = chem$cas

# Query CSID --------------------------------------------------------------
if (online) {
  csid = get_csid(todo_cs, token = token)
  saveRDS(csid, file.path(cachedir, 'csid.rds'))
  
} else {
  csid = readRDS(file.path(cachedir, 'csid.rds'))
  
}

# Query Chemspider data ---------------------------------------------------
csid2 = csid[!is.na(csid)]
# csid2 = csid2[146:148] # debug me!

if (online) {
  cs_l = list()
  for (i in seq_along(csid2)) {
    qu_csid = csid2[i]
    qu_cas = names(qu_csid)
    message('Querying: CAS:', qu_cas, '; CSID:', qu_csid,
            ' (', i, '/', length(csid2), ')')
    
    # query
    compinfo = try(cs_compinfo(qu_csid, token = token))
    if (!inherits(compinfo, 'try-error')) {
      compinfo$cas = qu_cas
    }
    extcompinfo = try(cs_extcompinfo(qu_csid, token = token))
    if (!inherits(extcompinfo, 'try-error')) {
      extcompinfo$cas = qu_cas
    }
    prop = try(cs_prop(qu_csid, token = token))
    if (!inherits(prop, 'try-error')) {
      prop$cas = qu_cas  
    }
    
    
    #list
    cs_l[[i]] = list(compinfo = compinfo,
                     extcompinfo = extcompinfo,
                     prop = prop)
    names(cs_l)[i] = qu_csid
  }
  # saving
  saveRDS(cs_l, file.path(cachedir, 'chemspider_l.rds'))

} else {
  
  cs_l = readRDS(file.path(cachedir, 'chemspider_l.rds'))
}


# interesting variables ---------------------------------------------------
# cs_l$`2931`$compinfo
# cs_l$`23807`$extcompinfo$mf # to retrieve element counts
# cs_l$`4707`$prop$`4707`$acd
# cs_l$`22412`$prop$`22412`$epi

# cleaning ----------------------------------------------------------------
oldw = getOption("warn")
options(warn = -1) # shuts off warnings

rm(chem, todo_cs, i, qu_cas, qu_csid, compinfo, extcompinfo, prop,
   csid, csid2, token)

options(warn = oldw); rm(oldw)
