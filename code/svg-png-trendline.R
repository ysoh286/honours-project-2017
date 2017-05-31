
## TRENDLINE CHALLENGE PART 3.2: 
#Work on a larger dataset and return a smoother upon brushing.
#Use a raster image for the plot and embed in SVG

# create a lattice plot with lots of points;

library(lattice)
library(gridSVG)
library(grid)

#build a plot;
income <- read.csv('~/Desktop/datasets/nzincome.csv', header = TRUE)


## actually, let's just try in base - might be easier...
library(gridGraphics)

old.par <- par()

#create plot with axes + points;
plot.new()
#get axes;
plot(income$weekly_hrs, income$weekly_income, col = income$sex, xlab = "weekly_hrs", ylab = "weekly_income")
origSize <- par("pin")
#turn into grid plot:
grid.echo()
#remove points;
grid.remove('graphics-plot-1-points-1')
#export remaining plot as svg;
all <- gridSVG::grid.export("NULL", exportCoords = "file", exportMappings = "inline", exportJS = "inline")
dev.off()

svgplane <- all$svg
coords <- all$coords

#load co-ordinates:
gridSVG::gridSVGCoords(coords)

#create png of only points:
plot.new()
png(file = 'rplot.png', bg = "transparent", width = origSize[1], height = origSize[2], units = "in", res = 72)
par(mar = rep(0, 4))
par("pin" = origSize)
plot(income$weekly_hrs, income$weekly_income, col = income$sex, xlab = "", ylab = "", axes = FALSE)
dev.off()

#so the problem with this is I've manually had to match it up in the svg, to make it work....
# :/ a bit frisky, but generally y needs to be moved 20 pxs higher. Viewports for each just change each time.

#match up with svg - insert into specific viewport:

setwd('~/Dropbox/honours-project-2017/code')

#Now using my svg in Shiny!:
newSvg <- paste(readLines('pics/axes.svg'), collapse = '\n')

#parse svg:
svgdoc <- XML::xmlParse(file = "pics/axes.svg")

## read in coordinate system:
jsonData <- gridSVG::readCoordsJS("pics/gridcoords.js")
gridSVGCoords(jsonData)

library(shiny)

shinyApp(
  ui <- fluidPage(
    HTML(newSvg)
  ),
  
  server <- function(input, output, session) {
    
  }
)

## It renders! 


## TO DOS: add functionalities in...
## need to change panelId to fit graphics plot + make js script more generalized.
## rather than return indexes, need to return co-orinate values and translate those as data co-ordinates.



shinyApp(
  ui <- fluidPage(
    titlePanel("Change a trendline without redrawing the entire plot: SVG + PNG"),
      #render the svg:
      HTML(newSvg),
      #testing to render text:
      sliderInput(
        "span",
        label = "Degree of smoothing",
        min = 0.25, max = 1, value = 1, step = 0.01),
      
    #attempting to send data from server to client: requires a use of a handler function.
    tags$script('
                Shiny.addCustomMessageHandler("newSmooth",
                function(newPt) {
                var newSmooth = document.getElementById("newSmooth");
                if (newSmooth == null || undefined) {
                var newSmooth = document.createElementNS("http://www.w3.org/2000/svg", "polyline");
                newSmooth.setAttribute("stroke", "black");
                newSmooth.setAttribute("stroke-width", "5");
                newSmooth.setAttribute("id", "newSmooth");
                var panel = document.getElementById("graphics-plot-1-box-1.1");
                panel.appendChild(newSmooth);
                }
                newSmooth.setAttribute("points", newPt);
                });'),

    #include script for brushing:
    includeScript('js/linked-brush-png-base.js')
    
    ),
  
  server <- function(input, output, session) {
    
    #recalculate new smoother:
    observe({
      if (!is.null(input$selectedPoints)) {
        
        #translate input$selectedPoints into data co-ordinates;
        panel <-"graphics-root::graphics-inner::graphics-figure-1::graphics-plot-1::graphics-window-1-1.2"
        p1 <- viewportConvertDim(panel, input$selectedPoints[1], input$selectedPoints[2], "svg", "native")
        p2 <- viewportConvertDim(panel, input$selectedPoints[3], input$selectedPoints[4], "svg", "native")
      
        selected_income = income[(p1$w <= income$weekly_hrs  & income$weekly_hrs <= p2$w), ]

         #plot loess model instead:
        
        if (nrow(selected_income) > 10) {
          
          x <- seq(min(selected_income$weekly_hrs), max(selected_income$weekly_hrs), length = 20)
          lo <- loess(weekly_income~weekly_hrs, data = selected_income, span = input$span)
          #Note that this is NOT stable when you try setting values close to log(1)/log(2).
          #if we set a span to something lower, it starts to get funny and runs into errors.
          #Loess smoothing starts to break down and return NA/Inf/-Inf prediction values...
          y <- predict(lo, x)
          
          #conversion to SVG pixel co-ordinates:
          svg_x <- viewportConvertX(panel, x, "native")
          svg_y <- viewportConvertY(panel, y, "native")
          
          #create 'points' string:
          newPt <-  paste(svg_x, svg_y, sep = ",", collapse = " ")
          
        } else {
          newPt <- '0,0'
        }
        } else {
        newPt <- "0,0"
      }
      session$sendCustomMessage(type = "newSmooth", newPt)
      
    })
    
  }
)


## trying in DOM?
library(DOM)

page <- htmlPage()

appendChild(page,
            child = svgNode(newSvg),
            ns = TRUE,
            response = svgNode())

## The image does not seem to render if it's from an external source that's local, but it does work w
# when you link it on the web. (On windows, it doesn't render in the RStudio panel, but does in the browser.)


#Can you convert gridSVGCoords from px and back


#------------------- Lattice version in progress... --------------------------
lattice::xyplot(weekly_income~weekly_hrs, data = income)
grid::grid.ls()

## okay, remove the plot points;
grid::grid.remove("plot_01.xyplot.points.panel.1.1")

##export coordinates;
all <- grid.export('axes.svg', exportCoords = "inline", exportMappings = "inline", exportJS = "inline")

## store svg;
svgplane <- all$svg


## replot the entire thing
lattice::xyplot(weekly_income~weekly_hrs, data = income, scales=list(x=list(at = NULL), y = list(at = NULL)), 
                xlab = NULL, ylab = NULL)

##use downViewport?
grid.ls()
downViewport("plot_01.border.panel.1.1")
