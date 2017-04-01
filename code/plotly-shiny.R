## Plotly + Shiny:
# resources: https://plot.ly/r/shiny-tutorial/

# checking versions
packageVersion('plotly')

# Adheres to HTMLwidgets, able to embed graphs.
# Can easily change stuff, with event_data()

# example from the tutorial:

library(shiny)
library(plotly)

ui <- fluidPage(
  plotlyOutput("plot"),
  verbatimTextOutput("event")
)


server <- function(input, output) {
  
  #renderPlotly = ggplot2 objects?
  output$plot <- renderPlotly({
    plot_ly(iris, x = ~Petal.Width, y = ~Petal.Length, type = "scatter")
  })
  
  output$event <- renderPrint({
    d <- event_data("plotly_hover")
    if (is.null(d)) {
      "Hover over a point!" 
    } else {
      d
    }

  })
}

shinyApp(ui, server)

## can you change this to a table?

ui <- fluidPage(
  plotlyOutput("plot"),
  tableOutput("event")
)

server <- function(input, output) {
  
  output$plot <- renderPlotly({
    plot_ly(iris, x = ~Petal.Width, y = ~Petal.Length, type = "scatter")
  })
  
  output$event <- renderTable({
    event_data("plotly_hover")
  })
}

shinyApp(ui, server)

## trying some of the other plotly functions - adapting example: https://plot.ly/r/shinyapp-plotly-events/

ui <- fluidPage(

  plotlyOutput("plot"),
  verbatimTextOutput("hover"),
  verbatimTextOutput("click"),
  tableOutput("brush")

)

server <- function(input, output) {
  
  output$plot <- renderPlotly({
    
    #use of a key 
    key <- row.names(iris)
    plot_ly(iris, x = ~Petal.Width, y = ~Petal.Length, key = ~key) %>%
      layout(dragmode = "select")
    
    }) 
  
  output$hover <- renderPrint({
    d <- event_data("plotly_hover")
    if (is.null(d)) "Hover events appear here...." 
    else d
  })
  
  output$click <- renderPrint({
    d <- event_data("plotly_click")
    if (is.null(d)) "Click events appear here..."
    else d
  }) 
  
  output$brush <- renderTable({
    event_data("plotly_selected")
  })
  
}

shinyApp(ui, server)


## Why doesn't brush work? FIXED.
ui <- basicPage(
  plotlyOutput("plot"),
  tableOutput("table")
)

server <- function(input, output) {
  output$plot <- renderPlotly({
    plot_ly(iris, x = ~Petal.Length, y = ~Petal.Width, type = "scatter", mode = "markers") %>%
      layout(dragmode = "select") #this is required to prevent zooming, and allow selection to be read
  })
  
  output$table <- renderTable({
    event_data("plotly_selected")
  })
}

shinyApp(ui, server)

#--------------------------------------
# Can plotly do facetting plots? 
# They call it 'subplots' - but you need to specify for each one separately:

unique(iris$Species)
p1 <-  plot_ly(iris, x = ~Petal.Width , y = ~Petal.Length, type = "scatter", mode = "markers")
p2 <-  plot_ly(iris, x = ~Petal.Width, y = ~Sepal.Length, type = "scatter", mode = "markers")
subplot(p1, p2)

library(dplyr)
groups <- group_by(iris, Species) #this breaks the dataset down into groups of rows by Species
#making each plot by group and storing it in a list...
plots <- do(groups,  p = plot_ly(., x = ~Petal.Width, y = ~Petal.Length, color = ~Species, type = "scatter", mode = "markers"))
#plot all the plots using the subplot function.
subplot(plots[['p']], nrows = 1, shareX = TRUE, shareY = TRUE) #shareX = share the x axis, shareY = share the y axis

#example provided to achieve trellis plots in R documentation:
groups <- group_by(income100, sex)
plots <- do(groups, p = plot_ly(., x = ~weekly_hrs, y = ~weekly_income, color = ~sex, type = "scatter", mode = "markers") %>% layout(dragmode = "select"))
subplot(plots[['p']], nrows =1 , shareX = TRUE, shareY = TRUE)
#Does throw a warning message - but the other way you could change the values is to change the 'name' to whatever group it is. Extracting names from tibble groups?

#doing it without dplyr:
setosa <- iris[iris$Species == "setosa", ]
virginica <- iris[iris$Species == "virginica", ]
versicolor <- iris[iris$Species == "versicolor", ]
p1 <- plot_ly(setosa, x = ~Petal.Width, y = ~Petal.Length, type = "scatter", mode = "markers", name = "setosa")
p2 <- plot_ly(virginica, x = ~Petal.Width, y = ~Petal.Length, type = "scatter", mode = "markers", name = "virginica") 
p3 <- plot_ly(versicolor, x = ~Petal.Width, y = ~Petal.Length, type = "scatter", mode = "markers", name = "versicolor")
subplot(p1, p2, p3, nrows = 1, shareX = TRUE, shareY = TRUE) 
#trying to put it in Shiny + linking table to plot?

groups <- group_by(iris, species)
plots <- do(groups, p = plot_ly(., x = ~Petal.Width, y = ~Petal.Length, color = ~Species, type = "scatter", mode = "markers")) 

