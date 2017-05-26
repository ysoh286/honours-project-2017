## DOM Version: Trendline Challenge PART II

## ---------------------- TRENDLINE CHALLENGE ----------------------

## Objective: Use the DOM package, JS + SVG to recreate the trendline challenge.

# Steps:
# try render an SVG
# render a slider/ inputs
# add javascript
# try send data from R to js and back?

#load:
library(DOM)
library(XML)
library(gridSVG)
library(lattice)

## render the plot - using the same lattice plot + iris dataset:
#draw plot in memory:
pdf(NULL)
lattice::xyplot(Petal.Length ~ Petal.Width, data = iris, pch = 19, type = c("p", "smooth"), col.line = "orange", lwd = 3)
#get svg output
svgdoc <- gridSVG::grid.export(NULL, exportMappings = "inline", exportJS = "inline", exportCoords = "inline")
svg <- svgdoc$svg
mappings <- svgdoc$mappings
coords <- svgdoc$coords
#load co-ordinates:
gridSVG::gridSVGCoords(coords)
dev.off()

# render using DOM:
page <- htmlPage() 

#add svg:
appendChild(page,
            child = svgNode(XML::saveXML(svg)),
            ns = TRUE,
            response = svgNode())

# get trendline;
trendline <- getElementById(page, "plot_01.loess.lines.panel.1.1.1.1", response = nodePtr())
setAttribute(page,
            trendline,
             "points",
             "0,0")

# add text for selecting linear and loess:
# try using <p> text instead of dropdowns for the moment...

appendChild(page,
            child = htmlNode('<p> Linear </p>'))

appendChild(page,
            child = htmlNode('<p><span> Loess </span></p>'))

#write R function to recalculate!

calculate  = function(...) {
  #x values:
  x <- seq(min(iris$Petal.Width), max(iris$Petal.Width), length = 20)
  #get panel viewport to match co-ordinates correctly:
  panel <- "plot_01.toplevel.vp::plot_01.panel.1.1.vp.2"

  if (grepl("Linear", list(...)[1])) {
    #linear model:
    linear <- lm(Petal.Length~Petal.Width, data = iris)
    y <- linear$coefficients[1] + linear$coefficients[2]*x
  } else {
      #loess model:
      lo <- loess(Petal.Length~Petal.Width,data = iris)
       y <- predict(lo, x)
  }

  #convert co-ordinates:
  svg_x <- viewportConvertX(panel, x, "native")
  svg_y <- viewportConvertY(panel, y, "native")

  #create 'points' string:
  pt <-  paste(svg_x, svg_y, sep = ",", collapse = " ")

  return(pt)

}

