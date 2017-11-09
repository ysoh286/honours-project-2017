#boxplot-scatter plot link - Figure 4.4
# requires: lattice, interactr
library(interactr)
library(lattice)

#draw plot and send to browser:
bw <- bwplot(iris$Sepal.Length, main = "Sepal Length")
box <- "plot_01.bwplot.box.polygon.panel.1.1"
interactions <- list(hover = styleHover(attrs = list(fill = "red",
                                                    fill.opacity = "1")))
draw(bw, box, interactions, new.page = TRUE)
#obtain the range of the box before we draw the scatterplot:
range <- returnRange(box)

#draw scatterplot:
sp <- xyplot(Sepal.Width ~ Sepal.Length, data = iris, main = "Sepal Width ~ Sepal Length")
points <- "plot_01.xyplot.points.panel.1.1"
draw(sp)

#highlightPoints: defined by user:
highlightPoints <- function(ptr) {
  index <- which(min(range) <= iris$Sepal.Length & iris$Sepal.Length <= max(range))
  setPoints(points, type = "index",
            value = index,
            attrs = list(fill = "red", fill.opacity = "1", class = "selected"))
}

boxClick <- list(onclick = "highlightPoints")
addInteractions(box, boxClick)
