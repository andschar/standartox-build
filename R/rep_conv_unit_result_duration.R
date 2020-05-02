# script to render meta information on unit conversions

# setup -------------------------------------------------------------------
source(file.path(src, 'gn_setup.R'))

# render ------------------------------------------------------------------
rmarkdown::render('Rmd/rep_conv_unit_result_duration.Rmd',
                  output_format = 'html_document',
                  output_file = file.path(summdir, 'conv_unit_result_duration.html'))

# log ---------------------------------------------------------------------
log_msg('REPORT: CONV: Unit conversion scripts reported.')

# cleaning ----------------------------------------------------------------
clean_workspace()
