##ARRAY OF PLOTS CHALLENGE:

#Challenge: Using existing tools, try to get a linked scatterplot matrix with zoom-in capabilities.

#----------------------------------- some ideas/setup.... ------------------------------------------

## A simple scatterplot matrix:
pairs(iris[, 1:4])

##ggplot2 version: - so it's suggested to use GGally package and ggpairs function instead...
install.packages('GGally')
library(GGally)
ggpairs(iris[, 1:4])

## could Plotly render this?
library(plotly)
ggpairs(iris, aes(color = Species)) %>% ggplotly()
  
## interesting? It's got some crosstalk going on already? Not sure (there appears to be a crosstalkKey). 
# The problem with this is the whole matrix is considered as 1 single plot.
# you can't zoom into a single plot (well you could, since you can technically pan/zoom in).
# Was looking into the HTML source code, and it's almost like gibberish (well, it only has the data in JSON format,
# and links to the javascript libraries + crosstalk libraries, but where on earth are the plots? O_O)
# Can't appear to save it as an HTML page despite it using crosstalk.

# ------------------------------------------------------------------------------------------------

# Making it from scratch?
# Use crosstalk to link everything together?
#use crosstalk:
library(crosstalk)
library(plotly)
shared_iris <- SharedData$new(iris)
#SepalLength:
sl1 <- plot_ly(data = shared_iris, x = ~Sepal.Length, y = ~Sepal.Width,color = ~Species, type = "scatter", mode = "markers")
sl2 <- plot_ly(data = shared_iris, x = ~Sepal.Length, y = ~Petal.Length,color = ~Species, type = "scatter", mode = "markers")
sl3 <- plot_ly(data = shared_iris, x = ~Sepal.Length, y = ~Petal.Width, color = ~Species, type = "scatter", mode = "markers")
sl4 <- plot_ly(data = shared_iris, x = ~Sepal.Length, y = ~Sepal.Length,color = ~Species, type = "scatter", mode = "markers")

#Sepal.Width:
sw1 <- plot_ly(data = shared_iris, x = ~Sepal.Width, y = ~Sepal.Width, color = ~Species, type = "scatter", mode = "markers")
sw2 <- plot_ly(data = shared_iris, x = ~Sepal.Width, y = ~Petal.Length, color = ~Species, type = "scatter", mode = "markers")
sw3 <- plot_ly(data = shared_iris, x = ~Sepal.Width, y = ~Petal.Width, color = ~Species, type = "scatter", mode = "markers")
sw4 <- plot_ly(data = shared_iris, x = ~Sepal.Width, y = ~Sepal.Length, color = ~Species, type = "scatter", mode = "markers")

#Petal.Length:
pl1 <- plot_ly(data = shared_iris, x = ~Petal.Length, y = ~Sepal.Width, color = ~Species, type = "scatter", mode = "markers")
pl2 <- plot_ly(data = shared_iris, x = ~Petal.Length, y = ~Petal.Length, color = ~Species, type = "scatter", mode = "markers")
pl3 <- plot_ly(data = shared_iris, x = ~Petal.Length, y = ~Petal.Width, color = ~Species, type = "scatter", mode = "markers")
pl4 <- plot_ly(data = shared_iris, x = ~Petal.Length, y = ~Sepal.Length, color = ~Species, type = "scatter", mode = "markers")

#Petal.Width:
pw1 <- plot_ly(data = shared_iris, x = ~Petal.Width, y = ~Sepal.Width, color = ~Species, type = "scatter", mode = "markers")
pw2 <- plot_ly(data = shared_iris, x = ~Petal.Width, y = ~Petal.Length, color = ~Species, type = "scatter", mode = "markers")
pw3 <- plot_ly(data = shared_iris, x = ~Petal.Width, y = ~Petal.Width, color = ~Species, type = "scatter", mode = "markers")
pw4 <- plot_ly(data = shared_iris, x = ~Petal.Width, y = ~Sepal.Length, color = ~Species, type = "scatter", mode = "markers")

