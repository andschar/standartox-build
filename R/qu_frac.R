# script to query information from the FRAC data base

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
url = 'http://www.frac.info/docs/default-source/publications/frac-code-list/frac-code-list-2018-final-v2.xlsx?sfvrsn=33684b9a_2'
destfile = paste0(tempfile(), '.xlsx')
download.file(url,
              destfile = destfile,
              mode = 'wb',
              quiet = TRUE)


# preparation -------------------------------------------------------------
frac = read_excel(destfile, sheet = 1)
setDT(frac)
setnames(frac, c('moa_code', 'moa', 'target_code', 'target_site', 'group_name', 'chemical_group', 'cname', 'comments', 'frac_code'))
frac$cname[2] = 'benalaxyl-M'
frac$cname[5] = 'metalaxyl-M'
frac$cname[104] = "iprobenfos" # (IBP)
frac$cname[109] = "quintozene" # (PCNB)
frac$cname[110] = "tecnazene" # (TCNB)
frac$cname[122] = "natamycin" # (pimaricin)
frac$cname[197] = "teclofthalam" # (bactericide)
frac$cname[213] = "copper" # (different salts)

if (online) {
  
  cir_frac = cir_query(frac$cname, 'cas')
  saveRDS(cir_frac, file.path(cachedir, 'cir_frac.rds'))
  
} else {
  cir_frac = readRDS(file.path(cachedir, 'cir_frac.rds'))
}

# adding CAS to FRAC table
frac_cas = rbindlist(lapply(lapply(cir_frac, '[', 1), data.table),
                     idcol = 'cname')

frac[frac_cas, cas := i.V1, on = 'cname']
frac[ , casnr := casconv(cas, direction = 'tocasnr') ]
frac[ , comp_type := 'fungicide' ]

# final dt ----------------------------------------------------------------
cols_fr_fin = c('cas', 'cname', 'chemical_group')
frac2 = frac[ , .SD, .SDcols = cols_fr_fin ]

# cleaning ----------------------------------------------------------------
rm(destfile, url, cir_frac, frac_cas, cols_fr_fin)


