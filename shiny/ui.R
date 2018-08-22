# script for a shiny app selecting EC50 values

# setup -------------------------------------------------------------------
source('/home/andreas/Documents/Projects/etox-base/R/setup.R')
require(shiny)
require(shinyjs)
require(shinydashboard)
require(knitr)


# User Interface ----------------------------------------------------------
ui = fluidPage(
  useShinyjs(), # Include shinyjs
  
  titlePanel('Etox Base'),
  sidebarLayout(
    sidebarPanel(
      verticalLayout(
        selectInput(inputId = 'tax', label = 'Choose a taxon',
                    choices = c('Chironomidae', 'Daphniidae', 'Insecta', 'Crustacea', 'Annelida', 'Platyhelminthes', 'Mollusca', 'Makro_Inv', 'Fish', 'Algae', 'Bacillariophyceae', 'Plants')),
        splitLayout(
          numericInput(inputId = 'dur1', label = 'Test durations from (h)', value = 24),
          numericInput(inputId = 'dur2', label = 'to (h)', value = 48)
        ),
        splitLayout(
          fileInput(inputId = 'file_cas', label = 'Upload CAS',
                    accept = '.csv', placeholder = 'one column .csv'),
          actionButton(inputId = 'reset', label = 'Reset Input', style = 'margin-top:25px')
        ),
        splitLayout(
          radioButtons(inputId = 'habitat', label = 'Organism hatbitat',
                       choices = c('all', 'marine', 'brackish', 'freshwater', 'terrestrial'),
                       selected = 'freshwater'),
          radioButtons(inputId = 'continent', label = 'Continent',
                       choices = c('all', 'Africa', 'Americas', 'Asia', 'Europe', 'Oceania'),
                       selected = 'Europe'),
          checkboxInput(inputId = 'comp_solub_chck', label = 'Water solubility check')
        ),
        splitLayout(
          checkboxGroupInput(inputId = 'conc_type', label = 'Concentration type',
                             choiceValues = c('A', 'F'), # 'T', 'U'),
                             choiceNames = c('Active ingredient', 'Formulation'),
                             selected = c('A', 'F')),
          checkboxGroupInput(inputId = 'agg', label = 'Aggregate',
                             choices = c('min', 'max', 'md', 'mn', 'sd'),
                             selected = c('min', 'md'))
        ),
        splitLayout(
          checkboxGroupInput(inputId = 'comp', label = 'Compound columns',
                             choiceValues = c('comp_name', 'comp_type'),
                             choiceNames = c('Compound name', 'Compound type'),
                             selected = c('cas', 'comp_name')),
          checkboxGroupInput(inputId = 'infocols', label = 'Information columns',
                             choiceValues = c('info', 'taxa', 'vls', 'n'),
                             choiceNames = c('info', 'taxa', 'values', 'n'),
                             selected = 'taxa')
        ))),
    
    mainPanel(
      tabsetPanel(
        selected = 'README',
        tabPanel(
          'Table',
          headerPanel('EC50 values'),
          column(
            dataTableOutput(outputId = 'dat'), width = 11, offset = 0
          )
        ),
        tabPanel(
          'Summary',
          splitLayout(
            fluidPage(
              headerPanel('CAS'),
              verbatimTextOutput(outputId = 'summary_chem')
            ),
            fluidPage(
              headerPanel('Organisms'),
              verbatimTextOutput(outputId = 'summary_taxa')
            )
          )
        ),
        tabPanel(
          'Plots',
          tabsetPanel(
            tabPanel(
              'Sensitivity plots',
              headerPanel('Most sensitive EC50 values'),
              fluidRow(
                shinydashboard::box(width = 4,
                splitLayout(
                  numericInput(inputId = 'cutoff', label = 'Number of compounds', value = 25, width = '150px'),
                  radioButtons(inputId = 'yaxis', label = 'Y-Axis',
                               choiceValues = c('casnr', 'comp_name'),
                               choiceNames = c('CAS', 'Compound name'),
                               selected = 'casnr', inline = TRUE))
                )
              ),
              plotOutput(outputId = 'plot_sensitivity')
            ),
            tabPanel(
              'Meta plots',
              plotOutput(outputId = 'plot_meta')
            )
          )
        ),
        tabPanel(
          'Download',
          downloadButton(outputId = 'download', 'Download the data')
        ),
        tabPanel(
          'README',
          withMathJax(includeMarkdown('README.md'))
          # https://stackoverflow.com/questions/33499651/rmarkdown-in-shiny-application
        ),
        tabPanel(
          'Help',
          'Write the help pages'
        ),
        tabPanel(
          'Article',
          withMathJax(includeMarkdown('article.md'))
        )
      )
    )
  )
)


