# script to prepare EPA chemical classification data
# TODO additional super groups/classes

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data --------------------------------------------------------------------
epa_prop = readRDS(file.path(cachedir, 'ep_chemicals_source.rds'))

# classification chemicals ------------------------------------------------
# grouping
metal_alkaline_earth = c('Barium', 'Beryllium')
metal_trans = c('Copper', 'Manganese', 'Chromium', 'Cobalt', 'Copper', 'Iron',
                'Manganese', 'Nickel', 'Silver', 'Vanadium')
metal_posttrans = c('Aluminum', 'Cadmium', 'Lead', 'Mercury', 'Zinc')
metalloid = c('Antimony', 'Arsenic')
pesticide = c('Conazoles', 'DDT and metabolites', 'Neonicotinoids', 'Strobins')

# general groups
metals = c(metal_alkaline_earth, metal_trans, metal_posttrans, metalloid)

todo = list(endocrine_disruptor = 'edc',
            fungicide = 'conazole',
            metal = metalloid,
            nitrosamine = 'Nitrosamines',
            organotin = 'Organotin',
            pah = 'pah',
            pbde = 'pbde',
            pcb = 'pcb',
            pesticide = c('conazole', 'DDT and metabolites', 'Neonicotinoids', 'Strobins'),
            perchlorate = 'Perchlorates',
            personal_care_product = 'ppcp',
            pfa = 'pfas',
            pfoa = 'pfoa')

# variables
for (i in seq_along(todo)) {
  cl = todo[[i]]
  nam = names(todo)[i]
  epa_prop[ grep(paste0(cl, collapse = '|'), ecotox_group, ignore.case = TRUE),
            (nam) := TRUE ]
}

# chck --------------------------------------------------------------------
chck_dupl(epa_prop, 'cas')

# write -------------------------------------------------------------------
write_tbl(epa_prop, user = DBuser, host = DBhost, port = DBport, password = DBpassword,
          dbname = DBetox, schema = 'epa', tbl = 'epa_prop',
          key = 'cas',
          comment = 'Chemical Information from EPA ECotox DB.')

# log ---------------------------------------------------------------------
log_msg('QUERY: EPA: chemicals preparation script run.')

# cleaning ----------------------------------------------------------------
clean_workspace()






