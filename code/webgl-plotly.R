## Investigating webGL in Plotly:
# Resources: https://plot.ly/r/webgl-vs-svg-line-chart/
#            https://plot.ly/r/webgl-vs-svg/

# implementing webgl to render plots instead rather than SVG:
# simply change to type = "scattergl"
# according to how it works: it converts originally svg to a webgl plot.

library(plotly)

#simple scatterplot:
plot_ly(data = iris, x = ~Petal.Length, y = ~Petal.Width, type = "scattergl", mode = "markers", color = ~Species)

#it's nested inside an empty svg, but the points are rendered with canvas (which is what webgl is).
# trying on 11000 points:

plot_ly(data = income, x = ~weekly_hrs, y = ~weekly_income, type = "scattergl", mode = "markers", color = ~sex)

# what if I do an svg version?
plot_ly(data = income, x = ~weekly_hrs, y = ~weekly_income, type = "scatter", mode = "markers", color = ~sex)

#the svg version is alot slower than the webgl version. Even when you try hover over points, it's responsiveness is much slower.

# going further: could you go and render larger datasets?
#load a dataset:
air2008 <- read.csv('datasets/2008.csv', header = TRUE)
FARS <- read.csv('datasets/FARS.csv', header = TRUE)

#this dataset has got roughly around 7 million observations...
plot_ly(data = air2008, x = ~Distance, y = ~AirTime, type = "scattergl", mode = "markers")
# ...and it only takes around 5-10 seconds for it to render with webgl.
# pretty impressive? but of course, it just looks like a sea of blue... when you zoom it becomes a little clearer.

#trying different kinds of plots:
plot_ly(x = ~rnorm(1000000), type = "histogram")
# this still renders as an svg.

# Note that plotly chooses to do webgl for the following: 3D charts, heatmaps and scatterplots...
# It makes sense in that the other plots deal with grouped data/ or somehow have less svg elements to render.


# having bits of fun with heatmaps:

# 3D charting:







