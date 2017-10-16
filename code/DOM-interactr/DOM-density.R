## DOM - density change
library(DOM)
library(interactr)

#draw to plot:
col <- ifelse(iris$Species == "setosa", "red", ifelse(iris$Species == "virginica", "blue", "green"))
par(mfrow = c(1, 2))
plot(iris$Sepal.Width, iris$Sepal.Length, xlab = "Sepal Width", ylab = "Sepal Length",
     col = col, pch = 16)
# split densities between species:
f1 <- iris$Sepal.Length[which(iris$Species == "virginica")]
f2 <- iris$Sepal.Length[which(iris$Species == "setosa")]
f3 <- iris$Sepal.Length[which(iris$Species == "versicolor")]
f1d <- density(f1)
f2d <- density(f2)
f3d <- density(f3)
plot(1, type="n", ylim = c(0, 3), xlim = c(4, 8), xlab = "Sepal Length",
      ylab = "Density",
     main = "Densities for each species based on sepal length")
lines(f1d$x, f2d$y, col = "Blue")
lines(f2d$x, f2d$y, col = "Red")
lines(f3d$x, f3d$y, col = "Green")
allPlots <- recordPlot()
listElements(allPlots)
draw(allPlots, new.page = TRUE)

# find where the line lies:
l1 <- "graphics-plot-2-lines-1"
l2 <- "graphics-plot-2-lines-2"
l3 <- "graphics-plot-2-lines-3"
p1 <- findPanel(l1)

ff <- list(f1, f2, f3)

# add a new polygon:
densityShift <- function(index) {

  index <- as.numeric(unlist(strsplit(index, ",")))
  pt <- list()
  if (length(index) > 2) {
    selected <- iris[index, ]
    f1 <- selected$Sepal.Length[which(selected$Species == "virginica")]
    f2 <- selected$Sepal.Length[which(selected$Species == "setosa")]
    f3 <- selected$Sepal.Length[which(selected$Species == "versicolor")]
    ff <- list(f1, f2, f3)

    points <- lapply(ff, function(x) {
      if (length(x) < 2) {
        pt <- ""
        return(pt)
      } else {
        dd <- density(x)
        x <- dd$x
        y <- dd$y

        #add ends:
        x <- c(x[1], x, x[length(x)])
        y <- c(0, y, 0)
        #convert coordinates:
        pt <- convertXY(x, y, p1)
        return(pt)
      }
    })
    # update points:
    setPoints("graphics-plot-2-lines-1", type = "coords", value = points[[1]])
    setPoints("graphics-plot-2-lines-2", type = "coords", value = points[[2]])
    setPoints("graphics-plot-2-lines-3", type = "coords", value = points[[3]])
  }

}

#link callback functions together to pass index values to function
boxIndex = boxCallback(densityShift)
addSelectionBox(plotNum = 1, el = "graphics-plot-1-points-1", f = "boxIndex")
