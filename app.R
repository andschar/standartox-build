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
        inputId = 'conc1_type',
        label = 'Concentration type',
        choiceValues = stat_l$conc1_type$value,
        choiceNames = stat_l$conc1_type$name_perc,
        selected = grep('active.ingredien', stat_l$conc1_type$value, ignore.case = TRUE, value = TRUE)[1]
      ),
      prettyCheckboxGroup(
        inputId = 'chemical_class',
        label = 'Chemical class',
        choiceValues = stat_l$chemical_class$value,
        choiceNames = stat_l$chemical_class$name_perc,
        selected = NULL
      )
    ),
    menuItem(
      'Taxon',
      tabName = 'taxon',
      selectizeInput(inputId = 'tax',
                     label = 'Taxa',
                     choices = taxa_all_list,
                     selected = NULL,
                     multiple = TRUE,
                     options = list(create = FALSE)),
      prettyCheckboxGroup(
        inputId = 'habitat',
        label = 'Organism hatbitat',
        choiceValues = stat_l$habitat$value,
        choiceNames = stat_l$habitat$name_perc,
        selected = grep('fresh', stat_l$habitat$value, ignore.case = TRUE, value = TRUE)[1]
      ),
      prettyCheckboxGroup(
        inputId = 'region',
        label = 'Continent',
        choiceValues = stat_l$region$value,
        choiceNames = stat_l$region$name_perc,
        selected = grep('europe', stat_l$region$value, ignore.case = TRUE, value = TRUE)[1]
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
      #   choiceValues = stat_l$test_location$value,
      #   choiceNames = stat_l$test_location$value
      # ),
      ### END TODO
      splitLayout(
        prettyCheckboxGroup(
          inputId = 'effect',
          label = 'Effect group',
          choiceValues = stat_l$effect$value,
          choiceNames = stat_l$effect$name_perc,
          selected = c('MOR', 'POP', 'GRO', 'ITX')
        ),
        prettyRadioButtons(
          inputId = 'endpoint',
          label = 'Endpoint',
          choiceValues = stat_l$endpoint$value,
          choiceNames = stat_l$endpoint$name_perc,
          selected = c('XX50')
        )
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
      'Method',
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
        inputId = 'chemical',
        label = 'Chemical columns',
        choiceValues = c('casnr', 'cname'),
        choiceNames = c('CAS', 'Chemical name'),
        selected = c('casnr', 'cname')
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
        label = 'Number of chemicals',
        value = 25,
        width = '120px'
      ),
      prettyRadioButtons(
        inputId = 'yaxis',
        label = 'y-axis',
        choiceValues = c('casnr', 'cname'),
        choiceNames = c('CAS', 'chemical name'),
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
    fun_filter(
      dt = dat,
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
        dt = dat,
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
      comp = input$chemical,
      rm_outl = input$rm_outl
    )
  })
  # debuging
  # output$debug = eventReactive({
  #   saveRDS(data_fil(), '/tmp/data_fil')
  #   saveRDS(data_agg(), '/tmp/data_agg')
  # })
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
  # markdown ----------------------------------------------------------------
  # output$readme = renderUI({
  #   HTML(markdown::markdownToHTML(knit('README.Rmd', quiet = TRUE)))
  # })
  output$meta = renderUI({
    HTML(markdown::markdownToHTML(knit('meta.Rmd', quiet = TRUE)))
  })
  
  
  # version -----------------------------------------------------------------
  output$version = renderText(version_string)
  
}

# app ---------------------------------------------------------------------
shinyApp(ui = ui, server = server)




