library(shiny)
library(lattice)

shinyApp(
  ui <- basicPage(
  plotOutput("plot", click = "plot_click", brush = "plot_brush"),
  verbatimTextOutput("info")
),

server <- function(input, output) {
  output$plot <- renderPlot({
    x <- income$weekly_hrs
    y <- income$weekly_income
    xyplot(y~x,  main = "Lattice scatterplot of nzincome", ylab ="Weekly income", xlab = "Weekly hrs")
  })

  output$info <- renderText({
    paste0("Weekly_hrs=", input$plot_click$x, "\n Weekly_income=", input$plot_click$y)
  })

})
