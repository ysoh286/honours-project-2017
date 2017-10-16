## TESTING package with existing and new challenges:
# serves as demos/examples:

## Installation (as of 03/08 - should work!):

devtools::install_github("ysoh286/honours-project-2017", subdir = "interactr")
#installs DOM automatically
library(interactr)
options(viewer = NULL)

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
  setPoints(points, type = "index", value = index, attrs = list(fill = "red", fill.opacity = "1", class = "selected"))
}

boxClick <- list(onclick = 'highlightPoints')
addInteractions(box, boxClick)

## a possible solution using base:
boxplot(iris$Sepal.Length, horizontal = TRUE)
pl <- recordPlot()
listElements(pl)
box = "graphics-plot-1-polygon-1"
interactions <- list(hover = styleHover(attrs = list(fill = "red", fill.opacity = "1")))
draw(pl, box, interactions, new.page = TRUE)
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
  setPoints(points, type = "index", value = index, attrs = list(fill = "red", fill.opacity = "1", class = "selected"))
}
boxClick <- list(onclick = "highlightPoints")
addInteractions(box, boxClick)

## test on ggplot2
# Because its coordinate system differs on grid, need a different way to get data.
# (can't use returnRange())

library(ggplot2)
p <- ggplot(data = iris, aes(x = "", y = Sepal.Length)) + geom_boxplot()
p.elements <- listElements(p)
box <- findElement("geom_polygon.polygon")
interactions <- list(hover = styleHover(attrs = list(fill = "red", fill.opacity = "1", pointer.events = "all")))
draw(p, box, interactions, new.page = TRUE)

#find the range of the box:
boxData <- ggplot_build(p)$data[[1]]
#for a box plot - IQR: lower, upper
range <- c(boxData$lower, boxData$upper)

#add scatterplot:
sp <- ggplot(data = iris, aes(x = Sepal.Width, y =Sepal.Length)) + geom_point()
sp.elements <- listElements(sp)
draw(sp)
points <- findElement("geom_point.point")
highlightPoints <- function(ptr) {
  #find the index of points that lie within the range of the box
  index <- which(min(range) <= iris$Sepal.Length & iris$Sepal.Length <= max(range))
  setPoints(points, type = "index", value = index, attrs = list(fill = "red", fill.opacity = "1", class = "selected"))
}
boxClick <- list(onclick = "highlightPoints")
addInteractions(box, boxClick)

#BUT: you must print the plot (via listElements) in the R graphics device
# before you send to browser. Also need to compute the range of the box plot
# before you draw the scatterplot.

## test on iNZightPlots:
# Note: there are two ways you could solve this:
# either obtain the 'rearranged' data frame that's stored inside the plot
# OR plot.features = list(order.first = -1)
library(iNZightPlots)
p <- iNZightPlot(Sepal.Length, data = iris, plot.features = list(order.first = -1))
listElements(p)
box <- findElement("GRID.polygon")
range <- returnRange(box)
interactions <- list(hover = styleHover(attrs = list(fill = "red", fill.opacity = "1")))
draw(p, box, interactions, new.page = TRUE)
## add scatter plot:
sp <- iNZightPlot(Sepal.Width, Sepal.Length, data = iris, plot.features = list(order.first = -1))
listElements(sp)
points <- "SCATTERPOINTS"
draw(sp)
boxClick <- list(onclick = "highlightPoints")
addInteractions(box, boxClick)
# this only lights up half the box.
#This is because the box is defined as two polygons in svg (but grid only sees this as 1)

#to light up the points on the same plot:
p <- iNZightPlot(Sepal.Length, data = iris, plot.features = list(order.first = -1))
listElements(p)
box <- findElement('GRID.polygon')
points <- "DOTPOINTS"
range <- returnRange(box)
interactions <- list(hover = styleHover(attrs = list(fill = "red", fill.opacity = "1")),
					 onclick = "highlightPoints")
draw(p, box, interactions, new.page = TRUE)
# ideally, if these were plotted in the order according to the data frame,
# then these would light up correctly.
#However, iNZightPlots does reorder the entire data frame before plotting,
# which causes it to differ.

