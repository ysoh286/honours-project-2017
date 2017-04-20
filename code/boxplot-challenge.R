##Boxplot challenge:

## Attempt to replicate the boxplot challenge (or similar behaviour):

#load some data in!
income <- read.csv('datasets/nzincome.csv', header = TRUE)

## ---------------------------SHINY + ggvis/plotly-------------------------------------------
##ggvis:
library(ggvis)

income500 <- cbind(income[1:500, ], "All")

#shows dotplots and box plot?
ggvis(income500, ~"All", ~weekly_hrs) %>% layer_boxplots(fill.hover := "red") %>% layer_points()
#kind of half way there(not really.) 
#- when you want to put interactions together - either needs more thought 
# not sure if doable or actually supported? - I don't think so.


#computing the boxplot values:
#need to group_by first as compute_boxplot() can only take continuous variables.
x <- income %>% group_by(sex) %>% compute_boxplot(~weekly_hrs)

#LQ to UQ?
LQ <- x$lower_
UQ <- x$upper_



## Plotly + shiny: ideas??

plot_ly(cocaine, y = ~price, type = "box")

#theres' always this problem of being unable to just plot DOT PLOTS of 1 single variable.
priceWeight <- ifelse(cocaine$price > 4000, "High", "Low")
split_cocaine <- cbind(cocaine, priceWeight)

plot_ly(split_cocaine, x = ~priceWeight, y = ~weight, type = "scatter")



## ggvis: maybe try add limits (LQ, UQ, Median, Min, Max) using a slider. 
#I don't think there's an easy way to select on a box plot...

library(shiny)
library(plotly)



## ---------------------------NON-SHINY -------------------------------------------
library(crosstalk)

shared_iris <- SharedData$new(iris)

p <- plot_ly(shared_iris, x = ~Sepal.Width, y = ~Sepal.Length, color = ~Species, type = "scatter", mode = "markers")

## trying with the highlight() function:
## boxplot:
plot_ly(shared_iris, y = ~Sepal.Length, type = "box") %>%
  highlight(on = "plotly_hover", color = "red")  ## doesn't seem to work?

##scatterpoints:
plot_ly(shared_iris, x = ~Sepal.Width, y = ~Sepal.Length, type = "scatter", mode = "markers") %>%
  highlight(on = "plotly_hover", color = "red")

##could you have a boxplot with scatterpoints?
plot_ly(shared_iris, y = ~Sepal.Length,  type = "box", boxpoints = "all") %>%
  highlight(on = "plotly_selected", color ="red") ##can't register :(

## can you create it separately? this just makes more box plots for each group.
plot_ly(shared_iris, y = ~Sepal.Length, type = "box") %>%
  add_trace(color = ~Species)

## Sort of what we want...?
plot_ly(shared_iris, y = ~Sepal.Length, type = "box") %>%
  add_markers(x = ~Sepal.Length, color = ~Species)

## Try with crosstalk?

plot_ly(shared_iris, y = ~Sepal.Length, type = "box", boxpoints = "all")
filter_slider("Sepal.Length", "Sepal Length", shared_iris, column=~Sepal.Length, step=0.1, width=250)

## add the two together?
bscols(widths = 6,
       plot_ly(shared_iris, y = ~Sepal.Length, type = "box", boxpoints = "all"),
       filter_slider("Sepal.Length", "Sepal Length", shared_iris, column = ~Sepal.Length, step = 0.4)
) ## this changes the whole thing, which creates a problem cause we want the boxplot to stay stagnant.


## you could potentially just draw a selection box from the range of the box plot 
# Might be inaccurate though - if you have lots of points...
#can't specify the ticks/steps for filter slider. Limited as it only takes a single value.
bscols(widths = 6,
       plot_ly(shared_iris, y = ~Sepal.Length, type = "box") %>%
         add_markers(x = ~Sepal.Length, color = ~Species) %>%
         highlight("plotly_selected", color = "red"),
       filter_slider("Sepal.Length", "Sepal Length", shared_iris, column = ~Sepal.Length, step = 0.1) 
)

## trying on a different dataset:
income500 <- income[1:500, ]
shared_income500 <- SharedData$new(income500)

plot_ly(shared_income500, y = ~weekly_hrs, type = "box") %>%
  add_markers(x = ~weekly_hrs, color = ~sex) %>%
  highlight("plotly_selected", color = "red")
## This method really isn't reliable in the sense where the boxplot is very small and is only enlarged when 
## you select for the second time.

##try adding it separately...
plot_ly(income500, y = ~weekly_hrs, boxpoints = "all") %>% add_boxplot(x = "Overall")
# this is literally the same as specifying type = "box"

# I think I've reached a point where I'm out of ideas on trying to stretch this. 
# Or maybe I haven't found it yet.  Don't know enough about plotly...


## TAPPING INTO POSSIBLE JAVASCRIPT SOLUTIONS:
## Playing around and learning how to customise javascript interactions in a plotly graph
##trying onrender:

 



