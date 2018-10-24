# script for a shiny app selecting EC50 values

# setup -------------------------------------------------------------------
source('setup.R')

# User Interface ----------------------------------------------------------
ui = fluidPage(
  useShinyjs(), # Include shinyjs
  titlePanel('Etox Base'),
  sidebarLayout(
    sidebarPanel(
      #verticalLayout(
      tabsetPanel(
        tabPanel(
          'Compound',
          verticalLayout(
            br(),
            splitLayout(
              fileInput(inputId = 'file_cas', label = 'Upload CAS',
                        accept = '.csv', placeholder = 'one column .csv'),
              actionButton(inputId = 'reset', label = 'Reset Input', style = 'margin-top:25px')
            ),
            verticalLayout(
              checkboxGroupInput(inputId = 'conc_type', label = 'Concentration type',
                                 choiceValues = te_stats_l$tes_conc_type$val,
                                 choiceNames = paste0(
                                   te_stats_l$tes_conc_type$val,
                                   ' - ',
                                   te_stats_l$tes_conc_type$nam_long,
                                   ' (',
                                   te_stats_l$tes_conc_type$n,
                                   ')'),
                                 selected = c('A'))
              # helpText(a('Help', href = 'https://cfpub.epa.gov/ecotox/pdf/codeappendix.pdf'))
            ),
            splitLayout(
              checkboxGroupInput(inputId = 'chem_class', label = 'Chemical class',
                                 choiceValues = te_stats_l$chem_class$variable,
                                 choiceNames = te_stats_l$chem_class$nam_long_stat,
                                 selected = 'cgr_herbicide'),
              # TODO Don't know which data source provides such information
              # checkboxGroupInput(inputId = 'authorization', label = 'Authorized in')
              checkboxInput(inputId = 'comp_solub_chck', label = 'Water solubility check')
            )
          )
        ),
        tabPanel(
          'Taxa',
          verticalLayout(
            br(),
            selectInput(inputId = 'tax', label = 'Choose a taxon',
                        choices = c('Chironomidae', 'Daphniidae', 'Insecta', 'Crustacea', 'Annelida', 'Platyhelminthes', 'Mollusca', 'Makro_Inv', 'Fish', 'Algae', 'Bacillariophyceae', 'Plants')),
            splitLayout(
              checkboxGroupInput(inputId = 'habitat', label = 'Organism hatbitat',
                                 choiceValues = te_stats_l$habitat$variable,
                                 choiceNames = te_stats_l$habitat$nam_long_stat,
                                 selected = 'hab_fresh'),
              checkboxGroupInput(inputId = 'continent', label = 'Continent',
                                 choiceValues = te_stats_l$continent$variable,
                                 choiceNames = te_stats_l$continent$nam_long_stat,
                                 selected = 'reg_europe')
            )
          )
        ),
        tabPanel(
          'Test',
          verticalLayout(
            br(),
            splitLayout(
              numericInput(inputId = 'dur1', label = 'Test durations from (h)', value = 24),
              numericInput(inputId = 'dur2', label = 'to (h)', value = 48)
            ),
            splitLayout(
              checkboxGroupInput(inputId = 'effect', label = 'Effect group',
                                 choiceValues = te_stats_l$tes_effect$val,
                                 choiceNames = te_stats_l$tes_effect$nam),
              radioButtons(inputId = 'endpoint', label = 'TODO Endpoints',
                           choiceValues = c('EC50', 'LOEC', 'NOEC'),
                           choiceNames = c('L/EC50', 'LOEC', 'NOEC'),
                           selected = 'EC50')
            )
          )
        ),
        tabPanel(
          'Aggregation',
          verticalLayout(
            br(),
            splitLayout(
              checkboxGroupInput(inputId = 'agg', label = 'Aggregate',
                                 choices = c('min', 'max', 'md', 'mn', 'sd'),
                                 selected = 'md')
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
            )
          )
        )
      )
    ),
    
    # main panel --------------------------------------------------------------
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
                                      numericInput(inputId = 'cutoff',
                                                   label = 'Number of compounds',
                                                   value = 25, width = '120px'),
                                      radioButtons(inputId = 'yaxis', label = 'y-Axis',
                                                   choiceValues = c('casnr', 'comp_name'),
                                                   choiceNames = c('CAS', 'Compound name'),
                                                   selected = 'casnr', inline = FALSE))
                )
              ),
              plotOutput(outputId = 'plot_sensitivity')
            ),
            tabPanel(
              'Meta plots',
              headerPanel('Meta plot'),
              plotOutput(outputId = 'plot_meta')
            )
          )
        ),
        tabPanel(
          'Download',
          downloadButton(outputId = 'download', 'Download the data')
        ),
        tabPanel(
          'README'
          # TODO withMathJax(includeMarkdown('README.md')) # TODO include agian
          # https://stackoverflow.com/questions/33499651/rmarkdown-in-shiny-application
        ),
        tabPanel(
          'Help',
          'Write the help pages'
        ),
        tabPanel(
          'Missing',
          column(
            dataTableOutput(outputId = 'missing'), width = 11, offset = 0
          )
        ),
        tabPanel(
          'Article'
          #withMathJax(includeMarkdown('article.md'))
        ),
        tabPanel(
          'About',
          'EPA ECOTOX cersion: Version: 7 Juli 2018',
          'automate this on the server side!!'
        )
      )
    )
  )
)


