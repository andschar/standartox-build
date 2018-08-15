# script for a shiny app selecting EC50 values

# setup -------------------------------------------------------------------
source('/home/andreas/Documents/Projects/etox-base/R/setup.R')
require(shiny)


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
        checkboxGroupInput(inputId = 'habitat', label = 'Organism hatbitat',
                           choices = c('marine', 'brackish', 'freshwater', 'terrestrial')),
        checkboxGroupInput(inputId = 'continent', label = 'Continent',
                           choices = c('Africa', 'Americas', 'Antarctica', 'Asia', 'Europe', 'Oceania'))
      )),
    mainPanel(
      tabsetPanel(
        tabPanel(
          'Table',
          dataTableOutput(outputId = 'dat',
                          width = 4, height = 4)
          ),
        tabPanel(
          'Plot',
          'Test'
          ),
        tabPanel(
          'Download',
          downloadButton(outputId = 'download', 'Download the data')
        )
        )
      )
    )
  )


# # tutorial stuff:
# numericInput(inputId = 'n',
#              label = 'sample size', value = 25),
# plotOutput(outputId = 'hist')

