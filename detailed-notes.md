This document contains findings, examples, and all kinds of things related to the project. Will be updated weekly...

---
## Week 6 & 7 (13/04-28/04): Challenges - Part II

**Q: Continuation of challenges.**

On the to-do list for the break:
- Learn about plotly's API, more javascript + customising
- Learn about customising Shiny with Javascript + make a diagram of how Shiny really works with R + web browser (who's driving what in order to know which part should I be 'mending/breaking/bending' the rules with)
- Do the box plot challenge with Shiny vs with Javascript
- Learn iplots
- investigate how Facebook's Visdom works (looking similar to what we want to achieve in the array of plots challenge)
- Array of plots challenge - get a linking scatterplot matrix, then try make a zoom-in plot.
- Achieve the trendline challenge using Javascript alone
- investigate way to communicate between R and the web browser + Javascript

---
## Week 5 (06/04- 13/04): Challenges - Part I

**Q: Do the following challenges.**

*- Attempt to recreate the boxplot challenge using Plotly, ggvis, Shiny/Crosstalk*

*- Recreate the trendline challenge with Plotly, ggvis, Shiny/Crosstalk, iplots*

*- Array of plots challenge*

*- Address previous issues - crosstalk + plotly + shiny, redraws from crosstalk/plotly*

**Hard to find a way to stop things from replotting/redrawing...?**

Possible TO-DO'S for next week:
- Learn Plotly.JS and its API
- Investigate HTMLtools
- Try doing the exercises withOUT using Shiny

**A few minor mistakes + issues addressed:**
- event_data("plotly_selected") does indeed return a dataframe, NOT a LIST - output that was printed when trying on other plots was "list()".

- curveNumber can get a little complex when it comes to dealing with more complex facetted plots, but it is a group id for each subset for each plot (verified by a more complex ggplotly example added in Week 4).

- How Plotly interacts with crosstalk: under filtering it redraws the Plotly entire graph, while under selection - it appears to only update 'traces' (styles of points), which may explain why selection appears much faster than compared to filtering.

**Trendline challenge:**
- Easily achievable using Plotly + Shiny (or anything with Shiny) - however you still face the problem of re-rendering the entire plot.
- Plotly itself does not have statistical curves or statistcal functions to compute model fitting for trendlines (not designed to). Extensible by how much you know R (for data + model fitting) - you may need to get it in a correct 'format' before Plotly can do it.
(Here's an [example](https://moderndata.plot.ly/regression-diagnostic-plots-using-r-and-plotly/ where it's managed to plot residuals and scale location plots!) making residual and scale location plots from Plotly and R.)
- An even easier approach is using ggplotly(), which makes it simple if you're a whizz at ggplot2 through stat_smooth()/geom_smooth() (ggvis is in a sense trying to achieve this via layer_model_predictions(), where it does everything for you)
- Done with iNZightPlots + Shiny (just some simple trendline fitting - already established in iNZight Lite)

A possible problem/idea to investigate?
- How much 'math/stats' can JavaScript handle and would it be a good idea to make use of it (to create standalone plots), or let R do all the computation (and somehow link the two to drive a change in a trendline - in this case linked and not standalone, like Shiny - but avoid redraws). - get it talking to each other.

**Boxplot challenge:**
- It might be tough to do a selection on the boxplot itself via plotly (I would probably categorise it along 'Can be done if I knew Plotly.JS well or was a JavaScript whizz'). Despite this, I'm still going to give it a go  some time next week!
- Not getting very far at the moment, since there's always this funny problem of being unable to plot 1 variable dot plots through R...
- A possible idea is to use Shiny's sliders over the summary values of the box plot, which help filter which points are to be highlighted.

**Array of plots challenge:** Haven't gotten round to trying it yet! I have started looking at iPlots (still reading up on functions and code).
- An example of what kind of plots you'd like to look into?

#### NOTES:
Summary Tables:  Just to recap what I've learnt so far in the past month.


