# Standartox app reactive
# this app allows to choose between versions of the EPA ECOTOX

# setup -------------------------------------------------------------------
source('setup.R')
sidewidth = 350

# header ------------------------------------------------------------------
header = dashboardHeaderPlus(
  title = 'Standartox',
  titleWidth = sidewidth,
  fixed = TRUE,
  left_menu = tagList(
    dropdownBlock(
      id = 'download_agg',
      title = 'Download data',
      icon = icon('download'),
      downloadButton(outputId = 'download_fil', 'Filtered data'),
      downloadButton(outputId = 'download_agg', 'Aggregated data')
    )
  )
)

# sidebar -----------------------------------------------------------------
sidebar = dashboardSidebar(
  width = sidewidth,
  sidebarMenu(
    'Version',
    id = 'sidebar_version',
    menuItem(
      'EPA ECOTOX Version',
      tabName = 'data_set',
      uiOutput(outputId = 'data_set')
    )
  ),
  sidebarMenu(
    'Filters',
    id = 'sidebar_filter',
    menuItem(
      'Compound',
      tabName = 'compound',
      splitLayout(
        fileInput(
          inputId = 'file_cas',
          label = 'Upload CAS',
          accept = '.csv',
          placeholder = 'one column .csv'
        ),
        actionButton(
          inputId = 'reset',
          label = 'Reset',
          style = 'margin-top:37px'
        )
      ),
      uiOutput(outputId = 'rend_conc1_type'),
      uiOutput(outputId = 'rend_chemical_class')
    ),
    menuItem(
      'Taxon',
      tabName = 'taxon',
      uiOutput(outputId = 'rend_taxa'),
      uiOutput(outputId = 'rend_habitat'),
      uiOutput(outputId = 'rend_region')
    ),
    menuItem(
      'Test',
      tabName = 'test',
      splitLayout(
        numericInput(
          inputId = 'dur1',
          label = 'Durations from',
          value = 24
        ),
        numericInput(
          inputId = 'dur2',
          label = 'to (h)',
          value = 48
        )
      ),
      splitLayout(
        numericInput(
          inputId = 'yr1',
          label = 'Publication year from',
          value = 1900
        ),
        numericInput(
          inputId = 'yr2',
          label = 'to',
          value = substr(Sys.Date(),1,4)
        )
      ),
      splitLayout(
        prettyCheckboxGroup(
          inputId = 'acch',
          label = 'TODO! Acute / Chronic',
          # TODO take choices programatically!
          choiceValues = c('acute', 'chronic', 'nc'),
          choiceNames = c('acute', 'chronic', 'not classified')
        ),
        prettyCheckboxGroup(
          inputId = 'exposure', # exposure_type
          label = 'TODO! Exposure',
          choiceValues = c('diet', 'static'),
          choiceNames = c('diet', 'static')
        )
      ),
      prettyRadioButtons(
        inputId = 'test_location',
        label = 'Test location',
        choiceValues = stat_l$test_location$value,
        choiceNames = stat_l$test_location$value
      ),
      splitLayout(
        uiOutput(outputId = 'rend_effect'),
        uiOutput(outputId = 'rend_endpoint')
      )
    ),
    menuItem(
      'Checks',
      tabName = 'checks',
      prettyCheckbox(
        inputId = 'rm_outl',
        label = 'Remove outliers',
        value = TRUE
      )
    )
  ),
  sidebarMenu(
    'Aggregation',
    id = 'sidebar_agg',
    icon = icon('list-alt'),
    menuItem(
      'Aggregation',
      tabName = 'aggregation',
      prettyCheckboxGroup(
        inputId = 'agg',
        label = 'Aggregate',
        choiceValues = c('min', 'max', 'md', 'gm', 'mn', 'sd'),
        choiceNames = c('Minimum', 'Maximum', 'Median', 'Geometric Mean', 'Arithmetic Mean', 'Standard Deviation'),
        selected = 'gm'
      )
    )
  )
)


rightsidebar = rightSidebar()