############################
## Boxplot to density ##
############################

## apply it on 2009 CensusAtSchool data (Paul's example):

#get dataset off web:
census <- read.csv("http://new.censusatschool.org.nz/wp-content/uploads/2016/08/CaS2009_subset.csv", header = TRUE)

#subset the first 500 values... since gridSVG can't handle all 15000 values on the scatter plot:
census <- census[1:500, ]

# separate girls and boys:
boys <- census[census$gender == "male", ]
girls <- census[census$gender == "female", ]

# plot box plot of boys heights:
bw <- bwplot(boys$height, main = "Boxplot of boys' heights")
bw.elements <- listElements(bw, "boys_height")
box <- "boys_height.bwplot.box.polygon.panel.1.1"
interactions <- list(hover = styleHover(attrs = list(fill = "red", fill.opacity = "0.5", pointer.events = "all")))
draw(bw, box, interactions, new.page = TRUE)
range <- returnRange(box)

# add in a scatterplot of boys heights to armspan:
sp <- xyplot(boys$armspan ~ boys$height, main = "Height vs armspan (boys)", xlab = "Height(cm)", ylab = "Armspan")
sp.elements <- listElements(sp, "sp_bheight")
points <- "sp_bheight.xyplot.points.panel.1.1"
draw(sp)

#density plot of girls height:
dplot <- densityplot(~girls$height,
                     main="Density plot of girl's heights",
                     xlab="Height(cm)")
d.elements <- listElements(dplot, "girls_height")
dlist <- list(points = "girls_height.density.points.panel.1.1",
              lines = "girls_height.density.lines.panel.1.1")
draw(dplot)

# add invisible polygon to the page:
panel <- findPanel(dlist$lines)
addPolygon("highlightRegion", panel, class = "highlight",
           attrs = list(fill = "red",
                        stroke = "red",
                        stroke.opacity = "1",
                        fill.opacity= "0.5"))

#define what happens when you click (back in R):
highlightRange <- function(ptr) {

  coords <- returnRange(dlist$lines)
  index <- which(min(range) <= coords$x & coords$x <= max(range))
  xval <- coords$x[index]
  yval <- coords$y[index]

  # add start and end:
  xval <- c(xval[1], xval, xval[length(xval)])
  yval <- c(-1, yval, -1)

  pt <- convertXY(xval, yval, panel)
  #set points on added polygon
  setPoints("highlightRegion", type = "coords", value = pt)

  # highlight points in scatter plot:
  index <- which(min(range) <= boys$height  & boys$height <= max(range) & !is.na(boys$armspan))
  # note that if armspans are missing, then it will return 'element is undefined',
  # hence requires !is.na(boys$armspan) to remove missing values
  setPoints(points, type = "index", value = index, attrs = list(fill = "red", fill.opacity = "0.5", class = "selected"))

}

boxClick <- list(onclick = "highlightRange")
addInteractions(box, boxClick)

# a limitation of this is for coords to be calculated correctly,
#the density plot in the R graphics device must be present.
#(The an alternative is to calculate it beforehand and store its value)
# Also, not everything is immediate. Things happen in order!

############################
## Control a trendline ##
############################

# define plot
iris.plot <- xyplot(Petal.Length~Petal.Width,
                    data = iris,
                    pch = 19,
                    type = c("p", "smooth"),
                    col.line = "orange", lwd = 3)
#list elements and print plot
listElements(iris.plot)
#send plot to browser
draw(iris.plot, new.page = TRUE)
#add slider to page:
addSlider("slider", min = 0.5, max = 1, step = 0.05)
#user defines this function:
controlTrendline <- function(value) {
  showValue(value) #to show value of the slider
  value <- as.numeric(value)

  #user defines what to do next: (here, recalculates x and y)
  x <- seq(min(iris$Petal.Width), max(iris$Petal.Width), length = 20)
  lo <- loess(Petal.Length~Petal.Width, data = iris, span = value)
  y <- predict(lo, x)

  #convert coordinates and set points:
  panel <- findPanel('plot_01.xyplot.points.panel.1.1')
  pt <- convertXY(x, y, panel)
  setPoints("plot_01.loess.lines.panel.1.1", type = "coords", value = pt)
}
#pass function through to get values from slider
sliderValue <- sliderCallback(controlTrendline)
int <- list(oninput = "sliderValue")
addInteractions("slider", int)

