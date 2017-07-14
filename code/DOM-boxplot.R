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
## append events:

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


## a way to pass interactions through...
## or to record interactions in a for a specific element?
# but you need to be able to define what kind of interaction you want (generalized in certain ways)

## Have a separate javascript file that has all the interactive functions defined.
## R user needs to pass through what they want to interact with.
## Use of a list?
##interactions("midbox"=list(onclick=highlightSP)) <-- Paul's suggestion


## ideally: an event (onclick, onmouseout, onmouseover, keyup, keydown...etc) should have a function attached.
## so the list would have event-to-function pairs.
## But: interactions could be attached to a single element at a time (somehow need to get around this.) 
        # but you can attach multiple events to a single element at a time.

#constructing possible functions:
interactions <-addInteractions(id, list(onclick = highlightPoints, onmouseover = fill, onmouseout = unfill))
