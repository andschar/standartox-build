# script for a shiny app selecting EC50 values

# setup -------------------------------------------------------------------
source('R/setup.R')

server = function(input, output, session) {
  # data --------------------------------------------------------------------
  dat = reactive({
    fl = file.path('data', input$epa_version, paste0('standartox', input$epa_version, '.fst'))
    data.table(read_fst(fl))
  })
  stat_l = reactive({
    fl = file.path('data', input$epa_version, paste0('standartox', inpu$epa_version, '_shiny_stats', '.rds'))
    data.table(readRDS(fl))
  })
  observe({
    current_version = input$epa_version

    updatePrettyCheckbox(
      session = session,
      inputId = 'chemical_class',
      label = 'test',
      Values = stat_l()$chemical_class$value,
      selected = stat_l()$chemical_class$value[1]
    )
    # CONTINUE HERE!!! https://shiny.rstudio.com/reference/shiny/0.14/updateCheckboxGroupInput.html
  })
  
  
  # read csv + action button ------------------------------------------------
  # https://stackoverflow.com/questions/49344468/resetting-fileinput-in-shiny-app
  rv = reactiveValues(data = NULL,
                      reset = FALSE)
  observe({
    req(input$file_cas)
    req(!rv$reset)
    
    data = read.csv(input$file_cas$datapath,
                    header = FALSE,
                    stringsAsFactors = FALSE) # $datapath not very intuitive
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
    fun_filter(
      dt = dat(),
      conc1_type = input$conc1_type,
      chemical_class = input$chemical_class,
      tax = trimws(unlist(strsplit(input$tax,","))), # handle multiple inputs
      habitat = input$habitat,
      region = input$region,
      duration = c(input$dur1, input$dur2),
      publ_year = c(input$yr1, input$yr2),
      acch = input$acch,
      exposure = input$exposure,
      effect = input$effect,
      endpoint = input$endpoint,
      chck_solub = input$chck_solub,
      cas = rv$data
    )
  })
  
  data_agg = reactive({
    fun_aggregate(
      dt = fun_filter(
        dt = dat(),
        conc1_type = input$conc1_type,
        chemical_class = input$chemical_class,
        tax = trimws(unlist(strsplit(input$tax,","))), # handle multiple inputs
        habitat = input$habitat,
        region = input$region,
        duration = c(input$dur1, input$dur2),
        publ_year = c(input$yr1, input$yr2),
        acch = input$acch,
        exposure = input$exposure,
        effect = input$effect,
        endpoint = input$endpoint,
        chck_solub = input$chck_solub,
        cas = rv$data
      ),
      agg = input$agg,
      info = input$infocols,
      comp = input$comp,
      chck_outlier = input$chck_outlier
    )
  })
  
  # (2) output --------------------------------------------------------------
  output$tab = DT::renderDataTable({
    data_agg()
  },
  options = list(columnDefs = list(list(
    # targets = 0:4,
    render = JS(
      "function(data, type, row, meta) {",
      "return type === 'display' && data.length > 6 ?",
      "'<span title=\"' + data + '\">' + data.substr(0, 6) + '...</span>' : data;",
      "}"
    )
  ))),
  #dom = 't',
  rownames = FALSE,
  callback = JS('table.page(3).draw(false);'))
  
  
  # plot --------------------------------------------------------------------
  #pl =
  # n_pl = length(pl$x$data)
  # write_feather(n_pl, file.path(cachedir, 'n_pl'))
  
  # output$plotly_sensitivity = renderPlotly({
  #   filagg_pl(
  #     data_agg(),
  #     plot_type = 'dynamic',
  #     xaxis = input$xaxis,
  #     yaxis = input$yaxis,
  #     cutoff = input$cutoff
  #   )
  # })
  output$npl = renderText('3')
  # download ----------------------------------------------------------------
  # https://stackoverflow.com/questions/44504759/shiny-r-download-the-result-of-a-table
  output$download_fil = downloadHandler(
    filename = function() {
      paste(input$tax,
            #input$habitat, input$continent,
            paste0(input$dur1, input$dur2),
            'data_fil.csv',
            sep = '_')
    },
    content = function(fname) {
      write.csv(data_fil(), fname, row.names = FALSE)
    }
  )
  
  output$download_agg = downloadHandler(
    filename = function() {
      paste(input$tax,
            #input$habitat, input$continent,
            paste0(input$dur1, input$dur2),
            'data_agg.csv',
            sep = '_')
    },
    content = function(fname) {
      write.csv(data_agg(), fname, row.names = FALSE)
    }
  )
  
  # version -----------------------------------------------------------------
  output$version = renderText(version_string)
  
}