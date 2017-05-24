
# create a lattice plot with lots of points;

library(lattice)
library(gridSVG)
library(grid)

#build a plot;
income <- read.csv('~/Desktop/datasets/nzincome.csv', header = TRUE)


## actually, let's just try in base - might be easier...
library(gridGraphics)

old.par <- par()

plot.new()
png(file = 'rplot.png', bg = "transparent", width = origSize[1], height = origSize[2], units = "in", res = 72)
par(mar = rep(0, 4))
plot(income$weekly_hrs, income$weekly_income, col = income$sex, axes = FALSE)
dev.copy(png, 'rplot.png')
dev.off()


plot.new()
par("pin")
plot(income$weekly_hrs, income$weekly_income, col = income$sex, xlab = "weekly_hrs", ylab = "weekly_income")
origSize <- par("pin")


#get axes to export as svg;
grid.echo()

grid.ls()

#remove points;
grid.remove('graphics-plot-1-points-1')
all <- gridSVG::grid.export('axes.svg', exportCoords = "inline", exportMappings = "inline", exportJS = "inline")
svgplane <- all$svg

#so the problem with this is I've manually had to match it up in the svg, to make it work....
# :/ a bit frisky, but generally y needs to be moved 20 pxs higher. Viewports for each just change each time.

#Now using my svg in Shiny!:
newSvg <- paste(readLines('pics/axes.svg'), collapse = '\n')

library(shiny)

shinyApp(
  ui <- fluidPage(
    HTML(newSvg)
  ),
  
  server <- function(input, output, session) {
    
  }
)


## trying in DOM?
library(DOM)

page <- htmlPage()

appendChild(page,
            child = svgNode(newSvg),
            ns = TRUE,
            response = svgNode())

## the image won't show in either of DOM or Shiny.... :(
# TODO: investigate.

#Can you convert gridSVGCoords from px and back


#------------------- Lattice version in progress... --------------------------
lattice::xyplot(weekly_income~weekly_hrs, data = income)
grid::grid.ls()

## okay, remove the plot points;
grid::grid.remove("plot_01.xyplot.points.panel.1.1")

##export coordinates;
all <- grid.export('axes.svg', exportCoords = "inline", exportMappings = "inline", exportJS = "inline")

## store svg;
svgplane <- all$svg


## replot the entire thing
lattice::xyplot(weekly_income~weekly_hrs, data = income, scales=list(x=list(at = NULL), y = list(at = NULL)), 
                xlab = NULL, ylab = NULL)

##use downViewport?
grid.ls()
downViewport("plot_01.border.panel.1.1")
