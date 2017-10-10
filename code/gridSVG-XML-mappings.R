## gridSVG + gridSVGMappings + XML:
# Resources: Simon Potter's thesis Chapter 2.6,
#             https://www.stat.auckland.ac.nz/~paul/Reports/gridSVGnames/generating-unique-names.html

library(grid)
library(gridSVG)

# simple lattice plot:
library(lattice)
xyplot(1:10~1:10)
grid.ls()

# Returns:
#plot_01.background
#plot_01.xlab
#plot_01.ylab
#plot_01.ticks.top.panel.1.1
#plot_01.ticks.left.panel.1.1
#plot_01.ticklabels.left.panel.1.1
#plot_01.ticks.bottom.panel.1.1
#plot_01.ticklabels.bottom.panel.1.1
#plot_01.ticks.right.panel.1.1
#plot_01.xyplot.points.panel.1.1
#plot_01.border.panel.1.1

svgall <- grid.export(NULL, exportCoords = "inline", exportMappings = "inline")
svg <- svgall$svg
mappings <- svgall$mappings
coords <- svgall$coords

#return coordinate system:
gridSVGCoords(coords)

# use mappings and return mappings:
gridSVGMappings(mappings)
#retrieve points:
getSVGMappings("plot_01.xyplot.points.panel.1.1", "grob")
# return css:
getSVGMappings("plot_01.xyplot.points.panel.1.1", type = "grob", result = "selector")
#return xpath:
getSVGMappings("plot_01.xyplot.points.panel.1.1", type = "grob", result = "xpath")

# retrieve a viewport:
grid.ls(viewports = TRUE)
getSVGMappings("plot_01.toplevel.vp::plot_01.panel.1.1.vp", "vp") #returns two values
# The second viewport is where xypoints lie.

#use of gridSVG's coordinate system:
#viewportConvertX()
#viewportConvertDim
#viewportConvertHeight
#viewportConvertWidth
#viewportConvertX
#viewportConvertY

# using the XML package to bind data attributes to existing svg??
library(XML)

# get all points (from Paul's DOM 0.2 example):
# use of xpaths in order to specify what you want to target
points <- getNodeSet(svg,
                     "//svg:use",
                     namespaces = c(svg = "http://www.w3.org/2000/svg"))

# retrieve ids:
ids <- xmlSApply(points, xmlGetAttr, "id")

# what if I want just the polygons?
id <- getSVGMappings("plot_01.xyplot.points.panel.1.1", "grob")
points <- getNodeSet(svg,
                    paste0("//svg:g[@id='", id,"']/child::node()"),
                    namespaces = c(svg="http://www.w3.org/2000/svg"))
ids <- xmlSApply(points, xmlGetAttr, "id")

xmlElementsByTagName(points[[1]], id)


## make sure that this works on any plot...
par(mfrow = c(1, 2))

#plot both:
plot(mtcars$mpg, mtcars$wt,
     pch = 19, xlab = "miles per gallon", col = mtcars$am,
    ylab = "car weight")
barplot(table(mtcars$cyl))
pl <- recordPlot()
gridGraphics::grid.echo()
grid.ls()

svgall <- grid.export(NULL, exportCoords = "inline", exportMappings = "inline")
svg <- svgall$svg
mappings <- svgall$mappings
coords <- svgall$coords
gridSVGCoords(coords)
gridSVGMappings(mappings)
id <- getSVGMappings("graphics-plot-1-points-1", "grob")
points <- getNodeSet(svg,
                    paste0("//svg:g[@id='", id,"']/child::node()"),
                    namespaces = c(svg="http://www.w3.org/2000/svg"))
ids <- xmlSApply(points, xmlGetAttr, "id")

# on the bar plot?
id <- getSVGMappings("graphics-plot-2-rect-1", "grob")
bars <- getNodeSet(svg,
                    paste0("//svg:g[@id='", id,"']/child::node()"),
                    namespaces = c(svg="http://www.w3.org/2000/svg"))
barbar <- xmlSApply(bars, xmlGetAttr, "id")
