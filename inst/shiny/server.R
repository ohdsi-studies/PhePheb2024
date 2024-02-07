
shiny::shinyServer(function(input, output) {

  getIpIrCorrectionsReactive <- shiny::reactive(x = {
    rows <- irTable %>%
      dplyr::filter(
        .data$source %in% input$database &
        .data$stratum %in% input$stratum &
        .data$tName %in% input$target &
        .data$oName %in% input$outcome
      )

    rowsList <- split(rows, seq(nrow(rows)))

    rowsList <- lapply(
      X = rowsList,
      FUN = getCorrectedIrIp,
      method = input$method,
      sens = input$sens,
      spec = input$spec,
      ppv = input$ppv,
      npv = input$npv
    )

    rows <- dplyr::bind_rows(rowsList) %>%
      dplyr::select(c(source, method, tName, oName, stratum, IP, cIP, IPrel, IPeame, IR, cIR, IRrel, IReame))

    return(rows)
  })

  output$ipIrCorrections <- DT::renderDataTable(expr = {
    data <- getIpIrCorrectionsReactive()
    table <- DT::datatable(
      data,
      rownames = FALSE,
      class = "stripe compact",
      options = list(
        autoWidth = FALSE,
        scrollX = TRUE
      )
    )
    return(table)
  })

})
