## DOM - density change
library(DOM)
library(interactr)

census <- read.csv("http://new.censusatschool.org.nz/wp-content/uploads/2016/08/CaS2009_subset.csv",
         header = TRUE)
census500 <- census[1:500, ]
census <- census500[- which(is.na(census500$armspan) | is.na(census500$height) | is.na(census500$timetravel)), ]
plot(census$armspan, census$height)
d <- density(census$timetravel)

#draw to plot:
par(mfrow = c(1, 2))
plot(census$armspan, census$height, xlab = "Armspan", ylab = "Heights", pch = 16)
plot(density(census$timetravel), xlab = "Time travelled", ylab = "Density", main = "Density of time travelled to school")
allPlots <- recordPlot()
listElements(allPlots)
draw(allPlots, new.page = TRUE)
# BECAUSE GRIDSVG TAKES TOO LONG? IT EXCEEDS THE WAIT TIME?? Not sure - TO INVESTIGATE

dline <- "graphics-plot-2-lines-1"

densityShift <- function(index) {

  index <- as.numeric(unlist(strsplit(index, ",")))
  if (length(index) > 2) {
    dd <- density(census$timetravel[index])
    x <- dd$x
    y <- dd$y

    #convert coordinates:
    panel <- findPanel(dline)
    pt <- convertXY(x, y, panel)
  } else {
    pt = ""
  }
  # update points:
  setPoints(dline, type = "coords", value = pt)

}

#link callback functions together to pass index values to function
boxIndex = boxCallback(densityShift)
addSelectionBox(plotNum = 1, el = "graphics-plot-1-points-1", f = "boxIndex")