# body --------------------------------------------------------------------
body = dashboardBody(#setShadow(class = "dropdown-menu"),
  #tags$head(includeCSS('style.css')),
  br(),
  br(),
  br(),
  fluidRow(
    box(
      status = 'success',
      width = 9,
      collapsible = TRUE,
      withMathJax(includeMarkdown('README.md')) # https://stackoverflow.com/questions/33499651/rmarkdown-in-shiny-application
    )#,
    # box(
    #   title = 'Information',
    #   status = 'success',
    #   width = 3,
    #   collapsible = TRUE,
    #   uiOutput('meta')
    # )
  ),
  fluidRow(
    box(
      title = 'Aggregated values',
      status = 'primary',
      dataTableOutput(outputId = 'tab'),
      width = 9,
      offset = 0
    ),
    box(
      title = 'Inputs',
      status = 'primary',
      width = 3,
      prettyCheckboxGroup(
        inputId = 'comp',
        label = 'Compound columns',
        choiceValues = c('cname', 'comp_type'),
        choiceNames = c('Compound name', 'Compound type'),
        selected = c('cas', 'cname')
      ),
      prettyCheckboxGroup(
        inputId = 'infocols',
        label = 'Information columns',
        choiceValues = c('info', 'taxa', 'vls', 'n'),
        choiceNames = c('info', 'taxa', 'values', 'n'),
        selected = 'taxa'
      )
    )
  ),
  fluidRow(
    box(
      title = 'Plotly Sensitivity',
      status = 'primary',
      width = 9,
      plotlyOutput(outputId = 'plotly')
    ),
    #,
    #height = sprintf('%spx', n_pl * 400))),
    box(
      title = 'Inputs',
      status = 'primary',
      width = 3,
      numericInput(
        inputId = 'cutoff',
        label = 'Number of compounds',
        value = 25,
        width = '120px'
      ),
      prettyRadioButtons(
        inputId = 'yaxis',
        label = 'y-axis',
        choiceValues = c('casnr', 'cname'),
        choiceNames = c('CAS', 'Compound name'),
        selected = 'casnr',
        inline = FALSE
      ),
      prettyRadioButtons(
        inputId = 'xaxis',
        label = 'x-axis',
        choiceValues = c('limout', 'log'),
        choiceNames = c('Limit to range', 'Log x-axis'),
        selected = 'limout',
        inline = FALSE
      )
    )
  )
)

rightsidebar = rightSidebar()


body = dashboardBody(#setShadow(class = "dropdown-menu"),
  #tags$head(includeCSS('style.css')),
  fluidRow(
    box(
      title = 'Standartox',
      status = 'success',
      width = 12,
      collapsible = TRUE,
      withMathJax(includeMarkdown('README.md'))
    )
    # https://stackoverflow.com/questions/33499651/rmarkdown-in-shiny-application
  ),
  fluidRow(
    box(
      title = 'Aggregated values',
      status = 'primary',
      dataTableOutput(outputId = 'tab'),
      width = 9,
      offset = 0
    ),
    box(
      title = 'Inputs',
      status = 'primary',
      width = 3,
      prettyCheckboxGroup(
        inputId = 'comp',
        label = 'Compound columns',
        choiceValues = c('cname', 'comp_type'),
        choiceNames = c('Compound name', 'Compound type'),
        selected = c('cas', 'cname')
      ),
      prettyCheckboxGroup(
        inputId = 'infocols',
        label = 'Information columns',
        choiceValues = c('info', 'taxa', 'vls', 'n'),
        choiceNames = c('info', 'taxa', 'values', 'n'),
        selected = 'taxa'
      )
    )
  ),
  fluidRow(
    # box(
    #   title = 'Plotly Sensitivity',
    #   status = 'primary',
    #   width = 9,
    #   plotlyOutput(outputId = 'plotly_sensitivity')
    # ),
    #,
    #height = sprintf('%spx', n_pl * 400))),
    box(
      title = 'Inputs',
      status = 'primary',
      width = 3,
      numericInput(
        inputId = 'cutoff',
        label = 'Number of compounds',
        value = 25,
        width = '120px'
      ),
      prettyRadioButtons(
        inputId = 'yaxis',
        label = 'y-axis',
        choiceValues = c('casnr', 'cname'),
        choiceNames = c('CAS', 'Compound name'),
        selected = 'casnr',
        inline = FALSE
      ),
      prettyRadioButtons(
        inputId = 'xaxis',
        label = 'x-axis',
        choiceValues = c('limout', 'log'),
        choiceNames = c('Limit to range', 'Log x-axis'),
        selected = 'limout',
        inline = FALSE
      )
    )
  )
)

# page --------------------------------------------------------------------
ui = dashboardPagePlus(header, sidebar, body,
                       title = 'Etox Base',
                       skin = 'purple')


