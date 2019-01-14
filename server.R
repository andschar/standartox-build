# script for a shiny app selecting EC50 values

# setup -------------------------------------------------------------------
src = file.path(getwd(), 'R')
source(file.path(src, 'setup.R'))

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
  data_fil = reactive({
    fun_filter(dt = dat,
               tax = input$tax,
               habitat = input$habitat,
               continent = input$continent,
               conc_type = input$conc_type,
               effect = input$effect,
               endpoint = input$endpoint,
               chem_class = input$chem_class,
               duration = c(input$dur1, input$dur2),
               chck_solub = input$chck_solub,
               cas = rv$data)
  })
  
  data_agg = reactive({
    fun_aggregate(dt = data_fil,
                  agg = input$agg,
                  info = input$infocols,
                  comp = input$comp,
                  chck_outlier = input$chck_outlier)
  })


  # plots -------------------------------------------------------------------
  plot_sensitivity = reactive({
    ec50_filagg_plot(data_agg(), input$yaxis, input$xaxis, input$cutoff)
  })
  
  # (2) output ----
  # data ----
  output$dat = DT::renderDataTable({data_agg()},
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
  output$download_agg = downloadHandler(
    filename = function() { 
      paste(input$tax, #input$habitat, input$continent,
            paste0(input$dur1, input$dur2), 'data.csv', sep = '_')
    },
    content = function(fname) {
      write.csv(data_agg(), fname, row.names = FALSE)
    }
  )
  
  output$download_fil = downloadHandler(
    filename = 'test_filter.csv',
    content = function(fname) {
      write.csv(data_fil(), fname, row.names = FALSE)
    }
  )
  
  # missing ----
  # TODO maybe include with meta data on variables
  output$missing = DT::renderDataTable(var_missing)
  
  # EPA ECOTOX version ----
  output$version = renderText(version_string)
  
}

