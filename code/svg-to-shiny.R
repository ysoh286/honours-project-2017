## TRENDLINE CHALLENGE: Part II

## Objectives:
# Use Shiny, gridSVG + JS to change/add/remove the trendline withOUT redrawing the entire plot.
# Bypass Shiny's reactive programming and 'magic' updating.

# Steps:
#  - attempt to render an SVG through Shiny
#  - pass data from Shiny/R to the browser (and back if required)
#  - translate native co-ordinates from model fits in R into SVG pixels to be rendered
#  - change, add, remove accordingly

# Dependencies/packages used: shiny, XML, gridSVG, grid, lattice, iNZightPlots

#------------------------------------------------------------------------------------

library(XML)
# update gridSVG!!
install.packages("gridSVG", repos="http://R-Forge.R-project.org")
#note that this only works on Windows/Linux. It does not work on mac!
library(gridSVG)
library(grid)
library(shiny)


# --------------------------- RENDERING AN SVG WITH SHINY -------------------------
#a static iNZightPlot rendered as an SVG.
library(iNZightPlots)

pdf(NULL)
#drawing the plot:
iNZightPlot(1:10)
#output to svg:
svgOutput <- gridSVG::grid.export(NULL)$svg
svg <- paste(capture.output(svgOutput), collapse = "\n")
dev.off()

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

# Adapted timely-portfolio's example: changes the plot every time:
# https://github.com/timelyportfolio/shiny-grid-svg-v2

shinyApp(
  ui <- fluidPage(
    mainPanel(
      #render the svg:
      htmlOutput(outputId="svgOutput"),
      selectInput("trendline", label = "Select curve", choices = c("linear", "quadratic"), selected = "linear")
    )
  ),
  
  server <- function(input, output, session) {
    
    output$svgOutput <- renderText({
      #develop the iNZightPlot:
      pdf(NULL)
      iNZightPlots::iNZightPlot(Sepal.Length, Sepal.Width, data = iris, colby = Species, pch = 19, trend = input$trendline)
      #output to svg:
      svgdoc <- gridSVG::grid.export(name = NULL)$svg
      svgOutput <- capture.output(svgdoc)
      return(svgOutput)
      dev.off()
    })
  }
)

# This literally attaches an SVG to the html page using Shiny. Avoids using renderPlot()...
# But you still face the same problem of having to redraw the entire plot. (Does the same thing, except with svg).
# This works fine with iNZightPlots, but complains errors whenever I try to change to a lattice plot.
# Warnings: grobToDev.default: "We shouldn't be here?" <--- comes from gridSVG. 
#Not sure what the actual problem is...


#------------ ATTEMPTING to break SVG plot into different pieces for control ----------
#what if I can break it up?
#What if I could render simple grid plot, and just change the trendline of it?


# simple base plot using the iris data:
library(lattice)
#add a trendline:
xyplot(Petal.Length ~ Petal.Width, col = c("red", "blue", "green"), pch = 19, type = c("p", "smooth"), col.line = "orange", lwd = 3)
grid::grid.ls() #returns : plot_01.loess.lines.panel.1.1
svgdoc <- grid.export(name = NULL, "none", "none")$svg
svg <- capture.output(svgdoc)

trendLine <- getNodeSet(svgOutput, "//svg:g[@id='plot_01.loess.lines.panel.1.1.1']", c(svg="http://www.w3.org/2000/svg"))[[1]]
#I can't break up the svg as they're all nested in viewport <g> elements.
# becomes too hard to do. Plus it's not efficient as you still have to regenerate the entire svg output every time 
#(which is the equivalent of redrawing the entire plot each time.)
# need to find another way! :(

# ------- IDEA: LEVERAGE JS talkback to Shiny -------------------

# using a baseplot instead:
#load gridGraphics:
install.packages('gridGraphics')

#interestingly, you can't use a pdf(NULL) - grid.echo() suggests there's no graphics to replay?
plot(iris$Petal.Width, iris$Petal.Length, pch = 19)
#add a trendline:
abline(lm(iris$Petal.Length ~ iris$Petal.Width))
#transform basegraphics to grid graphics:
gridGraphics::grid.echo()
grid::grid.ls() #the trendline is graphics-plot-1-abline-ab-1

svgdoc <- gridSVG::grid.export(NULL)$svg
svg <- capture.output(svgdoc)

