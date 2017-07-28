## TESTING package with existing and new challenges:
# serves as demos/examples:

## Installation:

devtools::install_github("ysoh286/honours-project-2017", subdir = "interactr") 
library(interactr)

############################
## Boxplot challenge ##
############################

# TODO: FIX HIGHLIGHTPOINTS - FILTER!

# on a lattice plot:
library(lattice)
bw <- bwplot(1:10, main = "boxplot")
listElements(bw)
#map elements based upon list generated?
bwlist <- list(box = "plot_01.bwplot.box.polygon.panel.1.1",
               med = "plot_01.bwplot.dot.points.panel.1.1",
               ends = "plot_01.bwplot.cap.segments.panel.1.1")
#define interactions
interactions <- list(onmouseover = fill(bwlist$box, 'blue'),
                     onmouseout = unfill(bwlist$box))
#draw and send to browser
draw(bw, bwlist$box, interactions, new.page = TRUE)
sp <- xyplot(1:10 ~ 1:10, main = "scatterplot")
listElements(sp)
splist <- list(points = "plot_01.xyplot.points.panel.1.1")
draw(sp)
boxClick <- list(onclick = highlightPoints(bwlist$box, splist$points))
addInteractions(bwlist$box, boxClick)

## test on ggplot2:
library(ggplot2)
x <- as.data.frame(1:10)
p <- ggplot(data = x, aes(x = "", y = 1:10)) + geom_boxplot()
listElements(p)
# this changes every time (need to match to list generated)
# taken from listElements() output
blist <- list(box = "geom_polygon.polygon.500") 
interactions <- list(onmouseover = fill(blist$box, "red"),
                     onmouseout = unfill(blist$box))
draw(p, blist$box, interactions, new.page = TRUE)

#add scatterplot:
x <- as.data.frame(cbind(1:10, 1:10))
sp <- ggplot(data = x, aes(x = V1, y =V2)) + geom_point()
listElements(sp)
slist <- list(points = "geom_point.points.556")
boxClick <- list(onclick = highlightPoints(blist$box, slist$points))
draw(sp)
addInteractions(blist$box, boxClick)

## test on iNZightPlots:
library(iNZightPlots)
p <- iNZightPlot(1:10)
listElements(p)
blist <- list(box = "GRID.polygon.616")
interactions <- list(onmouseover = fill(blist$box, "red"),
                     onmouseout = unfill(blist$box))
draw(p, blist$box, interactions, new.page = TRUE)
## add scatter plot:
sp <- iNZightPlot(1:10, 1:10)
listElements(sp)
splist <- list(points = "SCATTERPOINTS")
draw(sp)
boxClick <- list(onclick = highlightPoints(blist$box, splist$points))
addInteractions(blist$box, boxClick)
#note that only half the box has been highlighted.

## a possible solution using base:
boxplot(1:10, horizontal = TRUE)
pl <- recordPlot()
listElements(pl)
bw.list <- list(box = "graphics-plot-1-polygon-2")
interactions <- list(onmouseover = fill(bw.list$box, "green"),
					 onmouseout = unfill(bw.list$box))
draw(p, bw.list$box, interactions, new.page = TRUE)

plot(1:10, 1:10)
sp <- recordPlot()
listElements(sp)
draw(sp)
#add interactions
sp.list <- list(points = "graphics-plot-1-points-1")
boxClick <- list(onclick = highlightPoints(bw.list$box, sp.list$points))
addInteractions(bw.list$box, boxClick)
## nothing appears - need to fix filter.

############################
## Trendlines ##
############################

# as of current: still needs alot of revision!
# draw the plot:
iris.plot <- xyplot(Petal.Length~Petal.Width, data = iris, pch = 19, type = c("p", "smooth"), col.line = "orange", lwd = 3)
listElements(iris.plot)

#send plot to browser
draw(iris.plot, new.page = TRUE)
#add slider:
addSlider("slider.1.1", 0.5, 1, 0.05, 
		  control.on = "plot_01.loess.lines.panel.1.1")

# user defines this function instead - but there should be some functions that make it easier
# this makes it flexible so that they can control other things, like a point, a different polygon...
controlTrendline <- function(value) {
  
  x <- seq(min(iris$Petal.Width), max(iris$Petal.Width), length = 20)
  panel <- "plot_01.toplevel.vp::plot_01.panel.1.1.vp.2"
  lo <- loess(Petal.Length~Petal.Width, data = iris, span = value)
  y <- predict(lo, x)
  
  #convert co-ordinates:
  svg_x <- gridSVG::viewportConvertX(panel, x, "native")
  svg_y <- gridSVG::viewportConvertY(panel, y, "native")
  
  #create 'points' string:
  pt <-  paste(svg_x, svg_y, sep = ",", collapse = " ")
  
  # update points:
  DOM::setAttribute(pageNo,
               plotObj,
               "points",
               pt,
               async = TRUE)
  
}

# define the control function (see above - but still not in a correct 'user' format)
# For flexibility, the user could define its own function back in R to on what can be done.
# by default, the callback function is one that simply returns the value of the slider.
# but they can define it further.
# let them define controlTrendline?? How would you generalize this?

#define interactions:
#identify that it's a slider interaction.
int <- list(oninput = "RDOM.Rcall('sliderValue', this, [ 'ptr' ], null)") 

#attach:
addInteractions("slider", int)

############################
## Selection Box ##
############################




