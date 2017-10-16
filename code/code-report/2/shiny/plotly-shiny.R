library(shiny)
library(plotly)

ui <- fluidPage(
  fluidRow(
    column(4, plotlyOutput("sourceplot")),
    column(4, plotlyOutput("boxplot")),
    column(4, plotlyOutput("histogram"))
  ),
  tableOutput("table")
)

server <- function(input, output) {

  #scatterplot
  output$sourceplot <- renderPlotly({
    plot_ly(income, x = ~weekly_hrs, y = ~weekly_income,
            color = ~highest_qualification, type = "scatter",
            mode = "markers", source = "source") %>%
      layout(dragmode = "select")
  })

  #render a box plot based upon the selection from scatterplot
  output$boxplot <- renderPlotly({
    s = event_data('plotly_selected', source = "source")
    selected_data <- income[s[["pointNumber"]], ]
    plot_ly(selected_data, x = ~weekly_hrs, type = "box")
  })

  #render a histogram based upon selection from scatterplot
  output$histogram <- renderPlotly({
    s = event_data('plotly_selected', source = "source")
    selected_data <- income[s[["pointNumber"]], ]
    plot_ly(selected_data, x = ~weekly_hrs, type = "histogram")
  })

  #render table results
  output$table <- renderTable({
    event_data('plotly_selected', source = "source")
  })

}

shinyApp(ui, server)
