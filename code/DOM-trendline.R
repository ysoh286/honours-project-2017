## DOM Version: Trendline Challenge PART II

## ---------------------- TRENDLINE CHALLENGE ----------------------

## Objective: Use the DOM package, JS + SVG to recreate the trendline challenge.

packageVersion('DOM')
packageurl <- "https://github.com/pmur002/DOM/archive/v0.4.tar.gz"
install.packages(packageurl, repos = NULL, type = "source")


# Steps:
# try render an SVG
# render a slider/ inputs
# add javascript
# try send data from R to js and back?

#todo: might DRY this if I get round to it.

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

pl <- getElementsByTagName(page, 'svg', response = htmlNode())

# get trendline;
trendline <- getElementById(page, "plot_01.loess.lines.panel.1.1.1.1", response = nodePtr())

# add text for selecting linear and loess:
# try using <p> text instead of dropdowns for the moment...

appendChild(page,
            child = htmlNode('<p id="linear"> Linear </p>'))

appendChild(page,
            child = htmlNode('<p id="loess"> Loess </p>'))

js <- 'highlight = function(i) {
       var spanText = document.getElementsByTagName("p")[i]
spanText.style.color = "red";
};

normal = function(i) {
var spanText = document.getElementsByTagName("p")[i]
spanText.style.color = "blue";
}'

appendChild(page,
            child = javascript(js))
setAttribute(page,
             elt = css("#linear"), 
             attrName = "onmouseover",
             attrValue = 'highlight(0)')
setAttribute(page,
             elt = css("#linear"), 
             attrName = "onmouseout",
             attrValue = 'normal(0)')
setAttribute(page,
             elt = css("#loess"), 
             attrName = "onmouseover",
             attrValue = 'highlight(1)')
setAttribute(page, 
             elt = css("#loess"),
             attrName = "onmouseout",
             attrValue = "normal(1)")

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

  # update points:
  setAttribute(page,
               trendline,
               "points",
               pt,
               async = TRUE)

}

#...or write JS function to update point co-ordinates:
#appendChild(page,
#            child=javascript('sendCoords = function(pt) {
#                             var svg = document.getElementsByTagName("svg")[0];
#                             var trendline = document.getElementById("plot_01.loess.lines.panel.1.1.1.1");
#                              trendline.setAttribute("points", pt);
#                             }'))

#set attributes: when you click on text, it changes to that model
setAttribute(page,
             elt = css("#linear"),
             attrName = "onclick",
             attrValue = 'RDOM.Rcall("calculate", this, [ "HTML" ], null)')

setAttribute(page,
             elt = css("#loess"),
             attrName = "onclick",
             attrValue = 'RDOM.Rcall("calculate", this, [ "HTML" ], null)')


## ADD A SLIDER TO CONTROL LOESS:

#add slider:
appendChild(page,
            child = htmlNode('<input name="sl" id="slider" type="range" min = "0" max = "1" step = "0.01"/>'),
            response = css())

appendChild(page, htmlNode('<p id="para"></p>'))

# getProperty 'value':
# Note that: getAttribute refers to HTML, getProperty refers to JS

sliderValue <- function(ptr) {
  value <- getProperty(page, ptr, "value", async = TRUE, callback = calcSmooth) 
}

calcSmooth <- function(value) {
  
  newPara <- htmlNode(paste('<p id="para">', value, '</p>'))
  replaceChild(page, newPara, css("#para"), async=TRUE)
  
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


#EXTEND FURTHER: can you do a direct interaction?
# add more JS for selection box: 
# TOASK: is there a way of attaching external javascript files rather than read it in?
appendChild(page,
            child = javascript(paste(readLines("js/linked-brush-lattice.js"), collapse=  "\n")))

## append a new smoother:
# create a new element + set its attributes:
newSmooth <- createElementNS(page,
                             "http://www.w3.org/2000/svg",
                             "polyline")
#find panel:
panel <- getElementById(page,
                        "plot_01.toplevel.vp::plot_01.panel.1.1.vp.2",
                        response = nodePtr())

appendChild(page,
            newSmooth,
            parent = panel,
            response = nodePtr())


## set attributes:
setAttribute(page,
             newSmooth,
             "stroke",
             "black")

setAttribute(page,
             newSmooth,
             "stroke-width",
             "1")

setAttribute(page,
             newSmooth,
             "id",
             "newSmooth")

## write functions to recalculate and draw new smoother:
hello <- function(ptr) {
	## get indices from data-select:
	value <- getAttribute(page, 
	                      ptr, 
	                      "data-select", 
	                      async = TRUE, 
	                      callback = createSmooth) ## testing if I get these values...
  
}

#create new smoother:
createSmooth  = function(value) {
  
  values <- as.numeric(unlist(strsplit(value, ",")))
  
  #filter selected points:
  if (length(values) > 20) {
    
    selected <- iris[values, ]
    x <- seq(min(selected$Petal.Width), max(selected$Petal.Width), length = 20)
    panel <- "plot_01.toplevel.vp::plot_01.panel.1.1.vp.2"
    
    # loess:
    lo <- loess(Petal.Length ~Petal.Width, data = selected, span = 1)
    y <- predict(lo, x)
    
    #convert co-ordinates:
    svg_x <- viewportConvertX(panel, x, "native")
    svg_y <- viewportConvertY(panel, y, "native")
    
    #create 'points' string:
    pt <-  paste(svg_x, svg_y, sep = ",", collapse = " ")
    
    # change the whole thing:
    setAttribute(page,
                 newSmooth,
                 "points",
                 pt,
                 async = TRUE)

  } else {
    
    #if there aren't enough points to compute a smoother
   setAttribute(page,
                newSmooth,
                "points",
                "",
                async = TRUE) 
  }
  
}

## Test: use JSON array instead - DOM 0.5.

page <- htmlPage()
appendChild(page,
            child = svgNode(XML::saveXML(svg)),
            ns = TRUE,
            response = svgNode())

appendChild(page,
            child = javascript(paste(readLines("js/linked-brush-lattice.js"), collapse=  "\n")))

hello <- function(...) {
  
  ## get indices from data-select:
  print(unlist(list(...))) ## testing if I get these values... - printed as a list.
  
}


#------------------------- IDEAS... ---------------------------

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
            child = htmlNode('<p id="sliderValue"> 0.5 </p>'))

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