############################
## Control bandwidths ##
############################
plot(density(census$height, bw = 0.1, na.rm = TRUE),
     main = "Density plot of heights",
     xlab = "Heights (cm)")
d.plot <- recordPlot()
listElements(d.plot)
dline <- "graphics-plot-1-lines-1"
draw(d.plot, new.page = TRUE)
#add slider to page:
addSlider("slider", min = 0.1, max = 1, step = 0.05)
#user defined function:
controlDensity <- function(value) {
  showValue(value)
  value <- as.numeric(value)

  dd <- density(census$height, bw = value, na.rm = TRUE)
  x <- dd$x
  y <- dd$y

  #convert coordinates:
  panel <- findPanel(dline)
  pt <- convertXY(x, y, panel)

  # update points:
  setPoints(dline, type = "coords", value = pt)
}
#define and attach interactions:
slideDensity <- sliderCallback(controlDensity)
int <- list(oninput = "slideDensity")
addInteractions("slider", int)

############################
## Linking: Selection Box ##
############################

#add a selection box!
# Can't write this with DOM because requires mouse events to be captured
# to append a JavaScript file.
#Because this doesn't exactly follow the same structure as other interactions
# hence, will slightly differ.

#steps:
iris.plot <- xyplot(Petal.Length~Petal.Width,
                    data = iris,
                    pch = 19,
                    type = c("p", "smooth"),
                    col.line = "green", lwd = 3)

listElements(iris.plot)
#send plot to browser
draw(iris.plot, new.page = TRUE)
#add selection box to page:
panel <- findPanel("plot_01.xyplot.points.panel.1.1")
addLine("newSmooth", panel, class = "hello", list(stroke = "red",
                                                  stroke.width = "1",
                                                  fill = "none"))
#create new smoother:
createSmooth  = function(index) {
  #this returns the indices of the points selected
  # could use DOM 0.5 and pass JSON through to avoid this step...
  index <- as.numeric(unlist(strsplit(index, ",")))
  #filter selected points:
  if (length(index) > 20) {
    selected <- iris[index, ]
    x <- seq(min(selected$Petal.Width), max(selected$Petal.Width), length = 20)
    lo <<- loess(Petal.Length ~Petal.Width, data = selected, span = 1)
    y <- predict(lo, x)
    #convert co-ordinates:
    pt <- convertXY(x, y, panel)
  } else {
    pt <- ""
  }
  setPoints("newSmooth", type = "coords", value = pt)
}

#link callback functions together to pass index values to function
boxIndex = boxCallback(createSmooth)
addSelectionBox(plotNum = 1, el = "plot_01.xyplot.points.panel.1.1", f = "boxIndex")
# you can call "lo" back to find out the loess equation for the graph.

############################
## Linking: Selection Box
## Multiple plots
############################
## NOT STABLE - CRASHES R!!
#steps:
iris.plot <- xyplot(Petal.Length~Petal.Width,
                    data = iris,
                    pch = 19)

listElements(iris.plot)
#send plot to browser
draw(iris.plot, new.page = TRUE)
passIndex = boxCallback(highlight)
addSelectionBox(plotNum = 1, el = "plot_01.xyplot.points.panel.1.1", "passIndex")

## add another scatter plot:
iris.plot2 <- xyplot(Sepal.Length ~ Sepal.Width,
                     data = iris,
                     pch = 19)
listElements(iris.plot2, "plot_02")
draw(iris.plot2)

#create highlights:
highlight  = function(index) {
  #this returns the indices of the points selected
  index <- as.numeric(unlist(strsplit(index, ",")))
  points <- "plot_02.xyplot.points.panel.1.1"
  setPoints(points, type = "index", value = index, attrs = list(fill = "red",
                                                                fill.opacity = "1",
                                                                class = "selected"))
}

#returns element is undefined?? Requires more thought.

## TO DOS:
## Weight example?
