# extra challenge: draw a bar plot on top of another?
# requires: DOM, interactr, XML, grid
# graphics: base R

library(DOM)
library(interactr)

#using the mtcars dataset:
head(mtcars)

# scatter and bar plot:
par(mfrow = c(1, 2))
plot(mtcars$mpg, mtcars$wt,
     pch = 19, xlab = "miles per gallon",
    ylab = "car weight")
barplot(table(mtcars$cyl))
pl <- recordPlot()
listElements(pl)
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
  # compute points for linking bar plot together:
  pt <- computeBars("graphics-plot-2-rect-1", panel, selected, "cyl")
  #draw bar plot that highlights selected region:
  setPoints("highlightRegion", type = "coords", value = pt)

}

addSelectionBox(plotNum = 1,
                el = "graphics-plot-1-points-1",
                f = "boxIndex")
boxIndex = boxCallback(rectangleMe)

# add instructions to the page:
appendChild(pageNo,
            htmlNode('<p id="man" style = "font-weight: bold;">
             Brush over the scatterplot and see which groups are highlighted
             on the bar plot! </p>'))

## challenge: try on a histogram:

hist(mtcars$hp)
d <- density(mtcars$drat)
plot(d)

## link a density plot, a histogram, and a bar plot together with scatters.


## hover effects (recreate animint)


## non-point selection:
