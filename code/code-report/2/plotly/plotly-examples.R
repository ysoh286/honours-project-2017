# standalone plotly examples:
library(plotly)
library(crosstalk)

# 1st example:
plotly::plot_ly(data = iris, x = ~Sepal.Width,
                y = ~Sepal.Length, color = ~Species,
                type = "scatter", mode = "markers")

# 2nd example:
#transform our data into a shared object
shared_iris <- SharedData$new(iris)
#generate plots
p1 <- plot_ly(shared_iris, x = ~Petal.Length,
              y = ~Petal.Width, color = ~Species, type = "scatter")
p2 <-  plot_ly(shared_iris, x = ~Sepal.Length,
               y = ~Sepal.Width, color = ~Species, type="scatter")
#layout the plots on the page, along with the data table
p <- subplot(p1, p2)
bscols(widths = 12,
       p,
       datatable(shared_iris))

# 3rd example:
shared_income <- SharedData$new(income)
bscols(
  widths = 6,
  list(filter_checkbox("sex", "Gender", shared_income, ~sex, inline  = TRUE),
       filter_slider("weekly_hrs", "Weekly Hours", shared_income, ~weekly_hrs),
       filter_select("ethnicity", "Ethnicity", shared_income, ~ethnicity)),
  plot_ly(shared_income, x = ~weekly_hrs, y = ~weekly_income, color = ~sex, type = "scatter", mode = "markers")
)

# 4th example: scatterplot matrix:
mtcars$cyl <- as.factor(mtcars$cyl)
shared_cars <- SharedData$new(mtcars[1:5])
pl <- GGally::ggpairs(shared_cars, aes(color = cyl))
ggplotly(pl)
