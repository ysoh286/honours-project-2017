# DOM - link a scatter plot brush to a table
# requires: interactr + DOM, lattice

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

#interactr's new function:


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

# instructions:
appendChild(pageNo,
            htmlNode('<p id = "man" style = "font-weight: bold;">
            Brush over the points to display a table! </p>'))