#leveraging the Shiny UI functions to put it altogether?
library(shiny)
shinyApp(
 ui <-  fluidPage(
  fluidRow(
    column(3, sw1), column(3, sw2), column(3, sw3), column(3, sw4)
  ),
  fluidRow(
  column(3, pl1), column(3, pl2), column(3, pl3), column(3, pl4)
  ),
  fluidRow(
    column(3, pw1), column(3, pw2), column(3, pw3), column(3, pw4)
  ),
  fluidRow(
    column(3,sl1), column(3, sl2), column(3, sl3), column(3, sl4)
  )
  ),
 
 server <- function(input, output) {}
)

##Technically this should work? and link things together? but it's only linking to 1 single plot. 
#Dunno if it's crosstalk being broken, or plotly? 
# (brushing issue... - okay, so Plotly's linking via crosstalk only works on subplot() objects.)
subplot(sw1, sw2, sw3, sw4, pl1, pl2, pl3, pl4, pw1, pw2, pw3, pw4, sl1, sl2, sl3, sl4, nrows = 4)

## trying plotly + Shiny + crosstalk:
shinyApp(
  ui <- fluidPage(
    fluidRow(
      plotlyOutput('plotMatrix')
    ),
    fluidRow(
      column(3,actionButton("show", "Zoom into plot5")),
      selectInput('view', "View plot", c("0" = "0", "1" = "1", "2" = "2"), "0")
    )
  ),
  
  server <- function(input, output, session) {
    
    #defined shared object/dataset:
    shared_iris <- SharedData$new(iris)
    
    observeEvent(input$show, {
      showModal(modalDialog(
        output$sl1 <- renderPlotly({
          plot_ly(data = shared_iris, x = ~Sepal.Length, y = ~Sepal.Width, color = ~Species, type = "scatter", mode = "markers")
        })
      ))
    })
    
    observeEvent(input$view, {
      
      if (input$view == "1") {
        showModal(modalDialog(
          output$sw1 <- renderPlotly({
            plot_ly(data = shared_iris, x = ~Sepal.Width, y = ~Sepal.Width, color = ~Species, type = "scatter", mode = "markers")
          })
        )
       )
      } else if (input$view == "2") {
        showModal(modalDialog(
          output$sw2 <- renderPlotly({
            plot_ly(data = shared_iris, x = ~Sepal.Width, y = ~Petal.Length, color = ~Species, type = "scatter", mode = "markers")
          })
        ) 
        )
      } else {
        return()
      }
      
    })
    
    output$plotMatrix <- renderPlotly({
      #SepalLength:
      sl1 <- plot_ly(data = shared_iris, x = ~Sepal.Length, y = ~Sepal.Width,color = ~Species, type = "scatter", mode = "markers")
      sl2 <- plot_ly(data = shared_iris, x = ~Sepal.Length, y = ~Petal.Length,color = ~Species, type = "scatter", mode = "markers", showlegend = FALSE)
      sl3 <- plot_ly(data = shared_iris, x = ~Sepal.Length, y = ~Petal.Width, color = ~Species, type = "scatter", mode = "markers", showlegend = FALSE)
      sl4 <- plot_ly(data = shared_iris, x = ~Sepal.Length, y = ~Sepal.Length,color = ~Species, type = "scatter", mode = "markers", showlegend = FALSE)
      
      #Sepal.Width:
      sw1 <- plot_ly(data = shared_iris, x = ~Sepal.Width, y = ~Sepal.Width, color = ~Species, type = "scatter", mode = "markers", showlegend = FALSE)
      sw2 <- plot_ly(data = shared_iris, x = ~Sepal.Width, y = ~Petal.Length, color = ~Species, type = "scatter", mode = "markers", showlegend = FALSE)
      sw3 <- plot_ly(data = shared_iris, x = ~Sepal.Width, y = ~Petal.Width, color = ~Species, type = "scatter", mode = "markers", showlegend = FALSE)
      sw4 <- plot_ly(data = shared_iris, x = ~Sepal.Width, y = ~Sepal.Length, color = ~Species, type = "scatter", mode = "markers", showlegend = FALSE)
      
      #Petal.Length:
      pl1 <- plot_ly(data = shared_iris, x = ~Petal.Length, y = ~Sepal.Width, color = ~Species, type = "scatter", mode = "markers", showlegend = FALSE)
      pl2 <- plot_ly(data = shared_iris, x = ~Petal.Length, y = ~Petal.Length, color = ~Species, type = "scatter", mode = "markers", showlegend = FALSE)
      pl3 <- plot_ly(data = shared_iris, x = ~Petal.Length, y = ~Petal.Width, color = ~Species, type = "scatter", mode = "markers", showlegend = FALSE)
      pl4 <- plot_ly(data = shared_iris, x = ~Petal.Length, y = ~Sepal.Length, color = ~Species, type = "scatter", mode = "markers", showlegend = FALSE)
      
      #Petal.Width:
      pw1 <- plot_ly(data = shared_iris, x = ~Petal.Width, y = ~Sepal.Width, color = ~Species, type = "scatter", mode = "markers", showlegend = FALSE)
      pw2 <- plot_ly(data = shared_iris, x = ~Petal.Width, y = ~Petal.Length, color = ~Species, type = "scatter", mode = "markers", showlegend = FALSE)
      pw3 <- plot_ly(data = shared_iris, x = ~Petal.Width, y = ~Petal.Width, color = ~Species, type = "scatter", mode = "markers", showlegend = FALSE)
      pw4 <- plot_ly(data = shared_iris, x = ~Petal.Width, y = ~Sepal.Length, color = ~Species, type = "scatter", mode = "markers", showlegend = FALSE)
      
      #put it altogether as a single plotly object
      subplot(sw1, sw2, sw3, sw4, pl1, pl2, pl3, pl4, pw1, pw2, pw3, pw4, sl1, sl2, sl3, sl4, nrows = 4)
      
    })
  }
)

