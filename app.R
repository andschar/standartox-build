# Standartox app reactive
# this app allows only uses the newest version of the EPA ECOTOX

# setup -------------------------------------------------------------------
source('setup.R')
# variables
sidewidth = 350

# data --------------------------------------------------------------------
source('data.R')

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
    'Filters',
    id = 'sidebar_filter',
    menuItem(
      'Chemical',
      tabName = 'chemical',
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
      prettyCheckboxGroup(
        inputId = 'concentration_type',
        label = 'Concentration type',
        choiceValues = catalog_l$concentration_type$variable,
        choiceNames = catalog_l$concentration_type$name_perc,
        selected = grep('active.ingredien', catalog_l$concentration_type$variable, ignore.case = TRUE, value = TRUE)[1]
      ),
      prettyCheckboxGroup(
        inputId = 'chemical_class',
        label = 'Chemical class',
        choiceValues = catalog_l$chemical_class$variable,
        choiceNames = catalog_l$chemical_class$name_perc,
        selected = grep('insecticide', catalog_l$chemical_class$variable, ignore.case = TRUE, value = TRUE)[1]
      )
    ),
    menuItem(
      'Taxon',
      tabName = 'taxon',
      selectizeInput(inputId = 'tax',
                     label = 'Taxa',
                     choices = catalog_l$taxa$variable,
                     selected = 'Daphnia magna',
                     multiple = TRUE,
                     options = list(create = FALSE)),
      prettyCheckboxGroup(
        inputId = 'habitat',
        label = 'Organism hatbitat',
        choiceValues = catalog_l$habitat$variable,
        choiceNames = catalog_l$habitat$name_perc,
        selected = grep('fresh', catalog_l$habitat$variable, ignore.case = TRUE, value = TRUE)[1]
      ),
      prettyCheckboxGroup(
        inputId = 'region',
        label = 'Region',
        choiceValues = catalog_l$region$variable,
        choiceNames = catalog_l$region$name_perc,
        selected = grep('europe', catalog_l$region$variable, ignore.case = TRUE, value = TRUE)[1]
      )
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
      # TODO
      # splitLayout(
      #   numericInput(
      #     inputId = 'yr1',
      #     label = 'Publication year from',
      #     value = 1900
      #   ),
      #   numericInput(
      #     inputId = 'yr2',
      #     label = 'to',
      #     value = substr(Sys.Date(),1,4)
      #   )
      # ),
      # splitLayout(
      #   prettyCheckboxGroup(
      #     inputId = 'acch',
      #     label = 'TODO! Acute / Chronic',
      #     # TODO take choices programatically!
      #     choiceValues = c('acute', 'chronic', 'nc'),
      #     choiceNames = c('acute', 'chronic', 'not classified')
      #   ),
      #   prettyCheckboxGroup(
      #     inputId = 'exposure', # exposure_type
      #     label = 'TODO! Exposure',
      #     choiceValues = c('diet', 'static'),
      #     choiceNames = c('diet', 'static')
      #   )
      # ),
      # prettyRadioButtons(
      #   inputId = 'test_location',
      #   label = 'Test location',
      #   choiceValues = catalog_l$test_location$variable,
      #   choiceNames = catalog_l$test_location$variable
      # ),
      ### END TODO
      splitLayout(
        prettyCheckboxGroup(
          inputId = 'effect',
          label = 'Effect group',
          choiceValues = catalog_l$effect$variable,
          choiceNames = catalog_l$effect$name_perc,
          selected = c('MOR', 'POP', 'GRO', 'ITX')
        ),
        prettyRadioButtons(
          inputId = 'endpoint',
          label = 'Endpoint',
          choiceValues = catalog_l$endpoint$variable,
          choiceNames = catalog_l$endpoint$name_perc,
          selected = c('XX50')
        )
      )
    )
  ),
  sidebarMenu(
    'Aggregation',
    id = 'sidebar_agg',
    icon = icon('list-alt'),
    menuItem(
      'Method',
      tabName = 'aggregation',
      prettyCheckboxGroup(
        inputId = 'agg',
        label = 'Aggregate',
        choiceValues = c('min', 'gmn', 'max'),
        choiceNames = c('Minimum', 'Geometric Mean', 'Maximum'),
        selected = 'gmn'
      )
    )
  )
)

