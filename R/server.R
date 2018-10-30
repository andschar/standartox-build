# script for a shiny app selecting EC50 values

# setup -------------------------------------------------------------------
source('setup.R')

# knit README beforehands
# TODO
# rmdfiles = c('README.Rmd', file.path(articledir, 'article.Rmd'))
# sapply(rmdfiles, knit, quiet = TRUE)
# knit('shiny/README.Rmd', output = 'shiny/README.md', quiet = TRUE)
# knit('shiny/article.Rmd', output = 'shiny/article.md', quiet = TRUE)

server = function(input, output) {

  # (1) preparation ---------------------------------------------------------
  
  # read csv + action button ------------------------------------------------
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
  
  # data + reactivity function ----------------------------------------------
  thedata = reactive({
    ec50_filagg(dt = dat,
                conc_type = input$conc_type,
                comp = input$comp,
                effect = input$effect,
                endpoint = input$endpoint,
                chem_class = input$chem_class,
                solub_chck = input$comp_solub_chck,
                habitat = input$habitat,
                continent = input$continent,
                tax = input$tax,
                dur = c(input$dur1, input$dur2),
                agg = input$agg,
                info = input$infocols,
                cas = rv$data)
  })


  # plots -------------------------------------------------------------------
  plot_sensitivity = reactive({
    ec50_filagg_plot(thedata(), input$yaxis, input$cutoff)
  })
  
  # (2) output ----
  # data ----
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

  # plots ----
  output$plot_sensitivity = renderPlot({ plot_sensitivity() })
  output$plot_meta = renderPlot({ gg_counter })
  
  # download ----
  # https://stackoverflow.com/questions/44504759/shiny-r-download-the-result-of-a-table
  output$download = downloadHandler(
    filename = function() { paste(input$tax, #input$habitat, input$continent,
                                  paste0(input$dur1, input$dur2), 'data.csv', sep = '_') }, 
    content = function(fname){
      write.csv(thedata(), fname, row.names = FALSE)
    }
  )
  
  # missing ----
  # TODO output$missing = DT::renderDataTable(tests_stat)
  
}

