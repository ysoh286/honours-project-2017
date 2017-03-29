#rbokeh examples:

library(rbokeh)
figure() %>%
  ly_points(Sepal.Length, Sepal.Width, data= iris, color = Species, hover = c(Sepal.Length, Sepal.Width, Species)) %>%
  tool_box_select() %>%
  tool_lasso_select()