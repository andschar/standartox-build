# script to manually get habitat information

# setup -------------------------------------------------------------------
source('R/setup.R')
# switches
online = online
# online = TRUE

# data --------------------------------------------------------------------
todo_habitat = readRDS(file.path(cachedir, 'epa_taxa.rds'))


# classification ----------------------------------------------------------


# Plants ------------------------------------------------------------------
# Family lookup list
lookup_man_fam = data.table(family = 'Poaceae', german_name = 'Suessgraeser',
                    supgroup = 'Plants', group = 'Spermatophyta', group_rank = 'subdivision', isFre = '0', isMar = '0', isTer = '1') # some Macrophytes!
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        #### Spermatophyta (subdivision) ----
                        as.list(c('Alismataceae', 'Froschlöffelgewaechse', 'Plants', 'Magnoliopsida', 'class', '1', '0', '1')), # macrophytes
                        as.list(c('Restionaceae', NA, 'Plants', 'Magnoliopsida', 'class', '0', '1', '1')),
                        as.list(c('Ruppiaceae', 'Saldengewächse', 'Plants', 'Magnoliopsida', 'class', '1', '1', '0')), # Macrophytes auch brackwasser (selten süßwasser)
                        as.list(c('Ceratophyllaceae', "Hornblattgewächse", 'Plants', 'Magnoliopsida', 'class', '1', '0', '0')),
                        as.list(c('Zosteraceae', "Seegrasgewächse", 'Plants', 'Magnoliopsida', 'class', '0', '1', '0')),
                        as.list(c('Nothofagaceae', "Scheinbuchen", 'Plants', 'Magnoliopsida', 'class', '0', '0', '1')),
                        as.list(c('Potamogetonaceae', "Laichkrautgewächse", 'Plants', 'Spermatophyta', 'subdivision', '1', '0', '0')),
                        as.list(c('Fabaceae', 'Huelsenfruechtler', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Asteraceae', 'Korbbluetler', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Brassicaceae', 'Kreuzbluetler', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')), # some Macrophytes!
                        as.list(c('Solanaceae', 'Nachtschattengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Rosaceae', 'Rosengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Malvaceae', 'Malvengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Cucurbitaceae', 'Kuerbisgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Amaranthaceae', 'Fuchsschwanzgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Pinaceae', 'Kieferngewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Liliaceae', 'Liliengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Convolvulaceae', 'Windengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Salicaceae', 'Weidengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Cyperaceae', 'Suessgraesser', 'Plants', 'Spermatophyta', 'subdivision', '1', '0', '1')),
                        as.list(c('Apiaceae', 'Doldenbluetler', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Lamiaceae', 'Lippenbluetler', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Chenopodiaceae', 'Fuchsschwanzgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')), # auf wikipedia mit Amaranthaceae gemeinsam
                        as.list(c('Polygonaceae', 'Knoeterichgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Cupressaceae', 'Zypressengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Fagaceae', 'Buchengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Caryophyllaceae', 'Nelkengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Euphorbiaceae', 'Wolfsmilchgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Ericaceae', 'Heidekrautgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Lemnaceae', 'Wasserlinsengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '1', '0', '0')),
                        as.list(c('Portulacaceae', 'Portulakgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Oleaceae', 'Oelbaumgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Aquifoliaceae', 'Stechpalmengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Scrophulariaceae', 'Braunwurzgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Rutaceae', 'Rautengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Myrtaceae', 'Myrtengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Theaceae', 'Teestrauchgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Rubiaceae', 'Raetegewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Haloragaceae', 'Tausendblattgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '1', '0', '1')),
                        as.list(c('Aizoaceae', 'Mittagsblumengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Vitaceae', 'Weinrebengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Aceraceae', 'Rosskastaniengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Celastraceae', 'Spindelbaumgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Plantaginaceae', 'Wegerichgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Arecaceae', 'Palmengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Apocynaceae', 'Hundsgiftgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Commelinaceae', 'Commelinagewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Oxalidaceae', 'Sauerkleegewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Linaceae', 'Leingewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Iridaceae', 'Schwertliliengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Taxaceae', 'Eibengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Primulaceae', 'Primelgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Molluginaceae', 'Mollugogewaechse', 'Plants', 'Spermatophyta', 'subdivision', '1', '0', '1')), # some wetland plants ?
                        as.list(c('Araceae', 'Aronstabgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '1', '0', '1')), # some macrophytes (also sub-family Lemnidae)
                        as.list(c('Geraniaceae', 'Storchschnabelgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Rhamnaceae', 'Kreuzdorngewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Hydrocharitaceae', 'Froschbissgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '1', '1', '0')), # macrophytes only
                        as.list(c('Cornaceae', 'Hartriegelgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Lythraceae', 'Blutweiderichgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Saxifragaceae', 'Steinbrechgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Crassulaceae', 'Dickblattgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')), #! relatively few aquatic plants
                        as.list(c('Podocarpaceae', 'Steineibengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Caprifoliaceae', 'Geißblattgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Begoniaceae', 'Schiefblattgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Anacardiaceae', 'Sumachgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Juglandaceae', 'Walnussgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Araliaceae', 'Walnussgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Buxaceae', 'Buchsbaumgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Verbenaceae', 'Eisenkrautgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Asclepiadaceae', 'Seidenpflanzengewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Asparagaceae', 'Spargelgewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Taxodiaceae', NA, 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')), # aktuell keine Familie mehr
                        as.list(c('Droseraceae', 'Sonnentaugewaechse', 'Plants', 'Spermatophyta', 'subdivision', '0', '0', '1')),
                        as.list(c('Acoraceae', 'Kalmusartige', 'Plants', 'Angiospermae', 'clade', '1', '0', '1')), # only one genera (Kalmus), Sumpfplanze
                        as.list(c('Tiliaceae', 'Lindengewaechse', 'Plants', 'Angiospermae', 'clade', '0', '0', '1')),
                        as.list(c('Xanthorrhoeaceae', 'Grasbaumgewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Papaveraceae', 'Mohngewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Tamaricaceae', 'Tamariskengewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Cannabaceae', 'Hanfgewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Cuscutaceae', 'Seide', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Hypericaceae', 'Johanneskrautgewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Balsaminaceae', 'Balsaminengewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Zingiberaceae', 'Ingergewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Valerianaceae', 'Baldriangewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Typhaceae', 'Rohkoblemgewaechse', 'Plants', 'Angiospermen', 'clade', '1', '0', '0')),
                        as.list(c('Lauraceae', 'Lorbeergewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Melastomataceae', 'Schwarzmundgewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Sparganiaceae', 'Rohrkolbengewaechse', 'Plants', 'Angiospermen', 'clade', '1', '0', '0')), # Veraltet, heutzutage gemeinsame Familie mit Typhaceae
                        as.list(c('Elaeagnaceae', 'oelweidengewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Pontederiaceae', 'Wasserhyazinthengewaechse', 'Plants', 'Angiospermen', 'clade', '1', '0', '0')),
                        as.list(c('Cannaceae', 'Blumenrohr', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Sapindaceae', 'Seifenbaumgewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Magnoliaceae', 'Magnoliengewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Berberidaceae', 'Berberitzengewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Ulmaceae', 'Ulmengewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Ranunculaceae', 'Hahnenfussgewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Piperaceae', 'Pfeffergewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Pedaliaceae', 'Sesamgewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Musaceae', 'Bananengewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Onagraceae', 'Nachtkerzengewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Tropaeolaceae', 'Kapuzinerkressengewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Orobanchaceae', 'Sommerwurzgewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Capparaceae', 'Kaperngewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Ebenaceae', 'Ebenholzgewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Hydrangeaceae', 'Hortensiengewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Marantaceae', 'Pfeilwurzgewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Betulaceae', 'Birkengewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Pittosporaceae', 'Klebsamengewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Cactaceae', 'Kakteengewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Hamamelidaceae', 'Zaubernussgewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Boraginaceae', 'Raublattgewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Polemoniaceae', 'Sperrkrautgewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Urticaceae', 'Brennnesselgewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Nyssaceae', 'Tupelogewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')), #! Sumpfpflanzen
                        as.list(c('Amaryllidaceae', 'Amaryllisgewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Montiaceae', 'Quellkrautgewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Cleomaceae', NA, 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Asphodelaceae', NA, 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Altingiaceae', NA, 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Nelumbonaceae', 'Lotosblumen', 'Plants', 'Angiospermen', 'clade', '1', '0', '1')),
                        as.list(c('Paeoniaceae', 'Pfingstrosen', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Phyllanthaceae', NA, 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Ptiliaceae', NA, 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        as.list(c('Adoxaceae', 'Moschuskrautgewaechse', 'Plants', 'Angiospermen', 'clade', '0', '0', '1')),
                        
                        
                        #### Polypodiopsida (echte Farne) (class) ----
                        as.list(c('Salviniaceae', 'Schwimmfarngewächse', 'Plants', 'Polypodiopsida', 'class', '1', '0', '0')),
                        as.list(c('Dryopteridaceae', 'Wurmfarngewaechse', 'Plants', 'Polypodiopsida', 'class', '0', '0', '1')),
                        as.list(c('Lomariopsidaceae', NA, 'Plants', 'Polypodiopsida', 'clade', '1', '0', '1')),
                        as.list(c('Pteridaceae', 'Saumfarngewaechse', 'Plants', 'Polypodiopsida', 'class', '0', '0', '1')),
                        as.list(c('Azollaceae', 'Schwimmfarngewaechse', 'Plants', 'Polypodiopsida', 'class', '1', '0', '0')),
                        as.list(c('Characeae', NA, 'Plants', 'Charophyta', 'division', '1', '0', '0'))
                        
))


# Bryophyta (division) - Mosses -------------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        as.list(c('Mielichhoferiaceae', NA, 'Bryophyta', 'Bryopsida', 'class', '0', '0', '1')),
                        as.list(c('Dicranaceae', NA, 'Bryophyta', 'Bryopsida', 'class', '0', '0', '1')),
                        as.list(c('Dumortieraceae', NA, 'Marchantiophyta', 'Marchantiopsida', 'class', '0', '0', '1'))
))


# Algae (monophyletic group) ----------------------------------------------
# [Heterokonts](https://en.wikipedia.org/wiki/Heterokont) are distributed between Algae and Fungi chunks, although they aren't fungi but pseudofungi (usually water moulds). Generally Heterkonts seperate between Colored groups (alga-like):_Ochrophyta (phylum) and Colorless groups: Pseudofungi (unranked), Bigyra (unranked). 
lookup_man_fam = rbindlist(list(lookup_man_fam,
#### Bacteria (domain): Eubacteria (kingdom): Cyanobacteria (phylum)
as.list(c('Nostocaceae', NA, 'Algae', 'Cyanobacteria', 'phylum', '1', '0', '0')),
as.list(c('Pseudanabaenaceae', NA, 'Algae', 'Cyanobacteria', 'phylum', '0', '1', '0')),
as.list(c('Stigonemataceae', NA, 'Algae', 'Cyanobacteria', 'phylum', '1', '0', '1')),
as.list(c('Naviculaceae', NA, 'Algae', 'Cyanobacteria', 'phylum', '1', '1', '0')),
as.list(c('Fragilariaceae', NA, 'Algae', 'Cyanobacteria', 'phylum', '1', '0', '0')),
as.list(c('Chroococcaceae', NA, 'Algae', 'Cyanobacteria', 'phylum', '0', '1', '0')),
as.list(c('Oscillatoriaceae', NA, 'Algae', 'Cyanobacteria', 'phylum', '1', '1', '0')),
as.list(c('Borziaceae', NA, 'Algae', 'Cyanobacteria', 'phylum', '1', '0', '0')),
as.list(c('Aphanizomenonaceae', NA, 'Algae', 'Cyanobacteria', 'phylum', '1', '1', '0')),
as.list(c('Rivulariaceae', NA, 'Algae', 'Cyanobacteria', 'phylum', '0', '1', '0')),
as.list(c('Fortieaceae', NA, 'Algae', 'Cyanobacteria', 'phylum', '1', '1', '0')),
as.list(c('Microcystaceae', NA, 'Algae', 'Cyanobacteria', 'phylum', '1', '1', '0')),
as.list(c('Merismopediaceae', NA, 'Algae', 'Cyanobacteria', 'phylum', '0', '1', '0')),
as.list(c('Hapalosiphonaceae', NA, 'Algae', 'Cyanobacteria', 'phylum', '0', '1', '0')),
as.list(c('Scytonemataceae', NA, 'Algae', 'Cyanobacteria', 'phylum', '1', '1', '1')),
as.list(c('Phormidiaceae', NA, 'Algae', 'Cyanobacteria', 'phylum', '0', '1', '0')),

#### Eukaryota (domain): Chlorophyta (division) ----
as.list(c('Polyblepharidaceae', NA, 'Algae', 'Chlorophyta', 'phylum', '0', '1', '0')),
as.list(c('Pithophoraceae', NA, 'Algae', 'Chlorophyta', 'phylum', '0', '1', '0')),
as.list(c('Haematococcaceae', NA, 'Algae', 'Chlorophyta', 'phylum', '1', '1', '0')),
as.list(c('Ankistrodesmaceae', NA, 'Algae', 'Chlorophyta', 'phylum', '1', '1', '0')),
as.list(c('Neochloridaceae', NA, 'Algae', 'Chlorophyta', 'phylum', '1', '0', '1')),
as.list(c('Prasiolaceae', NA, 'Algae', 'Chlorophyta', 'phylum', '0', '1', '0')),
as.list(c('Hydrodictyaceae', NA, 'Algae', 'Chlorophyta','division', '1', '0', '0')),
as.list(c('Scenedesmaceae', NA, 'Algae', 'Chlorophyta','division', '1', '0', '0')),
as.list(c('Oocystaceae', NA, 'Algae', 'Chlorophyta','division', '1', '0', '0')),
as.list(c('Chlorococcaceae', NA, 'Algae', 'Chlorophyta','division', '1', '1', '0')),
as.list(c('Dictyosphaeriaceae', NA, 'Algae', 'Chlorophyta','division', '1', '1', '0')),
as.list(c('Oedogoniaceae', NA, 'Algae', 'Chlorophyta','division', '1', '0', '0')),
as.list(c('Dunaliellaceae', NA, 'Algae', 'Chlorophyta','division', '0', '1', '0')),#GA:wiki says nothing about habitat
as.list(c('Chlamydomonadaceae', NA, 'Algae', 'Chlorophyta','division', '1', '1', '0')), ##GA: havent checked were they live yet. info not on wikipedia,
as.list(c('Polyphysaceae', NA, 'Algae', 'Chlorophyta','division', '1', '1', '0')),
as.list(c('Selenastraceae', NA, 'Algae', 'Chlorophyta','division', '1', '1', '0')),
as.list(c('Cladophoraceae', NA, 'Algae', 'Chlorophyta','division', '0', '1', '0')),
as.list(c('Chlorellaceae', NA, 'Algae', 'Chlorophyta','division', '1', '1', '0')),
as.list(c('Volvocaceae', NA, 'Algae', 'Chlorophyta','division', '1', '0', '0')),  
as.list(c('Coccomyxaceae', NA, 'Algae', 'Chlorophyta','division', '1', '1', '1')), # auch symbiotisch mit Algen 
as.list(c('Ulvaceae', NA, 'Algae', 'Chlorophyta','division', '1', '1', '0')), #GA:wiki sagt nichts ueber habitat
as.list(c('Micractiniaceae', NA, 'Algae', 'Chlorophyta','division', '1', '0', '0')),
as.list(c('Dasycladaceae', NA, 'Algae', 'Chlorophyta', 'division', '1', '1', '0')), # schwierig heruazufinden wo vorkam, hauptsaechlich in Fossilien :(
as.list(c('Radiococcaceae', NA, 'Algae', 'Chlorophyta', 'division', '1', '1', '0')),
as.list(c('Chlorochytriaceae', NA, 'Algae', 'Chlorophyta', 'division', '1', '1', '0')),
as.list(c('Halimedaceae', NA, 'Algae', 'Chlorophyta', 'division', '0', '1', '0')),
as.list(c('Pterospermataceae', NA, 'Algae', 'Chlorophyta', 'division', '0', '1', '0')),
as.list(c('Ulotrichaceae', NA, 'Algae', 'Chlorophyta', 'division', '0', '1', '0')),
as.list(c('Chlorodendraceae', NA, 'Algae', 'Chlorophyta', 'division', '0', '1', '0')),
as.list(c('Chaetophoraceae', NA, 'Algae', 'Chlorophyta', 'division', '0', '1', '0')),
as.list(c('Pedinomonadaceae', NA, 'Algae', 'Chlorophyta', 'division', '0', '1', '0')),

### Eukaryota: Viridiplantae: ----
as.list(c('Klebsormidiaceae', NA, 'Algae', 'Klebsormidiophyceae', 'class', '0', '1', '0')),

#### Eukaryota: Plantae: Charophyta: ----
## Zygnematophyceae (class)
as.list(c('Zygnemataceae', NA, 'Algae', 'Zygnematophyceae', 'class', '1', '0', '0')),
as.list(c('Desmidiaceae', NA, 'Algae', 'Zygnematophyceae', 'class', '1', '1', '0')),
as.list(c('Closteriaceae', NA, 'Algae', 'Zygnematophyceae', 'class', '1', '1', '0')),

#### Eukaryota: Hacrobia: Cryptista: Cryptophyta: ----
## Cryptophyceae (class)
as.list(c('Cryptomonadaceae', NA, 'Algae', 'Cryptophyta', 'phylum', '1', '1', '0')),
as.list(c('Pyrenomonadaceae', NA, 'Algae', 'Cryptophyta', 'phylum', '0', '1', '0')),



#### Eukaryota: Hacrobia (unranked): Haptophyta (unranked): Prymnesiophyceae (class)
as.list(c('Isochrysidaceae', NA, 'Algae', 'Prymnesiophyceae', 'class', '1', '1', '0')),
as.list(c('Syracosphaeraceae', NA, 'Algae', 'Prymnesiophyceae', 'class', '1', '1', '0')),
as.list(c('Coccolithaceae', NA, 'Algae', 'Prymnesiophyceae', 'class', '1', '1', '0')),

#### Eukaryota (domain): SAR: Alveolata: Dinoflagellata (phylum) ----
as.list(c('Gonyaulacaceae', NA, 'Algae', 'Dinoflagellata', 'infraphylum', '0', '1', '0')),
as.list(c('Oxytoxaceae', NA, 'Algae', 'Dinoflagellata', 'infraphylum', '0', '1', '0')),
as.list(c('Gymnodiniaceae', NA, 'Algae', 'Dinoflagellata', 'infraphylum', '0', '1', '0')),
as.list(c('Pyrocystaceae', NA, 'Algae', 'Dinoflagellata', 'infraphylum', '0', '1', '0')),
as.list(c('Heterodiniaceae', NA, 'Algae', 'Dinoflagellata', 'infraphylum', '0', '1', '0')),
as.list(c('Peridiniaceae', NA, 'Algae', 'Dinoflagellata', 'infraphylum', '0', '1', '0')),


#### Eukaryota (domain): Rhodophyta (division) - Red algae ----
## Florideophyceae (class)
as.list(c('Gracilariaceae', NA, 'Algae', 'Rhodophyta', 'phylum', '0', '1', '0')),
as.list(c('Rhodymeniaceae', NA, 'Algae', 'Rhodophyta', 'phylum', '0', '1', '0')),
as.list(c('Ceramiaceae', NA, 'Algae', 'Rhodophyta', 'phylum', '0', '1', '0')),
## Bangiophyceae (class)
as.list(c('Bangiaceae', NA, 'Algae', 'Rhodophyta', 'phylum', '0', '1', '0')),
## Porphyridiophyceae (class)
as.list(c('Porphyridiaceae', NA, 'Algae', 'Rhodophyta', 'phylum', '0', '1', '0')),



#### Eukaryota (domain): Chromista (kingdom): Heterokonts (infrakingdom) ----
# https://en.wikipedia.org/wiki/Heterokont
## Xantophyceae (class)
as.list(c('Pleurochloridaceae', NA, 'Algae', 'Xantophyceae', 'class', '0', '1', '0')),
## Phaeophyceae (class) - Brown algae
as.list(c('Chordariaceae', NA, 'Algae', 'Phaeophyceae', 'class', '0', '1', '0')),
as.list(c('Lessoniaceae', NA, 'Algae', 'Phaeophyceae', 'class', '0', '1', '0')),
as.list(c('Hormosiraceae', NA, 'Algae', 'Phaeophyceae', 'class', '0', '1', '0')),
## Bacillariophyceae (class)
as.list(c('Rhopalodiaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '0', '1', '0')),
as.list(c('Pinnulariaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '0', '1', '0')),
as.list(c('Cocconeidaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '0', '1', '0')),
as.list(c('Entomoneidaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '0', '1', '0')),
as.list(c('Skeletonemaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '1', '1', '0')),
as.list(c('Skeletonemataceae', NA, 'Algae', 'Bacillariophyceae', 'class', '1', '1', '0')),
as.list(c('Thalassiosiraceae', NA, 'Algae', 'Bacillariophyceae', 'class', '1', '1', '0')),
as.list(c('Gomphonemataceae', NA, 'Algae', 'Bacillariophyceae', 'class', '1', '1', '0')),
as.list(c('Stauroneidaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '1', '1', '0')),
as.list(c('Bacillariaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '1', '1', '0')),
as.list(c('Cymbellaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '1', '1', '0')),
as.list(c('Achnanthidiaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '1', '1', '0')),
as.list(c('Phaeodactylaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '0', '1', '0')), 
as.list(c('Amphipleuraceae', NA, 'Algae', 'Bacillariophyceae', 'class', '0', '1', '0')),
as.list(c('Sellaphoraceae', NA, 'Algae', 'Bacillariophyceae', 'class', '0', '1', '0')),
as.list(c('Stephanodiscaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '1', '1', '0')),
as.list(c('Bacillariophyceae', NA, 'Algae', 'Bacillariophyceae', 'class', '1', '1', '0')), #! wrong! but can't find family for Frustilia
as.list(c('Tabellariaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '0', '1', '0')),
as.list(c('Nitzschiaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '1', '1', '0')),
as.list(c('Achnanthaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '0', '1', '0')),
as.list(c('Catenulaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '0', '1', '0')),
as.list(c('Aulacoseiraceae', NA, 'Algae', 'Bacillariophyceae', 'class', '0', '1', '0')),
as.list(c('Bellerocheaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '0', '1', '0')),
as.list(c('Cymatosiraceae', NA, 'Algae', 'Bacillariophyceae', 'class', '0', '1', '0')),
as.list(c('Chaetocerotaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '0', '1', '0')),
as.list(c('Eunotiaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '1', '0', '0')), # https://biotaxa.org/Phytotaxa/article/view/phytotaxa.79.2.1/0
as.list(c('Melosiraceae', NA, 'Algae', 'Bacillariophyceae', 'class', '0', '1', '0')),
as.list(c('Ulnariaceae', NA, 'Algae', 'Bacillariophyceae', 'class', '1', '0', '0')),
## Chrysophyceae (class) - Golden algae
as.list(c('Chromulinaceae', NA, 'Algae', 'Chrysophyceae', 'class', '0', '1', '0')),
as.list(c('Synuraceae', NA, 'Algae', 'Chrysophyceae', 'class', '1', '0', '0')),
as.list(c('Chromulinales', NA, 'Algae', 'Chrysophyceae', 'class', '1', '0', '0')),
as.list(c('Ochromonadaceae', 'Goldalgen', 'Algae', 'Chrysophyceae', 'class', '1','0', '0')),
as.list(c('Chrysococcaceae', NA, 'Algae', 'Chrysophyceae', 'class', '0', '1', '0')),
## Synurophyceae (class)
as.list(c('Mallomonadaceae', NA, 'Algae', 'Synurophyceae', 'class', '1', '0', '0')),
as.list(c('Dinobryaceae', NA, 'Algae', 'Synurophyceae', 'class', '1', '0', '0')),
## Raphidophyceae
as.list(c('Vacuolariaceae', NA, 'Algae', 'Raphidophyceae', 'class', '0', '1', '0')),
as.list(c('Chattonellaceae', NA, 'Algae', 'Raphidophyceae', 'class', '0', '1', '0')),
## Eustigmatophyceae
as.list(c('Monodopsidaceae', NA, 'Algae', 'Eustigmatophyceae', 'class', '0', '1', '0')),
#### Eukaryota (domain): SAR: Rhizaria: Cercozoa (phylum) ----
as.list(c('Cercomonadidae', NA, 'Algae', 'Cercozoa', 'phylum', '1', '1', '1'))
))



# Euglenozoa (phylum) -----------------------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        as.list(c('Euglenaceae', NA, 'Algae', 'Euglenozoa', 'phylum', '1', '1', '0')),
                        as.list(c('Paranemataceae', NA, 'Algae', 'Euglenozoa', 'phylum', '1', '1', '0')),
                        as.list(c('Bodinidae', NA, 'Algae', 'Euglenozoa', 'phylum', '1', '1', '0'))
))



# Ciliophora (phylum) - Wimpertierchen ------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        #### Eukaryota (domain): SAR: Alveolata: Ciliophora (phylum) ----
                        as.list(c('Didiniidae', NA, 'Ciliophora', 'Ciliophora', 'phylum', '0', '1', '0')),
                        as.list(c('Tetrahymenidae', NA, 'Ciliophora', 'Ciliophora', 'phylum', '1', '0', '0')), # some are parasitic like Ichthyophthirius multifillis (SAR) # feeds on bacteria
                        as.list(c('Parameciidae', NA, 'Ciliophora', 'Ciliophora', 'phylum', '1', '1', '1')),
                        as.list(c('Euplotidae', NA, 'Ciliophora', 'Ciliophora', 'phylum', '1', '1', '1')),
                        as.list(c('Urotrichidae', NA, 'Ciliophora', 'Ciliophora', 'phylum', '1', '1', '0')),
                        as.list(c('Oxytrichidae', NA, 'Ciliophora', 'Ciliophora', 'phylum', '1', '1', '1')),
                        as.list(c('Spirostomidae', NA, 'Ciliophora', 'Ciliophora', 'phylum', '0', '1', '0')),
                        as.list(c('Colpodidae', NA, 'Ciliophora', 'Ciliophora', 'phylum', '1', '1', '1'))
))

# Rotifera (phylum) - Raedertierchen --------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        as.list(c('Proalidae', NA, 'Rotifera', 'Rotifera', 'phylum', '0', '1', '0')),
                        as.list(c('Brachionidae', NA, 'Rotifera', 'Rotifera', 'phylum', '1', '1', '0')),
                        as.list(c('Synchaetidae', NA, 'Rotifera', 'Rotifera', 'phylum', '0', '1', '0')),
                        as.list(c('Collothecidae', NA, 'Rotifera', 'Rotifera', 'phylum', '0', '1', '0')),
                        as.list(c('Asplanchnidae', NA, 'Rotifera', 'Rotifera', 'phylum', '1', '1', '0')),
                        as.list(c('Trochosphaeridae', NA, 'Rotifera', 'Rotifera', 'phylum', '0', '1', '0')),
                        as.list(c('Lecanidae', NA, 'Rotifera', 'Rotifera', 'phylum', '1', '1', '0')),
                        as.list(c('Trichocercidae', NA, 'Rotifera', 'Rotifera', 'phylum', '0', '1', '0')),
                        as.list(c('Philodinidae', NA, 'Rotifera', 'Rotifera', 'phylum', '1', '1', '1')),
                        as.list(c('Notommatidae', NA, 'Rotifera', 'Rotifera', 'phylum', '0', '1', '0'))
))



# Fungi -------------------------------------------------------------------
lookup_man_fam =
  rbindlist(list(lookup_man_fam,
                #### Heterokonts (infrakingdom): Colorless groups: Pseudofungi: Oomycetes: ----
                #! not actually fungi but due to the lack of pigments also not photosysnthetically active
                # https://en.wikipedia.org/wiki/Heterokont
                as.list(c('Saprolegniaceae', NA, 'Fungi', 'Oomycota', 'phylum', '0', '1', '0')),
                as.list(c('Peronosporaceae', NA, 'Fungi', 'Oomycota', 'phylum', '0', '1', '0')),
                as.list(c('Lagenidiaceae', NA, 'Fungi', 'Oomycota', 'phylum', '0', '0', '1')),
                as.list(c('Pythiaceae', NA, 'Fungi', 'Oomycota', 'phylum', '0', '0', '1')),
                #### Real Fungi: ----                        
                ## Ascomycota (Schlauchpilze)
                as.list(c('Phaeosphaeriaceae', 'Knopfbecherchenverwandte', 'Fungi', 'Ascomycota', 'phylum', '0', '0', '1')),
                as.list(c('Orbiliaceae', 'Knopfbecherchenverwandte', 'Fungi', 'Ascomycota', 'phylum', '0', '0', '1')),
                as.list(c('Davidiellaceae', NA, 'Fungi', 'Ascomycota', 'phylum', '0', '0', '1')),
                as.list(c('Amphisphaeriaceae', NA, 'Fungi', 'Ascomycota', 'phylum', '0', '0', '1')),
                as.list(c('Massarinaceae', NA, 'Fungi', 'Ascomycota', 'phylum', '0', '0', '1')),
                as.list(c('Cladosporiaceae', NA, 'Fungi', 'Ascomycota', 'phylum', '0', '0', '1')),
                as.list(c('Gnomoniaceae', NA, 'Fungi', 'Ascomycota', 'phylum', '0', '0', '1')),
                as.list(c('Phlogicylindriaceae', NA, 'Fungi', 'Ascomycota', 'phylum', '0', '1', '0')),
                as.list(c('Pleosporaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Sclerotiniaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Trichocomaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Nectriaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Glomerellaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Herpotrichiellaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Togniniaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Hypocreaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Halosphaeriaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Botryosphaeriaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Erysiphaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Mycosphaerellaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Valsaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Dothioraceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Aspergillaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Saccotheciaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '1', '0')), # listed in WORMS
                as.list(c('Cordycipitaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Leotiaceae', 'Gallertkaeppchenverwandte', 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Phyllostictaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '1', '0')),
                as.list(c('Phaeomoniellaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Parmeliaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Megalariaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Acarosporaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Discinaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Laboulbeniaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Dermateaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Hyponectriaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '0', '1')),
                as.list(c('Rhizinaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '1', '0')),
                as.list(c('Montagnulaceae', NA, 'Fungi', 'Ascomycota', 'division', '0', '1', '0')),
                
                ## Basidiomycota (Staenderpilze)
                as.list(c('Meruliaceae', NA, 'Fungi', 'Basidiomycota', 'division', '0', '0', '1')),
                as.list(c('Polyporaceae', NA, 'Fungi', 'Basidiomycota', 'division', '0', '0', '1')),
                as.list(c('Pleurotaceae', NA, 'Fungi', 'Basidiomycota', 'division', '0', '0', '1')),
                as.list(c('Bankeraceae', NA, 'Fungi', 'Basidiomycota', 'division', '0', '0', '1')),
                as.list(c('Entolomataceae', NA, 'Fungi', 'Basidiomycota', 'division', '0', '0', '1')),
                as.list(c('Pucciniaceae', NA, 'Fungi', 'Basidiomycota', 'division', '0', '0', '1')),
                as.list(c('Corticiaceae', NA, 'Fungi', 'Basidiomycota', 'division', '0', '0', '1')),
                as.list(c('Ceratobasidiaceae', NA, 'Fungi', 'Basidiomycota', 'division', '0', '0', '1')),
                as.list(c('Agaricaceae', 'Champignonverwandten', 'Fungi', 'Basidiomycota', 'division', '0', '0', '1')),
                as.list(c('Quambalariaceae', NA, 'Fungi', 'Basidiomycota', 'division', '0', '0', '1')),
                as.list(c('Atheliaceae', 'Gewebehautverwandte', 'Fungi', 'Basidiomycota', 'division', '0', '1', '1')), #eigentlich terretrisch, aber eine Art bevorzugt salzwasser habitate
                as.list(c('Phanerochaetaceae', NA, 'Fungi', 'Basidiomycota', 'division', '0', '1', '1')),
                as.list(c('Physalacriaceae', NA, 'Fungi', 'Basidiomycota', 'division', '0', '0', '1')),
                
                ## Zygomycota
                as.list(c('Mucoraceae', NA, 'Fungi',  'Zygomycota', 'division', '0', '0', '1')),
                as.list(c('Neozygitaceae', NA, 'Fungi',  'Zygomycota', 'division', '0', '0', '1')),
                as.list(c('Ustilaginaceae', 'Brandpilzverwandte', 'Fungi',  'Zygomycota', 'division', '0', '0', '1')),  
                as.list(c('Suillaceae', 'Schmierroehrlingsverwandte', 'Fungi',  'Zygomycota', 'division', '0', '0', '1')),  
                as.list(c('Venturiaceae', NA, 'Fungi',  'Zygomycota', 'division', '0', '0', '1')),  
                as.list(c('Clavicipitaceae', 'Mutterkornpilzverwandte', 'Fungi',  'Zygomycota', 'division', '0', '0', '1')),
                ## Glomeromycota
                as.list(c('Glomeraceae', NA, 'Fungi',  'Glomeromycota', 'division', '0', '0', '1'))
))

# Bryozoa (phylum) --------------------------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        as.list(c('Electridae', NA, 'Bryozoa', 'Bryozoa', 'phylum', '0', '1', '0'))
))


# Amoebozoa (phylum) ------------------------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        as.list(c('Tubiferaceae', 'Blutmilchpilz', 'Amoebozoa', 'Amoebozoa', 'phylum', '0', '0', '1'))
))



# Nematoda (phylum) - Fadenwuermer ----------------------------------------
lookup_man_fam =
  rbindlist(list(lookup_man_fam,
                 as.list(c('Trichostrongylidae', NA, 'Nematoda', 'Secernentea', 'class', '0', '0', '1')),
                 as.list(c('Oxyuridae', NA, 'Nematoda', 'Secernentea', 'class', '0', '0', '1')),
                 as.list(c('Heteroxynematidae', NA, 'Nematoda', 'Secernentea', 'class', '0', '0', '1')),
                 as.list(c('Trychostrongylidae', NA, 'Nematoda', 'Secernentea', 'class', '0', '0', '1')), # parasite
                 as.list(c('Hoplolaimidae', NA, 'Nematoda', 'Secernentea', 'class', '0', '0', '1')),
                 as.list(c('Mermithidae', NA, 'Nematoda', 'Adenophorea', 'class', '0', '0', '1')),
                 as.list(c('Rhabditidae', NA, 'Nematoda', 'Adenophorea', 'class', '0', '1', '0')),
                 as.list(c('Heteroderidae', 'Ruebenzystennematode', 'Nematoda', 'Adenophorea', 'class', '0', '0', '1')),
                 as.list(c('Enoplidae', NA, 'Nematoda', 'Enoplea', 'class', '0', '1', '0')),
                 as.list(c('Monhysteridae', NA, 'Nematoda', 'Chromadorea', 'class', '0', '1', '0')),
                 as.list(c('Meloidogynidae', NA, 'Nematoda', 'Adenophorea', 'class', '0', '0', '1')),
                 as.list(c('Panagrolaimidae', NA, 'Nematoda', 'Rhabditida', 'class', '1', '1', '1'))
))


# Nemertea (phylum) - Schnurwuermer ---------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        as.list(c('Tubulanidae', NA, 'Nemertea', 'Anopla', 'class', '0', '1', '0'))
))



# Annelida (phylum) - Ringelwuermer ---------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        as.list(c('Arenicolidae', NA, 'Annelida', 'Polychaeta', 'class', '0', '1', '0')),
                        as.list(c('Capitellidae', NA, 'Annelida', 'Polychaeta', 'class', '0', '1', '0')),
                        as.list(c('Amphinomidae', NA, 'Annelida', 'Polychaeta', 'class', '0', '1', '0')),
                        as.list(c('Dorvilleidae', NA, 'Annelida', 'Polychaeta', 'class', '0', '1', '0')),
                        as.list(c('Nereididae', NA, 'Annelida', 'Polycheata', 'class', '1', '1', '0')),
                        as.list(c('Serpulidae', 'Kalkroehrenwuermer', 'Annelida', 'Polychaeta', 'class', '0', '1', '0')),
                        as.list(c('Syllidae', NA, 'Annelida', 'Polycheata', 'class', '0', '1', '0')),
                        ## Clitellata (class)
                        as.list(c('Naididae', NA, 'Annelida', 'Clitellata', 'class', '1', '1', '0')),
                        as.list(c('Lumbricidae', NA, 'Annelida', 'Clitellata', 'class', '1', '1', '0')),
                        as.list(c('Enchytraeidae', NA, 'Annelida', 'Clitellata', 'class', '0', '0', '1')),
                        as.list(c('Lumbriculidae', NA, 'Annelida', 'Clitellata', 'class', '1', '1', '0')),
                        ## Hirudinea (subclass)
                        as.list(c('Glossiphoniidae', NA, 'Annelida', 'Clitellata', 'class', '1', '0', '0')),
                        as.list(c('Erpobdellidae', NA, 'Annelida', 'Clitellata', 'class', '1', '1', '0')), ##! hard to find info on habitat
                        as.list(c('Hirudinidae', NA, 'Annelida', 'Clitellata', 'class', '1', '0', '1')),
                        as.list(c('Tubificidae', 'Schlammröhrenwürmer ', 'Annelida', 'Clitellata', 'class', '1', '1', '0')),
                        as.list(c('Acoetidae', NA, 'Annelida', 'Clitellata', 'class', '0', '1', '0')) # class Gürtelwürmer (Clitellata)
))

# Fish --------------------------------------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        ## Synbranchiformes 
                        as.list(c('Mastacembelidae', "Stachelaale", 'Fish', 'Synbranchiformes', 'order', '0', '1', '0')), # brakish
                        as.list(c('Synbranchidae', "Kiemenschlitzaale", 'Fish', 'Synbranchiformes', 'order', '0', '1', '0')), # brakish!!!
                        ## Beryciformes
                        as.list(c('Cetomimidae', "Walkoepfe", 'Fish', 'Beryciformes', 'order', '0', '1', '0')),
                        ## Tetraodontiformes
                        as.list(c('Tetraodontidae', "Kugelfische", 'Fish', 'Tetraodontiformes', 'order', '0', '1', '0')),
                        ## Batrachoidiformes
                        as.list(c('Batrachoididae', 'Froschfische', 'Fish', 'Batrachoidiformes', 'order', '0', '1', '0')),
                        ## Carangiformes
                        as.list(c('Carangidae', 'Stachelmakrelen', 'Fish', 'Carangiformes', 'order', '0', '1', '0')),
                        ## Syngnathiformes
                        as.list(c('Syngnathidae', 'Seenadel', 'Fish', 'Syngnathiformes', 'order', '0', '1', '0')),
                        ## Labriformes
                        as.list(c('Labridae', 'Lippfische', 'Fish', 'Labriformes', 'order', '0', '1', '0')),
                        ## Acipenseriformes
                        as.list(c('Acipenseridae', 'Stoere', 'Fish', 'Acipenseriformes', 'order', '1', '1', '0')),
                        ## Cypriniformes
                        as.list(c('Cyprinidae', 'Karpfenfische', 'Fish', 'Cypriniformes', 'order', '1', '1', '0')),
                        as.list(c('Balitoridae', 'Flossensauger', 'Fish', 'Cypriniformes', 'order', '1', '1', '0')),
                        as.list(c('Nemacheilidae', 'Bachschmerlen', 'Fish', 'Cypriniformes', 'order', '1', '0', '0')),
                        ## Salmoniformes
                        as.list(c('Salmonidae', 'Lachsfische', 'Fish', 'Salmoniformes', 'order', '1', '1', '0')),
                        ## Centrachiformes
                        as.list(c('Centrarchidae', 'Sonnenbarsche', 'Fish', 'Centrarchiformes', 'order', '1', '0', '0')), # Sonnenbarsche
                        as.list(c('Kyphosidae', 'Steuerbarsche', 'Fish', 'Centrarchiformes', 'order', '0', '1', '0')),
                        as.list(c('Terapontidae', 'Grunzbarsche', 'Fish', 'Centrarchiformes', 'order', '1', '1', '0')),
                        as.list(c('Teraponidae', 'Grunzbarsche', 'Fish', 'Centrarchiformes', 'order', '1', '1', '0')), # same as Terapontidae
                        ## Cyprinodontiformes
                        as.list(c('Cyprinodontidae', 'Zahnkaerpflinge', 'Fish', 'Cyprinodontiformes', 'order', '1', '0', '0')),
                        as.list(c('Poeciliidae', 'Zahnkaerpflinge', 'Fish', 'Cyprinodontiformes', 'order', '1', '0', '0')),
                        as.list(c('Fundulidae', NA, 'Fish', 'Cyprinodontiformes', 'order', '1', '1', '0')),
                        as.list(c('Cobitidae', 'Steinbeiszer', 'Fish', 'Cyprinodontiformes', 'order', '1', '0', '0')),
                        as.list(c('Aplocheilidae', NA, 'Fish', 'Cyprinodontiformes', 'order', '1', '0', '0')),
                        as.list(c('Anablepidae', NA, 'Fish', 'Cyprinodontiformes', 'order', '1', '0', '0')), # freshwater and brackish
                        ## Siluriformes
                        as.list(c('Pimelodidae', 'Antennenwelse', 'Fish', 'Siluriformes', 'order', '1', '0', '0')),
                        as.list(c('Schilbeidae', 'Glaswelse', 'Fish', 'Siluriformes', 'order', '1', '0', '0')),
                        as.list(c('Ictaluridae', 'Katzenwelse', 'Fish', 'Siluriformes', 'order', '1', '0', '0')), # endemisch in Nordamerika
                        as.list(c('Clariidae', 'Kiemensackwelse', 'Fish', 'Siluriformes', 'order', '1', '0', '0')),
                        as.list(c('Bagridae', 'Stachelwelse', 'Fish', 'Siluriformes', 'order', '1', '0', '0')),
                        as.list(c('Siluridae', "Echte Welse", 'Fish', 'Siluriformes', 'order', '1', '0', '0')),
                        as.list(c('Catostomidae', 'Saugkarpfen', 'Fish', 'Cyprinodontiformes', 'order', '1', '0', '0')),
                        as.list(c('Callichthyidae', 'Panzer- und Schwielenwelse', 'Fish', 'Cyprinodontiformes', 'order', '1', '0', '0')),
                        as.list(c('Heptapteridae', NA, 'Fish', 'Cyprinodontiformes', 'order', '1', '0', '0')),
                        as.list(c('Loricariidae', 'Harnischwelse', 'Fish', 'Cyprinodontiformes', 'order', '1', '0', '0')),
                        as.list(c('Pangasiidae', "Haiwelse", 'Fish', 'Siluriformes', 'order', '1', '1', '0')),
                        ## Perciformes
                        as.list(c('Nototheniidae', "Antaktisdorsche", 'Fish', 'Perciformes', 'order', '0', '1', '0')),
                        as.list(c('Nototheniidae', "Antaktisdorsche", 'Fish', 'Perciformes', 'order', '0', '1', '0')),
                        as.list(c('Haemulidae', 'Süßlippen und Grunzer', 'Fish', 'Perciformes', 'order', '1', '1', '0')),
                        as.list(c('Cichlidae', 'Buntbarsche', 'Fish', 'Perciformes', 'order', '1', '0', '0')), # Mittel u. Suedamerika, Afrika
                        as.list(c('Percidae', 'Echte Barsche', 'Fish', 'Perciformes', 'order', '1', '0', '0')),
                        as.list(c('Embiotocidae', 'Brandungsbarsche', 'Fish', 'Perciformes', 'order', '0', '1', '0')),
                        as.list(c('Gobiidae', 'Grundeln', 'Fish', 'Perciformes', 'order', '1', '1', '0')), # das muesste man ggf. weiter aufteilen
                        as.list(c('Sparidae', 'Meerbrassen', 'Fish', 'Perciformes', 'order', '0', '1', '0')), 
                        as.list(c('Mugilidae', 'Meeraeschen', 'Fish', 'Perciformes', 'order', '1', '1', '0')),
                        as.list(c('Moronidae', 'Wolfsbarsche', 'Fish', 'Perciformes', 'order', '1', '1', '0')),
                        as.list(c('Kuhliidae', NA, 'Fish', 'Perciformes', 'order', '1', '1', '0')),
                        as.list(c('Gasterosteidae', 'Stichlinge', 'Fish', 'Perciformes', 'order', '1', '1', '0')),
                        as.list(c('Sciaenidae', 'Umberfische', 'Fish', 'Perciformes', 'order', '1', '1', '0')),
                        as.list(c('Callionymidae', 'Umberfische', 'Fish', 'Perciformes', 'order', '0', '1', '0')),
                        as.list(c('Zoarcidae', 'Aalmuttern', 'Fish', 'Perciformes', 'order', '0', '1', '0')),
                        as.list(c('Agonidae', 'Panzergroppen', 'Fish', 'Perciformes', 'order', '0', '1', '0')),
                        as.list(c('Centropomidae', 'Panzergroppen', 'Fish', 'Perciformes', 'order', '0', '1', '0')),
                        as.list(c('Scorpaenidae', "Skorpionfische", 'Fish', 'Perciformes', 'order', '0', '1', '0')),
                        
                        ## Anabantiformes
                        as.list(c('Channidae', 'Schlangenkopffische', 'Fish', 'Anabantiformes', 'order', '1', '0', '0')), # Afrika, Asien
                        as.list(c('Heteropneustidae', 'Kiemenschlauchwelse', 'Fish', 'Anabantiformes', 'order', '1', '0', '0')), # Asien
                        as.list(c('Anabantidae', 'Kletterfische und Buschfische', 'Fish', 'Anabantiformes', 'order', '1', '1', '0')),# primarily in fresh water but also in brackish water
                        as.list(c('Osphronemidae', NA, 'Fish', 'Anabantiformes', 'order', '1', '0', '0')),
                        as.list(c('Nandidae', NA, 'Fish', 'Anabantiformes', 'order', '1', '0', '0')),
                        ## Atheriniformes
                        as.list(c('Atherinidae', 'Altweltlichen aehrenfische', 'Fish', 'Atheriniformes', 'order', '1', '1', '0')),
                        as.list(c('Atherinopsidae', 'Neuweltliche aehrenfische', 'Fish', 'Atheriniformes', 'order', '1', '1', '0')),
                        as.list(c('Melanotaeniidae', 'Regenbogenfische', 'Fish', 'Atheriniformes', 'order', '1', '0', '0')),
                        ## Anguilliformes
                        as.list(c('Anguillidae', 'Aale', 'Fish', 'Atheriniformes', 'order', '1', '1', '0')),
                        as.list(c('Muraenidae', 'Muränen', 'Fish', 'Atheriniformes', 'order', '0', '1', '0')),
                        ## Beloniformes
                        as.list(c('Adrianichthyidae', 'Reisfische', 'Fish', 'Beloniformes', 'order', '1', '0', '0')), # auch Brackwasser (Indien, Indonesien, Japan)
                        ## Osteoglossiformes
                        as.list(c('Notopteridae', 'Altwelt-Messerfische', 'Fish', 'Osteoglossiformes', 'order', '1', '0', '0')),
                        as.list(c('Mormyridae', 'Nilhechte', 'Fish', 'Osteoglossiformes', 'order', '1', '0', '0')),
                        
                        ## Pleuronectiformes
                        as.list(c('Bothidae', 'Butte', 'Fish', 'Pleuronectiformes', 'order', '0', '1', '0')),
                        as.list(c('Pleuronectidae', 'Schollen', 'Fish', 'Pleuronectiformes', 'order', '1', '1', '0')),
                        as.list(c('Soleidae', 'Seezungen', 'Fish', 'Pleuronectiformes', 'order', '1', '1', '0')),
                        as.list(c('Scophthalmidae', 'Steinbutte', 'Fish', 'Pleuronectiformes', 'order', '0', '1', '0')),
                        as.list(c('Paralichthyidae', 'Steinbutte', 'Fish', 'Pleuronectiformes', 'order', '0', '1', '0')),
                        
                        ## Osmeriformes
                        as.list(c('Osmeridae', 'Stinte', 'Fish', 'Osmeriformes', 'order', '0', '1', '0')),
                        as.list(c('Plecoglossidae', NA, 'Fish', 'Osmeriformes', 'order', '1', '1', '0')),
                        
                        ## Esociformes
                        as.list(c('Esocidae', 'Hechtartige', 'Fish', 'Esociformes', 'order', '0', '1', '0')),
                        as.list(c('Umbridae', 'Hundsfische', 'Fish', 'Esociformes', 'order', '1', '0', '0')),
                        ## Galaxiiformes
                        as.list(c('Galaxiidae', 'Galaxien', 'Fish', 'Galaxiiformes', 'order', '1', '1', '0')),
                        ## Characiformes
                        as.list(c('Curimatidae', 'Breitlingssalmler', 'Fish', 'Characiformes', 'order', '1', '0', '0')),
                        as.list(c('Lebiasinidae', 'Schlanksalmler', 'Fish', 'Characiformes', 'order', '1', '0', '0')),
                        as.list(c('Characidae', 'Echte Salmler', 'Fish', 'Characiformes', 'order', '1', '0', '0')),
                        as.list(c('Hemiodontidae', 'Keulensalmler', 'Fish', 'Characiformes', 'order', '1', '0', '0')),
                        ## Petromyzontiformes
                        as.list(c('Petromyzontidae', NA, 'Fish', 'Petromyzontiformes', 'order', '1', '1', '0')),
                        ## Clupeiformes
                        as.list(c('Clupeidae', NA, 'Fish', 'Clupeiformes', 'order', '1', '1', '0')),
                        as.list(c('Engraulidae', 'Sardellen', 'Fish', 'Clupeiformes', 'order', '1', '1', '0')), # mostly in marine envrionments
                        ## Lepisosteiformes
                        as.list(c('Lepisosteidae', NA, 'Fish', 'Clupeiformes', 'order', '1', '1', '0'))
                        
))


# Amphibia ----------------------------------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        as.list(c('Pelobatidae', NA, 'Amphibia', 'Urodela', 'order', '0', '0', '1')),
                        as.list(c('Plethodontidae', 'Lungenlose Salamander', 'Amphibia', 'Urodela', 'order', '0', '0', '1')),
                        as.list(c('Alytidae', NA, 'Amphibia', 'Anura', 'order', '1', '0', '1')),
                        as.list(c('Hylidae', 'Laubfroesche', 'Amphibia', 'Anura', 'order', '1', '0', '1')),
                        as.list(c('Limnodynastidae', 'Australische Suedfroesche', 'Amphibia', 'Anura', 'order', '1', '0', '1')),
                        as.list(c('Myobatrachidae', 'Australische Suedfroesche', 'Amphibia', 'Anura', 'order', '1', '0', '1')),
                        as.list(c('Ambystomatidae', NA, 'Amphibia', 'Anura', 'order', '1', '0', '1')),
                        as.list(c('Bufonidae', 'Kroeten', 'Amphibia', 'Anura', 'order', '0', '0', '1')),
                        as.list(c('Bombinatoridae', 'Unken und Barbourfroesche', 'Amphibia', 'Anura', 'order', '1', '0', '1')),
                        as.list(c('Microhylidae', 'Engmaulfroesche', 'Amphibia', 'Anura', 'order', '1', '0', '1')),
                        as.list(c('Dicroglossidae', NA, 'Amphibia', 'Anura', 'order', '1', '0', '1')),
                        as.list(c('Pipidae', 'Zungenlose', 'Amphibia', 'Anura', 'order', '1', '0', '1')), # only adults are terrestrial
                        as.list(c('Leiuperidae', NA, 'Amphibia', 'Anura', 'order', '1', '0', '1')),
                        as.list(c('Leptodactylidae', 'Pfeiffrösche', 'Amphibia', 'Anura', 'order', '1', '0', '1')),
                        as.list(c('Scaphiopodidae', "Amerikanische Schaufelfußkröte", 'Amphibia', 'Anura', 'order', '1', '0', '1')),
                        as.list(c('Rhacophoridae', "Ruderfrösche", 'Amphibia', 'Anura', 'order', '1', '0', '1')),
                        as.list(c('Ranidae', "Echte Frösche", 'Amphibia', 'Anura', 'order', '1', '0', '1')),
                        
                        ## Caudata (order)
                        as.list(c('Salamandridae', 'Echte Samalander', 'Amphibia', 'Caudata', 'order', '1', '0', '1'))
))



# Reptilia ----------------------------------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        as.list(c('Eublepharidae', NA, 'Reptilia', 'Squamata', 'order', '1', '0', '1')),
                        as.list(c('Scincidae', NA, 'Reptilia', 'Squamata', 'order', '0', '0', '1'))
                        
))


# Crustacea (subphylum) ---------------------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        as.list(c('Triopsidae', 'Rückenschaler', 'Crustacea', 'Notostraca', 'order', '1', '0', '0')),
                        as.list(c('Thamnocephalidae', NA, 'Crustacea', 'Anostraca', 'order', '1', '0', '0')),
                        as.list(c('Streptocephalidae', NA, 'Crustacea', 'Anostraca', 'order', '1', '0', '0')),
                        # Crustacea (subphylum)
                        ## Branchiopoda (class)
                        ### Cladocera (order)
                        as.list(c('Holopediidae', 'Wasserfloehe', 'Crustacea', 'Cladocera', 'order', '1', '1', '0')),
                        as.list(c('Daphniidae', 'Wasserfloehe', 'Crustacea', 'Cladocera', 'order', '1', '0', '0')),
                        as.list(c('Artemiidae', 'Salzwasserkrebse', 'Crustacea', 'Cladocera', 'order', '1', '0', '0')), # Binnensalzgewaesser, nicht im Meer!
                        as.list(c('Macrothricidae', NA, 'Crustacea', 'Cladocera', 'order', '1', '0', '0')),
                        as.list(c('Moinidae', NA, 'Crustacea', 'Cladocera', 'order', '1', '1', '0')), #GA: fresh and brackish waters
                        as.list(c('Chydoridae', NA, 'Crustacea', 'Cladocera', 'order', '1', '1', '0')),
                        as.list(c('Bosminidae', NA, 'Crustacea', 'Cladocera', 'order', '1', '1', '0')),
                        as.list(c('Sididae', NA, 'Crustacea', 'Cladocera', 'order', '1', '1', '0')),
                        as.list(c('Ilyocryptidae', NA, 'Crustacea', 'Cladocera', 'order', '1', '0', '0')),
                        ## Malacostraca (class)
                        ### Cumacea (order)
                        as.list(c('Leuconidae', NA, 'Crustacea', 'Cumacea', 'order', '1', '1', '0')), # also brackish
                        ### Amphipoda (order)
                        as.list(c('Niphargidae', NA, 'Crustacea', 'Amphipoda', 'order', '1', '0', '0')),
                        as.list(c('Neoniphargidae', NA, 'Crustacea', 'Amphipoda', 'order', '1', '0', '0')),
                        as.list(c('Gammaridae', 'Bachflohkrebse', 'Crustacea', 'Amphipoda', 'order', '1', '0', '0')),
                        as.list(c('Hyalellidae', 'Bachflohkrebse', 'Crustacea', 'Amphipoda', 'order', '1', '0', '0')), # used to belong to Gammaridae
                        as.list(c('Parathelphusidae', NA, 'Crustacea', 'Amphipoda', 'order', '1', '0', '0')), # ASia
                        as.list(c('Phoxocephalidae', NA, 'Crustacea', 'Amphipoda', 'order', '0', '1', '0')),
                        as.list(c('Melitidae', NA, 'Crustacea', 'Amphipoda', 'order', '1', '1', '0')),
                        as.list(c('Ampeliscidae', NA, 'Crustacea', 'Amphipoda', 'order', '0', '1', '0')),
                        as.list(c('Pontoporeiidae', NA, 'Crustacea', 'Amphipoda', 'order', '1', '1', '0')),
                        as.list(c('Haustoriidae', NA, 'Crustacea', 'Amphipoda', 'order', '0', '1', '0')),
                        as.list(c('Talitridae', NA, 'Crustacea', 'Amphipoda', 'order', '1', '1', '1')),
                        as.list(c('Paramelitidae', NA, 'Crustacea', 'Amphipoda', 'order', '1', '0', '0')),
                        as.list(c('Aoridae', NA, 'Crustacea', 'Amphipoda', 'order', '0', '1', '0')),
                        
                        ### Decapoda
                        as.list(c('Potamidae', NA, 'Crustacea', 'Decapoda', 'order', '1', '0', '0')),
                        as.list(c('Palaemonidae', 'Felsen- und Partnergarnelen', 'Crustacea', 'Decapoda', 'order', '1', '1', '0')),
                        as.list(c('Cancridae', 'Taschenkrebse', 'Crustacea', 'Decapoda', 'order', '0', '1', '0')),
                        as.list(c('Portunidae', 'Schwimmkrabben', 'Crustacea', 'Decapoda', 'order', '1', '1', '0')),
                        as.list(c('Crangonidae', NA, 'Crustacea', 'Decapoda', 'order', '0', '1', '0')),
                        as.list(c('Cambaridae', NA, 'Crustacea', 'Decapoda', 'order', '1', '0', '0')), # ueberfam.: Flusskrebse
                        as.list(c('Sesarmidae', NA, 'Crustacea', 'Decapoda', 'order', '0', '1', '0')),
                        as.list(c('Grapsidae', 'Quadratkrabben', 'Crustacea', 'Decapoda', 'order', '1', '1', '1')), # hauptsaechlich in den Tropen
                        as.list(c('Nephropidae', 'Hummerartige', 'Crustacea', 'Decapoda', 'order', '0', '1', '0')),
                        as.list(c('Pandalidae', 'Tiefseegarnelen', 'Crustacea', 'Decapoda', 'order', '0', '1', '0')),
                        as.list(c('Paguridae', 'Rechtshaendige Einsiedlerkrebse', 'Crustacea', 'Decapoda', 'order', '0', '1', '0')),
                        as.list(c('Ocypodidae', NA, 'Crustacea', 'Decapoda', 'order', '0', '1', '1')),
                        as.list(c('Xanthidae', NA, 'Crustacea', 'Decapoda', 'order', '0', '1', '0')), #lebensraum in wikipedia nicht beschrieben
                        as.list(c('Atyidae', 'Suesswassergarnelen', 'Crustacea', 'Decapoda', 'order', '1', '1', '0')), #GA:keine richtigen marinen arten, aber manche leben in brackwasser
                        as.list(c('Alpheidae', 'Knallkrebse', 'Crustacea', 'Decapoda', 'order', '0', '1', '0')),
                        as.list(c('Gecarcinucidae', NA, 'Crustacea', 'Decapoda', 'order', '1', '0', '0')),
                        as.list(c('Parastacidae', NA, 'Crustacea', 'Decapoda', 'order', '1', '0', '0')),
                        as.list(c('Astacidae', NA, 'Crustacea', 'Decapoda', 'order', '1', '0', '0')),
                        as.list(c('Panopeidae', NA, 'Crustacea', 'Decapoda', 'order', '0', '1', '0')),
                        as.list(c('Trichodactylidae', NA, 'Crustacea', 'Decapoda', 'order', '1', '0', '0')),
                        as.list(c('Hippolytidae', 'Putzer- und Marmorgarnelen', 'Crustacea', 'Decapoda', 'order', '0', '1', '0')),
                        as.list(c('Macrophthalmidae', NA, 'Crustacea', 'Decapoda', 'order', '0', '1', '0')),
                        as.list(c('Majidae', 'Dreieckskrabben', 'Crustacea', 'Decapoda', 'order', '0', '1', '0')),
                        as.list(c('Menippidae', NA, 'Crustacea', 'Decapoda', 'order', '0', '1', '0')),
                        as.list(c('Diogenidae', NA, 'Crustacea', 'Decapoda', 'order', '0', '1', '0')),
                        as.list(c('Lithodidae', NA, 'Crustacea', 'Decapoda', 'order', '0', '1', '0')),
                        as.list(c('Luciferidae', NA, 'Crustacea', 'Decapoda', 'order', '0', '1', '0')),
                        
                        ### Mysida (order)
                        as.list(c('Mysidae', 'Wasserfloehe', 'Crustacea', 'Mysida', 'order', '1', '1', '0')), # Porter et al. 2008
                        as.list(c('Varunidae', NA, 'Crustacea', 'Mysida', 'order', '0', '1', '0')),
                        ### Isopoda (order)
                        as.list(c('Penaeidae', NA, 'Crustacea', 'Isopoda', 'order', '0', '1', '0')), # ev. genauere Differnzierung ueber Genera
                        as.list(c('Asellidae', NA, 'Crustacea', 'Isopoda', 'order', '1', '0', '1')),
                        as.list(c('Armadillidiidae', NA, 'Crustacea', 'Isopoda', 'order', '0', '0', '1')),
                        as.list(c('Porcellionidae', NA, 'Crustacea', 'Isopoda', 'order', '0', '0', '1')), # lebensraum in wikipedia nicht beschrieben
                        as.list(c('Oniscidae', NA, 'Crustacea', 'Isopoda', 'order', '0', '0', '1')),
                        as.list(c('Phreatoicidae', NA, 'Crustacea', 'Isopoda', 'order', '1', '0', '0')),
                        as.list(c('Bopyridae', NA, 'Crustacea', 'Isopoda', 'order', '1', '1', '0')),
                        as.list(c('Sphaeromatidae', NA, 'Crustacea', 'Isopoda', 'order', '1', '1', '0')),
                        
                        
                        ## Ostracoda (class)
                        as.list(c('Cypridopsinae', NA, 'Crustacea', 'Ostracoda', 'class', '1', '0', '0')),
                        as.list(c('Cyprididae', NA, 'Crustacea', 'Ostracoda', 'class', '1', '0', '0')), # the most diverse group of freshwater ostracods
                        as.list(c('Ilyocyprididae', NA, 'Crustacea', 'Ostracoda', 'class', '1', '0', '0')),
                        as.list(c('Notodromadidae', NA, 'Crustacea', 'Ostracoda', 'class', '0', '1', '0')),
                        
                        ## Copepoda (subclass)
                        as.list(c('Temoridae', NA, 'Crustacea', 'Copepoda', 'subclass', '1', '1', '0')),
                        as.list(c('Ameiridae', NA, 'Crustacea', 'Copepoda', 'subclass', '1', '1', '0')), 
                        as.list(c('Harpacticidae', NA, 'Crustacea', 'Copepoda', 'subclass', '1', '1', '0')),
                        as.list(c('Acartiidae', NA, 'Crustacea', 'Copepoda', 'subclass', '0', '1', '0')),
                        as.list(c('Diosaccidae', NA, 'Crustacea', 'Copepoda', 'subclass', '0', '1', '0')),
                        as.list(c('Centropagidae', NA, 'Crustacea', 'Copepoda', 'subclass', '1', '1', '0')),
                        as.list(c('Caligidae', NA, 'Crustacea', 'Copepoda', 'subclass', '0', '1', '0')),
                        as.list(c('Canthocamptidae', NA, 'Crustacea', 'Copepoda', 'subclass', '1', '1', '0')), #GA: only few marine species
                        as.list(c('Cyclopidae', NA, 'Crustacea', 'Copepoda', 'subclass', '1', '1', '0')),
                        as.list(c('Tisbidae', NA, 'Crustacea', 'Copepoda', 'subclass', '1', '1', '0')),
                        as.list(c('Diaptomidae', NA, 'Crustacea', 'Copepoda', 'subclass', '1', '0', '0')),
                        as.list(c('Eucalanidae', NA, 'Crustacea', 'Copepoda', 'subclass', '0', '1', '0')),
                        as.list(c('Clausocalanidae', NA, 'Crustacea', 'Copepoda', 'subclass', '0', '1', '0')),
                        as.list(c('Laophontidae', NA, 'Crustacea', 'Copepoda', 'subclass', '0', '1', '0')),
                        as.list(c('Pseudodiaptomidae', NA, 'Crustacea', 'Calanoida', 'order', '1', '1', '0')),
                        as.list(c('Oithonidae', NA, 'Crustacea', 'Copepoda', 'subclass', '1', '1', '0')),
                        
                        ## Thecostraca (subclass)
                        as.list(c('Balanidae', 'Seepocken', 'Crustacea', 'Thecostraca', 'subclass', '0', '1', '0'))
))


# Diplopoda (class) -------------------------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        as.list(c('Julidae', NA, 'Diplopoda', 'Julida', 'order', '0', '1', '1'))
))


# Insecta (class) ---------------------------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        ## Dermaptera (order)
                        as.list(c('Forficulidae', NA, 'Insecta', 'Dermaptera', 'order', '0', '0', '1')),
                        ## Megaloptera (order)
                        as.list(c('Corydalidae', NA, 'Insecta', 'Megaloptera', 'order', '1', '0', '1')),
                        as.list(c('Sialidae', "Schlammfliegen", 'Insecta', 'Megaloptera', 'order', '1', '0', '1')),
                        ## Diptera (order)
                        as.list(c('Mycetophilidae', 'Pilzmücken', 'Insecta', 'Diptera', 'order', '0', '0', '1')),
                        as.list(c('Culicidae', 'Stechmuecken', 'Insecta', 'Diptera', 'order', '1', '0', '1')),
                        as.list(c('Muscidae', 'Echte Fliegen', 'Insecta', 'Diptera', 'order', '0', '0', '1')),
                        as.list(c('Chironomidae', 'Zuckmuecken', 'Insecta', 'Diptera', 'order', '1', '1', '0')),
                        as.list(c('Agromyzidae', 'Minierfliegen', 'Insecta', 'Diptera', 'order', '0', '0', '1')),
                        as.list(c('Simuliidae', 'Kriebelmuecken', 'Insecta', 'Diptera', 'order', '1', '0', '1')),
                        as.list(c('Cecidomyiidae', 'Gallmuecken', 'Insecta', 'Diptera', 'order', '0', '0', '1')),
                        as.list(c('Anthomyiidae', 'Blumenfliegen', 'Insecta', 'Diptera', 'order', '0', '0', '1')),
                        as.list(c('Syrphidae', 'Schwebfliegen', 'Insecta', 'Diptera', 'order', '0', '0', '1')),
                        as.list(c('Drosophilidae', 'Taufliegen', 'Insecta', 'Diptera', 'order', '0', '0', '1')),
                        as.list(c('Ceratopogonidae', 'Gnitzen', 'Insecta', 'Diptera', 'order', '1', '0', '1')),
                        as.list(c('Chaoboridae', 'Bueschelmuecken', 'Insecta', 'Diptera', 'order', '1', '0', '1')),
                        as.list(c('Tephritidae', 'Bohrfliegen', 'Insecta', 'Diptera', 'order', '0', '0', '1')),
                        as.list(c('Chloropidae', 'Halmfliegen', 'Insecta', 'Diptera', 'order', '0', '0', '1')),
                        as.list(c('Limoniidae', 'Stelzmuecken', 'Insecta', 'Diptera', 'order', '0', '0', '1')),
                        as.list(c('Athericidae', 'Ibisfliegen', 'Insecta', 'Diptera', 'order', '0', '0', '1')),
                        as.list(c('Tipulidae', 'Schnaken', 'Insecta', 'Diptera', 'order', '0', '0', '1')),
                        as.list(c('Calliphoridae', 'Schmeißfliegen', 'Insecta', 'Diptera', 'order', '0', '0', '1')),
                        as.list(c('Sciaridae', "Trauermücke", 'Insecta', 'Diptera', 'order', '0', '0', '1')),
                        
                        ## Lepidoptera
                        as.list(c('Heliodinidae', NA, 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Noctuidae', 'Eulenfalter', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Tortricidae', 'Wickler', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Pyralidae', 'Zuensler', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Crambidae', 'Eulenfalter', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Aphididae', 'Roehrenblattlaeuse', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Plutellidae', 'Schleier- und Halbmotten', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Sphingidae', 'Schwaermer', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Gelechiidae', 'Palpenmotten', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Papilionidae', 'Ritterfalter', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Lycaenidae', 'Blaeulinge', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Nepticulidae', 'Zwergminiermotten', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Pieridae', 'Weißlinge', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Blastobasidae', NA, 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Arctiidae', 'Baerenspinner', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Psychidae', 'Echte Sacktraeger', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Gracillariidae', 'Miniermotten', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Lasiocampidae', 'Wollraupenspinner', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Geometridae', 'Spanner', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Erebidae', NA, 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Nolidae', 'Kahneulchen', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Bombycidae', 'Echte Spinner', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        as.list(c('Saturniidae', 'Pfauenspinner', 'Insecta', 'Lepidoptera', 'order', '0', '0', '1')),
                        ## Hemiptera
                        as.list(c('Adelgidae', NA, 'Insecta', 'Hemiptera', 'order', '1', '0', '0')),
                        as.list(c('Nepidae', "Skorpionswanzen", 'Insecta', 'Hemiptera', 'order', '1', '0', '0')),
                        as.list(c('Aleyrodidae', NA, 'Insecta', 'Hemiptera', 'order', '0', '0', '1')),
                        as.list(c('Delphacidae', NA, 'Insecta', 'Hemiptera', 'order', '0', '0', '1')),
                        as.list(c('Diaspididae', 'Deckelschildlaeuse', 'Insecta', 'Hemiptera', 'order', '0', '0', '1')),
                        as.list(c('Pentatomidae', 'Baumwanzen', 'Insecta', 'Hemiptera', 'order', '0', '0', '1')), # superfamily: Pentatomoidea
                        as.list(c('Lygaeidae', 'Bodenwanzen', 'Insecta', 'Hemiptera', 'order', '0', '0', '1')), #! were changed to Geocoridae?
                        as.list(c('Geocoridae', 'Bodenwanzen', 'Insecta', 'Hemiptera', 'order', '0', '0', '1')),
                        as.list(c('Cicadellidae', 'Zwergzikaden', 'Insecta', 'Hemiptera', 'order', '0', '0', '1')),
                        as.list(c('Anthocoridae', 'Blumenwanzen', 'Insecta', 'Hemiptera', 'order', '0', '0', '1')),
                        as.list(c('Miridae', 'Weichwanzen', 'Insecta', 'Hemiptera', 'order', '0', '0', '1')),
                        as.list(c('Coccidae', 'Napfschilzwanze', 'Insecta', 'Hemiptera', 'order', '0', '0', '1')),
                        as.list(c('Cercopidae', 'Blutzikade', 'Insecta', 'Hemiptera', 'order', '0', '0', '1')),
                        as.list(c('Pseudococcidae', 'Schmierlaeuse', 'Insecta', 'Hemiptera', 'order', '0', '0', '1')),
                        as.list(c('Psyllidae', NA, 'Insecta', 'Hemiptera', 'order', '0', '0', '1')),
                        as.list(c('Aphrophoridae', 'Schaumzikaden', 'Insecta', 'Hemiptera', 'order', '0', '0', '1')),
                        as.list(c('Aphalaridae', NA, 'Insecta', 'Hemiptera', 'order', '0', '0', '1')),
                        as.list(c('Belostomatidae', 'Riesenwanzen', 'Insecta', 'Hemiptera', 'order', '0', '0', '1')),
                        as.list(c('Gerridae', 'Wasserlaeufer', 'Insecta', 'Hemiptera', 'order', '1', '0', '0')),
                        as.list(c('Cicadidae', 'Singzikade', 'Insecta', 'Hemiptera', 'order', '0', '0', '1')),
                        as.list(c('Nabidae', 'Sichelwanzen', 'Insecta', 'Hemiptera', 'order', '0', '0', '1')),
                        as.list(c('Pleidae', "Zwergrückenschwimmer", 'Insecta', 'Hemiptera', 'order', '1', '0', '0')),
                        
                        #### Nepomorpha - Wasserwanzen
                        as.list(c('Notonectidae', 'Rueckenschwimmer', 'Insecta', 'Hemiptera', 'order', '1', '0', '1')), 
                        as.list(c('Corixidae', 'Ruderwanzen', 'Insecta', 'Hemiptera', 'order', '1', '0', '1')),
                        as.list(c('Micronectidae', 'Singzikade', 'Insecta', 'Hemiptera', 'order', '1', '0', '0')),
                        
                        
                        ## Hymenoptera
                        as.list(c('Halictidae', NA, 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        as.list(c('Aphidiinae', NA, 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        as.list(c('Eumenidae', 'Solitäre Faltenwespen', 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        as.list(c('Apidae', 'Bienen', 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        as.list(c('Trichogrammatidae', NA, 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        as.list(c('Braconidae', 'Brackwespen', 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        as.list(c('Curculionidae', 'Ruesselkaefer', 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        as.list(c('Eulophidae', 'Erzwespen', 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        as.list(c('Ichneumonidae', 'Schlupfwespen', 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        as.list(c('Scelionidae', NA, 'Insecta', 'Hymenoptera', 'order', '1', '0', '1')), # few attack aqu Insecta under water
                        as.list(c('Aphelinidae', NA, 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        as.list(c('Vespidae', 'Faltenwespen', 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        as.list(c('Formicidae', 'Ameisen', 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        as.list(c('Encyrtidae', NA, 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')), # parasites
                        as.list(c('Tenthredinidae', 'Echte Blattwespen', 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        as.list(c('Eupelmidae', NA, 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')), # parasisch
                        as.list(c('Megachilidae', NA, 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')), 
                        as.list(c('Cephidae', 'Halmwespen', 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        as.list(c('Cynipidae', 'Gallwespen', 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        as.list(c('Mymaridae', 'Zwergwespen', 'Insecta', 'Hymenoptera', 'order', '1', '0', '1')),
                        as.list(c('Figitidae', NA, 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        as.list(c('Dryinidae', NA, 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        as.list(c('Pteromalidae', NA, 'Insecta', 'Hymenoptera', 'order', '0', '0', '1')),
                        
                        
                        ## Coleoptera (Kaefer)
                        as.list(c('Cucujidae', 'Plattkaefer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        as.list(c('Lymexylidae', 'Werftkaefer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        as.list(c('Cetoniidae', 'Rosenkaefer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        as.list(c('Coccinellidae', 'Marienkaefer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        as.list(c('Chrysomelidae', 'Blattkaefer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        as.list(c('Scarabaeidae', 'Blattkaefer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        as.list(c('Tenebrionidae', 'Schwarzkaefer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        as.list(c('Carabidae', 'Laufkaefer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        as.list(c('Nitidulidae', 'Glanzkaefer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        # Amphicrossus japonicus (einziger Glanzkaefer der adult ins Wasser geht)
                        as.list(c('Bostrichidae', 'Bohrkaefer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        as.list(c('Elateridae', 'Schnellkaefer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        as.list(c('Trogidae', 'Erdkaefer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        as.list(c('Buprestidae', 'Prachtkaefer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        as.list(c('Erirhinidae', NA, 'Insecta', 'Coleoptera', 'order', '0', '0', '1')), # ist eine Familie der Ruesselkaefer
                        as.list(c('Dytiscidae', 'Schwimmkaefer', 'Insecta', 'Coleoptera', 'order', '1', '0', '0')),
                        as.list(c('Cantharidae', 'Weichkaefer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')), 
                        as.list(c('Cerambycidae', 'Bockkaefer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')), 
                        as.list(c('Staphylinidae', 'Kurzfluegler', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')), 
                        as.list(c('Anthicidae', 'Bluetenmulmkaefer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        as.list(c('Hydrophilidae', 'Wasserkaefer', 'Insecta', 'Coleoptera', 'order', '1', '0', '1')),
                        as.list(c('Laemophloeidae', NA, 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        as.list(c('Histeridae', 'Stutzkaefer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        as.list(c('Anobiidae', 'Nagekäfer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        as.list(c('Cryptophagidae', 'Schimmelkäfer', 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        as.list(c('Silvanidae', NA, 'Insecta', 'Coleoptera', 'order', '0', '0', '1')),
                        
                        #### Coleoptera in aquatic habitats
                        as.list(c('Gyrinidae', 'Taumelkäfer', 'Insecta', 'Coleoptera', 'order', '1', '0', '0')), # water beetles
                        as.list(c('Brentidae', 'Taumelkäfer', 'Insecta', 'Coleoptera', 'order', '1', '0', '0')),
                        as.list(c('Haliplidae', 'Wassertreter', 'Insecta', 'Coleoptera', 'order', '1', '0', '1')),
                        
                        
                        
                        ## Neuroptera (Netzfluegler)
                        as.list(c('Sisyridae', NA, 'Insecta', 'Neuroptera', 'order', '1', '0', '0')),
                        as.list(c('Nevrorthidae', NA, 'Insecta', 'Neuroptera', 'order', '1', '0', '0')),
                        as.list(c('Osmylidae', NA, 'Insecta', 'Neuroptera', 'order', '1', '0', '0')),
                        as.list(c('Chrysopidae', 'Florfliegen', 'Insecta', 'Neuroptera', 'order', '0', '0', '1')),
                        
                        ## Othoptera
                        as.list(c('Gryllidae', NA, 'Insecta', 'Othoptera', 'order', '0', '0', '1')),
                        as.list(c('Acrididae', NA, 'Insecta', 'Othoptera', 'order', '0', '0', '1')),
                        ## Thripidae
                        as.list(c('Thripidae', NA, 'Insecta', 'Thysanoptera', 'order', '0', '0', '1')), # probably paraphyletic group
                        ## Blattodea (Schaben)
                        as.list(c('Kalotermitidae', NA, 'Insecta', 'Blattodea', 'order', '0', '0', '1')),
                        as.list(c('Blattellidae', NA, 'Insecta', 'Blattodea', 'order', '0', '0', '1')),
                        as.list(c('Ectobiidae', NA, 'Insecta', 'Blattodea', 'order', '0', '0', '1')), # new name of Blattellidae
                        as.list(c('Blattidae', 'Schaben', 'Insecta', 'Blattodea', 'order', '0', '0', '1')),
                        ## Isoptera
                        as.list(c('Termitidae', NA, 'Insecta', 'Isoptera', 'order', '0', '0', '1')),
                        as.list(c('Rhinotermitidae', NA, 'Insecta', 'Isoptera', 'order', '0', '0', '1')),
                        ## Ephemeroptera (Eintagsfliegen) larval aquatisch, adult terrestrisch
                        as.list(c('Baetidae', NA, 'Insecta', 'Ephemeroptera', 'order', '1', '0', '1')),
                        as.list(c('Heptageniidae', NA, 'Insecta', 'Ephemeroptera', 'order', '1', '0', '1')),
                        as.list(c('Ephemerellidae', NA, 'Insecta', 'Ephemeroptera', 'order', '1', '0', '1')),
                        as.list(c('Ephemeridae', NA, 'Insecta', 'Ephemeroptera', 'order', '1', '0', '1')),
                        as.list(c('Siphlonuridae', NA, 'Insecta', 'Ephemeroptera', 'order', '1', '0', '1')),
                        as.list(c('Caenidae', NA, 'Insecta', 'Ephemeroptera', 'order', '1', '0', '1')),
                        as.list(c('Leptophlebiidae', NA, 'Insecta', 'Ephemeroptera', 'order', '1', '0', '1')),
                        as.list(c('Polymitarcyidae', NA, 'Insecta', 'Ephemeroptera', 'order', '1', '0', '1')),
                        as.list(c('Isonychiidae', NA, 'Insecta', 'Ephemeroptera', 'order', '1', '0', '1')),
                        as.list(c('Leptohyphidae', NA, 'Insecta', 'Ephemeroptera', 'order', '1', '0', '1')),
                        as.list(c('Ameletidae', NA, 'Insecta', 'Ephemeroptera', 'order', '1', '0', '1')),
                        ## Trichoptera (Koecherfliegen) i.d.R. larval aquatisch (in den Tropen ein paar Ausnahmen), Adult terrestisch
                        as.list(c('Hydropsychidae', NA, 'Insecta', 'Trichoptera', 'order', '1', '0', '1')),
                        as.list(c('Limnephilidae', NA, 'Insecta', 'Trichoptera', 'order', '1', '0', '1')),
                        as.list(c('Brachycentridae', NA, 'Insecta', 'Trichoptera', 'order', '1', '0', '1')),
                        as.list(c('Philopotamidae', NA, 'Insecta', 'Trichoptera', 'order', '1', '0', '1')),
                        as.list(c('Polycentropodidae', NA, 'Insecta', 'Trichoptera', 'order', '1', '0', '1')),
                        as.list(c('Helicopsychidae', NA, 'Insecta', 'Trichoptera', 'order', '1', '0', '1')),
                        as.list(c('Goeridae', NA, 'Insecta', 'Trichoptera', 'order', '1', '0', '1')),
                        as.list(c('Lepidostomatidae', NA, 'Insecta', 'Trichoptera', 'order', '1', '0', '1')),
                        as.list(c('Leptoceridae', NA, 'Insecta', 'Trichoptera', 'order', '1', '0', '1')),
                        as.list(c('Molannidae', NA, 'Insecta', 'Trichoptera', 'order', '1', '0', '1')),
                        as.list(c('Odontoceridae', NA, 'Insecta', 'Trichoptera', 'order', '1', '0', '1')),
                        ## Plecoptera (Steinfliegen) - larval aquatisch, adult terrestrisch
                        as.list(c('Pteronarcyidae', NA, 'Insecta', 'Plecoptera', 'order', '1', '0', '1')),
                        as.list(c('Perlidae', NA, 'Insecta', 'Plecoptera', 'order', '1', '0', '1')),
                        as.list(c('Perlodidae', NA, 'Insecta', 'Plecoptera', 'order', '1', '0', '1')),
                        as.list(c('Capniidae', NA, 'Insecta', 'Plecoptera', 'order', '1', '0', '1')),
                        as.list(c('Peltoperlidae', NA, 'Insecta', 'Plecoptera', 'order', '1', '0', '1')),
                        as.list(c('Leuctridae', NA, 'Insecta', 'Plecoptera', 'order', '1', '0', '1')),
                        as.list(c('Nemouridae', NA, 'Insecta', 'Plecoptera', 'order', '1', '0', '1')),
                        as.list(c('Taeniopterygidae', NA, 'Insecta', 'Plectoptera', 'order', '1', '0', '1')),
                        
                        ## Siphonaptera
                        as.list(c('Pulicidae', NA, 'Insecta', 'Siphonaptera', 'order', '0', '0', '1')),# parasites
                        ## Odonata
                        as.list(c('Libellulidae', 'Segellibellen', 'Insecta', 'Odonata', 'order', '1', '0', '1')),
                        as.list(c('Aeshnidae', 'Edellibellen', 'Insecta', 'Odonata', 'order', '1', '0', '1')),
                        as.list(c('Lestidae', 'Teichjungfern', 'Insecta', 'Odonata', 'order', '1', '0', '1')),
                        as.list(c('Coenagrionidae', 'Schlanklibellen', 'Insecta', 'Odonata', 'order', '1', '0', '1')),
                        as.list(c('Corduliidae', 'Falkenlibellen', 'Insecta', 'Odonata', 'order', '1', '0', '1')),
                        as.list(c('Gomphidae', 'Flussjungfern', 'Insecta', 'Odonata', 'order', '1', '0', '1'))
)) 



# Entognatha --------------------------------------------------------------
# class: Entognatha, sunclass: Collembola
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        as.list(c('Isotomidae', NA, 'Entognatha', 'Collembola', 'subclass', '0', '0', '1')),
                        as.list(c('Onychiuridae', NA, 'Entognatha', 'Collembola', 'subclass', '0', '0', '1')),
                        as.list(c('Sminthuridae', NA, 'Entognatha', 'Collembola', 'subclass', '0', '0', '1')),
                        as.list(c('Entomobryidae', NA, 'Entognatha', 'Collembola', 'subclass', '0', '0', '1')),
                        as.list(c('Poduromorpha', NA, 'Entognatha', 'Collembola', 'subclass', '0', '0', '1')),
                        as.list(c('Tullbergiidae', NA, 'Entognatha', 'Collembola', 'subclass', '0', '0', '1')),
                        as.list(c('Dermestidae', 'Speckkäfer', 'Entognatha', 'Collembola', 'subclass', '0', '0', '1')),
                        ## im Wasser lebend:
                        as.list(c('Poduridae', 'Wasserspringer', 'Entognatha', 'Collembola', 'subclass', '1', '0', '0'))
                        
))


# Arachnida (class) -------------------------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        ## Acari (Milben) (subclass)
                        as.list(c('Suctobelbidae', NA, 'Arachnida', 'Acari', 'subclass', '0', '0', '1')),
                        as.list(c('Polyaspididae', NA, 'Arachnida', 'Acari', 'subclass', '0', '0', '1')),
                        as.list(c('Trachytidae', NA, 'Arachnida', 'Acari', 'subclass', '0', '0', '1')),
                        as.list(c('Perlohmanniidae', NA, 'Arachnida', 'Acari', 'subclass', '0', '0', '1')),
                        as.list(c('Tenuipalpidae', NA, 'Arachnida', 'Acari', 'subclass', '0', '0', '1')),
                        as.list(c('Phytoseiidae', NA, 'Arachnida', 'Acari', 'subclass', '0', '0', '1')),
                        as.list(c('Ascidae', NA, 'Arachnida', 'Acari', 'subclass', '0', '0', '1')),
                        as.list(c('Varroidae', 'Schnabelmilben', 'Arachnida', 'Acari', 'subclass', '0', '0', '1')),
                        as.list(c('Hemisarcoptidae', NA, 'Arachnida', 'Acari', 'subclass', '0', '0', '1')),
                        as.list(c('Tetranychidae', NA, 'Arachnida', 'Acari', 'subclass', '0', '0', '1')),
                        as.list(c('Bdellidae', 'Schnabelmilben', 'Arachnida', 'Acari', 'subclass', '0', '0', '1')),
                        as.list(c('Eriophyidae', 'Gallmilben', 'Arachnida', 'Acari', 'subclass', '0', '0', '1')),   
                        as.list(c('Penthaleidae', NA, 'Arachnida', 'Acari', 'subclass', '0', '0', '1')),
                        as.list(c('Pionidae', NA, 'Arachnida', 'Acari', 'subclass', '0', '0', '1')),
                        as.list(c('Anystidae', NA, 'Arachnida', 'Acari', 'subclass', '0', '0', '1')),
                        #### Hydrachnidiae (Unterkohorte) - Süßwassermilben
                        as.list(c('Arrenuridae', NA, 'Arachnida', 'Acari', 'subclass', '1', '0', '0')),
                        ### Sarcoptiformes (order)
                        as.list(c('Acaridae', NA, 'Arachnida', 'Acari', 'subclass', '0', '0', '1')),
                        ## Ixodida (=Metastigmata) (Zecken)
                        as.list(c('Argasidae', 'Lederzecken', 'Arachnida', 'Ixodida', 'order', '0', '0', '1')),
                        ## Trombidiformes
                        as.list(c('Limnocharidae', NA, 'Arachnida', ' 	Trombidiformes', 'order', '0', '0', '1')),
                        
                        ## Aranae (order) - Echte Spinnen
                        as.list(c('Lycosidae', 'Wolfspinnen', 'Arachnida', 'Araneae', 'order', '0', '0', '1')),
                        as.list(c('Linyphiidae', 'Baldachinspinnen', 'Arachnida', 'Araneae', 'order', '0', '0', '1')),
                        as.list(c('Philodromidae', 'Laufspinnen', 'Arachnida', 'Araneae', 'order', '0', '0', '1')),
                        as.list(c('Eresidae', 'Röhrenspinnen', 'Arachnida', 'Araneae', 'order', '0', '0', '1')),
                        as.list(c('Tetragnathidae', 'Dickkieferspinnen', 'Arachnida', 'Araneae', 'order', '0', '0', '1'))
))


# Mollusca ----------------------------------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        ## Bivalvia (Muscheln)
                        as.list(c('Ostreidae', 'Austern', 'Mollusca', 'bivalvia', 'class', '0', '1', '0')),
                        as.list(c('Veneridae', 'Venusmuscheln', 'Mollusca', 'bivalvia', 'class', '0', '1', '0')),
                        as.list(c('Unionidae', 'Fluss- und Teichmuscheln', 'Mollusca', 'bivalvia', 'class', '0', '1', '0')),
                        as.list(c('Mytilidae', 'Miesmuscheln', 'Mollusca', 'bivalvia', 'class', '0', '1', '0')),
                        as.list(c('Dreissenidae', 'Dreikantmuscheln', 'Mollusca', 'bivalvia', 'class', '1', '1', '0')),
                        as.list(c('Pectinidae', 'Kammmuscheln', 'Mollusca', 'bivalvia', 'class', '0', '1', '0')),
                        as.list(c('Corbiculidae', 'Koerbchenmuscheln', 'Mollusca', 'bivalvia', 'class', '1', '1', '0')),
                        as.list(c('Astartidae', 'Astarten', 'Mollusca', 'bivalvia', 'class', '1', '1', '0')),
                        as.list(c('Arcidae', 'Archenmuscheln', 'Mollusca', 'bivalvia', 'class', '0', '1', '0')),
                        as.list(c('Cardiidae', 'Herzmuscheln', 'Mollusca', 'bivalvia', 'class', '0', '1', '0')),
                        as.list(c('Donacidae', 'Koffermuscheln', 'Mollusca', 'bivalvia', 'class', '0', '1', '0')),
                        as.list(c('Mactridae', 'Trogmuscheln', 'Mollusca', 'bivalvia', 'class', '0', '1', '0')),
                        as.list(c('Myidae', 'Klaffmuscheln', 'Mollusca', 'bivalvia', 'class', '0', '1', '0')),
                        as.list(c('Pisidiidae', 'Erbsenmuscheln', 'Mollusca', 'bivalvia', 'class', '1', '0', '0')),
                        ## Polyplacophora (class) - 
                        as.list(c('Leptochitonidae', NA, 'Mollusca', 'Polyplacophora', 'class', '0', '1', '0')),
                        ## Gastropoda (Schnecken)
                        as.list(c('Helicidae', NA, 'Mollusca', 'gastropoda', 'class', '0', '0', '1')),
                        as.list(c('Naticidae', NA, 'Mollusca', 'gastropoda', 'class', '0', '1', '0')),
                        as.list(c('Bulinidae', NA, 'Mollusca', 'gastropoda', 'class', '1', '0', '0')),
                        as.list(c('Pleuroceridae', NA, 'Mollusca', 'gastropoda', 'class', '1', '0', '0')),
                        as.list(c('Hydrobiidae', 'Wasserdeckelschnecken', 'Mollusca', 'gastropoda', 'class', '1', '1', '0')),
                        as.list(c('Haliotidae', 'Seeohren', 'Mollusca', 'gastropoda', 'class', '0', '1', '0')),
                        as.list(c('Ellobiidae', NA, 'Mollusca', 'gastropoda', 'class', '0', '0', '1')),
                        as.list(c('Acteonidae', NA, 'Mollusca', 'gastropoda', 'class', '0', '1', '0')),
                        as.list(c('Semisulcospiridae', NA, 'Mollusca', 'Gastropoda', 'class', '1', '0', '0')),
                        as.list(c('Melanopsidae', NA, 'Mollusca', 'Gastropoda', 'class', '1', '0', '0')),
                        as.list(c('Calyptraeidae', NA, 'Mollusca', 'Gastropoda', 'class', '1', '0', '0')),
                        
                        
                        ### Pulmonata (Lungenschnecken) (order)
                        #### Basommatophora (Wasserlungenschnecken) (suborder)
                        as.list(c('Planorbidae', 'Tellerschnecken', 'Mollusca', 'gastropoda', 'class', '1', '0', '0')),
                        as.list(c('Physidae', 'Blasenschnecken', 'Mollusca', 'gastropoda', 'class', '1', '0', '0')),
                        as.list(c('Lymnaeidae', 'Schlammschnecken', 'Mollusca', 'gastropoda', 'class', '1', '0', '0')),
                        ### Panpulmonata (order)
                        as.list(c('Pyramidellidae', NA, 'Mollusca', 'gastropoda', 'class', '0', '1', '0')),
                        #### Stylommatophora - Landlungenschnecken (suborder)
                        as.list(c('Limacidae', 'Schnegel', 'Mollusca', 'gastropoda', 'class', '0', '0', '1')),
                        as.list(c('Achatinidae', 'Afrikanischen Riesenschnecken', 'Mollusca', 'gastropoda', 'class', '0', '0', '1')),
                        as.list(c('Vertiginidae', 'Windelschnecken', 'Mollusca', 'gastropoda', 'class', '0', '0', '1')),
                        ### Sorbeoconcha - Sauggehaeuseschnecken
                        as.list(c('Thiaridae', 'Kronenschnecke', 'Mollusca', 'gastropoda', 'class', '1', '0', '0')),
                        as.list(c('Ampullariidae', 'Apfelschnecken', 'Mollusca', 'gastropoda', 'class', '1', '0', '0')),
                        as.list(c('Bullinidae', NA, 'Mollusca', 'gastropoda', 'class', '0', '1', '0')),
                        as.list(c('Nassariidae', NA, 'Mollusca', 'gastropoda', 'class', '0', '1', '0')),
                        ### Architaenioglossa (order)
                        as.list(c('Viviparidae', 'Sumpfdeckelschnecken', 'Mollusca', 'gastropoda', 'class', '1', '0', '0')),
                        ## Cephalopoda (class)
                        as.list(c('Onychoteuthidae', NA, 'Mollusca', 'Cephalopoda', 'class', '0', '1', '0'))
))


# Aves (class) - Voegel ---------------------------------------------------
lookup_man_fam =
  rbindlist(list(lookup_man_fam,
                 as.list(c('Columbidae', 'Tauben', 'Aves', 'Columbiformes', 'order', '0', '0', '1')),
                 as.list(c('Anatidae', 'Entenvoegel', 'Aves', 'Anseriformes', 'order', '1', '0', '1')),
                 as.list(c('Odontophoridae', 'Zahnwachteln', 'Aves', 'Galliformes', 'order', '1', '0', '1')),
                 as.list(c('Phasianidae', 'Fasanenartige', 'Aves', 'Galliformes', 'order', '1', '0', '1')),
                 as.list(c('Emberizidae', 'Ammern', 'Aves', 'Passeriformes', 'order', '0', '0', '1')),
                 as.list(c('Icteridae', 'Stärlinge', 'Aves', 'Passeriformes', 'order', '0', '0', '1')),
                 as.list(c('Rallidae', "Rallen", 'Aves', 'Gruiformes', 'order', '0', '0', '1')),
                 as.list(c('Fringillidae', "Finken", 'Aves', 'Gruiformes', 'order', '0', '0', '1')),
                 as.list(c('Muscicapidae', NA, 'Aves', 'Passeriformes', 'order', '0', '0', '1')),
                 as.list(c('Passeridae', NA, 'Aves', 'Passeriformes', 'order', '0', '0', '1')),
                 as.list(c('Cardinalidae', NA, 'Aves', 'Passeriformes', 'order', '0', '0', '1')),
                 as.list(c('Corvidae', NA, 'Aves', 'Passeriformes', 'order', '0', '0', '1'))
                
))


# Tunicata - Manteltiere (subphylum) --------------------------------------
lookup_man_fam =
  rbindlist(list(lookup_man_fam,
                 as.list(c('Styelidae', NA, 'Tunicata', 'Tunicata', 'subphylum', '0', '1', '0')),
                 as.list(c('Cionidae', NA, 'Tunicata', 'Tunicata', 'subphylum', '0', '1', '0')),
                 as.list(c('Doliolidae', NA, 'Tunicata', 'Tunicata', 'subphylum', '0', '1', '0'))
))



# Echinodermata - Stachehaeuter (phylum) ----------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        ## Crinoidea (class) - Seelilien / Haarsterne
                        as.list(c('Antedonidae', NA, 'Echinodermata', 'Crinoidea', 'class', '0', '1', '0')),
                        ## Ophiuroidea (class) - Schlangensterne
                        as.list(c('Amphiuridae', NA, 'Echinodermata', 'Ophiuroidea', 'class', '0', '1', '0')),
                        ## Echinoidea (class) - Seeigel
                        as.list(c('Echinidae', NA, 'Echinodermata', 'Echinoidea', 'class', '0', '1', '0')),
                        as.list(c('Arbaciidae', NA, 'Echinodermata', 'Echinoidea', 'class', '0', '1', '0')),
                        as.list(c('Dendrasteridae', NA, 'Echinodermata', 'Echinoidea', 'class', '0', '1', '0')),
                        as.list(c('Echinometridae', NA, 'Echinodermata', 'Echinoidea', 'class', '0', '1', '0')),
                        as.list(c('Strongylocentrotidae', NA, 'Echinodermata', 'Echinoidea', 'phylum', '0', '1', '0')),
                        as.list(c('Temnopleuridae', NA, 'Echinodermata', 'Echinoidea', 'class', '0', '1', '0'))
))


# Platyhelminthes (phylum) - Plattwuermer ---------------------------------
lookup_man_fam =
  rbindlist(list(lookup_man_fam,
                 as.list(c('Triaenophoridae', NA, 'Platyhelminthes', 'Platyhelminthes', 'phylum', '0', '1', '0')),
                 as.list(c('Fasciolidae', NA, 'Platyhelminthes', 'Platyhelminthes', 'phylum', '0', '0', '1')),
                 as.list(c('Paramphistomatidae', NA, 'Platyhelminthes', 'Platyhelminthes', 'phylum', '0', '0', '1')),
                 as.list(c('Diplostomidae', NA, 'Platyhelminthes', 'Platyhelminthes', 'phylum', '1', '0', '1')),
                 as.list(c('Paramphistomidae', NA, 'Platyhelminthes', 'Platyhelminthes', 'phylum', '0', '1', '0')),
                 as.list(c('Echinostomatidae', NA, 'Platyhelminthes', 'Platyhelminthes', 'phylum', '1', '1', '1')), #according to WORMS
                 as.list(c('Hemiuridae', NA, 'Platyhelminthes', 'Platyhelminthes', 'phylum', '0', '1', '0')),
                 as.list(c('Apocreadiidae', NA, 'Platyhelminthes', 'Platyhelminthes', 'phylum', '1', '1', '0')),
                 as.list(c('Dugesiidae', NA, 'Platyhelminthes', 'Platyhelminthes', 'phylum', '1', '0', '0')),
                 as.list(c('Schistosomatidae', NA, 'Platyhelminthes', 'Platyhelminthes', 'order', '1', '1', '1')), # parasite
                 as.list(c('Planariidae', NA, 'Platyhelminthes', 'Platyhelminthes', 'phylum', '1', '1', '0'))
))


# Gastrotricha (phylum) - Bauchhaerlinge ----------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        as.list(c('Chaetonotidae', NA , 'Gastrotricha', 'Gastrotricha', 'phylum', '1', '1', '0'))
))


# Chaetognatha (phylum) ---------------------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        as.list(c('Sagittidae', NA , 'Chaetognatha', 'Chaetognatha', 'phylum', '1', '1', '0'))
))


# Cnidaria - Nesseltiere (phylum) -----------------------------------------
# Heterotrophi. Mostly in marine envrionments. Rarely by use of endosymbionts.
lookup_man_fam = 
  rbindlist(list(lookup_man_fam,
                 as.list(c('Poritidae', NA, 'Cnidaria', 'Anthozoa', 'class', '0', '1', '0')),
                 as.list(c('Pocilloporidae', NA, 'Cnidaria', 'Anthozoa', 'class', '0', '1', '0')),
                 as.list(c('Antipathidae', NA, 'Cnidaria', 'Hydrozoa', 'class', '0', '1', '0')),
                 as.list(c('Hydridae', 'Suesswasserpolypen', 'Cnidaria', 'Hydrozoa', 'class', '1', '0', '0')),
                 as.list(c('Dendrophylliidae', NA, 'Cnidaria', 'Hydrozoa', 'class', '0', '1', '0')),
                 as.list(c('Acroporidae', NA, 'Cnidaria', 'Hydrozoa', 'class', '0', '1', '0')),
                 as.list(c('Aiptasiidae', NA, 'Cnidaria', 'Hydrozoa', 'class', '0', '1', '0')),
                 as.list(c('Campanulinidae', NA, 'Cnidaria', 'Hydrozoa', 'class', '0', '1', '0')),
                 as.list(c('Deltocyathidae', NA, 'Cnidaria', 'Anthozoa', 'class', '0', '1', '0'))
))


# Porifera (phylum) - Schwaemme -------------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        as.list(c('Halichondriidae', NA, 'Porifera', 'Porifera', 'phylum', '0', '1', '0')),
                        as.list(c('Raspailiidae', NA, 'Porifera', 'Porifera', 'phylum', '0', '1', '0'))
))

# Viruses -----------------------------------------------------------------
lookup_man_fam = rbindlist(list(lookup_man_fam,
                        as.list(c('Polydnaviridae', NA, 'Viruses', 'Viruses', 'viruses', '0', '0', '1')),
                        as.list(c('Baculoviridae', NA, 'Viruses', 'Viruses', 'viruses', '0', '0', '1')),
                        as.list(c('Alphaflexiviridae', NA, 'Viruses', 'Viruses', 'viruses', '0', '0', '1'))
))


# Mammalia (class) --------------------------------------------------------
lookup_man_fam =
  rbindlist(list(lookup_man_fam,
                 as.list(c('Mustelidae', 'Marder', 'Mammalia', 'Rodentia', 'order', '0', '0', '1')),       
                 as.list(c('Caviidae', 'Meerschweinchen', 'Mammalia', 'Rodentia', 'order', '0', '0', '1')),
                 as.list(c('Muridae', 'Langschwanzmäuse', 'Mammalia', 'Rodentia', 'order', '0', '0', '1')),
                 as.list(c('Cricetidae', 'Wühler', 'Mammalia', 'Rodentia', 'order', '0', '0', '1'))
))



# Checks ------------------------------------------------------------------
if (length(which(isTRUE(duplicated(lookup_man_fam$family)))) < 1) {
  message('No duplicates.')
} else {
  warning('Duplicates!')
}


# Write to file + Todo ----------------------------------------------------
# Classified taxa
fwrite(lookup_man_fam, file.path(cachedir, 'lookup_man_fam_list.csv'))

# to do
chck_habitat =
  unique(todo_habitat[ !family %in% lookup_man_fam$family, ][order(family)]$family)
if (length(chck_habitat) == 0) {
  message('All entries classified.')
} else {
  message('The following taxa are still to be classified:\n', paste0(chck_habitat, '\n'))
  fwrite(data.table(chck_habitat),
         file.path(tempdir(), 'lookup_man_fam_todo.csv'))
}

# Cleaning ----------------------------------------------------------------
rm(todo_habitat)

# Macrophytes [OWN FILE, TO GENUS LEVEL] ----------------------------------
# Maybe create an own list as they often don't form own families.
# necessary 'cause in Poaceae and Brassicaceae are some Macrophytes
# genus level
#! not finished yet!
# lookup_macrophyte = data.table(genus = 'Limnosipanea', german_name = NA, family = 'Rubiaceae', epa_supgroup = 'Plants', epa_taxon = 'Angiospermae', epa_tx_rank = 'clade', epa_isFre = '1', isMacPhy = '1', epa_isMar = '0', epa_isTer = '0')
# 
# lookup_macrophyte = rbindlist(list(lookup_macrophyte,
#                                    
#                                    # plants 

                                    # as.list(c('Sagittaria', 'Pfeilkraut', 'Alismataceae', NA, 'Plants', 'Froschlöffelgewaechse', 'class', '1', '1', '0', '1'))
#                                    as.list(c('Zostera', NA, 'Zosteraceae', 'Plants', 'Angiospermae', 'clade', '0', '1', '1', '0')),
#                                    as.list(c('Hippuris', NA, 'Plantaginaceae', 'Plants', 'Angiospermae', 'clade', '1', '1', '0', '0')),
#                                    as.list(c('Callitriche', NA, 'Plantaginaceae', 'Plants', 'Angiospermae', 'clade', '1', '1', '0', '0')),
#                                    as.list(c('Anubias', 'Speerblaetter', 'Araceae', 'Plants', 'Angiospermae', 'clade', '1', '1', '0', '0')),
#                                    as.list(c('Cryptocoryne', 'Wasserkelche', 'Araceae', 'Plants', 'Angiospermae', 'clade', '1', '1', '0', '0')),
#                                    as.list(c('Orontium', NA, 'Araceae', 'Plants', 'Angiospermae', 'clade', '1', '1', '0', '0')),
#                                    as.list(c('Pistia', 'Wassersalat', 'Araceae', 'Plants', 'Angiospermae', 'clade', '1', '1', '0', '0')),
#                                    as.list(c('Wolffia', NA, 'Araceae', 'Plants', 'Angiospermae', 'clade', '1', '1', '0', '0')),
#                                    as.list(c('Spirodela', NA, 'Araceae', 'Plants', 'Angiospermae', 'clade', '1', '1', '0', '0')),
#                                    as.list(c('Lemna', NA, 'Araceae', 'Plants', 'Angiospermae', 'clade', '1', '1', '0', '0')),
#                                    as.list(c('Trapa', NA, 'Lythraceae', 'Plants', 'Angiospermae', 'clade', '1', '1', '0', '0'))
#                                    as.list(c('Nelumbonaceae', 'Lotosblumen', 'Plants', 'Angiospermen', 'clade', '1', '0', '1', '1')),
#                                    as.list(c('Azollaceae', 'Schwimmfarngewaechse', 'Plants', 'Polypodiopsida', 'class', '1', '1', '0', '0')),
#                                    as.list(c('Characeae', NA, 'Plants', 'Charophyta', 'division', '1', '1', '0', '0'))
# )),
# as.list(c('Nelumbonaceae', 'Lotosblumen', 'Plants', 'Angiospermen', 'clade', '1', '0', '1', '1')),
# 'Azolla pinnata'
# 
# as.list(c('Potamogetonaceae', "Laichkrautgewächse", 'Plants', 'Spermatophyta', 'subdivision', '1', '1', '0', '0'))
# ))



# help --------------------------------------------------------------------
# family - family you just searched
# supgroup - refer to the groups that are already here (e.g. Plants, Algae, Fungi, Fish, etc.)
# group - refer to the entries that are already here (e.g. Angiospermae, Ascomycota, Perciformes etc.)
# group_rank - rank that relates to epa_taxon (puting epa_taxon & epa_tx_rank here like this is a little bad practice ;))
# german_name
# isFre - is freshwater yes/no (1/0)
# isMar - is marine 
# isTer - is Terrestrial








