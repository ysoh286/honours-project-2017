library(ggvis)

# 1st example:
ggvis(iris, ~Sepal.Width, ~Sepal.Length, fill = ~Species) %>%
    layer_points() %>%
    add_tooltip(function(iris) paste("Sepal Width: ", iris$Sepal.Width, "\n",
                                     "Sepal Length: ", iris$Sepal.Length))

# 2nd example:
ggvis(mtcars, ~wt, ~mpg, fill = ~gear) %>%
  layer_points() %>%
  layer_smooths(stroke:= "red", span = input_slider(0.5, 1,
                                                    value = 1,
                                                    label = "Span of loess smoother" )) %>%
  layer_model_predictions(stroke:="blue",
                          model = input_select(c("Loess" = "loess",
                                                 "Linear Model" = "lm",
                                                 "RLM" = "MASS::rlm"),
                                               label = "Select a model"))
