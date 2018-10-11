# this script should query the opp data base which comprises test data from pesticide manufacturers
# the opp data base was last updated in 2014 in ECOTOX
# https://cfpub.epa.gov/ecotox/help.cfm?sub=mr-related

# data source
# http://www.ipmcenters.org/Ecotox/index.cfm

require(RODBC)

path = '/home/andreas/Downloads/Ecotox.mdb'

db = odbcDriverConnect(sprintf("Driver={Microsoft Access Driver (*.mdb, *.accdb)};
                                DBQ=%s", path))

db = odbcDriverConnect("Driver={Microsoft Access Driver (*.mdb, *.accdb)};
                        DBQ=/home/andreas/Downloads/Ecotox.mdb")
