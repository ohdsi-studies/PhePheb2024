# header =======================================================================
header <- shinydashboard::dashboardHeader(title = "Phenotype error")

# side bar =====================================================================
sidebarMenu <- shinydashboard::sidebarMenu(

  id = "tabs",

  shinydashboard::menuItem(
    text = "Correction thresholds",
    tabName = "correctionThresholds"
  ),

  shiny::conditionalPanel(

    condition = "input.tabs == 'correctionThresholds'",

    shinyWidgets::pickerInput(
      inputId = "method",
      label = "Method",
      choices = methods,
      selected = methods[1],
      multiple = FALSE
    ),

    shinyWidgets::pickerInput(
      inputId = "database",
      label = "Database",
      choices = databases,
      selected = databases,
      multiple = TRUE
    ),

    shinyWidgets::pickerInput(
      inputId = "stratum",
      label = "Stratum",
      choices = strata,
      selected = strata[1],
      multiple = TRUE
    ),

    shinyWidgets::pickerInput(
      inputId = "target",
      label = "Target",
      choices = targets,
      selected = targets[1],
      multiple = FALSE
    ),

    shinyWidgets::pickerInput(
      inputId = "outcome",
      label = "Outcome",
      choices = outcomes,
      selected = outcomes[1],
      multiple = TRUE
    ),

    shiny::sliderInput(
      inputId = "sens",
      label = "Sensitivity",
      value = 1,
      min = 0,
      max = 1,
      step = 0.0001
    ),

    shiny::sliderInput(
      inputId = "spec",
      label = "Specificity",
      value = 1,
      min = 0,
      max = 1,
      step = 0.0001
    ),

    shiny::sliderInput(
      inputId = "ppv",
      label = "PPV",
      value = 1,
      min = 0,
      max = 1,
      step = 0.0001
    ),

    shiny::sliderInput(
      inputId = "npv",
      label = "NPV",
      value = 1,
      min = 0,
      max = 1,
      step = 0.0001
    )
  )
)

sidebar <- shinydashboard::dashboardSidebar(sidebarMenu)


# body =========================================================================
bodyTabItems <- shinydashboard::tabItems(

  shinydashboard::tabItem(
    tabName = "correctionThresholds",
    shinydashboard::box(
      title = "IP: /1000 P, IR: /1000 PYs",
      width = NULL,
      height = NULL,
      DT::dataTableOutput(outputId = "ipIrCorrections")
    )
  )
)

body <- shinydashboard::dashboardBody(bodyTabItems)

# dashboard ====================================================================
shinydashboard::dashboardPage(
  header = header,
  sidebar = sidebar,
  body = body
)
