#' @export
server <- shinyServer(function(input, output, session) {

  output$dist_plot <- renderPlot({
    hist(rnorm(input$obs))
  })

  output$acc <- renderPrint({
    if (is.null(input$access_token)) return()
    to_get <- paste0(
      "https://pf-analytics.auth0.com/userinfo?access_token=", input$access_token
    )
    httr::GET(to_get) %>%
      httr::content("text") %>%
      jsonlite::fromJSON()
  })

})
