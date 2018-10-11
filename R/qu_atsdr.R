# script to query the Agency for Toxic Substances and Disease Registry - ATSDR data base
# https://www.atsdr.cdc.gov/substances/indexAZ.asp

# TODO unfinished script
# TODO idea is to query chemical classes from the website
# TODO probably not needed

# setup -------------------------------------------------------------------
source('R/setup.R')
require(rvest)

# query -------------------------------------------------------------------

url = 'https://www.atsdr.cdc.gov/substances/indexAZ.asp'

indexAZ = read_html(url)

test = indexAZ %>% 
  html_nodes(xpath = '//*[@id="content-main"]') %>% 
  html_children()


