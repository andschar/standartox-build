# script to prepare EPA chemical classification data

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
cla_che = readRDS(file.path(cachedir, 'ep_chemicals_source.rds'))

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
         is_metal := 1L ]
cla_che[ grep(paste0(pesticide, collapse = '|'), ecotox_group),
         is_pesticide := 1L ]
cla_che[ grep(paste0(pesticide, collapse = '|'), ecotox_group),
         is_pesticide := 1L ]
cla_che[ grep(paste0(pesticide, collapse = '|'), ecotox_group),
         is_pesticide := 1L ]
cla_che[ grep('(?i)conazoles', ecotox_group),
         is_fungicide := 1L ]
cla_che[ grep('(?i)pfoa', ecotox_group),
         is_pfoa := 1L ]
cla_che[ grep('(?i)ppcp', ecotox_group),
         is_pcp := 1L ]
cla_che[ grep('(?i)pcb', ecotox_group),
         is_pcb := 1L ]
cla_che[ grep('(?i)edc', ecotox_group),
         is_edc := 1L ]
cla_che[ grep('(?i)organotin', ecotox_group),
         is_organotin := 1L ]

cla_che[ , .N, ecotox_group][order(-N)] # TODO CONTINUE HERE!

# final table -------------------------------------------------------------
ep_chem_fin = cla_che[ , lapply(.SD, as.integer),
                       .SDcols =! c('cas', 'cname', 'ecotox_group'), cas ]
ep_chem_fin[cla_che, cname := i.cname, on = 'cas']
# names
setnames(ep_chem_fin, clean_names(ep_chem_fin))
setcolorder(ep_chem_fin, c('cas', 'cname'))

# writing -----------------------------------------------------------------
write_tbl(ep_chem_fin, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'phch', tbl = 'epa',
          comment = 'Chemical Information from EPA ECotox DB.')

# log ---------------------------------------------------------------------
log_msg('EPA chemicals preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()






