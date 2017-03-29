## Highcharter example: 

devtools::install_github('jbkunst/highcharter')

library(highcharter)

# A simple plot using highcharter:
hchart(iris, "scatter", hcaes(x = Petal.Width, y = Petal.Length, group = Species))

## Note that you can add more than one widget on the page, but no interactions/link between table and plot

library(crosstalk)
library(DT)

bscols(
  hchart(iris, "scatter", hcaes(x = Petal.Width, y = Petal.Length, group = Species)),
  datatable(iris),
  device = "lg"
)

## gives an error when you try using
SharedObject (replacing iris with shared_iris <- SharedData$new(iris))