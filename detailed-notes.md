This document contains findings, examples, and all kinds of things related to the project. Will be updated weekly...

---
## Week 4 (30/03 - 06/04): Shiny + Plotly, Shiny + ggvis, 'what-ifs' on avoiding redrawing plots?

 **Q: Investigate the following in more detail: Shiny + Plotly, Shiny + ggvis, Crosstalk**

 *Can Plotly and ggvis do facetting? Can it do other kinds of plots? Complete redraws from crosstalk?*

 **A:** **Plotly** can render facetted plots through either using ggplot2 and ggplotly() or by using a subplot() function - one approach where you need to draw each individual plot before you can put it altogether. Plotly provides a range of different plots (from histograms, heatmaps, scatterplots, boxplots, barplots, line plots... dot plots are a bit of a challenge as they view these as a special kind of 'scatterplot' - but it faces a similar problem where it requires 2 variables).
However, there are limitations to using event_data("plotly_selected") - it only appears to work on scatter plots and facetted plots and returns an empty list when the user tries to do a selection over any of the other plots listed above.
event_data("plotly_hover", "plotly_click") are more versatile in the sense that they are able to return a single point/bar/value.

Columns in the list that event_data() returns:
- curveNumber represents either the 'trace' (subsets) or a corresponding plot number (if you have facetting plots with a single subset/group)
- x and y return x and y values corresponding to the plot, pointNumber returns the point number on the plot

- In terms of linked brushing between plots via shiny (either plotly or ggvis): in these examples, the selection appears to be redrawn on top of the points that are being selected, creating an additional layer of plotting.  
- Crosstalk seems to be easier to achieve linked brushing with less code + no reliance on Shiny

