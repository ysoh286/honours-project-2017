##Boxplot challenge:

## Attempt to replicate the boxplot challenge (or similar behaviour):

#load some data in!
income <- read.csv('datasets/nzincome.csv', header = TRUE)

##ggvis:
library(ggvis)

income500 <- cbind(income[1:500, ], "All")

#shows dotplots and box plot?
ggvis(income500, ~"All", ~weekly_hrs) %>% layer_boxplots(fill.hover := "red") %>% layer_points()
#kind of half way there(not really.) 
#- when you want to put interactions together - either needs more thought (not sure if doable?)


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



## plotly + crosstalk?


