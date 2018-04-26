#' @export
ui <- fluidPage(
  tags$head(
    tags$script(src = "js/access-token.js")
  ),
  sidebarLayout(
    sidebarPanel(
      sliderInput("obs", "Number of obs:", min = 10, max = 500, value = 100)
    ),
    mainPanel(
      plotOutput("dist_plot"),
      textOutput("acc")
    )
  )
)
