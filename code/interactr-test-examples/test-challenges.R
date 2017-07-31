## TESTING package with existing and new challenges:
# serves as demos/examples:

## Installation:

devtools::install_github("ysoh286/honours-project-2017", subdir = "interactr")
#installs DOM automatically
library(interactr)

############################
## Boxplot to points ##
############################

library(lattice)
bw <- bwplot(iris$Sepal.Length, main = "boxplot")
bw.elements <- listElements(bw)
box <- "plot_01.bwplot.box.polygon.panel.1.1"
interactions <- list(hover = styleHover(attrs = list(fill = "red", fill.opacity = "1")))
draw(bw, box, interactions, new.page = TRUE)
#obtain the range of the box before we draw the scatterplot:
range <- returnRange(box)

sp <- xyplot(Sepal.Width ~ Sepal.Length, data = iris, main = "scatterplot")
listElements(sp)
points <- "plot_01.xyplot.points.panel.1.1"
draw(sp)

#highlightPoints: defined by user:
highlightPoints <- function(ptr) {
  index <- which(min(range) <= iris$Sepal.Length & iris$Sepal.Length <= max(range))
  setPoints(points, type = "points", range = index, attrs = list(fill = "red", fill.opacity = "1", class = "selected"))
}

boxClick <- list(onclick = 'highlightPoints')
addInteractions(box, boxClick)

## test on ggplot2: DOES NOT WORK!

library(ggplot2)
p <- ggplot(data = iris, aes(x = "", y = Sepal.Length)) + geom_boxplot()
p.elements <- listElements(p)
# this changes every time (need to match to list generated)
# taken from listElements() output
box <- "geom_polygon.polygon.52"
interactions <- list(hover = styleHover(attrs = list(fill = "red", fill.opacity = "1")))
draw(p, box, interactions, new.page = TRUE)
#find the range of the box: - returnRange FAILS ON THIS.
## returns an error due to convertX not returning data values under 'native'.
range <- c(5.1, 6.4)
#add scatterplot:
sp <- ggplot(data = iris, aes(x = Sepal.Width, y =Sepal.Length)) + geom_point()
sp.elements <- listElements(sp)
draw(sp)
points <- "geom_point.points.108"
highlightPoints <- function(ptr) {
  #find the index of points that lie within the range of the box
  index <- which(min(range) <= iris$Sepal.Length & iris$Sepal.Length <= max(range))
  print(index)
  setPoints(points, type = "points", range = index, attrs = list(fill = "red", fill.opacity = "1", class = "selected"))
}
boxClick <- list(onclick = "highlightPoints")
addInteractions(box, boxClick)

#switching order of draw works fine.
#BUT: you must print the plot (via listElements) before you send to browser.

## a possible solution using base:
boxplot(iris$Sepal.Length, horizontal = TRUE)
pl <- recordPlot()
listElements(pl)
box = "graphics-plot-1-polygon-1"
interactions <- list(hover = styleHover(attrs = list(fill = "red", fill.opacity = "1")))
draw(p, box, interactions, new.page = TRUE)
range <- returnRange(box)

plot(iris$Sepal.Length, iris$Sepal.Width)
sp <- recordPlot()
listElements(sp)
draw(sp)
#add interactions
points <- 'graphics-plot-1-points-1'
highlightPoints <- function(ptr) {
  #find the index of points that lie within the range of the box
  index <- which(min(range) <= iris$Sepal.Length & iris$Sepal.Length <= max(range))
  setPoints(points, type = "points", range = index, attrs = list(fill = "red", fill.opacity = "1", class = "selected"))
}
boxClick <- list(onclick = "highlightPoints")
addInteractions(box, boxClick)
# other polygons are 'hover'-highlighted - need to restrict to id.

## test on iNZightPlots:
library(iNZightPlots)
p <- iNZightPlot(Sepal.Length, data = iris)
listElements(p)
box <- "GRID.polygon.675"
interactions <- list(hover = styleHover(attrs = list(fill = "red", fill.opacity = "1")))
draw(p, box, interactions, new.page = TRUE)
## add scatter plot:
sp <- iNZightPlot(Sepal.Width, Sepal.Length, data = iris)
listElements(sp)
points <- "SCATTERPOINTS"
draw(sp)
boxClick <- list(onclick = "highlightPoints")
addInteractions(box, boxClick)
#THIS DOESN'T WORK AS IT SHOULD...
#note that only half the box has been highlighted.

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




