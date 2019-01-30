# UI of the etox-base app

# setup -------------------------------------------------------------------
src = file.path(getwd(), 'R')
source(file.path(src, 'setup.R'))

# variables ---------------------------------------------------------------
sidewidth = 350

# data --------------------------------------------------------------------
#n_pl = read_feather(file.path(cache, 'n_pl'))

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
      downloadButton(outputId = 'download_agg', 'Aggregated data'),
      downloadButton(outputId = 'download_fil', 'Filtered data')
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
        choiceValues = te_stats_l$tes_conc_type$variable,
        choiceNames = te_stats_l$tes_conc_type$nam_fin,
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
          label = 'Test durations from',
          value = 24
        ),
        numericInput(
          inputId = 'dur2',
          label = 'to (h)',
          value = 48
        )
      ),
      prettyCheckboxGroup(
        inputId = 'acch',
        label = 'TODO! Acute / Chronic',
        # TODO take choices programatically!
        choiceValues = c('acute', 'chronic', 'nc'),
        choiceNames = c('acute', 'chronic', 'not classified')
      ),
      splitLayout(
        prettyCheckboxGroup(
          inputId = 'effect',
          label = 'Effect group',
          choiceValues = te_stats_l$tes_effect$variable,
          choiceNames = te_stats_l$tes_effect$nam_fin,
          selected = c('MOR', 'POP', 'GRO', 'ITX')
        ),
        prettyCheckboxGroup(
          inputId = 'endpoint',
          label = 'Endpoints',
          choiceValues = te_stats_l$tes_endpoint$variable,
          choiceNames = te_stats_l$tes_endpoint$nam_fin,
          selected = c('LC50', 'EC50')
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
        choiceValues = c('min', 'max', 'md', 'mn', 'sd'),
        choiceNames = c('Minimum', 'Maximum', 'Median', 'Mean', 'Standard Deviation'),
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
