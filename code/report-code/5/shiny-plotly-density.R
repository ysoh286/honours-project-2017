library(shiny)
library(plotly)

census <- read.csv("http://new.censusatschool.org.nz/wp-content/uploads/2016/08/CaS2009_subset.csv",
                   header = TRUE)

ui <- basicPage(
  plotlyOutput("plot"),
  sliderInput("range", "Bandwidth", min = 0.1, max = 1, value = 0.1)
)

server <- function(input, output) {
  output$plot <- renderPlotly({
    ggplot(census) + aes(x = height) + geom_density(adjust = input$range)
  })
}

shinyApp(ui, server)