| Comparison  | Similarities     | Differences   |
|:------------| :-------------   | :-------------|
| Shiny vs Crosstalk    |   Allow users to control and communicate information between plots and other inputs/outputs (such as tables, sliders, e.t.c).    | Crosstalk limited to two features, you can achieve much more with Shiny. Crosstalk's aim is to link HTMLwidgets seamlessly together. Shiny requires R session to power everything, crosstalk is more standalone and easy to share. |
| Plotly vs ggvis | Construction of plots using layers, use of pipeline operator %>% (functional in the sense where you can constantly modify plots by storing plot objects in variables), compatible with Shiny, both provide in-plot interactions, construction of facetted and multi-panel plots are relatively similar (via subplots/subvis). No support for 1 variable dotplots (programmed to look for a y-variable). Both support a wide variety of plots. Both use JS libraries/APIs that are built upon D3.     | ggvis can provide out-plot interactions, while Plotly alone cannot. Vega vs Plotly.js. ggvis interactions are driven through R, Plotly interactions driven by JS. No support for facetted plots for ggvis(yet!). For Plotly, facetted plots achievable using ggplotly() + ggplot2 or subplot().        |
| ggvis vs Shiny | Both use R sessions to drive interactions (in fact, ggvis communicates between R and the web browser via Shiny), very similar inputs and interactions can be achieved. | ggvis does not allow layout control, Shiny does. ggvis allows for some basic in-plot interactions to be achieved, while Shiny does not.|


| | Pros/Strengths        | Cons/Weaknesses | Comments? |
|:---------- | :--------- | :-----------| :---------|
| Shiny | Generic, allows UI and layouts on the page to be easily customised, out-plot interactions  , popular for incorporating interactions via R without the need to learn other web technologies. Can easily be connected with other packages such as Plotly, ggvis. Extensible to using R for statistical computing.  |  Rerunning code and redrawing plots (inefficient on large datasets),  limited on in-plot interactions. Linked brushing (via brushedPoints) only works on base plots and ggplot2 - may be supported through other packages in their own way (plotly: plotly_selected, ggvis: linked_brush).  | Been around for quite a while. |
| Crosstalk | Great with dealing with row-observation data, no reliance on R (standalone sense), great for linked brushing and filtering , easy to link up tables to plots via making data frame as shared key objects. Selection may not require redrawing.  |  Does not work on aggregated and summarised data, hard to implement (requires set up through R on your own widget + JS), selection and filtering must be well defined through JS interactions, only has two features so far: selection/linked brushing and filtering. May require redrawing of plots (depends on how author has defined JS interactions and what it does with the data). Currently supported HTMLwidgets: Plotly, Leaflet, d3scatter, DT.  |    Still in development, relatively new.  |


**A bit more on ggvis and its interactivity:**
- Been watching Winston Chang's presentation about ggvis from the useR conference in 2014. [Youtube link](https://www.youtube.com/watch?v=wYafq7hYWcg)

Some notes from this presentation are recorded below:
- Interactivity is driven by Shiny: "functional reactive programming,  a reactive can use a  value from another reactive - creating a dependency of reactives which persist. When something changes, everything that's dependent on it changes (recompute)."
- Vega.js is doing the rendering - either as SVG, or HTML canvas, NO R graphics AT ALL.
- ggplot is fundamentally different from ggvis
- Bidirectional links: have to be careful how you setup the reactives carefully.
- Large datasets? - in browser rendering done by JavaScript, can get sluggish when interacting when you've got lots of points. (If you're dealing with large data -> do computation in R first, then scale. They intend to change to using C to do computation as it's alot faster than R. )
- may not work on early version of R due to package dependencies

**Fast search: Crosstalk + Plotly + Shiny**

Here are some working demo examples that use crosstalk, plotly and shiny together (found in the Plotly repository):

