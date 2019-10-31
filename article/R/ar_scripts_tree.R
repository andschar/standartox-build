# script to visualize Standartox building pipline
# TODO not finished

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# data.tree ---------------------------------------------------------------
# NOTE could this be automated?
pipeline = Node$new('run_build.R')
# Build scripts
build = pipeline$AddChild('Build scripts')
build$AddChild('gn_setup.R')  
build$AddChild('bd_epa_download.R')
build$AddChild('bd_sql_functions.R')
build$AddChild('bd_epa_errata.R')
build$AddChild('bd_epa_meta.R')
build$AddChild('bd_epa_lookup.R')
look = pipeline$AddChild('Lookup scripts')
look$AddChild('look_concentration_units.R')
look$AddChild('look_duration_units.R')
look$AddChild('look_norman.R')
# Identifier scripts
identifier = pipeline$AddChild('Identifier scripts')
identifier$AddChild('id_cir_dwld.R')
identifier$AddChild('id_cir_prep.R')
identifier$AddChild('id_pc_cid_dwld.R')
identifier$AddChild('id_pc_cid_prep.R')
identifier$AddChild('id_epa_tax_dwld.R')
identifier$AddChild('id_epa_tax_prep.R')
# Query other data bases
query = pipeline$AddChild('Query scripts - qu_run_dwld.R, qu_run_prep.R')
# Chemical information
alan_wood = query$AddChild('Alan Wood')
alan_wood$AddChild('qu_aw_dwld.R')
alan_wood$AddChild('qu_aw_prep.R')
chebi = query$AddChild('ChEBI')
chebi$AddChild('qu_chebi_dwld.R')
chebi$AddChild('qu_chebi_prep.R')
chem_spider = query$AddChild('Chemspider')
chem_spider$AddChild('qu_cs_scrape_dwld.R')
chem_spider$AddChild('qu_cs_scrape_prep.R')
print(pipeline)
pan = query$AddChild('Pesticide Action Network')
pan$AddChild('qu_pan_dwld.R')
pan$AddChild('qu_pan_prep.R')
pubchem = query$AddChild('Pubchem')
pubchem$AddChild('qu_pc_prop_dwld.R')
pubchem$AddChild('qu_pc_prop_prep.R')
pubchem$AddChild('qu_pc_syn_dwld.R')
pubchem$AddChild('qu_pc_syn_prep.R')
physprop = query$AddChild('Physprop')
physprop$AddChild('qu_pp_dwld.R')
physprop$AddChild('qu_pp_prep.R')
epa_chem = query$AddChild('EPA Chemical')
epa_chem$AddChild('qu_epa_chem_dwld.R')
epa_chem$AddChild('qu_epa_chem_prep.R')
eurostat = query$AddChild('Eurostat')
eurostat$AddChild('qu_eurostat_dwld.R')
eurostat$AddChild('qu_eurostat_prep.R')
wikipedia = query$AddChild('Wikipedia')
wikipedia$AddChild('qu_wiki_dwld.R')
wikipedia$AddChild('qu_wiki_prep.R')
# Taxonomic information
epa_habitat = query$AddChild('EPA Habitat')
epa_habitat$AddChild('qu_epa_habi_dwld.R')
epa_habitat$AddChild('qu_epa_habi_prep.R')
gbif = query$AddChild('GBIF')
gbif$AddChild('qu_gbif_dwld.R')
gbif$AddChild('qu_gbif_prep.R')
worms = query$AddChild('WoRMS')
worms$AddChild('qu_worms_dwld.R')
worms$AddChild('qu_worms_prep.R')
query_final = query$AddChild('Final scripts - qu_run_final.R')
query_final$AddChild('qu_phch_fin.R')
query_final$AddChild('qu_taxa_fin.R')
build_stx = pipeline$AddChild('Build Standartox')
build_stx$AddChild('bd_standartox.R')
build_stx$AddChild('exp_standartox.R')
build_stx$AddChild('exp_standartox_catalog.R')
build_stx$AddChild('cpy_standartox.R')
pipeline$AddChild('chck_unit_conversions.R')
pipeline$AddChild('gn_backup.R')
pipeline$AddChild('gn_end.R')

# plot --------------------------------------------------------------------
# TODO make a nicer visualization

# write -------------------------------------------------------------------
ggsave(plot = ggdendro::ggdendrogram(as.dendrogram(pipeline), rotate = TRUE, size = 2),
       file.path(article, 'figures', 'scripts_dendrogram.png'),
       height = 12, width = 5)

# log ---------------------------------------------------------------------
log_msg('ARTICLE: PLOT: Scripts dendrogram plotted.')

# cleaning ----------------------------------------------------------------
clean_workspace()


# MAYBE USEFUL CODE -------------------------------------------------------
# require(igraph)  
# plot(as.igraph(pipeline, directed = TRUE, direction = "climb"), asp = 0)
# 
# plot(as.dendrogram(pipeline), center = TRUE, horiz = TRUE)
#   
# plot(as.igraph(pipeline, directed = TRUE, direction = "climb"),
#      #layout = l,
#      rescale = TRUE,
#      # axes = TRUE,
#      ylim = c(0,3),
#      xlim = c(0,3),
#      asp = 0,
#      #vertex.size = 5, 
#      #vertex.label.cex = 0.8
#      ) 
# 
# 
# require(networkD3)
# 
# acmeNetwork <- ToDataFrameNetwork(pipeline, "name")
# simpleNetwork(acmeNetwork[-3], fontSize = 12)
# 
# pacman::p_load(ggdendro)
# require(ggplot2)
# 
# ggdendrogram(as.dendrogram(pipeline), rotate = TRUE, size = 2)
# 
# 
# 
# require(r2d3)
# vec = c(0.3, 0.6, 0.8, 0.95, 0.40, 0.20)
# vec = iris$Sepal.Length
# test = r2d3(data = vec, script = "barchart.js")
# test