**ggvis** is currently under development (they're still currently expanding their API). Facetted plots are currently unavailable, but is being developed under a function known as subvis() and appears to work similarly to facetting with Plotly. Unlike ggplot2, there is currently no function that automatically does facetting (such as facet_wrap/facet_grid). It would be interesting to see how much can be achieved using the Vega library.

**Crosstalk + Plotly:** Still investigating. It appears to be a lot faster than Shiny. Not actually sure if crosstalk would actually rerun code like Shiny, or if it depends on the Javascript library itself and how it renders/updates plots.

**What if challenges:**
- Boxplot challenge: see 'what-if' folder >> boxplot.svg
I'm still investigating how to do the 'what if' challenges! Still trying to find if there's a function that allows removal/addition of plot layers without redrawing the plot (though, chances of it seem pretty slim at the moment).

#### NOTES:

**Shiny + Plotly:**
- Because Plotly has been adapted as an HTMLwidget, it's easy to embed plots into Shiny
- Plotly can also render plots from ggplot2
- appears to be much easier to achieve in-plot interactions as well as link things to the plots
- [CRAN documentation](https://cran.r-project.org/web/packages/plotly/plotly.pdf)
- A cheatsheet for using [Plotly in R](https://images.plot.ly/plotly-documentation/images/r_cheat_sheet.pdf)
- You can create *faceted plots* - need to build each plot before you can put it altogether using the subplot() function
- you could also build faceted plots from ggplot2, then render with Plotly (using ggplotly())
- Limitations? It appears that you can't select points from different 'curves' and limited to that subplot. Selection box does not appear correctly (but if you drag over the points you wish to select, the table correctly reports those points corresponding to that plot) - best to reset the plot if you wish to select points from a different subplot.
- Curve number changes according to whichever plot you refer to (counts from 0 onwards rather than 1), point number refers to the point (row number in the original data).
- Curve number can also refer to 'trace' (if you've got a subset in your data - e.g. Gender of males and females, males = 0 and females = 1)
> curveNumber: for mutiple traces, information will be returned in a stacked fashion - *Plotly in R website*

```
ui <- basicPage(
  plotlyOutput("plot"),
  tableOutput("table")
)

server <- function(input, output) {

  groups <- group_by(iris, Species)
  plots <- do(groups, p = plot_ly(., x = ~Petal.Width, y = ~Petal.Length, color = ~Species, type = "scatter", mode = "markers")
                          %>% layout(dragmode = "select"))

  output$plot <- renderPlotly({
    subplot(plots[['p']], nrows = 1, shareX = TRUE, shareY = TRUE)
  })

  output$table <- renderTable({
    event_data("plotly_selected")
  })
}

shinyApp(ui, server)

```

- event_data("plot_selected") produces a data frame with a 'curve number' and appears to work best with scatterplots. When attempting to render values in a table, the selection does not return anything when tried on bar plots, histograms, heatmaps, boxplots (there appears to be no mechanism for dealing with aggregated data - just returns an empty list). "plotly_click" and "plotly_hover" are more versatile in which they work for most plots as they return a single point/bar/value.
- Plotly also can't appear to plot single variable dot plots (without 2 variables, plot makes no sense).
>"Dot plots show changes between two points in time or between two conditions." - *Dot Plots in R, Plotly website*

- It is possible to do linked brushing with Plotly. A key or a unique identifier in the dataset needs to be present to link two plots together.
- The example follows something similar to linked brushing in ggvis  - use of a key to link between the two, but also drawing a layer on top of the plot to show selected values. (The code below links the two together, but still reports duplicate readings due to having duplicate 'traces'. Still looking into a solution for it...)
- Would it be possible to actually use point number generated by event_data() as an identifier instead? Not sure. (Actually, that might not be such a good idea if you've got facetting plots going on.)

```
#setting up user interface and layout:
ui <- fluidPage(
  fluidRow(
    column(6, plotlyOutput("plot1")),
    column(6, plotlyOutput("plot2"))
    ),
  tableOutput("table")
)

server <- function(input, output) {

  #for datasets without an identifier - make your own (by default, use row numbers...)
  id <- seq_len(nrow(iris))

  #bind to dataset:
  iris <- cbind(iris, id)

  #render first plot:
  output$plot1 <- renderPlotly({
    selected <- event_data("plotly_selected")
    plot <- plot_ly(iris, x = ~Petal.Length, y = ~Petal.Width, type = "scatter", mode = "markers", source = "plot") %>%
      add_markers(key = ~id) #add markers for id
    layout(plot, dragmode = "select")
  })

  output$plot2 <- renderPlotly({
    selected <- event_data("plotly_selected", source = "plot")

    plot <- plot_ly(iris, x = ~Sepal.Length, y = ~Sepal.Width, type = "scatter", mode = "markers") %>%
      add_markers(key = ~id)

      #add markers for id - would it be possible to get rid of this and somehow just use the key to link the two together?
      #this appears to add on the additional traces that we don't want.

    if (!is.null(selected)) {
      #find all the values that have been selected:
      select <- iris[iris$id %in% selected[["key"]], ]
      #to locate selected points: color them red (it's like an additional layer on top - similar to what's been done on ggvis!)
      plot <- add_markers(plot, data = select, color = I("red"))
    }

    layout(plot, dragmode = "select")

      })

  output$table <- renderTable({
    event_data("plotly_selected", source = "plot")
  })
}

shinyApp(ui, server)


```
- An example where we can generate a plot using event_data("plotly_selected"):

```
#uses the income.csv dataset: note that n = 11000 - just to see how well plotly + shiny responds...

ui <- fluidPage(
  fluidRow(
    column(4, plotlyOutput("sourceplot")),
    column(4, plotlyOutput("boxplot")),
    column(4, plotlyOutput("histogram"))
  ),
  tableOutput("table")
)

server <- function(input, output) {

  #scatterplot
  output$sourceplot <- renderPlotly({
    plot_ly(income, x = ~weekly_hrs, y = ~weekly_income, color = ~sex, type = "scatter", mode = "markers", source = "source") %>%
      layout(dragmode = "select")
  })

  #render a box plot based upon the selection from scatterplot
  output$boxplot <- renderPlotly({
    s = event_data('plotly_selected', source = "source")
    selected_data <- income[s[["pointNumber"]], ]
    plot_ly(selected_data, x = ~weekly_hrs, type = "box")
  })

  #render a histogram based upon selection from scatterplot
  output$histogram <- renderPlotly({
    s = event_data('plotly_selected', source = "source")
    selected_data <- income[s[["pointNumber"]], ]
    plot_ly(selected_data, x = ~weekly_hrs, type = "histogram")
  })

  #render table results
  output$table <- renderTable({
    event_data('plotly_selected', source = "source")
  })

}

shinyApp(ui, server)

```

**Shiny + ggvis:**
- ggvis still appears to be under development! They're still currently trying to expand their API.
  - [Questions and discussions](https://groups.google.com/forum/#!forum/ggvis)
  - [Github repository](https://github.com/rstudio/ggvis)
- Aims to be something more restricted than d3, but good for exploratory analysis and follows the 'Grammar of Graphics'
- Facetting plots are currently unavailable. However, it appears to be under development through a function called subvis() that achieves a similar set up to Plotly - need to individually plot, and then you can put it altogether. Someone has actually asked on the forum of whether there would be a facetting function, Wickham's (2013) stated that it may not be necessary as it's easy to embed plots together - but there is demand for it = subvis() in the works - search through the google group discussion with 'facetting' + [demo on subvis](https://github.com/rstudio/ggvis/blob/master/demo/subvis.R)

- Supported plots: scatter plots, regression lines, bar graphs, line graphs, histograms, box plots, kernel density plots and dot plots (you can't do box plots of 1 continuous variable though - might need a bit more thought). Look at 'ggvis-shiny.R' in the code folder or the [ggvis Cookbook](http://ggvis.rstudio.com/cookbook.html)
- Different kinds of interactions? Basic, but could get you far enough with out using Shiny. If you need more complex interactions, developers say to use Shiny with ggvis.
  - hovers
  - input: sliders, select, checkboxes..e.t.c
- It appears you could prevent redrawing of the plot if you just use ggvis alone. But that probably needs to be justified by understanding how the Vega library works when it updates things...

- For a linked brushing example and other bits and bobs with ggvis, refer to Week 3,'ggvis-shiny.R' in the code folder, or the original [demos](https://github.com/rstudio/ggvis/tree/master/demo) given by RStudio in the ggvis repository.

**Comparing Shiny vs Crosstalk on Plotly:**
- Carson Sievert (who has written *Plotly for R* and documentation for the plotly package + provided many good examples to learn from) has also investigated whether to use Shiny or Crosstalk and its limitations.
  - [Linking views with Shiny](https://cpsievert.github.io/plotly_book/linking-views-with-shiny.html)
  - [Linked Views without Shiny (via Crosstalk)](https://github.com/cpsievert/plotly_book/blob/master/linked-views.Rmd#linking-views-without-shiny)


- His talk on interactive web graphics from R highlights most of the pros and cons + lots of examples of what can be done (includes a working example of changing an interactive polynomial model to a scatter plot - flick to slide 27)
[Interactive Web Graphics in R using Plotly and Shiny](http://cpsievert.github.io/talks/20160121/#27)


- Investigating in more detail on how Shiny's reactivity works:
  - [An overview on reactivity](https://shiny.rstudio.com/articles/reactivity-overview.html)
  - [Understanding reactivity](https://shiny.rstudio.com/articles/understanding-reactivity.html)


- Unfortunately, due to Shiny's reactive nature and requirement to 'rerun' code to update things, we may be unable prevent redrawing (ie you must run plot_ly() function within in order to update/change the plot - you can't run additional layers separately...)

- Through plotting packages, it is hard to add or remove things without calling the original plot
For example, it requires the plot_ly() function, and you cannot run an 'add_markers()' command alone. In ggvis, when we store the plot into a variable and try run individual commands, the plot changes accordingly and gets replotted. To understand this in more detail, may need to look at the Vega library and how the updating works.)


- It's hard to tell if crosstalk actually rerenders the plot or not :/ Crosstalk may only be responsible for making links - it may depend on whether Plotly plots are being 'updated' or redrawn via the javascript library - may have to dig into Plotly's JS library to find out how it's rendering stuff connected to crosstalk.
  - Attempting to read the [source code](https://github.com/rstudio/crosstalk/blob/master/R/crosstalk.R) (which actually demonstrates how crosstalk can be used with Shiny with shared V6 objects)
  - [Crosstalk package notes](https://github.com/rstudio/crosstalk/blob/master/NOTES.md)


- Still looking for a solution to prevent redrawing... :(
- You can hide lines and such easily, but that's when it's already on the plot.

#### 'WHAT-IF' CHALLENGES:

**- Adding/changing a trendline**
- Using ggvis + layer_model_predictions() + layer_smooths() - currently has linear models, loess smoothing and RLM provided. Not sure if you could actually write your own models in though. These allow changes on the trendline:

```
ggvis(income, ~weekly_hrs, ~weekly_income, fill = ~sex) %>%
  layer_points() %>%
  layer_smooths(stroke:= "red", span = input_slider(0.5, 1, value = 1, label = "Span of loess smoother" )) %>%
  layer_model_predictions(stroke:="blue",
                          model = input_select(c("Loess" = "loess", "Linear Model" = "lm", "RLM" = "MASS::rlm"), label = "Select a model"),
                          se = input_checkbox(value = FALSE, label = "Show standard errors"))

```
- You could probably replicate the same thing in Shiny + ggvis (but probably needs to redraw the plot everytime...)
- Still looking into trying to add/remove lines from a plot

**- Boxplot challenge with iNZight:** Similar to previous project - done in 30 minutes. See the 'what-if' folder, 'boxplot.svg'.
- There is actually a problem in which if I keep adding more features to it (from my summer project), it's becoming hard to maintain and becomes like spaghetti code (...and that's probably because I don't know enough JavaScript or simply a good structure/design to facilitate all these interactions).

#### OTHER IDEAS:
- Some resources to look at in communicating Javascript to R, R to Javascript:
 - Dean Attali's shinyjs package and tips on how to enhance Shiny interactions (if we plan to go down the Shiny route...)
    - [ShinyJS CRAN Documentation](https://cran.r-project.org/web/packages/shinyjs/shinyjs.pdf)
    - [Send messages from R to JavaScript, and back](https://github.com/daattali/advanced-shiny#message-r-to-javascript)
    - [Simple AJAX system for Shiny apps](https://github.com/daattali/advanced-shiny#api-ajax)

---
## Week 3 (23/03-30/03): Understanding more Shiny, limits to functions

**Q: What are the limits to Shiny's interactive functions (e.g.brushedPoints())?**

**A:**
The main limitation of using these interactive functions that Shiny provides is that they **only work on base and ggplot2** (includes facetted plots). They appear to work on a mapping condition where plotted co-ordinates on a high resolution PNG are aligned to the data. Without this 'mapping', it fails (as seen with lattice plots). The function tries to handle missing data appropriately but doesn't handle large datasets very well.
It can be adapted to bar and box plots but requires a bit more code and thought.

You can link two plots together to achieve linked brushing by making the dataset 'reactive' based upon what is being selected by the user.

Note that the limits to brushedPoints() would apply to some of the other functions that Shiny also has for incorporating interactivity (such as nearPoints()).

**ggvis** has its own functions that allow for similar interactions to be achieved (but requires a few more lines of code as you have to make a link rather than brushedPoints() that does it automatically).

- Alot of interactions that Shiny achieves are not interactions directly on/inside the plot, but rather something outside of the plot that 'redraws'/'reshapes' it. (e.g. filter slides to control a variable or number of counts, or 'animations' that are rather static images joined together than 'moving' points on the graph ). That could possibly be explained by how Shiny works with its reactive engine...

- In comparison to week 1's HTMLwidgets, those had interactions within the plot, but in a standalone sense where they're not linked to anything else but themselves.


#### NOTES:
- According to its documentation, brushedPoints() works on base plots and ggplot2 (note that CRAN version works for base plots, but the dev version for Shiny is required for ggplots)
- brushedPoints() allows selection of data by allowing the user to draw a selection box over points
- Most of these code examples written below are adapted from Shiny's articles about incorporating interactivity in different ways:
  - [Selecting rows of data](https://shiny.rstudio.com/articles/selecting-rows-of-data.html)
  - [Plot interaction](https://shiny.rstudio.com/articles/plot-interaction.html)
  - [Advanced plot interaction](http://shiny.rstudio.com/articles/plot-interaction-advanced.html)

**Linking a plot to a table:**
- works with base plots, ggplot2
- fails on grid plots, lattice

Example using ggplot2:

```
#to use brushedPoints() on ggplot2, use the dev version of Shiny.
devtools::install_github('rstudio/shiny')

library(shiny)
library(ggplot2)

ui <- basicPage(
  plotOutput("plot", brush = "plot_brush"),
  tableOutput("iris_table")
)

server <- function(input, output) {

  output$plot <- renderPlot({
    ggplot(iris, aes(x = Petal.Width, y = Petal.Length)) + geom_point()
  })

  output$iris_table <- renderTable({
    brushedPoints(iris, input$plot_brush, xvar = "Petal.Width", yvar = "Petal.Length")
    })
}

shinyApp(ui, server)

```

WHY? (It's still a bit confusing how it actually works...)

- brushedPoints() works on base plots and ggplot2 as the plot co-ordinates on the png are connected to the data, which allows for correct brushing.

- From looking at the open source code of brushedPoints(), it appears there are some functions that allow the mapping of these co-ordinates from the image/plot points to the data, as well as some scaling.
- Source code from the Shiny github repository: [brushedPoints](https://github.com/rstudio/shiny/blob/9613c58bf8120bcfdab35801b17167418b5464ac/R/image-interact.R)

- When trialling this on a lattice plot, it fails as it cannot detect what points have been selected and works on a different co-ordinate system (something that appears to make the graph span up to (1,1) - but you don't know where the origin is). The data has not been matched with the co-ordinates of these points, hence it reports different values when you click on the points...

- Shiny does have another function that renders an image, to which you may be able to attach some interaction with.

>'Instead of plot coordinates scaled to the data, they will contain pixel coordinates. You may need to transform these coordinates to something useful for your data.' - from Shiny's advanced plot interaction article

Example attempting to use lattice plots:
```
library(shiny)
library(lattice)

## Use of nzincome.csv dataset, which is stored in a variable called income
income <- read.csv('datasets/nzincome.csv', header = TRUE)
income100 <- income[1:100, ]

ui <- basicPage(
  plotOutput("plot", click = "plot_click", brush = "plot_brush"),
  verbatimTextOutput("info"),
  tableOutput("income_table")
)

server <- function(input, output) {
  output$plot <- renderPlot({
    x <- income100$weekly_hrs
    y <- income100$weekly_income
    xyplot(y~x,  main = "Lattice scatterplot of nzincome", ylab ="Weekly income", xlab = "Weekly hrs")
  })

  output$info <- renderText({
    paste0("Weekly_hrs=", input$plot_click$x, "\n Weekly_income=", input$plot_click$y)
  })

  output$income_table <- renderTable({
    brushedPoints(income100, input$plot_brush, xvar = "weekly_hrs", yvar = "weekly_income")
  })

}

shinyApp(ui, server)

```

**Facetted plots (ggplot2):**
- brushedPoints() does work for facetted (multipanel) plots drawn with ggplot2
- Note that it fails on data with missing values (in corporation with table)

- Example of facetted plots:

```
## Shiny app with facetted plots produced by ggplot2:

ui <- basicPage(
  plotOutput("plot", brush = "plot_brush"),
  tableOutput("income_table")
)

server <- function(input, output) {
  output$plot <- renderPlot({
    ggplot(income100, aes(x = weekly_hrs, y= weekly_income, color = sex)) + geom_point() + facet_grid(.~ethnicity)
  })

  output$income_table <- renderTable({
    brushedPoints(income100, input$plot_brush, xvar = "weekly_hrs", yvar = "weekly_income")
  })
}

shinyApp(ui, server)
```

**Box plots and bar plots**
- There's an example provided under Shiny's advanced plot interaction article that allows box plot interactivity under the section 'Categorical axes'. It suggests that bar plots can also achieve the same.
- Requires more thought and code, but ideally, brushPoints works best with scatterplots

**Dot plots?**
- Doesn't seem to work on dotplots with 1 continuous variable
- Works on multi-dot plots (1 continuous variable with 1 categorical variable) - but it seems a little unreliable (doesn't appear to display all the data if you've got a lot of values...)
- Same situation applies for base plots (using stripchart())
- If the points don't lie on the axes (horizontal stacking), it won't be detected.

```
ui <- basicPage(

  plotOutput("plot", brush = "plot_brush", hover = "plot_hover"),
  verbatimTextOutput("hpoint"),
  tableOutput("table")

)

server <- function(input, output) {

  output$plot <- renderPlot({
    #ggplot(income100, aes(x = weekly_income, fill = sex)) + geom_dotplot(binwidth = 50)
    ggplot(income100, aes(x = sex, y = weekly_hrs, fill = sex)) + geom_dotplot(binaxis = 'y', stackdir = 'center')
  })

  output$hpoint <- renderText({
    paste0("weekly_hrs = ", input$plot_hover$y)
  })

  output$table <- renderTable({
    brushedPoints(income100, input$plot_brush, xvar = "sex", yvar = "weekly_hrs")
    #so it doesn't seem to work if you've only got one variable.... - a bit laggy.
  })

}

shinyApp(ui, server)

```

**Linking between plots?**
- It is possible to do a link between two plots!
- In the example below it's only one way (ie one plot affects the other, but not vice versa)
- Done by making the selected/brushed dataset reactive + redrawing of plot
- A question of whether you could do it both ways?

```
#Linking different plots? - possible. https://jjallaire.shinyapps.io/shiny-ggplot2-brushing/ is an example of this. This example has been adapted from that.

ui <- basicPage(
  plotOutput("plot1", brush = "plot1_brush"),
  plotOutput("plot2"),
  tableOutput("table")
)

server <- function(input, output) {

  selected <- reactive({
    iris_brushed <- brushedPoints(iris, input$plot1_brush)
    if (nrow(iris_brushed) == 0) {
      iris_brushed = iris }
      iris_brushed
  })

  output$plot1 <- renderPlot({
    ggplot(iris, aes(x = Petal.Width, y = Petal.Length, color = Species)) + geom_point()
  })

  print(selected)
  output$plot2 <- renderPlot({
    ggplot(selected(), aes(x = Sepal.Width, y = Sepal.Length, color = Species)) + geom_point()
  })

  output$table <- renderTable({
    selected()
  })

}

shinyApp(ui, server)

```

**Could you do the same with ggvis?**
- ggvis has its own set of functions that allow for similar interactions to be achieved.
- To get something similar to brushPoints(), a few additional lines of code are required: linked object required, and also making the dataset reactive to brushing to link plot brushing to the table.
- Can incorporate simple ggvis interactions (such as hovers and clicks, sliders)
- [ggvis Interactivity](http://ggvis.rstudio.com/interactivity.html)
- [CRAN Documentation](https://cran.r-project.org/web/packages/ggvis/ggvis.pdf)


Code in R (adapted from ggvis demo apps):
```
#Note that there could be warnings - ggvis appears to be using an 'old' function that's been deprecated...

ui <- basicPage(
  #need to use ggvis output for this
  ggvisOutput("plot"),
  tableOutput("brushed_data")
  #ideally, want to show brushed data through the table
)

server <- function(input, output, session) {

  #create an id for each row of data
  iris <- cbind(iris, id = seq_len(nrow(iris)))

  #creating a linked brush object
  lb <- linked_brush(iris$id, "blue")

  #selecting brushed values:
  selected <- lb$selected

  #making the dataset reactive to the brush
  iris_selected <- reactive({
    if (!any(selected())) return(iris)
    iris[selected(), ]
  })

    iris %>%
      ggvis(~Petal.Length, ~Petal.Width, fill = ~Species) %>%
      layer_points(fill.brush := "blue") %>%
      #takes linked brushing input
      lb$input() %>%
      #adds the selected data points on top of the plot
      add_data(iris_selected) %>%
      bind_shiny("plot")

    output$brushed_data <- renderTable({
      iris_selected()
    })

}

shinyApp(ui, server)

```

#### OTHER IDEAS:
- Could we render and link an SVG's co-ordinates and create brushing? Possible, but requires mapping.
- How hard would it be to try 'map' co-ordinates? Too hard.
- How do things differ when trying to integrate HTMLwidgets into Shiny? (see week4 with Plotly)
- Are there any other options that achieve interactivity in R rather than using Shiny, HTMLwidgets through a web browser?
- Are there any better examples of 'in-plot' interactions?
- Incorporating Shiny interactions directly on iNZight plots (iNZight Lite)?

---
## Week 2 (16/03-23/03): Looking at Shiny, ggvis, rVega + talk to R

**Q: Looking at ggvis, rvega, and Shiny, can we link a plot to a table + is it possible to return values selected to R?**  

**A:** It may be possible to link a ggvis plot to a table.
There are examples/variations where in a Shiny app, the plot links to a table (or a certain row of points). With R sessions running, would be nice to investigate if you could pass something back.

Examples that achieve similar things:
- Shiny's article on selection of points (not related to a table, but the output it gives are rows from the dataframe itself), uses base plots and ggplot2
https://shiny.rstudio.com/articles/selecting-rows-of-data.html

- ggvis's demo apps - includes linked brushing, hovers, and filtering
https://github.com/rstudio/ggvis/tree/master/demo/apps

- DT's examples on linking DT to the plot (select on table to point, rather than plot to table)
https://yihui.shinyapps.io/DT-rows/
- More about linking DT to Shiny: http://rstudio.github.io/DT/shiny.html


**Overall comment:** I think I still need some time to learn and understand Shiny to see what else it can do/can't do - but it seems that a lot of interactivity can be achieved (for inspiration: [Shiny's gallery](https://shiny.rstudio.com/gallery/)). Wonder if I can actually try get the server to print something during the R session whenever the user does something (like change inputs)...


#### NOTES:
**Shiny:** https://shiny.rstudio.com/
- R package that allows ease of building web applications through R
- Tutorial page: https://shiny.rstudio.com/tutorial/

Advantages of using Shiny:
- Code all in R - inclusive of HTML/CSS customisation (UI), addition of custom JavaScript possible (https://shiny.rstudio.com/articles/js-events.html, Shiny's JavaScript tutorial)
- Most HTMLWidgets can be used with Shiny

Disadvantages of using Shiny:
- Speed and efficiency (Shiny's reactive engine uses a process of 're-running' code, which could slow things down when dealing with big data sets)
- Prepackaged functions - which are great, but alot happens behind each function. Would it be hard to customise (would we run into a similar problem with JavaScript libraries from week 1)?

**ggvis:** http://ggvis.rstudio.com/
- data visualisation package, looks very similar to ggplot
- allows interactivity through R, 'uses shiny's infrastructure' to do this rather than a JS library
- graphics rendered (SVG) are done using Vega (JS library? - converts plot objects to JSON)
- Vega Library: https://vega.github.io/vega/

- Attempting to write a Shiny app that links ggvis plot to table: see Week 3.


**rVega:** https://github.com/metagraf/rVega
- DON'T USE.
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
