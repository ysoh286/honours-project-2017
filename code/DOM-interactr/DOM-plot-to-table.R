# DOM - link a scatter plot brush to a table:

library(DOM)
library(interactr)
library(lattice)
iris.plot <- xyplot(Petal.Length~Petal.Width,
                    data = iris,
                    pch = 19)

listElements(iris.plot)
#send plot to browser
draw(iris.plot, new.page = TRUE)

#table:
tblTag <- appendChild(pageNo,
                      child = htmlNode('<table id = "tbl1"> </table>'),
                      response = htmlNode())

returnTable <- function(index) {

  index <- as.numeric(unlist(strsplit(index, ",")))
  selected <- iris[index, ]
  ktbl <- as.character(knitr::kable(selected,
                                    "html", table.attr = "id = 'tbl1'"))
  replaceChild(pageNo,
               htmlNode(ktbl),
               css("#tbl1"),
               response = htmlNode(),
               async = TRUE)

}

boxIndex = boxCallback(returnTable)
addSelectionBox(plotNum = 1,
                el = "plot_01.xyplot.points.panel.1.1",
                f = "boxIndex")

# possible ideas: integrate table selection into interactr?
# What could happen: return an aggregated table?


#--- shortened version:
library(lattice)
iris.plot <- xyplot(Petal.Length~Petal.Width,
                    data = iris,
                    pch = 19)

listElements(iris.plot)
#send plot to browser
draw(iris.plot, new.page = TRUE)

#table:
tblTag <- appendChild(pageNo,
                      child = htmlNode('<table id = "tbl1"> </table>'),
                      response = htmlNode())

addTable(name = "tbl1", df = NULL)

returnTable <- function(index) {

  index <- as.numeric(unlist(strsplit(index, ",")))
  selected <- iris[index, ]
  updateTable("tbl1", selected)

}

boxIndex = boxCallback(returnTable)
addSelectionBox(plotNum = 1,
                el = "plot_01.xyplot.points.panel.1.1",
                f = "boxIndex")
