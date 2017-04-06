#ggvis - some basics:
library(ggvis) #note that a warning appears that this package is still under development.
library(dplyr)

#load some datasets:

income <- read.csv('datasets/nzincome.csv', header = TRUE)

#trying to do different plots: http://ggvis.rstudio.com/cookbook.html

#this doesn't plot anything - requires layer points:
ggvis(iris, x = ~Petal.Length, y = ~Petal.Width, fill = ~Species) %>%
  layer_points()

ggvis(income, x = ~weekly_hrs, y= ~weekly_income, fill = ~sex) %>%
  layer_points()

ggvis(income, ~weekly_hrs, ~weekly_income, fill = ~sex) %>%
  layer_points(size := 10, stroke := "blue")

#adding regression lines?
ggvis(income, ~weekly_hrs, ~weekly_income) %>%
  layer_points(size := 10, fill := "blue") %>%
  layer_smooths(stroke := "red")

ggvis(income, ~weekly_hrs, ~weekly_income) %>%
  layer_points() %>%
  layer_model_predictions(model = "lm", se = TRUE)

# different kinds of regression lines?
ggvis(income, ~weekly_hrs, ~weekly_income) %>%
  layer_points(fill := "blue") %>%
  layer_model_predictions(model = "loess", se = TRUE, stroke = "red") %>%
  layer_model_predictions(model = "lm", se = TRUE, stroke = "green") 

#grouping?
ggvis(income, ~weekly_hrs, ~weekly_income, fill = ~factor(sex)) %>%
  layer_points() %>%
  group_by(sex) %>% #layering different model trendlines based upon group
  layer_model_predictions(model = "lm")


# bar plots:
#works for 1 categorical variable
ggvis(income, ~highest_qualification, fill = ~highest_qualification) %>%
  layer_bars()

#stacked?
ggvis(income, ~highest_qualification, fill = ~sex) %>%
  layer_bars()

# two way bar plots??

# the second variable => is looking for a y continuous variable. So you can't just do it straight off...
ggvis(income, ~highest_qualification, ~weekly_hrs, fill = ~highest_qualification) %>% #most likely aggregate all the weekly hours for each group.
  layer_bars()

# line graphs:
ggvis(income, ~weekly_hrs, ~weekly_income) %>%
  layer_lines() #might not be such a good idea... - might be better to use time series data instead.

x <- runif(1:100)
y <- runif(1:100)
random <- as.data.frame(cbind(x, y))
ggvis(random, x = ~x, y = ~y) %>%
  layer_lines(fill := "blue", stroke := "red")

#adding points?
ggvis(random, x = ~x, y = ~y) %>%
  layer_points() %>%
  layer_lines()

# creating histograms:
ggvis(income, ~weekly_hrs) %>%
  layer_histograms(width = 20, boundary = 0) %>%
  add_axis("x", title = "Weekly Hours") %>%
  add_axis("y", title = "Frequency") #use width to sepcify the widths of the histograms, boundary = starting point?, or use center if you want bars to be at center.

#box plots:
#specify categorical variable first, then continuous variable.
ggvis(income, ~sex, ~weekly_hrs) %>% layer_boxplots() 

#could you do a single box plot?
ggvis(income, ~weekly_hrs) %>% layer_boxplots()
#throws an error... : Can't find prop y.update? (so...maybe it's looking for a y variable?)

#can you do single variable dot plots?
income10 <- income[1:10, ]
ggvis(income10, ~weekly_hrs) %>% layer_points() #works! :)

# what if I stored it in a vis?

vis <- ggvis(income, ~weekly_hrs, ~weekly_income)
layer_points(vis, fill := "blue")
layer_points(vis) %>% layer_model_predictions(model = "loess", se = TRUE)
layer_points(vis) 
layer_model_predictions(vis, model = "loess", se = TRUE) #replots every time - doesn't retain or plot on top.

# can you add things on? and remove things?
ggvis(income, ~weekly_hrs, ~weekly_income) 
# you can't run layer_points as a separate command. It just plots without it.
#throws an error, which means - it might be hard to add/remove things because everything seems to be relative to the plot.

#attempting to do facetting plots:
iris %>%
   group_by(Species) %>%
  ggvis(~Petal.Length, ~Petal.Width)%>%
  subvis()

#currently doesn't work - subvis() is under development.

#---------------------------------- ADDING INTERACTIVITY: --------------

# inputs are similar to those that are provided in Shiny - very basic interaction can be created without using Shiny. It's advised that if you want to achieve more, turn to Shiny.

#Bar plots - hovers:
ggvis(income, ~highest_qualification, fill = ~highest_qualification, fill.hover := "red") %>%
  layer_bars()


#Scatterplots:
ggvis(income, ~weekly_hrs, ~weekly_income) %>%
  layer_points() %>%
  layer_smooths(span = input_slider(0.5, 1, value = 1, label = "span")) 
  

#Density plot? adapted from : http://ggvis.rstudio.com/interactivity.html
ggvis(income, ~weekly_hrs) %>%
  layer_densities(
    kernel = input_select(
      c("Gaussian" = "gaussian",
        "Rectangular" =  "rectangular",
        "Cosine" = "cosine"), label = "Kernel"
    )
  )

#----- WHAT IF CHALLENGE: ADDING/CHANGING/REMOVING TRENDLINE....
#Could I do a ggvis example without using shiny for plotting trendlines? YES. [ WHAT-IF CHALLENGE ]
ggvis(income, ~weekly_hrs, ~weekly_income, fill = ~sex) %>%
  layer_points() %>%
  layer_smooths(stroke:= "red", span = input_slider(0.5, 1, value = 1, label = "Span of loess smoother" )) %>%
  layer_model_predictions(stroke:="blue", 
                          model = input_select(c("Loess" = "loess", "Linear Model" = "lm", "RLM" = "MASS::rlm"), label = "Select a model"),
                          se = input_checkbox(value = FALSE, label = "Show standard errors"))



#----- another example...
ggvis(income, ~weekly_hrs, ~weekly_income, fill = ~sex) %>%
  layer_points() %>%
  group_by(sex) %>%
  layer_smooths(stroke := "red", span = input_slider(0, 1, value = 1, label = "Span of loess smoother (red)")) %>%
  layer_model_predictions(stroke:="blue", 
                          model = input_select(c("Loess" = "loess", "Linear Model" = "lm", "RLM" = "MASS::rlm"), label = "Select a model"),
                          se = input_checkbox(value = FALSE, label = "Show standard errors"))
  
#maybe try on a different dataset?
ggvis(cocaine, ~weight, ~price) %>%
  layer_points() %>%
  layer_smooths(stroke := "red", span = input_slider(0.5, 1, value = 1, label = "Span of loess curve (red)")) %>%
  layer_model_predictions(stroke := "blue", model = input_select(c("Loess" = "loess", "Linear Model" = "lm", "RLM" = "MASS::rlm"), label = "Select a model"),
                          se = TRUE)


#----------- SIMPLE EXAMPLE using ggvis + shiny together:
#still need to do...


