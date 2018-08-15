# script for a shiny app selecting EC50 values

# setup -------------------------------------------------------------------
source('/home/andreas/Documents/Projects/etox-base/R/setup.R')
require(shiny)
require(DT)

# functions
source('/home/andreas/Documents/Projects/etox-base/R/fun_ec50filter_aggregation.R')

# data --------------------------------------------------------------------
tests_fl = readRDS(file.path(cachedir, 'tests_fl.rds'))

# debuging
input = list(habitat = 'freshwater',
             continent = 'Europe',
             tax = 'Algae',
             dur = c(48, 96))


server = function(input, output) {
  
  thedata = reactive({
    ec50_filagg(tests_fl,
                habitat = input$habitat,
                continent = input$continent,
                tax = input$tax,
                dur = c(input$dur1, input$dur2))#,
                      #cas = input$cas)
  })
  
  output$dat = DT::renderDataTable({thedata()},
    options = list(
      columnDefs = list(list(
      #targets = 15,
      render = JS(
        "function(data, type, row, meta) {",
        "return type === 'display' && data.length > 6 ?",
        "'<span title=\"' + data + '\">' + data.substr(0, 6) + '...</span>' : data;",
        "}"))
      ),
      dom = 't'),
    callback = JS('table.page(3).draw(false);'))
  # download
  # https://stackoverflow.com/questions/44504759/shiny-r-download-the-result-of-a-table
  output$download <- downloadHandler(
    filename = function() {'data.csv'}, 
    content = function(fname){
      write.csv(thedata(), fname)
    }
  )
  
  # # tutorial stuff:
  # output$hist = renderPlot({
  #   hist(rnorm(input$n))
  # })
}