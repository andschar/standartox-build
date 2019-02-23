# script to classify chemicals and organisms accoring to EPA data
# TODO additional super groups/classes

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# query ---------------------------------------------------------------
if (online_db) {
  drv = dbDriver("PostgreSQL")
  con = dbConnect(drv, user = DBuser, dbname = DBetox, host = DBhost, port = DBport, password = DBpassword)
  
  cla_che = dbGetQuery(con, "SELECT cas_number, chemical_name AS cname, ecotox_group
                             FROM ecotox.chemicals")
  setDT(cla_che)
  cla_che[ , cas_number := as.character(cas_number) ]
  cla_che[ , cas := casconv(cas_number) ][ , cas_number := NULL ]
  
  dbDisconnect(con)
  dbUnloadDriver(drv); rm(con, drv)
  
  saveRDS(cla_che, file.path(cachedir, 'ep_chemicals_source.rds'))
  
} else {
  
  cla_che = readRDS(file.path(cachedir, 'ep_chemicals_source.rds'))
}

# classification chemicals ------------------------------------------------
# grouping
metal_alkaline_earth = c('Barium', 'Beryllium')
metal_trans = c('Copper', 'Manganese', 'Chromium', 'Cobalt', 'Copper', 'Iron', 'Manganese', 'Nickel', 'Silver', 'Vanadium')
metal_posttrans = c('Aluminum', 'Cadmium', 'Lead', 'Mercury', 'Zinc')
metalloid = c('Antimony', 'Arsenic')

pesticide = c('Conazoles', 'DDT and metabolites', 'Neonicotinoids', 'Strobins')

# TODO this groups are not yet implemented!
nonmetal_reactive = c('selenium')

dibenzofuran = 'Dibenzofurans'
edcs = 'Endocrine Disrupting Chemicals (EDCs)'
explosives = 'Explosives'
solvent = 'Glycol Ethers'
nitrosamine = 'Nitrosamines'
organotin = 'Organotin'
perchlorate = 'Perchlorates'
pfoa = 'Perfluorooctane Sulfonates and Acids (PFOS/PFOA)'
ppcp = 'Pharmaceutical Personal Care Products (PPCPs)'
phthalate = 'Phthalate Esters'
pah = 'Polyaromatic Hydrocarbons (PAHs)'
pbde = 'Polybrominated Diphenyl Ethers (PBDEs)'
pcb = 'Polychlorinated Biphenyls (PCBs)'
strobin = 'Strobins'
ions = 'Major Ions'
### END: not implemented

# general groups
metals = c(metal_alkaline_earth, metal_trans, metal_posttrans, metalloid)

# variables
cla_che[ grep(paste0(metals, collapse = '|'), ecotox_group),
         ep_metal := 1L ]
cla_che[ grep(paste0(pesticide, collapse = '|'), ecotox_group),
         ep_pesticide := 1L ]
cla_che[ grep(paste0(pesticide, collapse = '|'), ecotox_group),
         ep_pesticide := 1L ]
cla_che[ grep(paste0(pesticide, collapse = '|'), ecotox_group),
         ep_pesticide := 1L ]
cla_che[ grep('(?i)conazoles', ecotox_group),
         ep_fungicide := 1L ]
cla_che[ grep('(?i)pfoa', ecotox_group),
         ep_pfoa := 1L ]
cla_che[ grep('(?i)ppcp', ecotox_group),
         ep_pcp := 1L ]
cla_che[ grep('(?i)pcb', ecotox_group),
         ep_pcb := 1L ]
cla_che[ grep('(?i)edc', ecotox_group),
         ep_edc := 1L ]
cla_che[ grep('(?i)organotin', ecotox_group),
         ep_organotin := 1L ]

cla_che[ , .N, ecotox_group][order(-N)] # TODO CONTINUE HERE!

# final table -------------------------------------------------------------
ep_chem_fin = cla_che[ , lapply(.SD, as.integer),
                       .SDcols =! c('cas', 'cname', 'ecotox_group'), cas ]
ep_chem_fin[cla_che, ep_cname := i.cname, on = 'cas']

# writing -----------------------------------------------------------------
saveRDS(ep_chem_fin, file.path(cachedir, 'ep_chem_fin.rds'))

# log ---------------------------------------------------------------------
msg = 'EPA chemicals script run'
log_msg(msg)

# cleaning ----------------------------------------------------------------
clean_workspace()