ui <- basicPage(
  plotlyOutput("plot"),
  tableOutput("table")
)

server <- function(input, output) {
  
  groups <- group_by(iris, Species)
  plots <- do(groups, p = plot_ly(., x = ~Petal.Width, y = ~Petal.Length, color = ~Species, type = "scatter", mode = "markers") 
                          %>% layout(dragmode = "select")) 
  
  output$plot <- renderPlotly({
    subplot(plots[['p']], nrows = 1, shareX = TRUE, shareY = TRUE)
  })
  
  output$table <- renderTable({
    event_data("plotly_selected")
  })
}

shinyApp(ui, server) 

#---- what if I try doing it individually?

#the funny thing with this, is it's always selecting on the middle - you can't select anywhere else, but it reports everything.
# Another example of facetting using ggplotly:

p <- ggplot(iris, aes(x = Petal.Width, y = Petal.Length, color = Species)) + geom_point() + facet_grid(.~Species)
ggplotly() %>% layout(dragmode = "select")

ui <- basicPage(
  plotlyOutput("plot"),
  tableOutput("table")
)

server <- function(input, output) {
 
  output$plot <- renderPlotly({
  p <- ggplot(iris, aes(x = Petal.Width, y = Petal.Length, color = Species)) + geom_point() + facet_grid(.~Species)
  ggplotly() %>% layout(dragmode = "select")
  })
  
  output$table <- renderTable({
    event_data("plotly_selected")
  })
  
}

shinyApp(ui, server)

#works for ggplotly. Same thing applies - selection box doesn't appear where you've actually selected, but table reports correct values.
#curve number in this case changes according to whichever graph you've selected on.

#--------------------------------------
#TESTING PLOTLY_SELECTED  and what it reports? Does it change every time you've got a different graph? Extensible?
#A linked brushing example to produce the different kinds of plots on the same page...?

#using the income data (cause it's got alot more to play with...)

ui <- basicPage(
  plotlyOutput("bar"),
  plotlyOutput("scatter"),
  plotlyOutput("line"),
  plotlyOutput("heatmap"),
  plotlyOutput("histogram"), 
  plotlyOutput("boxplot"),
  plotlyOutput("boxplot"),
  plotlyOutput("dotplot"),
  tableOutput("table1"),
  verbatimTextOutput("textbar"),
  verbatimTextOutput("textscatter"),
  verbatimTextOutput("texthistogram")
)

server <- function(input, output) {
  
  output$bar <- renderPlotly({
    #a bar plot?
    plot_ly(x = c("Apples", "Oranges"), y = c(20, 30), type = "bar", source = "barplot") %>% layout(dragmode = "select")
  }) 
  
  output$scatter <- renderPlotly({
    #a scatterplot?
    plot_ly(income, x= ~weekly_hrs, y = ~weekly_income, color = ~sex, type = "scatter", mode = "markers", source = "scatter") %>% layout(dragmode = "select")
  })
  
  output$line <- renderPlotly({
    #a line plot?
    plot_ly( x = sort(runif(1:100)), y = sort(runif(1:100)),  type = "scatter", mode = "lines", source = "line") %>% layout(dragmode = "select")
  })
  
  output$heatmap <- renderPlotly({
    plot_ly(z = volcano, type = "heatmap", source = "heatmap") %>% layout(dragmode = "select")
  })
  
  output$histogram <- renderPlotly({
    plot_ly(income, x = ~weekly_hrs, type = "histogram", source = "histogram") %>% layout(dragmode = "select")
  })
  
  output$boxplot <- renderPlotly({
    plot_ly(income, y = ~weekly_hrs, type = "box", source = "box") %>% layout(dragmode = "select")
  })
  
  output$table1 <- renderTable({
    event_data("plotly_selected", source = "scatter")
  })

  output$textbar <- renderPrint({
    event_data("plotly_hover", source = "barplot")
  })
  
  output$textscatter <- renderPrint({
    event_data("plotly_hover", source = "heatmap")
  })
  
  output$texthistogram <- renderPrint({
    event_data("plotly_hover", source = "histogram")
  })
  
}

shinyApp(ui, server)

#so, barplots, lineplots, don't return anything under 'plotly_selected' for a table. 
#However, you can use it to drive something else (e.g. another plot?)
# plotly_hover and plotly_click work with these graphs to give single points, but when it comes to a selection, nothing is given (meaning, no mechanism for aggregating data, except for on scatter points).


# A linked brushing example (replicating a crosstalk example):


#--------------------------------------

#WHAT-IF CHALLENGE:
#Adding a trendline + changes to trendlines:

income <- read.csv('~/Desktop/datasets/nzincome.csv', header = TRUE)

plot_ly(income, x=~weekly_hrs, y = ~weekly_income) %>%
  add_lines(~weekly_hrs, y = ~weekly_income)

# Could you do the same with crosstalk + HTMLwidgets?





#Looking at Shan-I's example, it only works...
# this only works when you're using the CRAN ersion of plotly. 
#the dev version of plotly crashes with ggplot2 and throws an error.
#As of date, I've downgraded back down to the CRAN version of plotly.

