This document contains findings, examples, and all kinds of things related to the project. Will be updated weekly...

## Week 2 (16/03-23/03): Looking at Shiny, ggvis, rVega + talk to R

**Q: Looking at ggvis, rvega, and Shiny, can we link a plot to a table + is it possible to return values selected to R?**  

**A:** It may be possible to link a ggvis plot to a table... (I just haven't figured it out yet!)
There are examples/variations where in a Shiny app, the plot links to a table (or a certain row of points). HOWEVER, none of them appear to report something back into R whenever you select something on the user side. With R sessions running, would be nice to investigate if you could pass something back.

Examples that achieve similar things:
- Shiny's article on selection of points (not related to a table, but the output it gives are rows from the dataframe itself) - uses ggplot2
https://shiny.rstudio.com/articles/selecting-rows-of-data.html

- ggvis's demo apps on filtering to control points that appear on the graph and on the table (basic)
https://github.com/rstudio/ggvis/tree/master/demo/apps

- DT's examples on linking DT to the plot (select on table to point, rather than plot to table)
https://yihui.shinyapps.io/DT-rows/
More about linking DT to Shiny: http://rstudio.github.io/DT/shiny.html

Advantages of using Shiny:
- Code all in R - inclusive of HTML/CSS customisation (UI), addition of custom JavaScript possible (https://shiny.rstudio.com/articles/js-events.html, Shiny's JavaScript tutorial)
- Most HTMLWidgets can be used with Shiny

Disadvantages of using Shiny:
- ?? (needs more investigation)

**Overall comment:** I think I still need some time to learn and understand Shiny to see what else it can do/can't do - but it seems that a lot of interactivity can be done in R. Wonder if I can actually try get the server to print something during the R session whenever the user does something (like change inputs).


#### NOTES:
**Shiny:** https://shiny.rstudio.com/
- R package that allows ease of building web applications through R
- Tutorial page: https://shiny.rstudio.com/tutorial/

**ggvis:** http://ggvis.rstudio.com/
- data visualisation package, looks very similar to ggplot
- allows interactivity through R, 'uses shiny's infrastructure' to do this rather than a JS library
- graphics rendered (SVG) are done using Vega (JS library? - converts plot objects to JSON)
- Vega Library: https://vega.github.io/vega/

- Attempting to write a Shiny app that links ggvis plot to table: (still in progress...)


**rVega:** https://github.com/metagraf/rVega DON'T USE.
- r interface for Vega
- Also uses Shiny for interactivity, can also integrate into Shiny
- Very limited features, package doesn't appear to have any documentation :(
- Ideally, for using the Vega library - use ggvis instead.


## Week 1 (09/03-16/03): Looking at different JS libraries, linking plots to tables

**Q: Is it possible to link a plot to a table using the following: plotly, rbokeh, highcharter, ggvis, rvega?**

**A:**
  - NO to highcharter, rbokeh
  - YES to plotly (using crosstalk), Bokeh (through Python)
  - ?? Not sure for ggvis, rvega - needs more investigation. Possibly use Shiny?

    The graphs generated are rendered as SVG elements - interaction could be added manually by writing own JS. However, you lose all the interactivity that you passed through in R that appears to be driven by something else, but not JS.

**Overall comment:** It's possible, but requires you to know the JS library/ R package inside out in order to customize interactions (even just trying to implement crosstalk could take a while to figure out what kind of Javascript interactions you want to achieve). These javascript libraries are made to make plotting and generation of interactive plots easy for the user, but when you want to try do something else, it becomes hard to modify.

Even though these JavaScript libraries are available, some only document how to use it for its main purpose (to generate an interactive plot easily for the web) through a different programme (such as R, Python, MATLAB, e.t.c).

*Random thought: Could I find a JS library that's more flexible in creating customised interaction and visualisation?*

#### NOTES:

**Plotly:**  https://plot.ly/
- Graphing library, build upon D3
- Supported for R  https://plot.ly/r/ and a few other languages (Python, Matlab)
- JS Library: Plotly.JS
- can be linked with ggplot2
- has linked brushing available

A: YES - using crosstalk. You can link plotly graphs with a DT (DataTable), or several graphs with linked brushing and a DT.

Code in R:
```
# Note: for crosstalk to work, you need to install the development versions of these packages from github. The official and CRAN versions do not have crosstalk integrated in them.

devtools::install_github('ropensci/plotly')
devtools::install_github('rstudio/crosstalk')
devtools::install_github('rstudio/DT')

library(crosstalk)
library(plotly)
library(DT)

# a simple plotly plot:
p <- plot_ly(iris, x = ~Petal.Length, y  = ~Petal.Width, color = ~Species, type = "scatter")
p

# using Crosstalk to link plot to table:
#Create a shared object (the data)
shared_iris <- SharedData$new(iris)

#putting everything together:
bscols(
  plot_ly(shared_iris, x = ~Petal.Length, y = ~Petal.Width, color = ~Species, type = "scatter"),
  datatable(shared_iris)
  )

# Linked brushing between two plots and a table:
shared_iris <- SharedData$new(iris)
bscols(
  widths = c(6, 6, 12), #though, need to check on this
  plot_ly(shared_iris, x = ~Petal.Length, y = ~Petal.Width, color = ~Species, type = "scatter"),
  plot_ly(shared_iris, x = ~Sepal.Length, y = ~Sepal.Width, color = ~Species, type="scatter"),
  datatable(shared_iris)
  )

```

**Bokeh:** http://bokeh.pydata.org/en/latest/
- Visualisation library for creating web-based plots rendered using HTML canvas
- JS Library: BokehJS
- rbokeh: the r interface - but does not have all the features that bokeh provides in comparison to Python (built more specifically to Python programmers), http://hafen.github.io/rbokeh/
- Able to achieve linked brushing with rbokeh, but not link a table

A: YES, but only on Python and to the table provided by Bokeh.
    NO on rbokeh due to only plotting functions provided. However, developer Ryan Hafen (who made rbokeh) is thinking about integrating crosstalk which could make this possible. http://ryanhafen.com/blog/rbokeh-0-5-0

Code in R:
```
# Simple rbokeh plot:

library(rbokeh)
figure() %>%
  ly_points(Sepal.Length, Sepal.Width, data= iris, color = Species, hover = c(Sepal.Length, Sepal.Width, Species)) %>%
  tool_box_select() %>%
  tool_lasso_select()

```
Code in Python for linking plot to a Bokeh table - still writing...

**Highcharter:** http://jkunst.com/highcharter/
- r wrapper/interface for HighChartsJS
- HighCharts website: http://www.highcharts.com/

A: NO. Once again, the developer has also thought about adding crosstalk, which could make this possible with DT. (Currently, you can add a DT on the same page using crosstalk as separate entities, but none of the links/interactions are available.)
The other problem is that Highcharts does not appear to have a mechanism to select points (ie, no box selection or way of isolating a single point - you can only select 'groups' of points) which may make crosstalk implementation more complex.

Code in R:
```
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

```

#### OTHER TECHNOLOGIES, TOOLS & IDEAS:
**Crosstalk:** https://rstudio.github.io/crosstalk/
- "An add-on to HTMLwidgets", package that allows htmlwidgets to cross-communicate and link together
- Interactions available: linked brushing, filtering
- Supported HTMLwidgets: Plotly, DT, Leaflet
- generation of HTML pages, uses Bootstrap, jQuery...
- Use of a sharedObject(V6) - in simple terms, you turn your data into a sharedObject which becomes interlinked between all widgets, making linked interactions possible (but that's only if your widget's already linked up with crosstalk)
- Limitations: Not all HTMLwidgets could easily implement this, they have to meet some criteria.
See the criteria and limitations here:
https://rstudio.github.io/crosstalk/authoring.html
- Relatively new/experimental, but has potential to be expanded across other htmlwidgets (some other the developers of the other widgets above are looking into it)
- R Documentation: https://cran.r-project.org/web/packages/crosstalk/crosstalk.pdf
