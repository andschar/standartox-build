# Standartox app reactive
# this app allows only uses the newest version of the EPA ECOTOX

# setup -------------------------------------------------------------------
source('~/Projects/standartox-build/app/setup.R')
# variables
sidewidth = 400

# data --------------------------------------------------------------------
source(file.path(app, 'data.R'))

# catalog -----------------------------------------------------------------
catalog = readRDS(file.path(datadir2, paste0('standartox_catalog_app.rds')))

# render here as data.table
# NOTE much faster than providing as vector
casnr_dt = catalog$casnr[ , lapply(.SD, casconv, direction = 'tocas'), .SDcols = 'variable' ]
setnames(casnr_dt, 'CAS')
cname_dt = catalog$cname[ , .SD, .SDcols = 'variable' ]
setnames(cname_dt, 'Chemical_name')
tax_dt = catalog$taxa[ , .SD, .SDcols = 'variable' ]
setnames(tax_dt, 'Taxon')

# header ------------------------------------------------------------------
header = dashboardHeader(
  title = 'Standartox',
  titleWidth = sidewidth,
  fixed = TRUE,
  leftUi = tagList(
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
      'Chemicals',
      tabName = 'chemical',
      startExpanded = FALSE, # TODO why is app so slow when TRUE
      selectizeInput(
        inputId = 'casnr',
        label = 'CAS input',
        # choices = list(casnr = casnr_dt$CAS,
        #                cname = cname_dt$Chemical_name), # TODO allow chemical name as input
        # TODO allow chemical name as input
        choices = casnr_dt,
        selected = NULL,
        multiple = TRUE,
        options = list(create = FALSE)
      ),
      splitLayout(
        prettyCheckboxGroup(
          inputId = 'concentration_unit',
          label = 'Concentration unit',
          choiceValues = catalog$concentration_unit$variable,
          choiceNames = catalog$concentration_unit$name_perc,
          selected = grep('ug/l|ppb', catalog$concentration_unit$variable,
                          ignore.case = TRUE, value = TRUE)[1]
        ),
        prettyCheckboxGroup(
          inputId = 'concentration_type',
          label = 'Concentration type',
          choiceValues = catalog$concentration_type$variable,
          choiceNames = catalog$concentration_type$name_perc,
          selected = grep('active.ingredien', catalog$concentration_type$variable,
                          ignore.case = TRUE, value = TRUE)[1]
        )
      ),
      prettyCheckboxGroup(
        inputId = 'chemical_role',
        label = 'Chemical role',
        choiceValues = catalog$chemical_role$variable,
        choiceNames = catalog$chemical_role$name_perc,
        selected = grep('insecticide', catalog$chemical_role$variable,
                        ignore.case = TRUE, value = TRUE)[1]
      ),
      prettyCheckboxGroup(
        inputId = 'chemical_class',
        label = 'Chemical class',
        choiceValues = catalog$chemical_class$variable,
        choiceNames = catalog$chemical_class$name_perc,
        selected = grep('neonicotinoid', catalog$chemical_class$variable,
                        ignore.case = TRUE, value = TRUE)[1]
      )
    ),
    menuItem(
      'Taxa',
      tabName = 'taxon',
      selectizeInput(
        inputId = 'tax',
        label = 'Taxa',
        choices = tax_dt,
        selected = 'Daphnia magna',
        multiple = TRUE,
        options = list(create = FALSE)),
      splitLayout(
        prettyCheckboxGroup(
          inputId = 'habitat',
          label = 'Hatbitat',
          choiceValues = catalog$habitat$variable,
          choiceNames = catalog$habitat$name_perc,
          selected = grep('fresh', catalog$habitat$variable,
                          ignore.case = TRUE, value = TRUE)[1]
        ),
        prettyCheckboxGroup(
          inputId = 'region',
          label = 'Region',
          choiceValues = catalog$region$variable,
          choiceNames = catalog$region$name_perc,
          selected = grep('europe', catalog$region$variable,
                          ignore.case = TRUE, value = TRUE)[1]
        )
      ),
      splitLayout(
        prettyCheckboxGroup(
          inputId = 'trophic_lvl',
          label = 'Trophic level',
          choiceValues = catalog$trophic_lvl$variable,
          choiceNames = catalog$trophic_lvl$name_perc,
          selected = grep('hetero', catalog$trophic_lvl$variable,
                          ignore.case = TRUE, value = TRUE)[1]
        ),
        prettyCheckboxGroup(
          inputId = 'ecotox_grp',
          label = 'Ecotoxicological grouping',
          choiceValues = catalog$ecotox_grp$variable,
          choiceNames = catalog$ecotox_grp$name_perc,
          selected = grep('inverte', catalog$ecotox_grp$variable,
                          ignore.case = TRUE, value = TRUE)[1],
        )
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
      splitLayout(
        prettyCheckboxGroup(
          inputId = 'exposure',
          label = 'Exposure group',
          choiceValues = catalog$exposure$variable,
          choiceNames = catalog$exposure$name_perc,
          selected = grep('aquatic', catalog$exposure$variable,
                          ignore.case = TRUE, value = TRUE)[1]
        ),
        prettyRadioButtons(
          inputId = 'endpoint',
          label = 'Endpoint',
          choiceValues = catalog$endpoint$variable,
          choiceNames = catalog$endpoint$name_perc,
          selected = c('XX50')
        )
      ),
      prettyCheckboxGroup(
        inputId = 'effect',
        label = 'Effect group',
        choiceValues = catalog$effect$variable,
        choiceNames = catalog$effect$name_perc,
        selected = grep('mortality', catalog$effect$variable,
                        ignore.case = TRUE, value = TRUE)[1]
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

rightsidebar = dashboardControlbar()

# body --------------------------------------------------------------------
body = dashboardBody(
  use_tracking(), # log
  br(),
  br(),
  br(),
  fluidRow(
    box(
      status = 'success',
      width = 9,
      collapsible = TRUE,
      withMathJax(includeMarkdown(file.path(rootdir, 'README.md'))) # https://stackoverflow.com/questions/33499651
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
        choices = c('Chemical name', 'CAS'),
        selected = c('Chemical name', 'CAS')
      ),
      prettyCheckboxGroup(
        inputId = 'infocols',
        label = 'Information columns',
        choices = c('taxa', 'n'),
        selected = c('taxa', 'n')
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

ui = dashboardPage(header = header,
                   sidebar = sidebar,
                   body = body,
                   title = 'Standartox',
                   skin = 'purple')

server = function(input, output, session) {
  # log ---------------------------------------------------------------------
  track_usage(
    storage_mode = store_rds(path = file.path(app, 'log/app'))
  )
  # renderUI ----------------------------------------------------------------
  casnr_input = reactive({
    casnr = gsub('-', '', handle_input_multiple(input$casnr), fixed = TRUE)
    if (length(casnr) == 0) {
      casnr = NULL
    }
    casnr
  })
  # handle multiple inputs
  taxa_input = reactive({
    handle_input_multiple(input$tax)
  })
  # filter ------------------------------------------------------------------
  data_fil = reactive({
    fil <<- stx_filter(
      test = stx_test,
      chem = stx_chem,
      taxa = stx_taxa,
      refs = stx_refs,
      concentration_unit_ = input$concentration_unit,
      concentration_type_ = input$concentration_type,
      chemical_role_ = input$chemical_role,
      chemical_class_ = input$chemical_class,
      taxa_ = taxa_input(),
      trophic_lvl_ = input$trophic_lvl,
      habitat_ = input$habitat,
      region_ = input$region,
      ecotox_grp_ = input$ecotox_grp,
      duration_ = c(input$dur1, input$dur2),
      effect_ = input$effect,
      endpoint_ = input$endpoint,
      exposure_ = input$exposure,
      casnr_ = casnr_input()
    )
    fil
  })
  # TODO add outlier flaging here
  # CONTINUE HERE (writte: 19.3.2020)
  # aggregate ---------------------------------------------------------------
  data_agg = reactive({
    fil = stx_filter(
      test = stx_test,
      chem = stx_chem,
      taxa = stx_taxa,
      refs = stx_refs,
      concentration_unit_ = input$concentration_unit,
      concentration_type_ = input$concentration_type,
      chemical_role_ = input$chemical_role,
      chemical_class_ = input$chemical_class,
      taxa_ = taxa_input(),
      trophic_lvl_ = input$trophic_lvl,
      habitat_ = input$habitat,
      region_ = input$region,
      ecotox_grp_ = input$ecotox_grp,
      duration_ = c(input$dur1, input$dur2),
      effect_ = input$effect,
      endpoint_ = input$endpoint,
      exposure_ = input$exposure,
      casnr_ = casnr_input()
    )
    agg = standartox:::stx_aggregate(fil)[ , .SD, .SDcols = c('cname', 'cas', 'gmn', 'n', 'tax_all') ]
    setnames(agg,
             c('cname', 'cas', 'gmn', 'tax_all'),
             c('Chemical name', 'CAS', 'geometric mean', 'taxa'))
    agg[ , .SD, .SDcols = c(input$chemical, 'geometric mean', input$infocols) ]
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
  # output$plotly = renderPlotly({
  # TODO
  #   plotly_fin(
  #     agg = data_agg(),
  #     fil = data_fil(),
  #     xaxis = input$xaxis,
  #     yaxis = input$yaxis,
  #     cutoff = input$cutoff
  #   )
  # })
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
