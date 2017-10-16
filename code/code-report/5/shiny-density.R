library(shiny)

census <- read.csv("http://new.censusatschool.org.nz/wp-content/uploads/2016/08/CaS2009_subset.csv",
                   header = TRUE)

# build shiny app               
ui <- basicPage(
  plotOutput("plot"),
  sliderInput("range", "Bandwidth", min = 0.1,
              max = 1, value = 0.1)
)

server <- function(input, output) {
  output$plot <- renderPlot({
    plot(density(census$height, bw = input$range, na.rm = TRUE),
         main = "Density plot of heights",
         xlab = "Heights (cm)")
  })
}

shinyApp(ui, server)
