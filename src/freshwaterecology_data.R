#### Species data from freshwatere cology.info ####
## Andreas Scharmüller

#! Maybe not the newest version
fwecol = read.csv('/media/andreas/disk_AS2TB/data/koenig_NETSTORAGE_20170724/FreshwaterEcology/Freshwaterecology_komplett.csv',
                  header = TRUE, sep = ',') 
## Species
fwecol_sp = unique(gsub('([a-z]+)\\s([a-z]+)\\s?.*', '\\1 \\2',
                        fwecol$Taxon, ignore.case = TRUE))
fwecol_sp = fwecol_sp[-grep('Micropsectra \"', fwecol_sp)]
fwecol_sp = fwecol_sp[-grep('Parakiefferiella \"spec Kingbeek', fwecol_sp)]

fwecol_sp[grep('(Holoconops)', fwecol_sp)] =
  gsub('([A-z]+)\\s(.+)*\\s([a-z]+)', '\\1 \\3', fwecol_sp[grep('(Holoconops)', fwecol_sp)])

## Genus
fwecol_gn = unique(gsub('([A-z]+)\\s([a-z]+)', '\\1', fwecol_sp))

## Check if Species name is logner than 2 words
# https://stackoverflow.com/questions/8920145/count-the-number-of-words-in-a-string-in-r
any(vapply(strsplit(fwecol_sp, "\\W+"), length, integer(1)) != 2)