# server ------------------------------------------------------------------
server = function(input, output, session) {

  # data --------------------------------------------------------------------
  ## data
  dat = reactive({
    v = input$version
    # v = 20190314 # debuging
    fl = file.path('data', v, paste0('standartox', v, '.fst'))
    dat = data.table(read_fst(fl))
    
    return(dat)
  })
  # all taxa list
  taxa_all_list = reactive({
    sort(unique(unlist(dat()[ , .SD, .SDcols = grep('tax_', names(dat())) ])))
  })
  ## meta data
  stat_l = reactive({
    v = input$version
    # v = 20190314 # debuging
    fl = file.path('data', v, paste0('standartox', v, '_shiny_stats', '.rds'))
    stat_l = readRDS(fl)
    
    return(stat_l)
  })
  # renderUI ----------------------------------------------------------------
  ## version
  output$data_set = renderUI({
    selectInput(inputId = 'version',
                label = 'Version',
                choices = epa_versions,
                selected = max(epa_versions))
  })
  ## render filters
  output$rend_conc1_type = renderUI({
    prettyCheckboxGroup(
      inputId = 'conc1_type',
      label = 'Concentration type',
      choiceValues = stat_l()$conc1_type$value,
      choiceNames = stat_l()$conc1_type$name_perc,
      selected = stat_l()$conc1_type$value[1]
    )
  })
  output$rend_chemical_class = renderUI({
    prettyCheckboxGroup(
      inputId = 'chemical_class',
      label = 'Chemical class',
      choiceValues = stat_l()$chemical_class$value,
      choiceNames = stat_l()$chemical_class$name_perc,
      selected = stat_l()$chemical_class$value[1]
    )
  })
  output$rend_habitat = renderUI({
    prettyCheckboxGroup(
      inputId = 'habitat',
      label = 'Organism hatbitat',
      choiceValues = stat_l()$habitat$value,
      choiceNames = stat_l()$habitat$name_perc,
      selected = stat_l()$habitat$value[1]
    )
  })
  output$rend_region = renderUI({
    prettyCheckboxGroup(
      inputId = 'region',
      label = 'Continent',
      choiceValues = stat_l()$region$value,
      choiceNames = stat_l()$region$name_perc,
      selected = stat_l()$region$value[1]
    )
  })
  output$rend_effect = renderUI({
    prettyCheckboxGroup(
      inputId = 'effect',
      label = 'Effect group',
      choiceValues = stat_l()$effect$value,
      choiceNames = stat_l()$effect$name_perc,
      selected = c('MOR', 'POP', 'GRO', 'ITX')
    )
  })
  output$rend_endpoint = renderUI({
    prettyRadioButtons(
      inputId = 'endpoint',
      label = 'Endpoint',
      choiceValues = stat_l()$endpoint$value,
      choiceNames = stat_l()$endpoint$name_perc,
      selected = c('XX50')
    )
  })
  # handle multiple inputs
  taxa_input = reactive({
    input_tax = input$tax
    if (!is.null(input_tax)) {
      input_tax = na.omit(trimws(unlist(strsplit(input_tax, ","))))
      input_tax = input_tax[ input_tax != '' ]
    }
    
    return(input_tax)
  })
  output$rend_taxa = renderUI({
    selectizeInput(inputId = 'tax',
                   label = 'Taxa',
                   choices = taxa_all_list(),
                   selected = NULL,
                   multiple = TRUE,
                   options = list(create = FALSE))
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
  
  # filter ------------------------------------------------------------------
  data_fil = reactive({
    fun_filter(
      dt = dat(),
      conc1_type = input$conc1_type,
      chemical_class = input$chemical_class,
      tax = taxa_input(),
      habitat = input$habitat,
      region = input$region,
      duration = c(input$dur1, input$dur2),
      publ_year = c(input$yr1, input$yr2),
      acch = input$acch,
      exposure = input$exposure,
      effect = input$effect,
      endpoint = input$endpoint,
      cas = rv$data
    )
  })

  # aggregate ---------------------------------------------------------------
  data_agg = reactive({
    fun_aggregate(
      dt = fun_filter(
        dt = dat(),
        conc1_type = input$conc1_type,
        chemical_class = input$chemical_class,
        tax = taxa_input(),
        habitat = input$habitat,
        region = input$region,
        duration = c(input$dur1, input$dur2),
        publ_year = c(input$yr1, input$yr2),
        acch = input$acch,
        exposure = input$exposure,
        effect = input$effect,
        endpoint = input$endpoint,
        cas = rv$data
      ),
      agg = input$agg,
      info = input$infocols,
      comp = input$comp,
      rm_outl = input$rm_outl
    )
  })

  # table -------------------------------------------------------------------
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
  output$plotly = renderPlotly({
    plotly_fin(
      agg = data_agg(),
      fil = data_fil(),
      xaxis = input$xaxis,
      yaxis = input$yaxis,
      cutoff = input$cutoff
    )
  })
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

# app ---------------------------------------------------------------------
shinyApp(ui = ui, server = server)




