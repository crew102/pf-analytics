#' @export
server <- shinyServer(function(input, output, session) {

  output$dist_plot <- renderPlot({
    hist(rnorm(input$obs))
  })

})
