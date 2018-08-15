# script for a shiny app selecting EC50 values

# setup -------------------------------------------------------------------
source('/home/andreas/Documents/Projects/etox-base/R/setup.R')
require(shiny)


# User Interface ----------------------------------------------------------
ui = fluidPage(
  # actionButton() #??
  checkboxGroupInput(inputId = 'habitat', label = 'Pick an organism hatbitat',
                     choices = c('marine', 'brackish', 'freshwater', 'terrestrial')),
  checkboxGroupInput(inputId = 'continent', label = 'Pick a continent',
                     choices = c('Africa', 'Americas', 'Antarctica', 'Asia', 'Europe', 'Oceania')),
  selectInput(inputId = 'tax', label = 'Choose a taxon',
              choices = c('Chironomidae', 'Daphniidae', 'Insecta', 'Crustacea', 'Annelida', 'Platyhelminthes', 'Mollusca', 'Makro_Inv', 'Fish', 'Algae', 'Bacillariophyceae', 'Plants')),
  dataTableOutput(outputId = 'dat')
  
  # # tutorial stuff:
  # numericInput(inputId = 'n',
  #              label = 'sample size', value = 25),
  # plotOutput(outputId = 'hist')
)