## ------------------------------------------------------------------------------------------------------------------
#trying using crosstalk + Shiny + d3scatter instead...:
shinyApp(
  ui <- fluidPage(
    fluidRow(
      column(3, d3scatterOutput('sw1')), 
      column(3, d3scatterOutput('sw2')), 
      column(3, d3scatterOutput('sw3')), 
      column(3, d3scatterOutput('sw4'))
    ),
    fluidRow(
      column(3, d3scatterOutput('sl1')), 
      column(3, d3scatterOutput('sl2')), 
      column(3, d3scatterOutput('sl3')), 
      column(3, d3scatterOutput('sl4'))
    ),
    fluidRow(
      ##would modals work?
      column(3,actionButton("show", "Zoom into plot5")),
      column(3, actionButton("link", "Link to Wikipedia"))
  )
  ),
  
  server <- function(input, output, session) {
    shared_iris <- SharedData$new(iris)
    
    observeEvent(input$show, {
      showModal(modalDialog(
        output$sl1 <- renderD3scatter({
          d3scatter(data = shared_iris, x = ~Sepal.Length, y = ~Sepal.Width, color = ~Species)
        })
      ))
    })
    
    observeEvent(input$link, {
      showModal(urlModal('https://en.wikipedia.org/wiki/Iris_flower_data_set', title = "About the iris dataset")
      )
    })
    
    output$sl1 <- renderD3scatter({
      d3scatter(data = shared_iris, x = ~Sepal.Length, y = ~Sepal.Width, color = ~Species)
    })
    
    output$sl2 <- renderD3scatter({
      d3scatter(data = shared_iris, x = ~Sepal.Length, y = ~Petal.Length, color = ~Species)
    })
    
    output$sl3 <- renderD3scatter({
      d3scatter(data = shared_iris, x = ~Sepal.Length, y = ~Petal.Width, color = ~Species)
    })
    
    output$sl4 <- renderD3scatter({
      d3scatter(data = shared_iris, x = ~Sepal.Length, y = ~Sepal.Length, color = ~Species)
    })
    
    output$sw1 <- renderD3scatter({
      d3scatter(data = shared_iris, x = ~Sepal.Width, y = ~Sepal.Width, color = ~Species)
    })
    
    output$sw2 <- renderD3scatter({
      d3scatter(data = shared_iris, x = ~Sepal.Width, y = ~Petal.Length, color = ~Species)
    })
    
    output$sw3 <- renderD3scatter({
      d3scatter(data = shared_iris, x = ~Sepal.Width, y = ~Petal.Width, color = ~Species)
    })
    
    output$sw4 <- renderD3scatter({
      d3scatter(data = shared_iris, x = ~Sepal.Width, y = ~Sepal.Length, color = ~Species)
    })
    
  }
  
)

