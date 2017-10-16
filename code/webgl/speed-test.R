## Simple speed testing: webgl in rbokeh, plotly, gridSVG:

library(gridSVG)
library(rbokeh)
library(plotly)


# Test 1: rendering 11,000 points:
income <- read.csv("~/Desktop/datasets/nzincome.csv", header = TRUE)

# plotly: SVG
plot_ly(data = income, x = ~weekly_hrs, y = ~weekly_income, type = "scatter", mode = "markers", color = ~sex)

## test speed time:

#svg version:
system.time(for (i in 1:100) {
  plot_ly(data = income, x = ~weekly_hrs, y = ~weekly_income, type = "scatter", mode = "markers", color = ~sex)
})/100

#time recorded: 0.00203 0.00037 0.00246 

# webgl version:
plot_ly(data = income, x = ~weekly_hrs, y = ~weekly_income, type = "scattergl", mode = "markers", color = ~sex)

#time recorded: 0.00189 0.00019 0.00209 

# Maybe 10,000 points is too small to see a difference in plotly.

#for rbokeh: CANVAS

# testing on gridSVG + lattice plot:
lattice::xyplot(weekly_income ~weekly_hrs, data = income)

system.time(grid.export(NULL)) #this is really.... slow, and this is only just for 1 iteration.

#------------------------------- TEST ON 50,000 POINTS ------------------------
x <- sample(1:100000, 5*10^4, replace = TRUE)
y <- sample(1:100000, 5*10^4, replace = TRUE)

plot_ly(x = x, y = y, type = "scatter", mode = "markers")

#time elapsed: 0.00195 0.00018 0.00216 

plot_ly(x = x, y = y, type = "scattergl", mode = "markers")

 
figure(webgl = FALSE) %>%
    ly_points(x, y)

figure(webgl = TRUE) %>%
ly_points(x, y)

#------------------------- TEST ON 100,000 points ----------------------------

x <- sample(1:100000, 1*10^5, replace = TRUE)
y <- sample(1:100000, 1*10^5, replace = TRUE)

#time it takes to load onto the browser:
plot_ly(x = x, y = y, type = "scatter", mode = "markers")

 plot_ly(x = x, y = y, type = "scattergl", mode = "markers")

  figure(webgl = FALSE) %>%
    ly_points(x, y)

  figure(webgl = TRUE) %>%
    ly_points(x, y)

#------------------------------- TEST ON 500K POINTS ------------------------

x <- sample(1:100000, 5*10^5, replace = TRUE)
y <- sample(1:100000, 5*10^5, replace = TRUE)

plot_ly(x = x, y = y, type = "scatter", mode = "markers")

plot_ly(x = x, y = y, type = "scattergl", mode = "markers")

#time elapsed: 0.00190 0.00016 0.00207 

#rbokeh: canvas - too slow
  figure(webgl = FALSE) %>%
    ly_points(x, y)
}

#time elapsed: 0.45254 0.02174 0.48895  

# rbokeh: webgl
  figure(webgl = TRUE) %>%
    ly_points(x, y)

#time elapsed: 0.42759 0.01730 0.44661 


#------------------------------- TEST ON 1 MILLION POINTS ------------------------
# test on 1 million points:
x <- sample(1:10000, 10^6, replace = TRUE)
y <- sample(1:10000, 10^6, replace = TRUE)

# plotly: webgl:
plot_ly(x = x, y = y, type = "scattergl", mode = "markers")


#rbokeh: webgl:
  figure(webgl = TRUE) %>%
  ly_points(x, y)

#System.time run:
# 0.80677 0.04476 0.85227 


#Note that the times don't reflect the actual time it loads onto the webpage. It only computes the time it's left in R(?).




