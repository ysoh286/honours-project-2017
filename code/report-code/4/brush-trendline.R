# brush over points to generate a smoother
# requires: lattice, interactr

library(interactr)
library(lattice)

iris.plot <- xyplot(Petal.Length ~ Petal.Width,
                    data = iris,
                    pch = 19,
                    type = c("p", "smooth"),
                    col.line = "orange", lwd = 3)
listElements(iris.plot)
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

pointsPanel <- findPanel("plot_01.xyplot.points.panel.1.1")
addLine("newSmooth", pointsPanel, class = "hello", list(stroke = "red",
                                                        stroke.width = "1",
                                                        fill = "none"))
#create new smoother:
createSmooth  = function(index) {
  #this returns the indices of the points selected
  index <- as.numeric(unlist(strsplit(index, ",")))
  #filter selected points:
  if (length(index) > 20) {
    selected <- iris[index, ]
    x <- seq(min(selected$Petal.Width), max(selected$Petal.Width), length = 20)
    lo <- loess(Petal.Length ~Petal.Width, data = selected, span = 1)
    y <- predict(lo, x)
    #convert co-ordinates:
    pt <- convertXY(x, y, pointsPanel)
  } else {
    pt <- ""
  }
  setPoints("newSmooth", type = "coords", value = pt)
}

boxIndex = boxCallback(createSmooth)
addSelectionBox(plotNum = 1, el = "plot_01.xyplot.points.panel.1.1", f = "boxIndex")