## In this case, I've only done about half the matrix, but it works - you can write up a modal button, and it will show and link...
# Ideally what we'd like to have is if you could click on the entire plot and remove the use of buttons, 
#but that capability using Shiny isn't available.
## What if you want to put it into a new browser window...? 
# Probably not possible unless you manage to link that page back to the R session too.


## doing it with d3scatter instead:
#SepalLength:
sl1 <- d3scatter(data = shared_iris, x = ~Sepal.Length, y = ~Sepal.Width, color = ~Species, width = "100%")
sl2 <- d3scatter(data = shared_iris, x = ~Sepal.Length, y = ~Petal.Length, color = ~Species, width = "100%")
sl3 <- d3scatter(data = shared_iris, x = ~Sepal.Length, y = ~Petal.Width, color = ~Species,  width = "100%")
sl4 <- d3scatter(data = shared_iris, x = ~Sepal.Length, y = ~Sepal.Length, color = ~Species,  width = "100%")

#Sepal.Width:
sw1 <- d3scatter(data = shared_iris, x = ~Sepal.Width, y = ~Sepal.Width, color = ~Species,  width = "100%")
sw2 <- d3scatter(data = shared_iris, x = ~Sepal.Width, y = ~Petal.Length, color = ~Species,  width = "100%")
sw3 <- d3scatter(data = shared_iris, x = ~Sepal.Width, y = ~Petal.Width, color = ~Species,  width = "100%")
sw4 <- d3scatter(data = shared_iris, x = ~Sepal.Width, y = ~Sepal.Length, color = ~Species,  width = "100%")

#Petal.Length:
pl1 <- d3scatter(data = shared_iris, x = ~Petal.Length, y = ~Sepal.Width, color = ~Species,  width = "100%")
pl2 <- d3scatter(data = shared_iris, x = ~Petal.Length, y = ~Petal.Length, color = ~Species,  width = "100%")
pl3 <- d3scatter(data = shared_iris, x = ~Petal.Length, y = ~Petal.Width, color = ~Species,  width = "100%")
pl4 <- d3scatter(data = shared_iris, x = ~Petal.Length, y = ~Sepal.Length, color = ~Species,  width = "100%")

#Petal.Width:
pw1 <- d3scatter(data = shared_iris, x = ~Petal.Width, y = ~Sepal.Width, color = ~Species,  width = "100%")
pw2 <- d3scatter(data = shared_iris, x = ~Petal.Width, y = ~Petal.Length, color = ~Species,  width = "100%")
pw3 <- d3scatter(data = shared_iris, x = ~Petal.Width, y = ~Petal.Width, color = ~Species,  width = "100%")
pw4 <- d3scatter(data = shared_iris, x = ~Petal.Width, y = ~Sepal.Length, color = ~Species,  width = "100%")

## doing it with just crosstalk to produce HTML page, no link to zoom plot?:
bscols(widths = c(3, 3, 3, 3),
       sl1,
       sl2,
       sl3,
       sl4,
       sw1,
       sw2,
       sw3,
       sw4,
       pl1,
       pl2,
       pl3,
       pl4,
       pw1,
       pw2,
       pw3,
       pw4
)

## ------------------------------------------------------------------------------------------------------------------
## ggplotly? Just putting the scatterplot with a d3scatter plot together. 
bscols( widths = NA,
  sl1,
  GGally::ggpairs(shared_iris, aes(color = Species)) %>% ggplotly()
)

##Co-ordinating linked views with Shiny alone, without using crosstalk??
## ------------------------------------------------------------------------------------------------------------------
## Using ggvis + shiny? code adapted from ggvis' demo on linked brushing.
library(ggvis)