- [Basic demo app](https://github.com/ropensci/plotly/blob/51e159ba825b007657c1d7534825ef25afc7e7af/demo/shiny/basic/app.R)
- [Using DT](https://github.com/ropensci/plotly/blob/51e159ba825b007657c1d7534825ef25afc7e7af/demo/shiny/DT/app.R)

- You need to define the shared dataset/data outside of the shiny app in order for it to work... not sure why yet (maybe in order for crosstalk to work?).
- A simple example using the iris dataset found in the code folder.


**Investigating crosstalk + Plotly in more detail:**
- Crosstalk only supports filtering and selection
- After digging through and looking for more source code: FINALLY FOUND THIS (though, still making sense of it), which may explain how the filtering and selection works on Plotly with crosstalk:
[plotly.js via HTMLwidgets](https://github.com/ropensci/plotly/blob/08fe476068da4f5925c5cb696cf07c221d2c6942/inst/htmlwidgets/plotly.js)
- At line 476, it suggests that Plotly redraws under filtering
- At line 484 - function TraceManager.prototype.updateSelection suggests that it may be just changing the styling of key objects rather than redrawing the whole plot under selection...?
- This may explain why it's so much faster than Shiny at selection and linked brushing (because you don't have to redraw things EVERY single time - it's just changing styles...)
- Still uncertain if these are really the correct functions that are driving crosstalk-plotly behaviour/interactions.
- Awaiting confirmation... **[CONFIRMED]**

*Plotly.redraw() does indeed rerender the entire plot, but they're working on maybe trying to prevent it via selection logic.*

- Is it possible to customise or add on plot interactions into Plotly graphs, and if so - how can this be achieved?

*It is possible - need to learn Plotly's API + read on how to plug in custom JS for this.*
- Not sure how long this could take, but will give it a go anyway!

**iPlots:**
- [iPlots page](http://rosuda.org/software/iPlots/)
- interactive graphs in R using Java
- features: querying, highlighting, color brushing, changing parameters
- *Does it redraw?*
- Possible to add things to a plot via its API?
- functions for different graphs: imosaic(), ibar(),ipcp() (parallel plots), ibox(), ilines(), ihist()... e.t.c

- Facetting: ??


**An advanced facetting example/array of plots challenge:** Currently still on the to-do list.

**Boxplot challenge:**
- Easily achievable with iNZight/gridSVG/custom JS (though, a possible future problem is the ease of matching the correct elements to interactions if there are lots of elements on the page)
- Trying to attempt it with Shiny + filter sliders (still working on it!).

**Trendline challenge:**
- When you're coupling it with Shiny - it seems everything's doable (in an R sense).
- Main advantages of using Shiny becomes much clearer in the sense where you have access to R to do statistical computation (such as computing models, lines, and you could probably go further with of what kind of trendline you want to plot - e.g. formulas, type of model, type of family distribution (GAM), span for loess...e.t.c)
- Downside for using Shiny: recomputation takes time and it's inefficent (and sometimes Shiny lags + or is unstable), + can't do it on large datasets
- Plotly + Shiny: Plotly itself has limited statistical curves. You can achieve the same by linking it up to Shiny. However, if you use ggplot2 + ggplotly - you can go further as ggplot2 has built in functions that help make plotting of smoothers easier.
- ggvis alone: Because ggvis does use Shiny's infrastructure to drive its interactions + ui inputs, you can achieve this via using layer_model_predictions() (limited to 3 different types of models at the moment) and layer_smooths() (loess) function.
- ggvis + Shiny: probably can achieve more models using other R packages that are made for modelling.


---
## Week 4 (30/03 - 06/04): Shiny + Plotly, Shiny + ggvis, 'what-ifs' on avoiding redrawing plots?

 **Q: Investigate the following in more detail: Shiny + Plotly, Shiny + ggvis, Crosstalk**

 *Can Plotly and ggvis do facetting? Can it do other kinds of plots? Complete redraws from crosstalk?*

 **A:** **Plotly** can render facetted plots through either using ggplot2 and ggplotly() or by using a subplot() function - one approach where you need to draw each individual plot before you can put it altogether. Plotly provides a range of different plots (from histograms, heatmaps, scatterplots, boxplots, barplots, line plots... dot plots are a bit of a challenge as they view these as a special kind of 'scatterplot' - but it faces a similar problem where it requires 2 variables).
However, there are limitations to using event_data("plotly_selected") - it only appears to work on scatter plots and facetted plots and returns an empty list when the user tries to do a selection over any of the other plots listed above.
event_data("plotly_hover", "plotly_click") are more versatile in the sense that they are able to return a single point/bar/value.

Columns in the ~~list~~ **DATAFRAME** (got confused because the output returned = "list()") that event_data() returns:
- curveNumber represents either the 'trace' (subsets) or a corresponding plot number (if you have facetting plots with a single subset/group)
- **UPDATE:** In cases of facetted plots - curveNumber counts from no. of plots to each subset group (becomes a lot more complex - see a more complex plot below).
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

A more complex example using ggplotly and how curveNumber works in facetted plots:

```
income500 <- income[1:500, ]

ui <- basicPage(
  plotlyOutput("plot"),
  tableOutput("table")
)

server <- function(input, output) {

  output$plot <- renderPlotly({
    ggplot(income500, aes(x = weekly_hrs, y = weekly_income, color = sex)) + geom_point() + facet_grid(highest_qualification~ethnicity)
    ggplotly() %>%
      layout(dragmode = "select")
  })

  output$table <- renderTable({
    event_data("plotly_selected")
  })
}

shinyApp(ui, server)

#in this case: curveNumber counts from 0 to the length of plots x no. of groups you're subsetting by.
# E.g. Females are counted as 0 to 19, males are counted from 20 onwards to 42.

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
- Difference between ':=' notation and '=' notation:
   - := is used if you wish to make points of a fixed color and size (on an unscaled value - e.g. pixel co-ordinate system)
   - = is used for mapping (where if you want to map data to co-ordinates rather than have just pixels - ideally use for when passing variables to get correct scaling on the plot)

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

- Through plotting packages, it is hard to add or remove things without calling the original plot.
For example, it requires the plot_ly() function, and you cannot run an 'add_markers()' command alone. In ggvis, when we store the plot into a variable and try run individual commands, the plot changes accordingly and gets replotted. To understand this in more detail, may need to look at the Vega library and how the updating works.)

- Comparing Shiny to Crosstalk:
  - Crosstalk is limited to selection and filtering
  - Crosstalk allows in-plot interactions
  - Crosstalk does not require an R-session - rather, most interactions are driven by Javascript in the browser
  - Crosstalk is still under development - currently cannot summarize/aggregate data
  - Shiny is more generic and allows 'out-plot' interactions, requires redrawing of the whole plot when something changes (based upon input/output system and reactivity) but the user sees it as something different
  - It is possible to use both together, as Shiny can identify shared V6 objects
  - In comparing how to do linked brushing, crosstalk is alot faster in the sense that it doesn't have to redraw the plot, and does it very quickly whereas in Shiny, you may need to make your own key in order to link things up (unless you're comparing plotly - event_data() can do it automatically)


- **UPDATE 08/04: See Week 5 - With plotly, it redraws when you do filtering, but only changes styles of the points when it does selection through crosstalk.**
It's hard to tell if crosstalk actually rerenders the plot or not :/ Crosstalk may only be responsible for making links - it may depend on whether Plotly plots are being 'updated' or redrawn via the javascript library - may have to dig into Plotly's JS library to find out how it's rendering stuff connected to crosstalk.
  - Attempting to read the [source code](https://github.com/rstudio/crosstalk/blob/master/R/crosstalk.R) (which actually demonstrates how crosstalk can be used with Shiny with shared V6 objects)
  - [Crosstalk package notes](https://github.com/rstudio/crosstalk/blob/master/NOTES.md)


- Still looking for a solution to prevent redrawing... :(
- You can hide lines and such easily, but that's when it's already on the plot.

#### 'WHAT-IF' CHALLENGES:

**- Adding/changing a trendline**
- Using ggvis + layer_model_predictions() + layer_smooths() - currently has linear models, loess smoothing and RLM provided. Not sure if you could actually write your own models in though. These allow changes on the trendline:

```
#install if required:
install.packages('ggvis')

library(ggvis)

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
