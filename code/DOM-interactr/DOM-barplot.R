## challenge: draw a bar plot on top of another?

library(DOM)
library(interactr)

#using the mtcars dataset:
head(mtcars)

# scatter:
## TRIAL: a different method - just plot both on the same page:
par(mfrow = c(1, 2))

#plot both:
plot(mtcars$mpg, mtcars$wt,
     pch = 19, xlab = "miles per gallon", col = mtcars$am,
    ylab = "car weight")
barplot(table(mtcars$cyl))
pl <- recordPlot()
listElements(pl)

#draw the plot to the browser:
draw(pl, new.page = TRUE)

#add invisible polygon to draw highlights
panel <- findPanel("graphics-plot-2-rect-1")
addPolygon("highlightRegion", panel, class = "highlight",
           attrs = list(fill = "black",
                        stroke = "black",
                        stroke.opacity = "1",
                        fill.opacity= "0.5"))

rectangleMe <- function(index) {

  index <- as.numeric(unlist(strsplit(index, ",")))
  selected <- mtcars[index, ]

  # the table function does not report zeroes! :(
  t1 <- sum(selected$cyl == 4)
  t2 <- sum(selected$cyl == 6)
  t3 <- sum(selected$cyl == 8)

  counts <- c(t1, t2, t3)

  pp <- grid::grid.get('graphics-plot-2-rect-1')
  x <- grid::convertX(pp$x, "native", valueOnly = TRUE)
  w <- grid::convertX(pp$width, "native", valueOnly = TRUE)

  #x values:
  gg <- numeric(6)
  gg1 <- ifelse((1:6) %% 2 == 0, w, 0)
  gg2 <- rep(x, each = 2) + gg1
  gg3 <- rep(gg2, each = 2)

  # get y values:
  ycount <- rep(counts, each = 4)
  ll <- length(ycount)
  y1 <- seq(1, ll, by = 4)
  y2 <- seq(4, ll, by = 4)

  ycount[y1] = 0
  ycount[y2] = 0

  #draw bar plot polygon:
  pt <- convertXY(gg3, ycount, panel)
  setPoints("highlightRegion", type = "coords", value = pt)

}

addSelectionBox(plotNum = 1,
                el = "graphics-plot-1-points-1",
                f = "boxIndex")
boxIndex = boxCallback(rectangleMe)


# make a general function for linking between bar plots and histograms:
linkBars <- function() {
  # the table function does not report zeroes! :(
  t1 <- sum(selected$cyl == 4)
  t2 <- sum(selected$cyl == 6)
  t3 <- sum(selected$cyl == 8)

  counts <- c(t1, t2, t3)

  pp <- grid::grid.get('graphics-plot-2-rect-1')
  x <- grid::convertX(pp$x, "native", valueOnly = TRUE)
  w <- grid::convertX(pp$width, "native", valueOnly = TRUE)

  #x values:
  gg <- numeric(6)
  gg1 <- ifelse((1:6) %% 2 == 0, w, 0)
  gg2 <- rep(x, each = 2) + gg1
  gg3 <- rep(gg2, each = 2)

  # get y values:
  ycount <- rep(counts, each = 4)
  ll <- length(ycount)
  y1 <- seq(1, ll, by = 4)
  y2 <- seq(4, ll, by = 4)

  ycount[y1] = 0
  ycount[y2] = 0
}

# The unfortunate situation with interactr is that you really have to put things
# in a certain order for everything to work smoothly.
# One of them is finding the panel using grid (which requires the device to be
# on the plot you're dealing with)
# You must have the graphics device open in R and also the web page open.
# .... it might be difficult to stretch to more than 1 plot :/
# Q: Does grid depend on which R device is open?

# ---------------------------------------------------------

#  TODO Challenge: INCOMPLETE
# replicate one of animint's examples:
tips <- reshape::tips
barplot(table(tips$smoker), main = "Smoker or non-smoker?")
lev <- levels(tips$smoker)

#store plot, list elements, send plot to browser
bplot <- recordPlot()
listElements(bplot)
draw(bplot, new.page = TRUE)

# scatter plot:
plot(tips$total_bill, tips$tip, xlab = "Total bill", ylab = "Tip", pch = 19)
splot <- recordPlot()
listElements(splot)
draw(splot)

# MAJOR LIMITATION ALERT: I can't target anything other than the first element
# in interactr (due to temporary solution of setting everything to end with '.1.1')

rect1 <- getElementById(pageNo,
                       'graphics-plot-1-rect-1.1.1',
                        response = nodePtr())

rect2 <- getElementById(pageNo,
                       'graphics-plot-1-rect-1.1.2',
                        response = nodePtr())

## could use XML package to target a few elements?
# but what about things tht are added to the page?
# Could we use DOM then? list the children of a parent

#-----------------------------------------------------
#OFF TOPIC: Facet plots?
# what is lattice's naming scheme when you have lots of plots?
head(mtcars)

xyplot(mpg ~ wt| gear,
      data = mtcars,
      main = "scatterplot by gear",
      ylab = "miles per gallon",
      xlab = "weight of car")

grid::grid.ls()
