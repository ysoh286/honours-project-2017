library(XML)
library(gridSVG)
library(grid)

## testing things out:
devtools::load_all('iNZightRegression')
devtools::load_all('iNZightMR')
devtools::load_all('inZightPlots-interact')

#iNZightPlot(1:5, 1:5, trend = "linear")
# I might work with iNZightPlots later 
#- the problem I run into is that the grid line changes name EVERY TIME you rerun the plot.
#grid.ls()
#identifying the line:
#grid.edit("GRID.lines.217", gp = gpar(col = "red"))
#trying to get svg element using XML getNodeSet()
#trendLine <- getNodeSet(svgdoc,"//svg:g[@id='GRID.lines.217.1']", c(svg="http://www.w3.org/2000/svg"))[[1]]
#class(trendLine)


# okay, does that mean I could put an SVG plot in?
# ----- RENDERING AN SVG WITH SHINY -------------------------
#random iNZightPlot
library(iNZightPlots)
iNZightPlot(1:10)
svgOutput <- gridSVG::grid.export(NULL)$svg
svg <- paste(capture.output(svgOutput), collapse = "\n")

shinyApp(
  ui <- fluidPage(
    tags$div(id = "svg-container",
             HTML(svg)
    )),
  
  server <- function(input, output, session) {
    
  }
)

# IT RENDERS! But I can't do much with it..
#could I do this using renderUI and uiOutput/htmlOutput?

# Adapted timely-portfolio's example:

# this pretty much views the svg as one entire object.
shinyApp(
  ui <- fluidPage(
    mainPanel(
      #render the svg:
      htmlOutput(outputId="svgOutput")
      #add external javascript:
      
    )
  ),
  
  server <- function(input, output, session) {
    
    output$svgOutput <- renderText({
      #develop the iNZightPlot:
      dev.new(width=10, height = 10)
      iNZightPlot(Sepal.Length, Sepal.Width, data = iris, colby = Species, pch = 19, trend = "linear")
      #output to svg:
      svgdoc <- gridSVG::grid.export(name = NULL)$svg
      svgOutput <- capture.output(svgdoc)
      return(svgOutput)
    })
  }
)

# This literally attaches an SVG to the html page using Shiny. Avoids using renderPlot()...
#But you still face the same problem of having to redraw the entire plot.

#------------ ATTEMPTING to break SVG plot into different pieces for control ----------
#what if I can break it up? Use a simpler plot:
#What if I could render simple grid plot, and just change the trendline of it?

shinyApp(
  ui <- fluidPage(
    htmlOutput(output = "svgOutput"),
    selectInput("trendline", label = "Select curve", choices = c("Loess" = "smooth", "Linear" = "r", "Cubic" = "spline"), seleced = "Loess")
  ),
  
  server <- function(input, output, session) (
    
    #default lattice plot:
    svgOutput <-  reactive({
    lattice::xyplot(Petal.Length ~ Petal.Width, data = iris, col = c("red", "blue", "green"), pch = 19, type = c("p", "smooth"), col.line = "orange", lwd = 3)
    svgdoc <- gridSVG::grid.export(name = NULL)$svg
    svgOutput <- capture.output(svgdoc)
    return(svgOutput)
    })
    
    output$svgOutput <- renderText({
      #new:
      lattice::xyplot(iris$Petal.Length ~ iris$Petal.Width, col = c("red", "blue", "green"), pch = 19, type = c("p", input$trendline), col.line = "orange", lwd = 3)
      newsvg <- gridSVG::grid.export(name = NULL)$svg
      
      if (input$trendline == "smooth") {
        trendLine <- XML::getNodeSet(newsvg, "//svg:g[@id='plot_01.loess.lines.panel.1.1.1']", c(svg="http://www.w3.org/2000/svg"))[[1]]
        tLOut <- paste(capture.output(trendLine), collapse = "\n")
        #replace:
        tlLine <- grep("lines.panel.1.1.1", svgOutput)[1]
        svgOutput[tlLine] <- tLOut
      } else if (input$trendline == "r"){
        newsvg <- gridSVG::grid.export(name = NULL)$svg
        trendLine <- XML::getNodeSet(newsvg, "//svg:g[@id='plot_01.lmline.segments.panel.1.1.1']", c(svg = "http://www.w3.org/2000/svg"))[[1]]
        tLOut <- paste(capture.output(trendLine), collapse = "\n")
        tlLine <- grep("segments.panel.1.1.1", svgOutput)[1]
        svgOutput[tlLine] <- tLOut
      } else {
        print(NULL)
      }
      return(svgOutput)
    })
    
  )
)


# simple base plot using the iris data:
library(lattice)
#add a trendline:
xyplot(Petal.Length ~ Petal.Width, col = c("red", "blue", "green"), pch = 19, type = c("p", "smooth"), col.line = "orange", lwd = 3)
grid::grid.ls() #returns : plot_01.loess.lines.panel.1.1
svgdoc <- grid.export(name = NULL, "none", "none")$svg
svgdoc <- grid.export("test.svg")
svg <- capture.output(svgdoc)

trendLine <- getNodeSet(svgOutput, "//svg:g[@id='plot_01.loess.lines.panel.1.1.1']", c(svg="http://www.w3.org/2000/svg"))[[1]]
# I can extract stuff, but then how am I actually going to write it into the page?

#okay, for this I can extract the trendline, but then how am I going to replace it?
#I can't break up the svg as they're all nested in viewport <g> elements.
# becomes too hard to do... 
# need to find an alternative for this.
#return the parent node for the trendline?

# ------- IDEA 2: LEVERAGE GRIDSVG MAPPINGS + JAVASCRIPT?? -------------------


