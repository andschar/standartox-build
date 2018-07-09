#### Fliessgewaesserbewertung: Operationelle Taxaliste Mai 2011 ####
# http://www.fliessgewaesserbewertung.de/download/bestimmung/
require(readxl)
xlsx1 <- '/home/andreas/Documents/UBA/data/Operationelle Taxaliste_Mai2011.xls'
fl_bew = read_excel(xlsx1)

fl_bew = as.data.frame(fl_bew)
names(fl_bew)[1:9] <- c('group', 'family', 'dvnr', 'taxa_bliste', 'id_art', 'taxa_perlodesDB',
                        'author', 'determination_lit', 'note')
# fill Taxa columns with according values
source('/home/andreas/Documents/UBA/Project/R/functions/repeat_last.R')
fl_bew[ ,1:2] = lapply(fl_bew[ ,1:2], repeat_last)
fl_bew = fl_bew[!is.na(fl_bew$taxa_bliste), ]

## Species
fl_bew_sp = fl_bew[-grep('Gen.', fl_bew$taxa_perlodesDB), ]$taxa_perlodesDB
fl_bew_sp = fl_bew_sp[-grep('sp.', fl_bew_sp)]
fl_bew_sp = fl_bew_sp[-grep('Gr.', fl_bew_sp)]
fl_bew_sp = fl_bew_sp[-grep('/', fl_bew_sp)]

## Genus
fl_bew_sp = unique(gsub('([A-z]+)\\s([a-z]+)(\\s.+)*', '\\1 \\2', fl_bew_sp)) # due to reduction there's a duplicate
fl_bew_gn = unique(gsub('([A-z]+)\\s(.+)*', '\\1', fl_bew_sp))

## Check if Species name is logner than 2 words
# https://stackoverflow.com/questions/8920145/count-the-number-of-words-in-a-string-in-r
any(vapply(strsplit(fl_bew_sp, "\\W+"), length, integer(1)) != 2)