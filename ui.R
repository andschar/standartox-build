# UI of the etox-base app

# setup -------------------------------------------------------------------
src = file.path(getwd(), 'R')
source(file.path(src, 'setup.R'))

# data --------------------------------------------------------------------
source(file.path(src, 'data.R'))

# variables ---------------------------------------------------------------
sidewidth = 350

# header ------------------------------------------------------------------
header = dashboardHeaderPlus(
  title = 'Etox Base',
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
      prettyCheckboxGroup(
        inputId = 'conc_type',
        label = 'Concentration type',
        choiceValues = te_stats_l$tes_conc1_type$variable,
        choiceNames = te_stats_l$tes_conc1_type$nam_fin,
        selected = c('A')
      ),
      prettyCheckboxGroup(
        inputId = 'chem_class',
        label = 'Chemical class',
        choiceValues = te_stats_l$chem_class$variable,
        choiceNames = te_stats_l$chem_class$nam_fin,
        selected = 'cgr_herbicide'
      )
    ),
    menuItem(
      'Taxon',
      tabName = 'taxon',
    #  #### UNDER CONSTRUCTION ----
      selectInput(
        inputId = 'tax',
        label = 'Choose a taxon',
        choices = c(
          'Daphniidae',
          'Chironomidae',
          'Insecta',
          'Crustacea',
          'Annelida',
          'Platyhelminthes',
          'Mollusca',
          'Makro_Inv',
          'Fish',
          'Algae',
          'Bacillariophyceae',
          'Plants'
        )
      ),
      # textInput(
      #   inputId = 'tax',
      #   label = 'Put in a taxon',
      #   placeholder = 'Separate by comma'
      # ),
    ### END CONSTRUCTION
      prettyCheckboxGroup(
        inputId = 'habitat',
        label = 'Organism hatbitat',
        choiceValues = te_stats_l$habitat$variable,
        choiceNames = te_stats_l$habitat$nam_fin,
        selected = 'hab_fresh'
      ),
      prettyCheckboxGroup(
        inputId = 'continent',
        label = 'Continent',
        choiceValues = te_stats_l$continent$variable,
        choiceNames = te_stats_l$continent$nam_fin,
        selected = 'reg_europe'
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
          choiceValues = c('diet'),
          choiceNames = c('diet')
        )
      ),
      splitLayout(
        prettyCheckboxGroup(
          inputId = 'effect',
          label = 'Effect groups',
          choiceValues = te_stats_l$tes_effect$variable,
          choiceNames = te_stats_l$tes_effect$nam_fin,
          selected = c('MOR', 'POP', 'GRO', 'ITX')
        ),
        prettyRadioButtons(
          inputId = 'endpoint',
          label = 'Endpoints',
          choiceValues = te_stats_l$tes_endpoint$variable,
          choiceNames = te_stats_l$tes_endpoint$nam_fin,
          selected = c('XX50')
        )
      )
    ),
    menuItem(
      'Checks',
      tabName = 'checks',
      prettyCheckbox(inputId = 'chck_solub', label = 'Water solubility check'),
      prettyCheckbox(
        inputId = 'chck_outlier',
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
        selected = 'md'
      )
    )
  )
)


rightsidebar = rightSidebar()

# body --------------------------------------------------------------------
body = dashboardBody(#setShadow(class = "dropdown-menu"),
  #tags$head(includeCSS('style.css')),
  fluidRow(
    box(
      title = 'Etox-Base',
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
      dataTableOutput(outputId = 'dat'),
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
        choiceValues = c('comp_name', 'comp_type'),
        choiceNames = c('Compound name', 'Compound type'),
        selected = c('cas', 'comp_name')
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
      plotlyOutput(outputId = 'plotly_sensitivity')
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
        choiceValues = c('casnr', 'comp_name'),
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
