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
rmdfiles = c('README.Rmd', 'article.Rmd')
sapply(rmdfiles, knit, quiet = TRUE)
# knit('shiny/README.Rmd', output = 'shiny/README.md', quiet = TRUE)
# knit('shiny/article.Rmd', output = 'shiny/article.md', quiet = TRUE)

# data --------------------------------------------------------------------
tests_data = readRDS(file.path(cachedir, 'tests_fl.rds'))

# shiny -------------------------------------------------------------------
server = function(input, output) {
  
  # read file + reset button ----
  # https://stackoverflow.com/questions/49344468/resetting-fileinput-in-shiny-app
  rv = reactiveValues(
    data = NULL,
    reset = FALSE
  )
  
  observe({
    req(input$file_cas)
    req(!rv$reset)
    
    data = read.csv(input$file_cas$datapath,
                    header = FALSE, stringsAsFactors = FALSE) # $datapath not very intuitive
    data = data[ ,1]
    rv$data = data
  })
  
  observeEvent(input$reset, {
    rv$data = NULL
    rv$clear = TRUE
    reset('file_cas')
  }, priority = 1000) # priority?
  
  # data + function ----
  thedata = reactive({
    ec50_filagg(tests_data,
                conc_type = input$conc_type,
                comp = input$comp,
                solub_chck = input$comp_solub_chck,
                habitat = input$habitat,
                continent = input$continent,
                tax = input$tax,
                dur = c(input$dur1, input$dur2),
                agg = input$agg,
                info = input$infocols,
                cas = rv$data)
  })
  
  # plots ----
  plot_sensitivity = reactive({
    ec50_filagg_plot(thedata(), input$yaxis, input$cutoff)
  })

  # output ----
  # data
  output$dat = DT::renderDataTable({thedata()},
    options = list(
      columnDefs = list(list(
        # targets = 0:4,
        render = JS(
          "function(data, type, row, meta) {",
          "return type === 'display' && data.length > 6 ?",
          "'<span title=\"' + data + '\">' + data.substr(0, 6) + '...</span>' : data;",
          "}"))
      )),
      #dom = 't',
      rownames = FALSE,
    callback = JS('table.page(3).draw(false);'))
  # summary
  output$summary_chem = renderPrint({ unique(thedata()$casnr) })
  output$summary_taxa = renderPrint({ thedata()$taxa })
  
  # plots
  output$plot_sensitivity = renderPlot({ plot_sensitivity() })
  output$plot_meta = renderPlot({ ggplot(iris) })
  
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

