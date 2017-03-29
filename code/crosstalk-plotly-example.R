# Note: for crosstalk to work, you need to install the development versions of these packages from github. The official and CRAN versions do not have crosstalk integrated in them. Adapted from crosstalk website. https://rstudio.github.io/crosstalk/

devtools::install_github('ropensci/plotly')
devtools::install_github('rstudio/crosstalk')
devtools::install_github('rstudio/DT')

library(crosstalk)
library(plotly)
library(DT)

# a simple plotly plot:
p <- plot_ly(iris, x = ~Petal.Length, y  = ~Petal.Width, color = ~Species, type = "scatter")
p

# using Crosstalk to link plot to table:
#Create a shared object (the data)
shared_iris <- SharedData$new(iris)

#putting everything together:
bscols(
  plot_ly(shared_iris, x = ~Petal.Length, y = ~Petal.Width, color = ~Species, type = "scatter"),
  datatable(shared_iris)
)

# Linked brushing between two plots and a table:
shared_iris <- SharedData$new(iris)
bscols(
  widths = c(6, 6, 12), #though, need to check on this
  plot_ly(shared_iris, x = ~Petal.Length, y = ~Petal.Width, color = ~Species, type = "scatter"),
  plot_ly(shared_iris, x = ~Sepal.Length, y = ~Sepal.Width, color = ~Species, type="scatter"),
  datatable(shared_iris)
)
