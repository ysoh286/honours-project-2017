#simple shiny app:

library(shiny)

ui <- basicPage(
  plotOutput("plot"),
  sliderInput("range", "Span:", min = 0.25, max = 1, value = 0.75)
)

server <- function(input, output) {
  output$plot <- renderPlot({
    plot(cars$speed, cars$dist, main = "Speed to stopping distance", xlab = "Speed", ylab = "Distance",
         las = 1)
    loModel <- loess(dist ~ speed, data = cars, span = input$range)
    lines(cars$speed, predict(loModel))
  })

}

shinyApp(ui, server)
