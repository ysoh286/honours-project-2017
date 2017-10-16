library(DOM)
library(interactr)

# load census data:
census <- read.csv("http://new.censusatschool.org.nz/wp-content/uploads/2016/08/CaS2009_subset.csv",
                   header = TRUE)

# control a density plot using **interactr**
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
