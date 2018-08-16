# script for a shiny app selecting EC50 values
# setup -------------------------------------------------------------------
source('/home/andreas/Documents/Projects/etox-base/R/setup.R')
require(shiny)
require(knitr)
require(DT)

# functions
source('/home/andreas/Documents/Projects/etox-base/R/fun_ec50filter_aggregation.R')
source('/home/andreas/Documents/Projects/etox-base/R/fun_ec50filter_aggregation_plots.R')

# knit README beforehands
rmdfiles = c('README.Rmd')
sapply(rmdfiles, knit, quiet = TRUE)

# data --------------------------------------------------------------------
tests_fl = readRDS(file.path(cachedir, 'tests_fl.rds'))

# shiny -------------------------------------------------------------------
server = function(input, output) {
  #### reactive/observer objects ----
  # data
  thedata = reactive({
    ec50_filagg(tests_fl,
                subst_type = input$subst_type,
                habitat = input$habitat,
                continent = input$continent,
                tax = input$tax,
                dur = c(input$dur1, input$dur2),
                agg = input$agg,
                info = input$infocols)
  })
  # plot
  plot_sensitivity = reactive({
    ec50_filagg_plot(thedata())
  })

  #### output objects ----
  # data
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
      #dom = 't',
      row.names = FALSE),
    callback = JS('table.page(3).draw(false);'))
  # plots
  output$plot_sensitivity = renderPlot({plot_sensitivity()})
  output$plot_meta = renderPlot({ggplot(iris)})
  
  # download
  # https://stackoverflow.com/questions/44504759/shiny-r-download-the-result-of-a-table
  output$download = downloadHandler(
    filename = function() { paste(input$tax, #input$habitat, input$continent,
                                  paste0(input$dur1, input$dur2), 'data.csv', sep = '_') }, 
    content = function(fname){
      write.csv(thedata(), fname, row.names = FALSE)
    }
  )

  
}