#note that you need to do this on an externalPtr() object
trendline <- XML::getNodeSet(svgdoc, "//svg:g[@id='graphics-plot-1-abline-ab-1.1']", c(svg="http://www.w3.org/2000/svg"))[[1]]

#------- trial 1: Simple changing of the color of the trendline -----------------------
# This demonstrates that you can change the style of the trendline easily.

library(shiny)

  #draw plot:
  pdf(NULL)
  lattice::xyplot(Petal.Length ~ Petal.Width, data = iris, col = c("red", "blue", "green"), pch = 19, type = c("p", "smooth"), col.line = "orange", lwd = 3)
  #get svg output
   svgdoc <- gridSVG::grid.export(NULL)$svg
   svgOutput <- capture.output(svgdoc)
   dev.off()

shinyApp(
  ui <- fluidPage(
    mainPanel(
      #render the svg:
      HTML(svgOutput),
      selectInput("color", 
                  label = "Select color", 
                  choices = c("red", "blue"), 
                  selected = "red"),
      selectInput("trendline", 
                  label = "Select trendline", 
                  choices = c("smooth", "linear"), 
                  selected = "smooth"),
      
      #attempting to send data from server to client: requires a use of a handler function.
      tags$script('
                  Shiny.addCustomMessageHandler("myCallbackHandler", 
                  function(color) {
                  document.getElementById("plot_01.loess.lines.panel.1.1.1.1").style.stroke = color;
                  });'),
      tags$script('
            Shiny.addCustomMessageHandler("testmessage",
            function(trendLine) {
            console.log(document.getElementById("plot_01.loess.lines.panel.1.1.1.1"))
            });')
      
      )
    ),
  
  server <- function(input, output, session) {
      
    #to send data to handler function: use of an observer - sending a JS object:
    observe({
      if (input$color == "red") {
        color = "red"
        session$sendCustomMessage(type = "myCallbackHandler", color)
      } else {
        color = "blue"
       session$sendCustomMessage(type = "myCallbackHandler", color) 
      }
    })
    
    
    
  }
)

## there was the idea of using gridSVG to generate the svg whenever the trendline attributes change,
#however, there is always a warning/error on grobToDev.default: "We shouldn't be here!" whenever I try to write 
# it in the server function.
#Either way: it's not recommended since you still have to reproduce the entire output.
## If there was a way to just produce a single SVG object...? (might be too much of a stretch - needs context/co-ordinates)


# Attempting to identify co-ordinates for each model (fitted values + x-values):
#generating a set of points for each model:
#try a loess:
plot(iris$Petal.Width, iris$Petal.Length)
lo <- loess(Petal.Length~Petal.Width,data = iris)
y <- predict(lo, x)
lines(x, y, type = "l", col = "green")
#co-rodinates x, y align

#For a linear model:
abline(lm(Petal.Length~Petal.Width, data = iris))
linear <- lm(Petal.Length~Petal.Width, data = iris)
#generate list of x values:
x <- seq(min(iris$Petal.Width), max(iris$Petal.Width), length = 100)

plot(iris$Petal.Width, iris$Petal.Length)
abline(lm(Petal.Length~Petal.Width, data = iris), col = "blue")#this requires intercept + slope
y <- linear$coefficients[1] + linear$coefficients[2]*x #formula for a linear model
lines(x, y, type = 'l', col = "red")
#co-ordinates x,y align with linear model.

# Translate into svg co-ordinates:
#According to gridSVG: we could do it two ways - either through browser(via JS), or via R. 
#Both methods require exporting the co-ordinates JS file.

#refer back to lattice plot instead:
#draw plot:
lattice::xyplot(Petal.Length ~ Petal.Width, data = iris, pch = 19, type = c("p", "smooth"), col.line = "orange", lwd = 3)
#get svg output + mappings + coords + JS functions
all <- gridSVG::grid.export(NULL, exportCoords = "inline", exportMappings = "inline", exportJS = "inline")
mappings <- all$mappings
coords <- all$coords
#trying:
gridSVG::gridSVGCoords(coords)


#conversion to SVG pixels?:
svg_x <- viewportConvertX("plot_01.toplevel.vp.1", x, "native")
svg_y <- viewportConvertY("plot_01.toplevel.vp.1", y, "native")

pt <-  paste(svg_x, svg_y, sep = ",", collapse = " ")

#trendline ID:
new <- XML::newXMLNode("polyline",
                  parent = "plot_01.toplevel.vp.1",
                  attrs = list(
                    points = pt, 
                    stroke = "green",
                    fill = "green",
                    "fill-opacity" = "1"
                  )) 
#somehow this crashes RStudio TT_TT and won't run. 
#Instead, I'm going to replace the points via JS.


##-------------- trial 2: attempting to change trendline  ----------------------

#draw plot:
pdf(NULL)
cols <- c("red", "green", "blue")
lattice::xyplot(Petal.Length ~ Petal.Width, data = iris, col = cols[iris$Species], pch = 19, type = c("p", "smooth"), col.line = "orange", lwd = 3)
#get svg output
all <- gridSVG::grid.export(NULL, exportCoords = "inline", exportMappings = "inline", exportJS = "inline")
mappings <- all$mappings
coords <- all$coords
dev.off()
svgOutput <- capture.output(all$svg)
#get panel viewport to match co-ordinates correctly:
panel <- "plot_01.toplevel.vp::plot_01.panel.1.1.vp.2"

#store co-ordinates and load functions:
gridSVG::gridSVGCoords(coords)

shinyApp(
  ui <- fluidPage(
    titlePanel("Change a trendline without redrawing the entire plot:"),
    sidebarLayout(
      sidebarPanel(
        selectInput("color", 
                    label = "Select color", 
                    choices = c("red", "blue"), 
                    selected = "red"),
        selectInput("trendline", 
                    label = "Select trendline", 
                    choices = c("Loess" = "loess", "Linear" = "linear", "GLM" = "glm"), 
                    selected = "loess"),
        
        conditionalPanel(
           condition = "input.trendline == 'glm'",
          selectInput(
            "family", 
            label = "Distribution",
            choices = c("Gaussian" = "gaussian", "Binomial" = "binomial", "Poisson" = "poisson", "Gamma" = "gamma"),
            selected = "gaussian")
          ),
        
        conditionalPanel(
          condition = "input.trendline == 'loess'",
          sliderInput(
            "span",
            label = "Degree of smoothing",
            min = 0.25, max = 1, value = 1, step = 0.01)
          )
        ),
      
      mainPanel(
        #render the svg:
        HTML(svgOutput)
          )
        ),
    
      #attempting to send data from server to client: requires a use of a handler function.
      tags$script('
                  Shiny.addCustomMessageHandler("colorCall", 
                  function(color) {
                  var trendline = document.getElementById("plot_01.loess.lines.panel.1.1.1.1");
                  trendline.style.stroke = color;
                  });'),
      tags$script('
            Shiny.addCustomMessageHandler("trendlineCall",
            function(pt) {
              var trendline = document.getElementById("plot_01.loess.lines.panel.1.1.1.1");
              trendline.setAttribute("points", pt);
            });')
      
    ),
  
  server <- function(input, output, session) {
    
    #to send data to handler function: use of an observer - sending a JS object:
    observe({
      if (input$color == "red") {
        color = "red"
        session$sendCustomMessage(type = "colorCall", color)
      } else {
        color = "blue"
        session$sendCustomMessage(type = "colorCall", color) 
      }
    })
    
    
    observe({
      x <- seq(min(iris$Petal.Width), max(iris$Petal.Width), length = 20)
      
      if (input$trendline == "linear") {
        #linear model:
        linear <- lm(Petal.Length~Petal.Width, data = iris)
        y <- linear$coefficients[1] + linear$coefficients[2]*x 
      } else if (input$trendline == "loess") {
        #loess model:
        lo <- loess(Petal.Length~Petal.Width,data = iris, span = input$span)
        y <- predict(lo, x)
      } else {
        #general linear model:
        glm <- glm(Petal.Length~Petal.Width, data = iris, family = "gaussian")
        y <- glm$coefficients[1] + glm$coefficients[2]*x 
      }
      
      #conversion to SVG pixel co-ordinates:
      svg_x <- viewportConvertX(panel, x, "native")
      svg_y <- viewportConvertY(panel, y, "native")
      
      #create 'points' string:
      pt <-  paste(svg_x, svg_y, sep = ",", collapse = " ")
      session$sendCustomMessage(type = "trendlineCall", pt)
      
    })

  }
)


## Optional: Could we do a D3 wiggle?


## -------------- An iNZightPlots version? ------------------------------
# for this to be generalized, need to organise the naming of plot objects so that it's not random.
# Currently, everytime we replot, it will change every time.
# If we do manage to implement this, probably will have to implement a naming scheme to keep plots consistent.

#draw plot:

income1000 <- income[1:1000,]

pdf(NULL)
iNZightPlots::iNZightPlot(weekly_hrs, weekly_income, colby = sex, data = income1000, trend = "linear")
#get svg output
all <- gridSVG::grid.export(NULL, exportCoords = "inline", exportMappings = "inline", exportJS = "inline")
mappings <- all$mappings
coords <- all$coords
dev.off()
svgOutput <- capture.output(all$svg)
#get panel viewport to match co-ordinates correctly:
#note: you need to change this every time you replot, since it's always different each time.
panel <- "container::VP:TOPlayout::GRID.VP.4143::VP:PLOTlayout::GRID.VP.4144::GRID.VP.4145::VP:locate.these.points.1"

#store co-ordinates and load functions:
gridSVG::gridSVGCoords(coords)

shinyApp(
  ui <- fluidPage(
    titlePanel("Change a trendline without redrawing the entire plot:"),
    sidebarLayout(
      sidebarPanel(
        selectInput("color", 
                    label = "Select color", 
                    choices = c("red", "blue"), 
                    selected = "red"),
        selectInput("trendline", 
                    label = "Select trendline", 
                    choices = c("Loess" = "loess", "Linear" = "linear", "GLM" = "glm"), 
                    selected = "loess"),
        
        conditionalPanel(
          condition = "input.trendline == 'glm'",
          selectInput(
            "family", 
            label = "Distribution",
            choices = c("Gaussian" = "gaussian", "Binomial" = "binomial", "Poisson" = "poisson", "Gamma" = "gamma"),
            selected = "gaussian")
        ),
        
        conditionalPanel(
          condition = "input.trendline == 'loess'",
          sliderInput(
            "span",
            label = "Degree of smoothing",
            min = 0.25, max = 1, value = 1, step = 0.01)
        )
      ),
      
      mainPanel(
        #render the svg:
        HTML(svgOutput)
      )
    ),
    
    #attempting to send data from server to client: requires a use of a handler function.
    tags$script('
                Shiny.addCustomMessageHandler("colorCall", 
                function(color) {
                //you need to replace this every time since it changes name every time you replot.
                var trendline = document.getElementById("GRID.lines.492.1.1");
                trendline.style.stroke = color;
                });'),
      tags$script('
                  Shiny.addCustomMessageHandler("trendlineCall",
                  function(pt) {
                //you need to replace this every time since it changes name every time you replot.
                  var trendline = document.getElementById("GRID.lines.492.1.1");
                  trendline.setAttribute("points", pt);
                  });')
      
    ),
  
  server <- function(input, output, session) {
    
    #to send data to handler function: use of an observer - sending a JS object:
    observe({
      if (input$color == "red") {
        color = "red"
        session$sendCustomMessage(type = "colorCall", color)
      } else {
        color = "blue"
        session$sendCustomMessage(type = "colorCall", color) 
      }
    })
    
    
    observe({
      x <- seq(min(income1000$weekly_hrs), max(income1000$weekly_hrs), length = 20)
      
      if (input$trendline == "linear") {
        #linear model:
        linear <- lm(weekly_income~weekly_hrs, data = income1000)
        y <- linear$coefficients[1] + linear$coefficients[2]*x 
      } else if (input$trendline == "loess") {
        #loess model:
        lo <- loess(weekly_income~weekly_hrs, data = income1000, span = input$span)
        y <- predict(lo, x)
      } else {
        #general linear model:
        glm <- glm(weekly_income~weekly_hrs, data = income1000, family = "gaussian")
        y <- glm$coefficients[1] + glm$coefficients[2]*x 
      }
      
      #conversion to SVG pixel co-ordinates:
      svg_x <- viewportConvertX(panel, x, "native")
      svg_y <- viewportConvertY(panel, y, "native")
      
      #create 'points' string:
      pt <-  paste(svg_x, svg_y, sep = ",", collapse = " ")
      session$sendCustomMessage(type = "trendlineCall", pt)
      
    })
    
  }
  )

# It works! :) loess smoothing works as the input changes.
# You could also do the co-ordinate conversion via JS (as long as you've exported the mappings from gridSVG).
# There's a question of how accurate is the plotting.
# Possible things to further investigate: Could you avoid using JS? (probably not, unless you're happy with redraws.)
