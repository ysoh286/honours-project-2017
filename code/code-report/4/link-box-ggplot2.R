# linking box plot with ggplot2:
#Requires: ggplot2, interactr

library(ggplot2)
library(interactr)
p <- ggplot(data = iris, aes(x = "", y = Sepal.Length)) + geom_boxplot()
p.elements <- listElements(p)
box <- findElement("geom_polygon.polygon")
interactions <- list(hover = styleHover(attrs = list(fill = "red",
                                                     fill.opacity = "1",
                                                     pointer.events = "all")))
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
  setPoints(points, type = "index", value = index,
            attrs = list(fill = "red", fill.opacity = "1", class = "selected"))
}
boxClick <- list(onclick = "highlightPoints")
addInteractions(box, boxClick)

# instructions:
appendChild(pageNo,
            htmlNode('<p id = "man" style = "font-weight: bold">
                      Click on the box in the box plot to highlight
                      the points in the scatter plot </p>'))
