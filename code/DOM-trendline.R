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

#find panel:
#get panel viewport to match co-ordinates correctly:
panel <- "plot_01.toplevel.vp::plot_01.panel.1.1.vp.2"

# rendering on DOM:
page <- htmlPage()

#add some divs:

appendChild(page,
            child = svgNode(XML::saveXML(svgdoc)),
            ns = TRUE,
            response = svgNode())

# add text for selecting linear and loess:
# try using <p> text instead of dropdowns for the moment...

appendChild(page,
            child = htmlNode('<p> Linear </p>'))

appendChild(page,
            child = htmlNode('<p><span> Loess </span></p>'))

# Is it possible to append to the same class?

cat = function(elt,css) {
}

#set attributes: 
setAttribute(page, elt = css("p"), attrName = "onclick", 
             attrValue = 'RDOM.Rcall("cat", [this], [ "HTML" ],null)')

setAttribute(page, elt = css("span"), attrName = "onclick",
             attrValue = 'RDOM.Rcall("cat", [this], ["HTML"], null)')
# Still not sure how this works...?

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
    lo <- loess(Petal.Length~Petal.Width,data = iris, span = input$span)
    y <- predict(lo, x)
  }
  
  #convert co-ordinates:
  svg_x <- viewportConvertX(panel, x, "native")
  svg_y <- viewportConvertY(panel, y, "native")
  
  return(c(svg_x, svg_y))
  
}

#append JS?
js <- 'highlight = function() {
       var trendline = document.getElementById("plot_01.loess.lines.panel.1.1.1.1");
        trendline.style.stroke = color;
};'

# This doesn't work. Returns nothing. 
# When you go to the console, it's like it won't return anything that's nested in a div.
# Hence try use getElementById() without divs

trendline <- getElementById(page, "plot_01.loess.lines.panel.1.1.1.1", response = nodePtr())
svg <- getElementsByTagName(page, "svg", response = nodePtr())

#Change color to green:
setAttribute(page, trendline, "stroke", "green")
#Change the trendline points:
setAttribute(page, trendline, "points", calculate("linear"))

appendChild(page,
            child = javascript(js))

# try setAttributes?
setAttribute(page,
             elt = css("p"),
             attrName = "onclick",
             attrValue = 'highlight()')


# there's a slight complication on trying to link dropdowns atm.
# Still figuring it out.

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