shinyApp(
  ui <- fluidPage(
    fluidRow(
      column(3, ggvisOutput('plot1')),
      column(3, ggvisOutput('plot2')),
      column(3, ggvisOutput('plot3')),
      column(3, ggvisOutput('plot4'))
    ),
    fluidRow(
      column(3, ggvisOutput('plot5')),
      column(3, ggvisOutput('plot6')),
      column(3, ggvisOutput('plot7')),
      column(3, ggvisOutput('plot8'))
    ),
    fluidRow(
      ## add a modal and see what happens?? Could I link them back to the other 4 plots?
      column(12, actionButton("show", "Show plot1")),
      column(12, ggvisOutput('plot0'))
    )
    
  ),

server <- function(input, output, session) {

   #set an id:
  iris$id <- seq_len(nrow(iris))
  
  #linked brush points
  lb <- linked_brush(keys = iris$id, "red")
  
  ## in this case: plot1 and plot2 can do brushing, but all plots are linked via a key.
  ## If brushing is done on plot1, then plot2, 3, 4 should show the points that are selected.
  ## Could use a little refining if you could clear the brushing on one plot after brushing on another.
  ## Just simplifying it to a single row (since it appears that ggvis plots don't fit/adjust in the bootstrap columns)
  ## seems like I can't just add ggvis output to a modal...
  
  observeEvent(input$show, {
    iris %>%
        ggvis(~Sepal.Length, ~Sepal.Width, key := ~id) %>%
        #then you layer on the points that are actually highlighted
       layer_points(fill := lb$fill, fill.brush := "blue") %>%
        set_options(width = 1120) %>%
        lb$input() %>%
        bind_shiny('plot0')
   })
  
  
 iris %>%
    ggvis(~Sepal.Length, ~Sepal.Width, key := ~id) %>%
    #then you layer on the points that are actually highlighted
    layer_points(fill := ~Species, fill.brush := "red") %>%
    add_tooltip(function(iris) {
      paste0("Sepal Length:", iris$Sepal.Length, "<br>", "Sepal Width:", iris$Sepal.Width)
    }, "hover") %>%
    set_options(width = 300) %>%
    lb$input() %>%
  bind_shiny('plot1')
  
  #plot2:
  iris %>%
    ggvis(~Sepal.Length, ~Sepal.Length, key := ~id) %>%
    layer_points(fill := lb$fill, fill.brush := "red") %>%
    add_tooltip(function(iris) {
      paste0("Sepal Length:", iris$Sepal.Length)
    }, "hover") %>%
    set_options(width = 300) %>%
    lb$input() %>%
    bind_shiny('plot2')
  

  
  #store whatever's selected as a reactive object for other plots to follow:
  #this can be used if you wish to do uni-directional linking. Otherwise, you could use
  #lb$input().
  selected <- lb$selected
  iris_selected <- reactive({
    iris[selected(), ]
    })
  
  #plot3: controlled by whatever's been highlighted
  #iris %>%
   # ggvis(~Sepal.Length, ~Petal.Length, key := ~id) %>%
   # layer_points() %>%
   # add_data(iris_selected) %>% ## add on an additional layer to show which are 'linked'
   # layer_points(fill := "red") %>%
  # bind_shiny('plot3')
  
  #plot4:
  #iris %>%
  # ggvis(~Sepal.Length, ~Sepal.Length, key := ~id) %>%
  #layer_points() %>%
  #  add_data(iris_selected) %>%
  # layer_points(fill := "red") %>%
  #  bind_shiny('plot4')
  
  #plot3: multidirectional
  iris %>%
    ggvis(~Sepal.Length, ~Petal.Width, key := ~id) %>%
    layer_points(fill := lb$fill, fill.brush := "green") %>%
    add_tooltip(function(iris) {
      paste0("Sepal Length:", iris$Sepal.Length, "<br>", "Petal Width:", iris$Petal.Width)
    }, "hover") %>%
    set_options(width = 300) %>%
    lb$input() %>%
    bind_shiny('plot3')
 
  
  #plot4: multidirectional
  iris %>%
    ggvis(~Sepal.Length, ~Petal.Length, key := ~id) %>%
    layer_points(fill := lb$fill, fill.brush := "red") %>%
    add_tooltip(function(iris) {
      paste0("Sepal Length:", iris$Sepal.Length, "<br>", "Petal Length:", iris$Petal.Length)
    }, "hover") %>%
    set_options(width = 300) %>%
    lb$input() %>%
    bind_shiny('plot4')
  
  #and you could probably keep going for every kind of plot and maybe write a loop for generating 
  # all these plots, somehow? 
  iris %>%
    ggvis(~Sepal.Width, ~Sepal.Width, key := ~id) %>%
    #then you layer on the points that are actually highlighted
    layer_points(fill := lb$fill, fill.brush := "red") %>%
    add_tooltip(function(iris) {
      paste0("Sepal Width:", iris$Sepal.Width)
    }, "hover") %>%
    set_options(width = 300) %>%
    lb$input() %>%
    bind_shiny('plot5')
  
  #plot2:
  iris %>%
    ggvis(~Sepal.Width, ~Sepal.Length, key := ~id) %>%
    layer_points(fill := lb$fill, fill.brush := "green") %>%
    add_tooltip(function(iris) {
      paste0("Sepal Width:", iris$Sepal.Width, "<br>", "Sepal Length:", iris$Sepal.Length)
    }, "hover") %>%
    set_options(width = 300) %>%
    lb$input() %>%
    bind_shiny('plot6')
  
  iris %>%
    ggvis(~Sepal.Width, ~Petal.Width, key := ~id) %>%
    layer_points(fill := lb$fill, fill.brush := "red") %>%
    add_tooltip(function(iris) {
      paste0("Sepal Width:", iris$Sepal.Width, "<br>", "Petal Width:", iris$Petal.Width)
    }, "hover") %>%
    set_options(width = 300) %>%
    lb$input() %>%
    bind_shiny('plot7')
  
  #plot4: multidirectional
  iris %>%
    ggvis(~Sepal.Width, ~Petal.Length, key := ~id) %>%
    layer_points(fill := lb$fill, fill.brush := "red") %>%
    add_tooltip(function(iris) {
      paste0("Sepal Width:", iris$Sepal.Width, "<br>", "Petal Length:", iris$Petal.Length)
    }, "hover") %>%
    set_options(width = 300) %>%
    lb$input() %>%
    bind_shiny('plot8')

 
  
  }
)

