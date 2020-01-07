# script to prepare EPA chemical classification data
# TODO additional super groups/classes

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
epa_chem = readRDS(file.path(cachedir, 'ep_chemicals_source.rds'))

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
epa_chem[ grep(paste0(metals, collapse = '|'), ecotox_group),
         metal := TRUE ]
epa_chem[ grep(paste0(pesticide, collapse = '|'), ecotox_group),
         pesticide := TRUE ]
epa_chem[ grep('(?i)conazoles', ecotox_group),
         fungicide := TRUE ]
epa_chem[ grep('(?i)pfoa', ecotox_group),
         pfoa := TRUE ]
epa_chem[ grep('(?i)ppcp', ecotox_group),
         pcp := TRUE ]
epa_chem[ grep('(?i)pcb', ecotox_group),
         pcb := TRUE ]
epa_chem[ grep('(?i)edc', ecotox_group),
         edc := TRUE ]
epa_chem[ grep('(?i)organotin', ecotox_group),
         organotin := TRUE ]

epa_chem[ , .N, ecotox_group][order(-N)] # TODO CONTINUE HERE!

# final table -------------------------------------------------------------
# names
clean_names(epa_chem)
setcolorder(epa_chem, c('cas', 'cas_number', 'cname'))

# check -------------------------------------------------------------------
chck_dupl(epa_chem, 'cas')

# write -------------------------------------------------------------------
write_tbl(epa_chem, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'epa_chem', tbl = 'prop',
          key = 'cas',
          comment = 'Chemical Information from EPA ECotox DB.')

# log ---------------------------------------------------------------------
log_msg('EPA chemicals preparation script run')

# cleaning ----------------------------------------------------------------
clean_workspace()






