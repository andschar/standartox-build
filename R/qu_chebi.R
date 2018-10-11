# script to query chemical data friom CHEBI data base

# TODO can probably be done via pubchem!!
# TODO data tree structure hard to implement

# TODO somehow an R package existed, but nor supported anymore
# TODO infromation on chemical classes can be found!
# TODO python example: https://github.com/ebi-wp/webservice-clients/blob/master/python/urllib/dbfetch_urllib2.py


# setup -------------------------------------------------------------------
require(data.table)

# intermediate Chebi data set ---------------------------------------------
file = tempfile()
download.file('ftp://ftp.ebi.ac.uk/pub/databases/chebi/archive/rel167/Flat_file_tab_delimited/compounds.tsv.gz',
              destfile = file)
system(sprintf('gunzip %s', file), intern = FALSE)

chebi = as.data.table(read.csv(file, sep = '\t', stringsAsFactors = FALSE))
setnames(chebi, tolower(names(chebi)))
sort(names(chebi))
nrow(chebi)

chebi[ grep('pest|insecticide|fungicide|herbicide', definition, ignore.case = TRUE), pest := 'yes' ]

chebi[ , .N, pest]
chebi[pest = 'yes']



grep('pest', chebi$DEFINITION[1:1000], ignore.case = TRUE, value = TRUE)

# intermediate web scrap --------------------------------------------------

name = 'Clothianidin'
id = get_wdid(name)
ids = wd_ident(id$id)
chebi = ids$chebi


baseurl = 'https://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:'


url = paste0(baseurl, chebi)

test = read_html(url)


test %>% 
  xml_find_all()
  html_attr(name = 'chebiTableContent')

# ideas -------------------------------------------------------------------

# 
# # https://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:39177
# 
# 
# baseurl = 'https://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:'
# id = '39177'
# 
# require(rvest)
# 
# url = paste0(baseurl, id)
# 
# test = read_html(url)
# 
# baseurl = 'http://www.ebi.ac.uk/Tools/dbfetch/dbfetch'
# paste0(baseurl, '/dbfetch.databases?style=xml')
# 
# 
# baseurl = 'https://www.ebi.ac.uk/ebisearch/ws/rest/?query='
# q = 'globin'
# 
# url = paste0(baseurl, q)
# 
# 
# require(httr)
# test = GET(url)
# 
# test = read_html(url)
# 
# 
# 
# baseurl = 'https://www.ebi.ac.uk/Tools/dbfetch/dbfetch/uniprotkb/'
# q = 'globin'
# 
# url = paste0(baseurl, q)
# 
# 'https://www.ebi.ac.uk/ebisearch/swagger.ebi'