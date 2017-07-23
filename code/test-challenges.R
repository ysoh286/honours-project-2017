## TESTING package with existing and new challenges:
# serves as demos/examples:

############################
## Boxplot challenge ##
############################

#setwd('~/Dropbox/honours-project-2017/interactr')
#devtools::load_all()
library(interactr)
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
blist <- list(box = "geom_polygon.polygon.500") 
# this changes every time (need to match to list generated)
# taken from listElements() output
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

## TODO: try with base

############################
## Trendlines ##
############################
