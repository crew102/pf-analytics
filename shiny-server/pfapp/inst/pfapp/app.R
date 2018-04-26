library(pfapp)
library(shiny)

# calling load all for purposes of quick dev workflow
devtools::load_all("../..")
shinyApp(ui, server)
