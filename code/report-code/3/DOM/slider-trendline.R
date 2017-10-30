# DOM: smooth-trendline
# When you move the slider/click on the text, the trend line will change!
# Requires: DOM, lattice, gridSVG, XML

library(DOM)
library(lattice)
library(gridSVG)

#draw plot in memory:
pdf(NULL)
lattice::xyplot(Petal.Length ~ Petal.Width, data = iris, pch = 19,
                type = c("p", "smooth"), col.line = "orange", lwd = 3)
#get svg output
svgdoc <- gridSVG::grid.export(NULL, exportCoords = "inline")
svg <- svgdoc$svg
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
trendline <- getElementById(page,
                            "plot_01.loess.lines.panel.1.1.1.1",
                            response = nodePtr())

# add text for selecting linear and loess:
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
calculate  = function(HTML) {
  #x values:
  x <- seq(min(iris$Petal.Width), max(iris$Petal.Width), length = 20)
  #get panel viewport to match co-ordinates correctly:
  panel <- "plot_01.toplevel.vp::plot_01.panel.1.1.vp.2"

  if (grepl("Linear", list(HTML)[1])) {
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
            child = htmlNode('<input name="sl" id="slider" type="range" min = "0.5" max = "1" step = "0.01"/>'),
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

# add some instructions to the page:
appendChild(page,
            htmlNode('<p id="man" style = "font-weight: bold;">
            Click on "Linear" to fit a straight line. <br>
            Click on "Loess" to fit a loess with a smoothing value of 0.5. <br>
            Move the slider to alter the smoothing value of the loess curve. </p>'))
