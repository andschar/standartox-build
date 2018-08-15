# script for a shiny app selecting EC50 values

# setup -------------------------------------------------------------------
source('/home/andreas/Documents/Projects/etox-base/R/setup.R')
require(shiny)
require(DT)

# functions
source('/home/andreas/Documents/Projects/etox-base/R/fun_ec50filter_aggregation.R')

# data --------------------------------------------------------------------
tests_fl = readRDS(file.path(cachedir, 'tests_fl.rds'))

server = function(input, output) {
  
  output$dat = DT::renderDataTable({
    dat = ec50_filagg(tests_fl,
                      habitat = input$habitat,
                      continent = input$continent,
                      tax = input$tax)
    
  })
  
  # # tutorial stuff:
  # output$hist = renderPlot({
  #   hist(rnorm(input$n))
  # })
}