
require(shinydashboard)



ui = dashboardPage(
  
  dashboardHeader(title = 'Etox Base'),
  
  dashboardSidebar(
    sidebarMenu(id = 'Menu',
                menuItem('Compound', tabName = 'compound',
                         checkboxGroupInput(inputId = 'conc_type', label = 'Concentration type',
                                            choiceValues = te_stats_l$tes_conc_type$val,
                                            choiceNames = paste0(
                                              te_stats_l$tes_conc_type$val,
                                              ' - ',
                                              te_stats_l$tes_conc_type$nam_long,
                                              ' (',
                                              te_stats_l$tes_conc_type$n,
                                              ')'),
                                            selected = c('A'))))
    # sidebarMenu('Taxa', tabName = 'taxa'),
    # sidebarMenu('Test', tabName = 'test'),
    # sidebarMenu('Checks', tabName = 'checks'),
    # sidebarMenu('Aggregation', tabName = 'aggregation')
  ),
  
  dashboardBody()
  
  
)