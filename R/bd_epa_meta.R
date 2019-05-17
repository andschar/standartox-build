# script to prepare and clean EPA ECOTOX data

# setup -------------------------------------------------------------------
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
# code appendix
download.file('https://cfpub.epa.gov/ecotox/pdf/codeappendix.pdf',
              file.path(data, 'ecotox', 'codeappendix.pdf'))
# user guide
download.file('https://nepis.epa.gov/Exe/ZyPDF.cgi?Dockey=P100UUBD.txt',
              file.path(data, 'ecotox', 'user_guide.pdf'))

# log ---------------------------------------------------------------------
log_msg('EPA META: files have been downloaded')


# cleaning ----------------------------------------------------------------
clean_workspace()