rightsidebar = rightSidebar()

# body --------------------------------------------------------------------
body = dashboardBody(
  br(),
  br(),
  br(),
  fluidRow(
    box(
      status = 'success',
      width = 9,
      collapsible = TRUE,
      withMathJax(includeMarkdown('README.md')) # https://stackoverflow.com/questions/33499651/rmarkdown-in-shiny-application
    ),
    box(
      title = 'Information',
      status = 'success',
      width = 3,
      collapsible = TRUE,
      textOutput(outputId = 'meta')
    )
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
        inputId = 'chemical',
        label = 'Chemical columns',
        choiceValues = c('cas', 'cname'),
        choiceNames = c('CAS', 'Chemical name'),
        selected = c('cas', 'cname')
      ),
      prettyCheckboxGroup(
        inputId = 'infocols',
        label = 'Information columns',
        choiceValues = c('taxa', 'n'),
        choiceNames = c('taxa', 'n'),
        selected = 'n'
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
        label = 'Number of chemicals',
        value = 25,
        width = '120px'
      ),
      prettyRadioButtons(
        inputId = 'yaxis',
        label = 'y-axis',
        choiceValues = c('cas', 'cname'),
        choiceNames = c('CAS', 'chemical name'),
        selected = 'cas',
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
                       title = 'Standartox',
                       skin = 'purple')
# server ------------------------------------------------------------------
server = function(input, output, session) {
  
  # renderUI ----------------------------------------------------------------
  # handle multiple inputs
  taxa_input = reactive({
    input_tax = input$tax
    if (!is.null(input_tax)) {
      input_tax = na.omit(trimws(unlist(strsplit(input_tax, ","))))
      input_tax = input_tax[ input_tax != '' ]
    }
    
    return(input_tax)
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
    stx_filter(
      dt = dat,
      concentration_type = input$concentration_type,
      chemical_class = input$chemical_class,
      taxa = taxa_input(),
      habitat = input$habitat,
      region = input$region,
      duration = c(input$dur1, input$dur2),
      publ_year = c(input$yr1, input$yr2), # NOTE currently not incorporated 
      # acch = input$acch, # NOTE currently not incorporated 
      # exposure = input$exposure,
      effect = input$effect,
      endpoint = input$endpoint,
      cas = rv$data
    )
  })
  # aggregate ---------------------------------------------------------------
  data_agg = reactive({
    stx_aggregate(
      dt = stx_filter(
        dt = dat,
        concentration_type = input$concentration_type,
        chemical_class = input$chemical_class,
        tax = taxa_input(),
        habitat = input$habitat,
        region = input$region,
        duration = c(input$dur1, input$dur2),
        publ_year = c(input$yr1, input$yr2),
        # acch = input$acch,
        # exposure = input$exposure,
        effect = input$effect,
        endpoint = input$endpoint,
        cas = rv$data
      ),
      agg = input$agg,
      comp = input$chemical,
      info = input$infocols
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
            input$habitat,
            input$continent,
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
            input$habitat,
            input$continent,
            paste0(input$dur1, input$dur2),
            'data_agg.csv',
            sep = '_')
    },
    content = function(fname) {
      write.csv(data_agg(), fname, row.names = FALSE)
    }
  )
  # markdown ----------------------------------------------------------------
  # output$readme = renderUI({
  #   HTML(markdown::markdownToHTML(knit('README.Rmd', quiet = TRUE)))
  # })
  output$meta = renderText(meta)
}

# app ---------------------------------------------------------------------
shinyApp(ui = ui, server = server)




