# WebGL + rbokeh:

# rbokeh also has some plots that can be rendered in webgl. Main purpose is to 
# be able to plot a lot more points more quickly.

#Most of these examples are adapted from here:
#http://ryanhafen.com/blog/plot-lots-of-data
#Note that rbokeh renders everything in CANVAS.

library(rbokeh)

x = rnorm(10000)
y = rnorm(10000)

#by setting 'a level of detail threshold  to make transitions smoother'
#downsampling occurs! Note that this method doesn't use webgl.
figure(lod_threshold = 100) %>%
  ly_points(x, y)
#when you pan and zoom, only a subset of points are shown.

#Render with webGL:
figure(webgl = TRUE) %>%
  ly_points(x, y)

#Note that it doesn't render well in RStudio's viewer pane. It's recommended to view in Chrome instead.



