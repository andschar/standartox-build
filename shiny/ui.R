# script for a shiny app selecting EC50 values

# setup -------------------------------------------------------------------
source('/home/andreas/Documents/Projects/etox-base/R/setup.R')
require(shiny)
require(knitr)


# User Interface ----------------------------------------------------------
ui = fluidPage(
  
  titlePanel('Etox Base'),
  sidebarLayout(
    sidebarPanel(
      # textInput(inputId = 'cas', label = 'Put in CAS',
      #           value = NULL), # TODO allow for multiple entries
      selectInput(inputId = 'tax', label = 'Choose a taxon',
                  choices = c('Chironomidae', 'Daphniidae', 'Insecta', 'Crustacea', 'Annelida', 'Platyhelminthes', 'Mollusca', 'Makro_Inv', 'Fish', 'Algae', 'Bacillariophyceae', 'Plants')),
      splitLayout(
        numericInput(inputId = 'dur1', label = 'Test durations from (h)', value = 24),
        numericInput(inputId = 'dur2', label = 'to (h)', value = 48)
      ),
      splitLayout(
        radioButtons(inputId = 'habitat', label = 'Organism hatbitat',
                     choices = c('marine', 'brackish', 'freshwater', 'terrestrial'),
                     selected = 'freshwater'),
        radioButtons(inputId = 'continent', label = 'Continent',
                     choices = c('Africa', 'Americas', 'Asia', 'Europe', 'Oceania'),
                     selected = 'Europe')
      ),
      splitLayout(
        checkboxGroupInput(inputId = 'agg', label = 'Aggregate',
                           choices = c('min', 'max', 'md', 'mn', 'sd'),
                           selected = c('min', 'md')),
        checkboxGroupInput(inputId = 'infocols', label = 'Information columns',
                           choices = c('info', 'taxa', 'vls', 'n'))
      ),
      splitLayout(
        checkboxGroupInput(inputId = 'subst_type', label = 'Substance type',
                           choices = c('A', 'F', 'T', 'U'))
      )),
    
    mainPanel(
      tabsetPanel(
        selected = 'README',
        tabPanel(
          'Table',
          dataTableOutput(outputId = 'dat')
        ),
        tabPanel(
          'Plots',
          tabsetPanel(
            tabPanel(
              'Sensitivity plots',
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
        )
      )
    )
  )
)


