# Note: for crosstalk to work, you need to install the development versions of these packages from github. The official and CRAN versions do not have crosstalk integrated in them. Adapted from crosstalk website. https://rstudio.github.io/crosstalk/

devtools::install_github('ropensci/plotly')
devtools::install_github('rstudio/crosstalk')
devtools::install_github('rstudio/DT')

library(crosstalk)
library(plotly)
library(DT)

##load some data in:
income <- read.csv('datasets/nzincome.csv', header = TRUE)

# a simple plotly plot:
p <- plot_ly(iris, x = ~Petal.Length, y  = ~Petal.Width, color = ~Species, type = "scatter", mode = "markers")
p

# using Crosstalk to link plot to table:
#Create a shared object (the data)
shared_iris <- SharedData$new(iris)

#putting everything together:
bscols(
  plot_ly(shared_iris, x = ~Petal.Length, y = ~Petal.Width, color = ~Species, type = "scatter", mode = "markers"),
  datatable(shared_iris)
)

# Linked brushing between two plots and a table:
shared_iris <- SharedData$new(iris)
bscols(
  widths = c(4, NA, NA), #though, need to check on this
  plot_ly(shared_iris, x = ~Petal.Length, y = ~Petal.Width, color = ~Species, type = "scatter", mode = "markers"),
  plot_ly(shared_iris, x = ~Sepal.Length, y = ~Sepal.Width, color = ~Species, type="scatter", mode = "markers"),
  datatable(shared_iris)
)


# a filtering example:
shared_income <- SharedData$new(income)
bscols(
  widths = c(6, NA),
  list(filter_checkbox("sex", "Gender", shared_income, ~sex, inline  = TRUE),
       filter_slider("weekly_hrs", "Weekly Hours", shared_income, ~weekly_hrs),
       filter_select("ethnicity", "Ethnicity", shared_income, ~ethnicity)),
  plot_ly(shared_income, x = ~weekly_hrs, y = ~weekly_income, color = ~sex, type = "scatter", mode = "markers")
)


