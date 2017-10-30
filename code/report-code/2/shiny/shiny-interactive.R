# shiny example showing on-plot interactivity:

library(shiny)
library(ggplot2)

ui <- basicPage(
  plotOutput("plot", brush = "plot_brush", hover = "plot_hover"),
  verbatimTextOutput("text"),
  tableOutput("income_table")
)

server <- function(input, output) {
  output$plot <- renderPlot({
    ggplot(income, aes(x = weekly_hrs, y= weekly_income, color = sex)) + geom_point() + facet_grid(.~ethnicity)
  })

  output$text <- renderText({
    paste0("You've hovering on: ", round(as.numeric(input$plot_hover$x), 2), ', ' , round(as.numeric(input$plot_hover$y), 2))
  })

  output$income_table <- renderTable({
    brushedPoints(income, input$plot_brush, xvar = "weekly_hrs", yvar = "weekly_income")
  })
}

shinyApp(ui, server)
