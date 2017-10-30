# link box plot, to scatter, to density
# resources: CensusAtSchool data 2009
# requires: interactr, lattice
library(lattice)
library(interactr)

census <- read.csv("http://new.censusatschool.org.nz/wp-content/uploads/2016/08/CaS2009_subset.csv", header = TRUE)

#subset the first 500 values...
census <- census[1:500, ]

# separate girls and boys:
boys <- census[census$gender == "male", ]
girls <- census[census$gender == "female", ]

# plot box plot of boys heights:
bw <- bwplot(boys$height, main = "Boxplot of boys' heights")
bw.elements <- listElements(bw, "boys_height")
box <- "boys_height.bwplot.box.polygon.panel.1.1"
interactions <- list(hover = styleHover(attrs = list(fill = "red",
                                                     fill.opacity = "0.5",
                                                     pointer.events = "all")))
draw(bw, box, interactions, new.page = TRUE)
range <- returnRange(box)

# add in a scatterplot of boys heights to armspan:
sp <- xyplot(boys$armspan ~ boys$height, main = "Height vs armspan (boys)",
              xlab = "Height(cm)", ylab = "Armspan")
sp.elements <- listElements(sp, "sp_bheight")
points <- "sp_bheight.xyplot.points.panel.1.1"
draw(sp)

#density plot of girls height:
dplot <- densityplot(~girls$height,
                     main="Density plot of girl's heights",
                     xlab="Height(cm)")
d.elements <- listElements(dplot, "girls_height")
dlist <- list(points = "girls_height.density.points.panel.1.1",
              lines = "girls_height.density.lines.panel.1.1")
draw(dplot)

# add invisible polygon to the page:
panel <- findPanel(dlist$lines)
addPolygon("highlightRegion", panel, class = "highlight",
           attrs = list(fill = "red",
                        stroke = "red",
                        stroke.opacity = "1",
                        fill.opacity= "0.5"))

#define what happens when you click (back in R):
highlightRange <- function(ptr) {

  coords <- returnRange(dlist$lines)
  index <- which(min(range) <= coords$x & coords$x <= max(range))
  xval <- coords$x[index]
  yval <- coords$y[index]

  # add start and end:
  xval <- c(xval[1], xval, xval[length(xval)])
  yval <- c(0, yval, 0)

  pt <- convertXY(xval, yval, panel)
  #set points on added polygon
  setPoints("highlightRegion", type = "coords", value = pt)

  # highlight points in scatter plot:
  index <- which(min(range) <= boys$height & boys$height <= max(range) & !is.na(boys$armspan))
  # note that if armspans are missing, then it will return 'element is undefined',
  # hence requires !is.na(boys$armspan) to remove missing values
  setPoints(points, type = "index",
            value = index,
            attrs = list(fill = "red", fill.opacity = "0.5", class = "selected"))

}

boxClick <- list(onclick = "highlightRange")
addInteractions(box, boxClick)

# add instructions:
appendChild(pageNo,
            htmlNode('<p id = "man" style = "font-weight: bold">
                      Click on the box to highlight link the interquartile
                      range with the other two plots </p>'))
