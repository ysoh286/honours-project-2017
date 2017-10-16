library(ggvis)
library(shiny)

shinyApp(

  ui <- basicPage(
  #need to use ggvis output for this
  ggvisOutput("plot"),
  tableOutput("brushed_data")
  #ideally, want to show brushed data through the table
),

server <- function(input, output, session) {

  #create an id for each row of data
  iris <- cbind(iris, id = seq_len(nrow(iris)))

  #creating a linked brush object
  lb <- linked_brush(iris$id, "blue")

  #selecting brushed values:
  selected <- lb$selected

  #making the dataset reactive to the brush
  iris_selected <- reactive({
    if (!any(selected())) return(iris)
    iris[selected(), ]
  })

    iris %>%
      ggvis(~Petal.Length, ~Petal.Width, fill = ~Species) %>%
      layer_points(fill.brush := "blue") %>%
      #takes linked brushing input
      lb$input() %>%
      #adds the selected data points on top of the plot
      add_data(iris_selected) %>%
      bind_shiny("plot")

    output$brushed_data <- renderTable({
      iris_selected()
    })

})
