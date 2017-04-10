##crosstalk-plotly-shiny example: 
# Might make linked brushing alot easier, but we'll see if it delivers.

#installation steps:
devtools::install_github('ropensci/plotly')
devtools::install_github('rstudio/crosstalk')
##devtools::install_github('rstudio/DT')

library(crosstalk)
library(plotly)
library(DT)
library(shiny)

#------- a simple example using iris data:

shared_iris <- SharedData$new(iris)

ui <- fluidPage(
  fluidRow(column(6,
                  plotlyOutput("plot1")),
           column(6,
                  plotlyOutput("plot2"))),
  tableOutput("table")
)

server <- function(input, output) {
  
  shared_iris <- SharedData$new(iris)
  
  output$plot1 <- renderPlotly({
    plot_ly(shared_iris, x = ~Petal.Width, y = ~Petal.Length, color = ~Species, type = "scatter", mode = "markers")
  })
  
  output$plot2 <- renderPlotly({
    plot_ly(shared_iris, x = ~Sepal.Width, y = ~Sepal.Length, color = ~Species, type = "scatter", mode = "markers")
  })
  
  output$table <- renderTable({
    event_data("plotly_selected")
  })
  
}


shinyApp(ui, server)


#you could expand this to doing more things than just trying to do linked brushing/filtering (otherwise why couple it with Shiny...).
#Though, if you're thinking of just linked brushing alone - maybe crosstalk alone does the job neatly.


#TODO: Make a more complex example??