# I have a feeling ggvis isn't responsive in snapping to bootstrap layouts... yet 
#(or somehow overrides fitting it within the 'column widths' specified under ui.)

## ------------------------------------------------------------------------------------------------------------------

## could it work with base plots? I might come back to this if I have time...
shinyApp(
  
  ui <- fluidPage(
    fluidRow(
      plotOutput('pairs', brush = 'plot_brush')
    ),
    fluidRow(
      verbatimTextOutput('plotText')
    )
  ),
  
  server <- function(input, output, session) {
    output$pairs <- renderPlot({
      pairs(iris[ ,1:4])
    })
    
    output$plotText <- renderPrint({
      brushedPoints
    })
  }
)

#---------------------------------------------------------------------------

## Investigating more through Plotly for R: https://cpsievert.github.io/plotly_book/navigating-many-views.html
## the trelliscope package, which is built upon Shiny?

install.packages('trelliscope')
library(trelliscope)

## using the javascript version: trelliscopeJS
devtools::install_github("hafen/trelliscopejs")
library(trelliscopejs)

qplot(Sepal.Width, Sepal.Length, data = iris) + facet_wrap(~Species)
## using trelliscope?
qplot(Sepal.Width, Sepal.Length, data = iris) + facet_trelliscope(~Species, nrow = 1, ncol = 3)
 ## okay, it's pretty static cause we're using qplot.

## According to its documentation, you can use Plotly graphs, even rbokeh graphs.
# It's pretty extensive on making trellis displays - fairly complex as it runs on its own.
# Doesn't appear to have zoom-in properties (or it does, but only focuses on a single plot.) - no linking?
# Maybe in the future might investigate this in more detail (if there's a need to focus on trellis displays).



