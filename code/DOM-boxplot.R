## box plot challenge with DOM: 
# - draw boxplot and scatterplot
# - define and add interactions

library(grid)
library(gridSVG)
library(DOM)
library(lattice)

#draw box plot:
bw <- bwplot(1:10, main = "boxplot")

#draw scatter plot:
sp <- xyplot(1:10~1:10, main = "scatterplot")

#convert to SVG:
convertToSVG <- function(pl, name = NULL) {
  
  ##draw svg:
  pdf(NULL)
  print(pl)
  ## name should be required if there is more than 1 plot (validation code needed)
  svgall <- grid.export(NULL, exportMappings = "inline", exportCoords = "inline", prefix = name)
  svg <- svgall$svg
  mappings <- svgall$mappings
  coords <- svgall$coords
  gridSVG::gridSVGCoords(coords)
  dev.off()
  
  return(svg)
  
}


#generate svg for box plot:
bwSVG <- convertToSVG(bw, name = "bw")

#generate svg for scatter plot:
spSVG <- convertToSVG(sp, name = "sp")

# write javascript:
fill <- "fill = function() {
    this.setAttribute('fill', 'red');
    this.setAttribute('fill-opacity', '1');
}"

unfill <- "unfill = function() {
  this.setAttribute('fill', 'transparent');
}" 

highlightPoints <- 'highlightPoints = function() {
  
  //Get the min and max of x:
  var range = this.getAttribute("points").split(" ");
  var min = range[0].split(",")[0];
  var max = range[2].split(",")[0];

  var Grob = "spplot_01.xyplot.points.panel.1.1.1";
  var count = document.getElementById(Grob).childElementCount;

  for (i = 1; i <= count; i ++) {
    var dot = document.getElementById(Grob + "." + i);
    var x = dot.x.baseVal.value;
    //run condition where if x is between the min and max of the box:
    if (min <= x && x <= max) {
      dot.setAttribute("fill", "red");
      dot.setAttribute("fill-opacity", "1");
    } else {
      dot.setAttribute("fill", "none");
      dot.setAttribute("fill-opacity", "0");
    }
  }

}'

## javascript for event listeners:
js <- "var box = document.getElementById('bwplot_01.bwplot.box.polygon.panel.1.1.1.1');
       box.addEventListener('mouseover', fill, false);
       box.addEventListener('mouseout', unfill, false);
       box.addEventListener('click', highlightPoints, false);"

#send boxplot and scatterplot to browser:

page <- htmlPage()

appendChild(page,
            child = svgNode(XML::saveXML(bwSVG)))

appendChild(page,
            child = svgNode(XML::saveXML(spSVG)))

## add javascript functions:
appendChild(page,
            child = javascript(fill))

appendChild(page,
            child = javascript(unfill))

appendChild(page,
            child = javascript(highlightPoints))

appendChild(page,
            child = javascript(js))

## note that: this is inaccurate (should light up points 4-8)
## there is a need for data attributes to be attached to svg elements.
## Too much javascript written. Need a way to customise accordingly.

#----------------------------- VERSION 1.1 -------------------------
## A different way which does not use 'this':
## append javascript functions to box:

# rewrite js functions:
fill <- "fill = function(id) {
  var plotObj = document.getElementById(id);
  plotObj.setAttribute('fill', 'red');
  plotObj.setAttribute('fill-opacity', '1');
}"

unfill <-"unfill = function(id) {
  var plotObj = document.getElementById(id);
  plotObj.setAttribute('fill', 'transparent');
}"


highlightPoints <- 'highlightPoints = function(obj, plObj) {
  
var plotObj = document.getElementById(obj);
//Get the min and max of x:
var range = plotObj.getAttribute("points").split(" ");
var min = range[0].split(",")[0];
var max = range[2].split(",")[0];

var count = document.getElementById(plObj).childElementCount;

for (i = 1; i <= count; i ++) {
var dot = document.getElementById(plObj + "." + i);
var x = dot.x.baseVal.value;
//run condition where if x is between the min and max of the box:
if (min <= x && x <= max) {
dot.setAttribute("fill", "red");
dot.setAttribute("fill-opacity", "1");
} else {
dot.setAttribute("fill", "none");
dot.setAttribute("fill-opacity", "0");
}
}

}'


page <- htmlPage()

appendChild(page,
            child = svgNode(XML::saveXML(bwSVG)))

appendChild(page,
            child = svgNode(XML::saveXML(spSVG)))

## append javascript:

appendChild(page,
            child = javascript(paste(fill, unfill, highlightPoints, sep = "\n")))

box <- 'bwplot_01.bwplot.box.polygon.panel.1.1.1.1'
sp <- 'spplot_01.xyplot.points.panel.1.1.1'

boxObj <- getElementById(page,
                         'bwplot_01.bwplot.box.polygon.panel.1.1.1.1',
                         response = nodePtr())

## append events using DOM:
fillFunc <- paste0("fill('", box, "')")
unfillFunc <- paste0("unfill('", box, "')")
highlightFunc <- paste0("highlightPoints('", box, "','", sp, "')")

setAttribute(page,
             boxObj,
             "onmouseover",
             fillFunc) 

setAttribute(page,
             boxObj,
             "onmouseout",
             unfillFunc)

setAttribute(page,
             boxObj,
             "onclick",
             highlightFunc)

#----------------- VERSION 2: REWRITE without using javascript, use DOM only. ------------

library(DOM)
library(grid)
library(gridSVG)
library(lattice)

#set up page:
page <- htmlPage()

appendChild(page,
            child = svgNode(XML::saveXML(bwSVG)))

appendChild(page,
            child = svgNode(XML::saveXML(spSVG)))

plotObj <- getElementById(page,
                          "plot_01.bwplot.box.polygon.panel.1.1.1",
                          response = nodePtr())
#fill function:
fill <- function(ptr) {
  
  setAttribute(page,
               ptr,
               "fill",
               "red",
               async = TRUE)
  
  setAttribute(page,
               ptr,
               "fill-opacity",
               "1",
               async = TRUE)
}

#unfill function:
unfill <- function(ptr) {

  setAttribute(page,
               ptr,
               "fill",
               "transparent",
               async = TRUE)
    
}

#attach data attribute?
#highlightPoints function:
highlightPoints <- function(ptr) {
  
  #subset data between these values:
  data <- as.data.frame(x = 1:10)
  colnames(data) <- "x"
  
  #upper and lower quartiles:
  uq <- quantile(data$x, 0.75)
  lq <- quantile(data$x, 0.25)
  
  subset <- which(lq <= data$x & data$x <= uq)
  
  #TODO:: filter points:
  
}


setAttribute(page,
             plotObj,
             "onmouseover",
             "RDOM.Rcall('fill', this, ['ptr'], NULL)")

setAttribute(page,
             plotObj,
             "onmouseout",
             "RDOM.Rcall('unfill', this, ['ptr'], NULL)")

setAttribute(page,
             plotObj,
             "onclick",
             "RDOM.Rcall('highlightPoints, this, ['ptr'], NULL)")