#write JS function to update point co-ordinates:
appendChild(page,
            child=javascript('sendCoords = function(pt) {
                             var svg = document.getElementsByTagName("svg")[0];
                             var trendline = document.getElementById("plot_01.loess.lines.panel.1.1.1.1");
                              trendline.setAttribute("points", pt);
                             }'))

#set attributes:
setAttribute(page,
             elt = css("p"),
             attrName = "onclick",
             attrValue = 'RDOM.Rcall("calculate", this, [ "HTML" ], sendCoords)')

setAttribute(page,
             elt = css("span"),
             attrName = "onclick",
             attrValue = 'RDOM.Rcall("calculate", this, [ "HTML" ], sendCoords)')


#Currently works: when you click on "Linear" - it changes to a linear model
# When you click on "Loess" - it changes to a loess model

#--------------------------- SLIDER --------------------------------
## What if we want to include a slider and somehow return the selected value?

page <- htmlPage()

#add svg:
appendChild(page,
            child = svgNode(XML::saveXML(svg)),
            ns = TRUE,
            response = svgNode())

#identify trendline
trendline <- getElementById(page, "plot_01.loess.lines.panel.1.1.1.1", response = nodePtr())

#add slider:
appendChild(page,
            child = htmlNode('<input name="sl" id="slider" type="range" min = "0" max = "1" step = "0.01"/>'),
            response = css())

# getProperty 'value':
# Note that: getAttribute refers to HTML, getProperty refers to JS

sliderValue <- function(ptr) {
  value <- getProperty(page, ptr, "value", async = TRUE, callback = calcSmooth) 
}

calcSmooth <- function(value) {
  
  #x values:
  x <- seq(min(iris$Petal.Width), max(iris$Petal.Width), length = 20)
  #get panel viewport to match co-ordinates correctly:
  panel <- "plot_01.toplevel.vp::plot_01.panel.1.1.vp.2"
  
    #loess model only:
    lo <- loess(Petal.Length~Petal.Width, data = iris, span = as.numeric(value))
    y <- predict(lo, x)
  
  #convert co-ordinates:
  svg_x <- viewportConvertX(panel, x, "native")
  svg_y <- viewportConvertY(panel, y, "native")
  
  #create 'points' string:
  pt <-  paste(svg_x, svg_y, sep = ",", collapse = " ")
  
  # update points:
  setAttribute(page,
               trendline,
               "points",
               pt,
               async = TRUE)
}

#you can change the attrName = "onchange" if you want the change to be seen after the 
# user has released the slider.
setAttribute(page,
             elt = css("input"),
             attrName = "oninput",
             attrValue = 'RDOM.Rcall("sliderValue", this, [ "ptr" ], null)')


 #----------------------------------------------------
# You could start adding dropdowns... maybe a future thing to experiment with.
# render a dropdown menu:
appendChild(page,
            child = htmlNode('<div id = "dropdown"> </div>'))
appendChild(page,
            child = htmlNode('<select name="trendType">
                             </select>'),
            parent = css('div'),
            response = htmlNode())
appendChild(page,
            child = htmlNode('<option value = "linear"> Linear </option>'),
            parent = css('select'))
appendChild(page,
            child = htmlNode('<option value = "loess" selected> Loess </option>'),
            parent = css('select'),
            response = css())

#------------------ TRIALS.... --------------------------

#You can change it manually by running the following:

#Calculate co-ordinates based upon different models:

calculate  = function(trend) {
  #x values:
  x <- seq(min(iris$Petal.Width), max(iris$Petal.Width), length = 20)
  #get panel viewport to match co-ordinates correctly:
  panel <- "plot_01.toplevel.vp::plot_01.panel.1.1.vp.2"

  if (trend == "linear") {
    #linear model:
    linear <- lm(Petal.Length~Petal.Width, data = iris)
    y <- linear$coefficients[1] + linear$coefficients[2]*x
  } else {
    #loess model:
    lo <- loess(Petal.Length~Petal.Width,data = iris)
    y <- predict(lo, x)
  }

  #convert co-ordinates:
  svg_x <- viewportConvertX(panel, x, "native")
  svg_y <- viewportConvertY(panel, y, "native")

  #create 'points' string:
  pt <-  paste(svg_x, svg_y, sep = ",", collapse = " ")

  return(pt)

}

#Change color to green:
setAttribute(page, trendline, "stroke", "green")

#Change the trendline:
setAttribute(page, trendline, "points", calculate("linear"))
setAttribute(page, trendline, "points", calculate("loess"))


#an alternative way to return the value of the slider...! (but it blocks oninput)

appendChild(page,
            child = htmlNode('<p> 0.5 </p>'))

js <- ' change = function() {
  var slider = document.getElementById("slider");
  var p = document.getElementsByTagName("p")[0];
  p.innerHTML = Number(slider.value).toFixed(2);
}'

appendChild(page,
            child = javascript(js))

setAttribute(page,
             elt = css("input"),
             attrName = "oninput",
             attrValue = "change()")

---------------------------------------------------------
#Using RDOM.Rcall?
cat = function(elt,css) {
}

#set attributes:
setAttribute(page, elt = css("p"), attrName = "onclick",
             attrValue = 'RDOM.Rcall("cat", [this], [ "HTML" ],null)')

setAttribute(page, elt = css("span"), attrName = "onclick",
             attrValue = 'RDOM.Rcall("cat", [this], ["HTML"], null)')
# Still not sure how this works...?

# This doesn't work. Returns nothing.
# When you go to the console, it's like it won't return anything that's nested in a div.
# Hence try use getElementById() without divs
# It's interesting that when you nest things in divs, things don't become seen...
# TODO: NEED TO LEARN WHAT'S THE DIFF BETWEEN A NODE, ATTRIBUTE, PROPERTY!

#wouldn't this work? 'value' = slider value - but it's failing- null not an object?? no idea.
setAttribute(page,
             elt = css("input"),
             attrName = "oninput",
             attrValue = 'RDOM.Rcall("hello", this.value, [ "HTML" ], null)')

