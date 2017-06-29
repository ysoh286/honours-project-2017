This document contains findings, examples, thoughts, ideas, and all kinds of things related (and the occasional 'unrelated') to the project. Will be updated weekly...

**Things to keep in mind:** When you get to a point where things start to take longer than expected, build your own.

**Report draft progress: Writing...** - requires a shiny server. CeR's RStudio server provides access to R.

https://ysoh286.shinyapps.io/report-draft/ - dead at the moment.

TODOS:
- extend DOM-trendline challenge
- Keep writing
- Something to test: ggvis's demo on rendering a selection box to draw a new trendline
- look at ggiraph in more detail
- attempt to get a bigger picture of how we'd customise direct interactions on plots in R?

LOOSE ENDS? Should these be further investigated or not?
- redo png-trendline challenge?
- Canvas APIs for fast rendering of large datasets

---

## WEEK 14 (29/06 - ?? ): Concepts?

- Identify what's similar in each challenge? What's different? Can you turn it into a function?

**Another pseudo-code plan?**
*still in progress...*

- A function to return 'main' elements back to R after they are sent to the browser (or after conversion to svg)

```r
#draws the plot and sends to browser
drawPlot(x, y, data, plottype, graphictype)
# plottype relates to what kind of plot it is, graphictype relates to if it might be a lattice plot, a base plot, an iNZightPlot?
# graph should be of a certain structure such that element ids would not change every time we pass it through gridSVG
```
- A function to return a list of whatever's on the browser back to R

```r
# return list of ids of elements that can be called with appropriate tags to help out
list_elements()
# imaginary example: list_elements(plot)
          # elements      id
          # panel       panel.1.1
          # lowerBox    polygon.1.1.1
          # upperBox    polygon.1.1.2
          # minLine     grid.line.1.1.1
          # maxLine     grid.line.2.1.1
          # points      points.1.1.1 (n)    

```

- A function to be able to attach simple mouse events to an element or a group of elements

- A function to be able to filter elements based upon a condition/range

- A function to be able to link elements together (somehow)


Extras that might be helpful:
- A function that can return more information about a certain element

Wandering ideas that may be off-topic:
- A possible function to 'translate' code that can be used in Shiny applications (but it might not be that useful ?)
- A function to add on tooltips + be able to specify what text goes inside

COMMONALITIES:
- There is a need for finding out WHAT elements are on the page (in gridSVG: find out the viewport containing the main plot objects we are dealing with) -it would be nice to be able to return ids of what they are
- MOUSE EVENTS such as mouseover, mouseout, clicks can be easily attached to an identified element and do basics such as: change color via fills and strokes
- A way of being able to link elements to each other because they correspond to the same data (e.g. a table row to a point, a point that lies within a range of a box, a point on one plot to another)

DIFFERENCES:
- Shiny and DOM have different systems of working around (Shiny relies on inputs and outputs. But the similar JavaScript code is used - needs to be passed into different functions like ```Shiny.addCustomMessageHandler('functionName/type', jsfunction(input)),``` and ```session$sendCustomMessage(type ='functionName/type', input)```)
- Function in R for converting coordinates into data is used in the trendline challenge (reused in both DOM and Shiny versions but may be too specific)

**Steps in each challenge:**

*Boxplot challenge:*
- Need for identifying polygon boxes/elements associated with boxplot
  - group together
  - add event listeners to correct 'element' (lowerbox)

  ```javascript

  lowerBox.addEventListener('mouseover', fillBox, false);

  fillBox = function() {
    lowerBox.setAttribute('fill', 'red');
  }

  ```
  - able to link to another element/group of elements (such as a set of points - use of a range and an if condition)

*Trendline challenge:*
- Need to render plot using gridSVG, load co-ordinate system for easy conversion of co-ordinates to data
- Identify trendline (getElementById)
- write javascript functions to append to inputs (dropdown menu or paragraphs) to change the color of the line
- R function to calculate points of the trendline and return converted points as a string
- JavaScript function to update points
- Extra slider that needs to be linked up as an input that gets passed through the R function to recalculate and update points on the trendline
- Extra script for selection box which utilises ```Shiny.onInputChange()``` to return an input that is then run through the same R function

*Linking plots:*
- Used crosstalk + plotly.
- A possiblity to recreate one between two gridSVG plots? (might be similar to linking a plot to a table row)


---

## WEEK 13 (22/06 - 29/06): Abstract thinking?

**Questions to answer:**
- **What can plotly not do?**
    - you can't add interactions without knowing D3/plotly API (an example of adding [custom interactions](https://plotly-book.cpsievert.me/custom-behavior-via-javascript.html) with plotly has been done by Sievert in his book)
    - ```event_data``` can only be used in conjunction with Shiny, where we can track inputs via ```plotly_click, plotly_hover, plotly_relayout```
    - What can it return from different plots?? *from week 3* ```plotly_click``` and ```plotly_hover``` can work on different plots to return the point at which the user has clicked on (except for box plots), but ```plotly_selected``` only works on scatter plots (everything else returns a empty data frame)
    - This data frame can be used back in R (you could use it to identify if a 'hover'/'click' has been made - but you can't change what event_data() returns. BUT: you can take this data frame and do things with it in R to render something else like a boxplot)

    Browser: user selects over scatterplot

    R: returns selection through event_data(), takes it to render a box plot with corresponding data frame that gets sent to the browser

    Browser: user sees newly rendered box plot


- **How can you make it EASIER to do what you've done WITHOUT knowing JavaScript?**

    - Most of my solutions are heavily reliant on gridSVG simply because we can map data and what's being rendered/sent to the web with its handy co-ordinate system
    - need to able to track what's what on the page - otherwise, hard to add interactions (a common problem with all other tools?)
    - Whatever specified in R should correspond to something that's being sent to the browser
    - Shiny does have functions to allow for customisation (acts as the 'bridge' between R and the browser) -> so we'd focus on providing functions that produce JavaScript output that can be put into R ??
      - Another way of manipulating DOM elements with [shiny](http://shiny.rstudio.com/articles/dynamic-ui.html)
   - something to investigate: most HTMLwidgets that we have looked at can work with Shiny and have a way of tracking on-plot interactions ->  are these interactions limited to return  to return a certain value, or can you customise that interaction??
    - what if you could send json (could originally be a array) back to R (as a list, data frame, matrix?) that can be used further??
    - Could come up with pre-written JavaScript for generic 'interactions', but also be able to be flexible enough so that things can change (so user can control what to return) which can be specified in R? (wishful thinking here) - but it would depend on what is used to generate the plot (stick to R plots? gridSVG? D3? HTMLwidget? ggvis/Vega?)
      - could be dependent on plot type as well? (e.g bar vs scatter)

  Possible steps:
    - Identify what's being generated in R, what gets sent to the browser returns a set of element 'ids' which correspond to key features of the plot back to R (e.g. a box plot could return element ids which correspond to quartiles, median, min, max and possible outliers, a scatter plot could return the general composition of the id of a point ('point.1.' + i) - or selection tags via D3 (specify parent/child)?)
    - user can define what element to target + use functions to attach interactions in R (which generates custom javascript to be sent to the browser)
    (e.g. something like ggiraph? - there's the option for those who know some javascript to write it in R to be passed through, or there is the standard option for the user)
    - user interacts on browser
    - depending on the function they've written, should return whatever they asked for back in R (or in the browser)??

  A possible example is the selection box:
  - Essentially a javascript file to drive this interaction (mousedown, mouseup, mousemove). It could potentially work on anything that's been passed through **gridSVG** (the only thing that changes is the viewport to where points/lines/bars are located)
    - What would you want to send back, and how would you change it? How does this information get passed from an R function -> JavaScript function ? (could look at htmlwidgets package - development of htmlwidgets in detail)


#### NOTES:

**Notes from meeting:**

- Problems that are found in existing tools are like "holes". Each tool can do similar things, but there are also other things they can do that differentiate them from each other.
  - Large dataset handling: the general solution appears to be to use canvas/webGL to render these plots
  - Linking different plots: doable in Shiny, but not on the web (most likely requires a full JavaScript solution)
- Each has its own system of doing things, so it might be difficult to generalize?

- Focus on talk back to R? ( solutions with no R connected deal with co-ordinating with JavaScript ... like crosstalk)
- The idea of developing an 'add-on' for tracking interactions? (kind of like crosstalk with HTMLwidgets)

R -------------> browser (send data to draw plot)

  <--------------       (send something related to interactivity back/what user has changed)

- Should we send data to the browser for more 'informative' data to be sent back or should we leave information back in R? (ie one of the main advantages for Shiny is that we keep data on the server side to avoid loading too many things on the browser/client side)
- Isn't this what we've already been doing with Shiny/DOM/gridSVG, where we can send co-ordinates, indexes, values?? (we could potentially send most things - as long as it's in a specific format that it can accept (i.e. DOM can read DOM elements, Shiny can pass through arrays/objects(not sure if there's a limit in how much you can pass? since it's not commonly used) + there's the option of creating new inputs and outputs that can be rendered on the page - you could potentially create an svg output/ or just simply throw it on as HTML)

**A possible challenge to look at - boxplots:** try render a boxplot + scatterpoints, and return the values that lie in between to R/or the web console. - or make R print something whenever top/bottom is clicked or hovered over.

 - The 'linking plot' problem: Couldn't you send the indices back , group the data in R and then compute a and aggregated plot with the existing indices?? and then it becomes interlinked?

 R  -------------> browser  (send scatterplot over)

    <------------- (send indices back, but R prints out and stores aggregated data instead)

    -------------> (once that's done, send a boxplot/bar plot?)

- How is this any different from linking everything with Shiny???

**Another look into ggiraph:**
 *Reviewed back in Week 7-9*
 - The ggiraph package is an HTMLwidget designed to make ggplot2 interactive with 'add-on' functions
 - has the following features: tooltips (hovers + labels),  onclick (JS function whenever click occurs on an element), data_id (for use with Shiny)
 - Simplistic, has 'basic' interactivity covered
 - selections can be done via Shiny
 - More flexibility on tooltips?
 - How it works: you build upon a ggplot by adding interactive functions under ggiraph, and pass it through the ggiraph() function.
 - Appears to 're-render' the plot in D3 + additional JS to pass data through from R -> browser  (from source code)
 - A more complex example by [Newman](http://dpnewman.com/ggiraph/)
 - An [example](https://rstudio-pubs-static.s3.amazonaws.com/221846_2ce0c17cc61740d7918ffa0c867ebf65.html) to which if you click on the scatter plot, it opens up a new web page with results about the car.
 - **How's this different from using plotly's ggplotly() function?**.i

---

## SEMESTER 1 RECAP:

**Aim:** Existing approaches for incorporating interactivity in plots + what might be good for iNZight?

**Tools investigated:**
- HTMLWidgets (plotly, rbokeh, highcharter...)
- ggvis
- ggiraph (with ggplot2)
- crosstalk
- Shiny
- DOM
- gridSVG
- iPlots

Others: webgl, canvas, V8

**Problems found:**
- Hard to customise own interactions on plot
- hard to extend plots or to build upon a plot (a 'standard' solution, except for gridSVG/ Shiny)
- you can build layers on top of a plot, but you can't modify a single layer without replotting
- Large dataset handling (SVG/DOM fails, gridSVG is slow)
- Linking + brushing on scatter plots only, but not on other plots
- Unnecessary redraws with Shiny (may lag on the user side if we are dealing with a large data set - a minor(?) issue)
- Maintaining connection between R and the browser to drive interactions vs standalone solutions (web driven)
- Mapping between plot components + data

**Proposed solutions/extensions:**
- Shiny can act as a more 'generic' solution -> there are ways to incorporate JavaScript, HTML to achieve custom interactivity/use of 'reactives' (such as isolate(), observe()) in R
- Combining Shiny + HTMLWidgets/ggvis gives on-plot interactions + off-plot interactions
- Combining Shiny/DOM + gridSVG allows for interaction with grid and grid-based plots, prevent redrawing (linked brushing)
- Use of canvas/webGL to handle rendering of large datasets
- Lower level tools such as gridSVG, D3 are better for customising interactions, but require more knowledge about JavaScript (tradeoff)

*Speculation for developing a more 'generic' solution that can be implemented for iNZight.*
-- Leaning towards: having to write own code, but with the help of JavaScript libraries like D3 or a canvas library for dealing with larger datasets.

Where to next??

Questionable??
- Linking different kinds of plots together (without REDRAWS from Shiny, more 'fluid' like iPlots)
- Is it necessary to have a 'reactive' programming model like Shiny?
- Crosstalk + Shiny use a 'key' for each row/observation to link scatter plots together. Is this something we should stick to?

---

## BREAK (01/06 - 22/06)

Tests/Exams are underway. :(

#### EXTRA NOTES for optional reading:

**1. The need for interactive visuals and what do users want?**

 *Need to update with a reading list/ lit review + find more!*

- purpose of communicating information (find patterns, anomalies, correlations, way of telling a 'story')

[Interactive Dynamics for Visual Analysis](http://delivery.acm.org/10.1145/2150000/2146416/p30-heer.pdf?ip=115.188.161.170&id=2146416&acc=OPEN&key=4D4702B0C3E38B35%2E4D4702B0C3E38B35%2E4D4702B0C3E38B35%2E6D218144511F3437&CFID=950138527&CFTOKEN=46582027&__acm__=1497854556_76ceca42ddbba2362a573b31d17930dc) - Jeffrey Heer, Ben Shneiderman

[What's in a good visualisation?](http://www.improving-visualisation.org/case-studies/id=6)

A [blog post](https://www.vis4.net/blog/posts/in-defense-of-interactive-graphics/) on why interactive visuals are great (but more focused on designing interactives):
- "You should not hide important content behind interactions" -tooltips for numbers, and more 'details' for the more interested user
- A way to allow users to explore the entire data set (if you have lots of data)
- In cases of 'scenario analysis' - users can see how their data changes
- A sense of trust/transparency through the data? (in journalism, it might bring more truth to readers)

An [argument](https://medium.com/@dominikus/the-end-of-interactive-visualizations-52c585dcafcb) for why interactive graphics aren't helpful (more of an indication of what should be avoided/or what's NOT helpful when you design an interactive visual):
- "If you make a tooltip or rollover, assume no one will ever see it." - 85% of page visitors ignore them, or miss out on hidden information.
- "Interaction lets you do more." - user 'personalizes' tools
- "Interaction enables people to adjust a visualisation to their own needs, ask different questions"
- Different definitions of 'interactivity' - Tufte's diagram on paper is 'interactive' in the sense that it makes the user HAVE to look INTO the data to find what they want.
- "Data visualists spend too much time about achieving interactions rather than finding uses for them"
- Think about: who's your audience, how much time do they have, what are their goals? Does interaction help?

Common interactions:
- brushing
- identification
- scaling
- linking

- People spend more time on analysing the data, and need tools to help them visualise the data easily (hence the increasing number of HTMLwidgets and R interfaces to JavaScript libraries) - Sievert points this out in a recent [blog post](https://cpsievert.me/2017/06/13/developing-tools-for-exploratory-visualization/).
- What if you could create your own interactive visual in R more deeply rather than just generate standard plots? (e.g. to specific problems such as explaining 'rejection sampling' in Bayesian statistics, or Chris's animation for explaining bar charts...) - A solution for this is you have to learn D3 or some JavaScript library outside of R, or work your way around using Shiny. The problem could be too broad to tackle...
- More standalone solutions for linking plots together (Shiny does linking fine, but it's not entirely shareable - you need to host it on a server, and either: you host it on shinyapps.io (for a limited time),  build your own, or you pay $$ for its service)


**2. What problems have we found with existing tools and how can we solve them?**
- Existing solutions do not require a knowledge of web tech create standard, non-extensive plots (just R)
- Users may demand for standalone solutions rather than those that connect to R (i.e. No shiny)
- More fluid changes/transitions (crosstalk is still an 'awkward solution' with plotly)
-  A way of visualizing and interacting with large datasets (where to store the data, how to display it?)
- Applicability??
  (An idea: A way of visualising models (like in 20x/330 - where we are given data, and we have to find the best model for it) - a way to compare models in an interactive way, select outliers and see how the model changes, compare fits 'on the fly'. Residuals and diagnostic plots are all connected. <- people might not even bother since there's no time for it.)


The problem we never got round to discussing (but was in Paul's meeting notes): **link different kinds of plots easily without using Shiny**
  >  "trying to find a way to create a series of interconnected graphs where I have a filter (either a drop down or series of checkboxes) where when an option is selected, all graphs are updated to show that group’s data.  I need to keep these graphs internal to our organization, so can’t use Shiny etc.; I am also unable to run R or other products on my server (company policy)." R-help 2017-04-23 from Chris Battiston


  - A proposed 'quick' solution: This could be done with crosstalk + plotly. However, that's only on the assumption that the 'interconnected' graphs deal with scatter plots/row observational data. Filters and checkboxes can be facilitated through crosstalk. The only problem is that if these graphs require displays of aggregated data (like histograms), then there might not be a viable solution.
  - You could probably do it in iPlots (but it's not made with the 'end user' in mind + not easily shareable). But you can't install software, so not an option.
  - The 'complicated' solution that's outside of R: code up all the links with D3?? (not sure if this is possible, but something like [model.js](http://bl.ocks.org/curran/f4041cac02f19ee460dfe8b709dc24e7) looks promising)

  - Using an 'interactive layer' like iPlots and Mondrian (e.g. if you have a histogram linked to a scatter plot, and you brush on the histogram, the 'interactive' layer shows what you've selected on top of the plot - might still require redraws on top? Not sure.)
    - would this be replicable with SVG/canvas?
    - Somehow need to link aggregate data with row-observational data (D3 has something called crossfilters for handling large data?)

**CANVAS/WEBGL OPTIONS:** are there higher-level javascript APIs that provide access
  to objects (as well as fast rendering) ?

[PixiJS](https://www.pixijs.com):
 [Examples](https://pixijs.github.io/examples/#/basics/basic.js)
- Could try use this to render plots??
- 2D WebGL renderer that uses canvas as a fallback (if webGL is not supported)

[Stardust:](https://stardustjs.github.io/) GPU-based Visualisation library
- webGL only
- Notation is similar to D3 where you can bind data to objects??

[Fabric.js:](http://fabricjs.com/fabric-intro-part-1)
- 'operate on objects' rather than context (...which is what the raw canvas does)
- Basic interactivity possible (mouse events, svg...)

[KineticJS:](https://github.com/ericdrowell/KineticJS/) - now no longer maintained.

[ProcessingJS:](http://processingjs.org/) -  *might not be a good choice, as its code/notation is looking kind of similar to webGL, looks more like something from scratch...*

**Other thoughts/ideas:**
Other tools for interactive data viz outside of R that are commonly used:
- Tableau (an [example](http://lenkiefer.com/2017/06/05/tableau-dash) that looks at housing data)
- D3 (an [example](http://students.brown.edu/seeing-theory/index.html) that teaches statistics and probability )

Irrelevant findings?
- The benefits of combining React + D3 - [blog post](https://medium.com/@Elijah_Meeks/interactive-applications-with-react-d3-f76f7b3ebc71)
- Visualising with Angular and D3 - [blog post](https://medium.com/@lsharir/visualizing-data-with-angular-and-d3-209dde784aeb)
- A [Data Visualisation](http://courses.cs.washington.edu/courses/cse442/17sp/) course at the University of Washington
  - This course teaches D3 and the fundamentals of visualising data (under computer science)
  - Includes web programming, design principles
  - Gets students to produce a [final project](https://cse442-17s.github.io/) (some of them look really cool) that gets assessed!

---

## Week 12 (25/05 - 01/06): More on webGL/Canvas, Wrap up trendline challenge

**Wrap up these things before you go on break for exams/tests :(**

- **Report Draft** is live for testing purposes here:
https://ysoh286.shinyapps.io/report-draft/
 (it's not complete, but surprisingly it renders all the shiny apps in one go. It does take a while to load and requires a strong internet connection ...otherwise it keeps disconnecting.)
 - I might still need to use the uni's server anyway because this is only live for 25 hours/month.

- Completed simple **DOM solution for trend line** reacting to slider!
- Advantages over Shiny: retain connection to R, you can keep adding/removing things on the page (unlike Shiny, where you have to stop the entire app and then rerun it if you change something.) You don't have to worry about the 'magic' behind Shiny (the whole concept of making things 'reactive'). It is a little faster and a lot more responsive (I'm guessing Shiny has a lot of things going on behind the scenes. They've got Bootstrap, jQuery e.t.c to make things look nicer, but you could probably add that in DOM which might make it easier to customize).

- The thing with Shiny is they tend to emphasize what can be done in R as their main audience is R users. Most of their tutorials are focused on using R. For those of us who do know web tech, what makes Shiny generic is that they do have functions available to stretch it further (but probably not commonly used).

- **Simple speed test:** there is a significant difference in speed when comparing webGL, canvas and SVG loading on the webpage

Note that this simple test is NOT a fair comparison. It's like comparing apples with oranges (especially when each of these are different in their own way). It is hard to monitor the speed from when the code is run in R to when it reaches and loads the browser (might require more expertise on the computing side to really know what's happening). Alternative would be to state from other studies that have focused on looking at this in detail.
This test simply illustrates the following: SVG < HTMLCanvas < WebGL in rendering many points with speed.

| Render Type  | 11K    | 50K    | 100K    | 500K     | 1M     |
| :----------  | :----- | :----- | :------ | :------- | :----- |
| Plotly SVG   |   2.05 | 6.40   |  11.98  |  1 min+  |   -    |
| Plotly webGL (stack.gl) |   1.65 |  1.60  |   1.75  |   3.26   | 4.00   |
| rbokeh canvas|        |  4.04+ |  -      |     -    |    -   |
| rbokeh webGL |        |  0.954 |  1.23   |   3.36   | 6.02   |
| raw webGL*    |   0.12   |   0.165  |    0.255    |    0.713      |    1.26    |  
| raw canvas** |  0.0306 | 0.0538  |  0.0726  |  0.551  |   1.03   |

\* just random points (vertices), no axes, no other libraries

** This shouldn't be less than webgl, but it's probably because I've done a simple test of plotting very small rectangles that look like points ( the webgl version may be rendering other things... hence may not be a fair comparison). BUT: what we find is that it gets a lot slower beyond 100K mark, and webGL may have the advantage on dealing with much more content.
  - These values are recorded in seconds and are the loading times recorded in the browser.
  - 11K = 11,000 points
  - '-' signifies that it took too long  (the user probably would've just given up.)
For rbokeh canvas, it's relatively slow. In theory it should be faster than SVG as it's only rendering raster images and does not take up too much memory as once its drawn something it's totally forgotten about it (whereas svg retains information).

Loading lots of data: SVG < HTML canvas < webGL

WebGL is great for visualising large datasets, but it's going to take a while to learn from scratch. Just setting up can take several lines of code.
- You could start making visualisations that go from 2D to 3D, back and forth. Transitions are more fluid.
- Because we can nest a canvas element in an svg element, we might be able to map co-ordinates of the SVG system into the webGL co-ordinate system (requires data to be sent to the GPU first).
- We can only attach event handlers (to interact with the canvas) if we nest it in an SVG.
- Downsides: SECURITY RISK? This is debatable, but some browsers actually block the use of webGL simply because of this reason. This also creates a minor browser compatibility problem (not surprisingly, IE doesn't support webGL very well).

What's really happening in **trendline challenge 3.1** ('the loess caterpillar'):
  1. When the user brushes over selected points (interaction written in JavaScript on the browser),
    the indexes of the points are sent back to R through the JavaScript function Shiny.onInputChange().
  2. R receives these indexes and we can use them to trace them back to the rows in the dataframe (We expect the indexes of the points to match up to the rows of the data frame. A limitation of this method is if we have missing data.) Then, we subset this as our selected dataset, and run through it the loess model to generate a set of x and y/fitted values.
  3. Once this is done, we use gridSVG's co-ordinate system to translate these values into SVG co-ordinates in R. After that, we can send these co-ordinates back to the browser.
  4. Once the browser receives these values, it updates the points of the line with a new set of points, which appears on the page.

This could be a general idea for using gridSVG and Shiny together along with its functions for sending data back and forth so far - the same applies to how we changed main trendline without redrawing the entire plot. Could possibly extend to more situations/challenges??

Disadvantages of doing this:
- gridSVG is relatively slow, especially when we get to over 1000 points. (Currently only preloaded svg has been tested)

... so we tried this:

**Shiny + JS + gridSVG + PNG trend line solution** for dealing with large datasets:
- Almost there! There's some incorrect mapping going on between the selection box, and the translation of co-ordinates.
- Caveats:
  - To nest an PNG inside an SVG element we use the < image > tag. However, this requires a URL of the png (ie you have to put your image up on the web somewhere/ or change the tag(not sure if ``` data:image/png base64; ``` would work )) otherwise Shiny (or DOM) can't read it (xlink:href).
  - Placing the PNG inside the svg takes a while to figure out to get it in the right place (is there a better way of putting things together using R for better 'accuracy'? (like what iNZightMaps does...))
  - Mapping situation: If the PNG is in the right place and we're using the right co-ordinate system (ie viewport for converting SVG co-ordinates back into 'native' data points), in theory everything should align...

  WHAT DIFFERS IN THIS COMPARED TO SVG:
  - Because the points are rendered as a png, we now can't return the indexes of the points. Rather, we return the co-ordinates of the bounding selection box. These get translated into data points which we can use to filter out the values that lie within the box.

- Possible other solutions to work on that might be more viable (but all require correct mapping):
    - render canvas elements inside the svg (need to match canvas co-ordinates to SVG)
    - render webGL elements inside svg

#### NOTES:
**More about webgl:**
- Notes are from [webgl fundamentals ](https://webglfundamentals.org/webgl/lessons/webgl-fundamentals.html), [Ming's WebGL tutorial](http://my2iu.blogspot.co.nz/2011/11/webgl-pre-tutorial-part-1.html), [TutorialsPoint](https://www.tutorialspoint.com/webgl/webgl_basics.htm)
- Generally used for rendering 3D plots rather than 2D (though possible)
- Idea based upon communication between CPU and GPU (send data to the GPU once and kept on there to minimize this communication, try make them work independently)
- Draws points, lines... e.t.c based upon code supplied, runs on GPU (Graphics Processing Unit)
- Code provided must be in pairs of functions (a vertex shader, fragment shader - each are written in C/C++ like -language called GLSL) [co-ordinates + colors]
  - The vertex shader computes vertex positions and reduces amount of communication between CPU and GPU. (where does it draw?)
  -  The fragment shader computes colors for each pixel drawn (how does it draw?)
- Any data must be passed through to the GPU

GPU:
- "single chip processor with ... rendering engine that can process minimum of 10 million polygons per second"
- accelerates creation of images in a frame buffer

COORDINATE SYSTEM in WEBGL:
- Operates on a 3D co-ordinate system (x,y,z - z signifies depth)
- restricted to (1,1,1) and (-1,-1,-1)
- To draw something: use vertices - these are stored in JavaScript arrays which are passed to the webgl pipeline using a 'vertex buffer'.
- Buffer: memory areas of webgl that hold data
  - Vertex buffer object: data corresponding to vertices
  - Index buffer object: data about the indices
  - Frame buffer: portion of memory to hold the scene data (contains width, height of the surface, color, depth)
- To draw 2D/3D objects - use drawArrays(), or drawElements()
  - for 3D objects, requires a mesh (to draw more than one primitive polygon)

THE NEED FOR SHADER PROGRAMS:
- This is needed so that it reduces the amount of communication between the GPU and the CPU
- These programs are used to draw these elements
- Vertex shader: called on every vertex, transforms geometry from 1 place to another
- Fragment shader: creating surfaces - runs on all pixels of every 'fragment' (fill in pixels, textures...)
  - Attributes: hold input values of vertex shader program - point vertex buffer objects per vertex data.
  - Uniforms: hold input data for vertex and fragment shaders (light position, texture co-ordinates)
  - Varyings: variables to pass from vertex -> fragment

STEPS:
- Initialize webGL environment
- Create arrays
- Create buffer objects as parameters
- Write shader programs
- Create attributes, Uniforms, transformation matrix if required

Vertices -> Vertex Shader -> Primitive Assembly -> Rasterisation -> Pixel Shader -> Frame Buffer.

DRAWBACKS:
-  A downside for webGL is a single program to render a single object can be very long (generally, there is code to set up the GL environment that has to be called before we can start using it).
- Minor issue: Browser compatibility. HTML5 Canvas and SVG are more likely to be available and accessible.
- You must know JavaScript to write in webGL
- webGL poses a security risk (however, debatable).

**Speed testing in R on plotly, rbokeh**

 These were done in R with plotly and rbokeh.
 Note that rbokeh renders as canvas elements or webgl. Plotly has the option of rendering as SVG or webgl (using stack.gl).
 Either 5 to 10 iterations were done for a different number of points.

The problem with measuring in R is that they do not record the time it takes when the widget appears on the web page.
(i.e with system.time() and microbenchmark(), we get values in microseconds, but they don't reflect the actual time it loads the widget on the browser (so it comes back saying it's done, but when we actually plot a single plot, it returns a blank page... until several seconds later). I'm guessing these functions aren't suitable as they record performances within R.)

The speeds recorded in R are roughly the same for plotly whether its webgl or SVG (0.002-0.003s). Rbokeh was slower at 0.45s, but would increase to 0.80s as the number of points increased.

I've taken the loading times (how long it takes to load on the page for the user to start interacting with it) as a measure instead.

- 11,000 points:
  - For plotly, we compared the svg and the webgl version and find that there are not much differences in time.

  - Plotly SVG: 2.09s, 2.06s, 2.11s, 1.93s, 2.41s, 1.99s, 1.92s, 1.94s, 2.14s, 2.09s
  - Plotly webGL: 1.64s, 1.43s, 1.85s, 1.41s, 1.78s, 1.48s, 1.97s
  - rbokeh canvas: ??
  - rbokeh webGL: ??

  - gridSVG is way too slow... even with 1 iteration of 10000 points takes too long in R.

  - rbokeh is relatively slower than plotly.

- 50,000 points:
  - Plotly SVG: 6.65s, 6.82s, 6.47s, 6.45s, 6.47s, 6.47s, 6.78s, 6.45s, 5.78s, 5.69s
  - Plotly webGL: 1.56s, 1.54s, 1.50s, 1.62s, 1.41s, 1.69s, 1.52s, 1.74s, 1.69s, 1.69s
  - rbokeh canvas: 4.04s, 4.01s, 4.01s, 4.06s, 4.08s (does take longer than recorded values to appear on the page.)
  - rbokeh webGL: 790ms, 949ms, 901ms, 836ms, 937ms, 1.05s, 1.12s, 990ms, 925ms, 1.04s

- 100,000 points:
  - Plotly SVG: 12.12s, 12.10s, 13.35s, 11.30s, 11.0s, 12.02s
  - Plotly webGL: 1.61s, 1.86s, 2.01s, 1.78s, 1.51s
  - rbokeh canvas: it's pretty slow as well (probably mirrors that of SVG, but it considered slightly faster than SVG)
  - rbokeh webGL: 1.13s, 1.16s, 1.24s, 1.23s, 1.37s

- 500,000 points:
  - Plotly SVG: 1 minute, and longer... (the user probably would've just given up by then)
  - Plotly webGL: 3.41s, 5.20s, 3.08s, 2.37s, 2.39s, 3.13s
  - rbokeh webGL: 3.18s, 3.59s, 3.27s, 3.24s, 3.52s, 3.34s

- 1,000,000 points:
  - Plotly webGL: 3.84s, 4.23s, 4.02s, 3.89s, 3.89s, 4.17s
  - rbokeh webGL: 5.72s, 6.19s, 5.91s, 6.12s, 5.96s, 6.23s

From this we can conclude that webGL is better at dealing with large datasets than compared to SVG. Differences can be seen even at the 50K mark, where times roughly tripled, even more so when we increase the number of points. HTML5 Canvas could be considered slightly faster than SVG, but still not as efficient as webGL.
[Tested on Google Chrome, Mac OS 10.12]

**More notes on speed with webGL and comparisons:**
- This is coherent with a [paper](http://valt.cs.tufts.edu/pdf/kee2012comparing.pdf) that compares the differences in rendering in Canvas, webGL, SVG (they've done more thorough tests!). Some notes:
  - they tested a parallel co-ordinates plot to render large amounts of data on the following: SVG, HTML5 Canvas, HTML5 Canvas with WebGL, Processing.js(a library that connects to the Processing program), KineticJS (an HTML5Canvas library)
  - They found that webGL is the best in performance and speed, however has the highest cost to the developer (a hefty 205 lines of code, in comparison to SVG which requires 29, 56 in canvas...)
  - They suggest that if performance is not an issue, use canvas rather than SVG (despite SVG being easier to implement)
  - The use of libraries don't make it any better or faster.
- Other developers have tested D3, Canvas and SVG for speed as well:
  - Peter Beshai's [examples](https://bocoup.com/blog/smoothly-animate-thousands-of-points-with-html5-canvas-and-d3) with canvas and D3 suggest that canvas alone is great for up to 10,000 points, but beyond that - webGL's a better option. (this is somewhat present in testing rbokeh's time to render in canvas.)
  - He uses regl (which is something built on top of webGL) to render  > 10,000 points [here](http://peterbeshai.com/beautifully-animate-points-with-webgl-and-regl.html).


**Tips on DOM:**
MAKE THINGS ASYNCHRONOUS!
- With RDOM.Rcall(), any requests to the browser -> ASYNC = TRUE.
- In order to use values returned by the requests to the browser - need to use a callback function.
- You can do this async + callback in sequence, but you cannot do a javascript 'callback' on the RDOM.Rcall() function.
- Know the difference between a side effect and a value for a function


## Week 10-11 (11/05 - 25/05): Quick intro to WebGL, Trendline Challenge Part 3, Report Draft v0.1

**Q: Complete the DOM solution for trendline challenge, extend by adding brushing to generate a smoother over selected points with existing tools and investigate webGL/Plotly, D3, V8.**

TRENDLINE CHALLENGE PART 3: [in progress]
Extending Shiny + gridSVG + JS
- Able to directly draw a separate trendline based upon selected points
- Reacts to the slider as well
- Currently working on making underlying plot a raster + layer svg line on top (a possible way solution for large datasets rather than getting gridSVG to produce everything).
    - managed to layer a raster in an svg, but having trouble rendering it in Shiny (it's failing to find the image.)

DOM SOLUTION:
- **UPDATE:** Fixed! The trendline now reacts to the slider... and it's more responsive than Shiny!
- Speed is still relatively quick
- You still have access to R while it's running (recall that one of the disadvantages to using Shiny is you don't have access to R when you're running your web application)

REPORT DRAFT:
- Written some of it, but it's not complete...
- Not sure if I should include a section on explaining main web technologies used (HTML, CSS, JS, SVG, Canvas, possibly webgl)
- The problem with hosting this online is Shiny - trying to find a way to host the Shiny apps that are embedded in the report.
- RPubs can host R Markdown files online, but they don't drive Shiny apps - things that require Shiny are generally just static images
- Shinyapps.io's free account only allows 5 apps to be hosted for a limited time of 25 hours
- The other alternative is to build my own Shiny server and host the apps on there and somehow link it back to an HTML page of the report (most likely will have a go at this during the mid semester break.)

WEBGL:
In brief: webGL stands for 'Web Graphics Library'. It is generally used for rendering 2D and 3D graphics on a web browser.

The main reason for using webGL with Plotly/rbokeh
is to increase performance and efficiency of rendering plots, primarily those with several data points. Other reasons include creating 'shading' and appearance effects in 3D plots.
Things are rendered inside a canvas element (a single DOM element rather than SVG, which has several DOM elements) which acts as a 'drawing' board and renders everything in pixels). This increases speed because there is only 1 single element, compared to several different elements to handle and render to the page.
You can also use canvas elements to draw objects as well.
There is a possibility of mixing the SVG + canvas together (as seen in a D3 example).

ADVANTAGES of webGL:
- Fast, efficient
- low-level

DISADVANTAGES of webGL:
- A pain to learn(a steep learning curve for those starting out?), maybe complex to implement (but rather, to save time: developers could use other javascript libraries that are built upon webGL)
- raster, not vector
- The main disadvantage appears to be a cost to the developer (takes too long?), but there are ways to combat this by using JavaScript libraries that are built upon webGl (such as three.js, stack.gl, ...) but make it easier to code.
- Because everything's written in JavaScript, and nested in one single DOM element, you may not manipulate it easily on the page (it's like anything that should be driven in that canvas, should be written there. It's like its own separate world on the webpage?)

Chris's idea taken from Mondrian:
- There's a demo from rbokeh that manages to zoom into hexbins such that when it gets to a certain point it starts rendering as points [here](http://ryanhafen.com/blog/plot-lots-of-data) - scroll down to 'Javascript callback teaser'. However, it's developmental (but it means it's possible!)

Possible ideas for extending DOM:
- A way of easily attaching external js/css files to a page (and possibly JavaScript libraries)

#### NOTES:

**Plotly parallel plot:**
- [Plotting a parallel plot in R](https://plot.ly/r/parallel-coordinates-plot/)

**WebGL**
- [WebGL - MDN](https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API) - includes a lot of tutorials + resources
- [WebGL - Khronos](https://www.khronos.org/webgl/)
- [WebGL Public Wiki page](https://www.khronos.org/webgl/wiki/Main_Page)
-  Examples and inspiration - [Chrome Experiments](https://www.chromeexperiments.com/webgl)
- "webGL (Web Graphics Library) is a JavaScript API for rendering interactive 3D/2D graphics within web browsers" - use of HTML5 canvas elements rather than SVG
- webGL is generally for 3D graphics/game development
- Support for: Firefox, Google Chrome, Opera, Safari, IE 11+
- utilises GPU rather than just the CPU alone

**Plotly + webGL:**
- [Plotly's use of webGL](https://plot.ly/r/webgl-vs-svg/) - ideally for rendering more elements on the browser (a solution for viewing large datasets?) + to increase performance and efficiency. (they compared themselves to Highcharts [here](https://plot.ly/highcharts-alternative/))
- Plotly uses something called stack.gl
- Their example of 1 million points doesn't show up very well when you zoom in + there is a slight lag. Not sure if users would be patient enough to wait... (but when you load it locally, it's fast enough.)
- webGL -> [stack.gl](http://stack.gl/)  used for scatter plots, heatmaps, and all 3D charting (other plots such as box plots, histograms ... not supported - don't need to since there render grouped elements = less!)
- Using webgl in R? there is a package called rgl!
- [Intro to rgl](https://cran.r-project.org/web/packages/rgl/vignettes/WebGL.html)

**rbokeh + webGL:**
- Generally under testing purposes?
- Once again, main reason for using webGL - testing purposes on efficiency against original svg, appearances, and trying new things with it.
- Hafen's [blog post](http://ryanhafen.com/blog/plot-lots-of-data) on using rbokeh and webgl together
- The bokeh (Python) version: [Speeding Up with webgl](http://bokeh.pydata.org/en/latest/docs/user_guide/webgl.html)

**What's the difference between canvas vs SVG vs webGL?**
- webGL provides a context for canvas elements to be drawn (in 2D).
- Difference between canvas and svg: (as explained in Chapter 16 of [Eloquent Javascript](http://eloquentjavascript.net/16_canvas.html))
  - SVG = DOM elements (focuses on shapes)
  - Canvas = single DOM element that renders a 'drawing' in a node
  - Canvas converts shapes to pixels(raster!), doesn't remember what they represent whereas SVG - shapes are preserved, moved and resized any time.
  - To draw things to the browser using webGL, you draw things within a canvas element (javascript code to draw from webgl, but it's inside a <canvas> element)
  - To move a shape on canvas: clear it and then redraw.
  - both use similar co-ordinate systems (top-left = 0,0)
- An [example](https://bl.ocks.org/starcalibre/5dc0319ed4f92c4fd9f9) of a scatterplot using SVG and canvas together using D3

**V8**
- [Introduction to V8 for R](https://cran.r-project.org/web/packages/V8/vignettes/v8_intro.html)
- [Google's V8 - original source](https://developers.google.com/v8/intro)
- [Repository](https://github.com/jeroen/V8)
- "V8 is Google's open source, high performance JavaScript engine" - essentially, a way where you can write JavaScript in R.
- It is an engine only - no window/browser window to link to
- Features: able to load JavaScript libraries, easily interchange data from R -> JS via JSON (uses jsonlite), call functions, convert objects between R and JavaScript easily, 'interactive console' that can be run in R for debugging
- Note that: DOM (Document Object Mode) objects are provided by the browser (ie Chrome, Firefox, RStudio's pane). V8 provides functions, data types, operators to be used.
- OpenCPU allows R functions to be called in JS, while V8 does the opposite
- Examples of how V8 can be used??
- [V8: JavaScript and R - Presentation by Hans Borchers](http://hwborchers.lima-city.de/Presents/V8talk.html#1)
  - Mentioned plotting libraries: plotly, rbokeh, vegalite?, googleVis
  - Javascript packages cannot be used such as npm, but you can load libraries either locally or url/CDN
  - Why would you use V8? For computation that cannot be vectorised in R + run javascript in R (of course, you need to know some javascript!).
  *Because there's no link to a DOM/web browser, not ideal for what we want to achieve. Could be helpful if we need to run javascript in R on the backend/server side, but it's likely you can achieve more faster results by sending it straight to the browser. There's a possibility to use it for converting data objects into JavaScript objects, but this can already be achieved with R package jsonlite.*

**Trendline challenge: Part 3**

- As we've seen in previous weeks (way back in Week 3), shiny can do it with base plots and ggplot2, and ggvis has got its own demo.
- Could we replicate the same thing on SVG/grid using Shiny to communicate back and forth? YES + it's much more dynamic (though, if users need a less dynamic version, might have to modify some JS).
 Possible steps:
 - write JS to select points on brushing (modify brush) - used previous code for iNZightPlots, and it runs. (what could happen is I could write a generalized version of this and it could be applied to any gridSVG plot as long as: panels and where the points lie are well defined in the plot.)
 - When selected store an array of point ids, send it back to R (using Shiny functions + JS functions)
  - somehow match point ids to data? Or convert co-ordinates back into data?
 - I've been able to send back just the indexes of the points which correspond to the data rows, provided that the gridSVG plot has plotted in ORDER of the data and that there are no missing values.
 - Another alternative to try is to convert the co-ordinates using gridSVGCoords (not sure if you could do a from/to switch)
 - Working on overlaying SVG on canvas [in progress]


**Things to think about:**
  - What if you could rethink a solution without assuming a static plot has been given?
  - Plotly can render [dropdowns](https://plot.ly/r/dropdowns/)/some basic UI controls in R without the use of Shiny - may need to revisit some of the challenges where a full javascript solution is given (somewhat standalone?).

---

## Week 7-9 (20/04 - 11/05): Expressing ideas, SVG + Shiny/DOM + JS

**Q: Reattempting the trendline challenge -  implementation of a solution that does NOT redraw the entire plot (SVG+JS+DOM/Shiny)**

**SVG+Shiny+JS:**
- Since there is a way of sending data/messages between Shiny and the browser, we can send the co-ordinates of the data from R/Shiny and update the 'points' on the trendline in JS, which only changes the trend-line.
- Can be done with iNZightPlots, but because there isn't a clear naming scheme - requires changing of tags and element names each time you re-plot.
- Things to be aware of: mapping between svg and data values, finding the correct viewport/panel. The change is much faster. Currently works on a single plot that's been defined in R before running Shiny. Takes a little long when you try produce SVG for a scatterplot with several points...

**Using DOM?:** (in progress)
- Managed to render the plot, dropdown menu.
- Still figuring out how to link 'click' to change - send data from R to browser and back and linking everything together...?
*Ask Paul how does RDOM.Rcall() work with the setAttribute() function + if you have multiple <p> tags on a page, how do you locate exactly which to assign attributes to? Why is it that when you nest an svg in a div tag and call getElementById() to find the svg, it returns 0?*

**JS + Shiny: How to communicate messages between client and server**
- You can send messages in JavaScript to Shiny and back. There's a blog post  [here](https://ryouready.wordpress.com/2013/11/20/sending-data-from-client-to-server-and-back-using-shiny/) about how you can use these functions to send messages/data back and forth.
  - JavaScript functions: Shiny.onInputChange() - used to send data from client(JS) to server(Shiny/R), Shiny.addCustomMessageHandler() - used to receive data from Shiny to JS
  - Shiny functions (use of an observer): session$sendCustomMessage(), observe(), observeEvent() - used to send data from Shiny to JS

- You can also write JavaScript in the UI component in Shiny since it's an HTML page, it's the same as writing between < script > tags using tags$script(), or using includeScripts() to link to external scripts
- (in progress) Can I incorporate my code from last summer into an iNZightPlot that's linked to Shiny?


**Q: Think about how you'd like to express a solution to the three challenges without thinking about existing tools (can be in pseudo-code, concepts, diagrams...)**

How would you develop your version to achieve interactivity?

- MAIN IDEA: Since there are many existing packages that produce static plots in R already, build upon one of these packages to incorporate interactivity in (or make a separate package specifically for adding events/interaction in).

- Assumption: a static plot with no interactivity attached is provided.

WHAT WOULD BE HELPFUL?
- different functions for plotting, different functions for adding/removing interactivity
- A function that shows which R objects correspond to which JavaScript/SVG elements/DOM objects (so for example, like how grid has grid.ls() and iPlots has iobj.list(), be able generate a list of R objects with their corresponding JavaScript ids/object labels). For the user the R-object list would be useful, for developers that want to add customised interactions via JavaScript, they'd know which objects to call. There could be a possibility of writing JavaScript in R directly (something like what onRender() from the htmlwidgets package does, and Shiny's JavaScript functions.))
- Something that allows easy mapping and interchange between data and pixel co-ordinates
- Differentiation between objects (points, lines, axes, titles...) that make up the plot, additional objects as layers (objects that make up a layer), and the entire plot itself (layers that make up a plot), so that interactivity can be customised in different ways

- Some of these things are already present in the gridSVG package. There is a naming structure between grid objects and SVG elements generated, and there are functions + XML package that allow mappings/elements to be retrieved in both JS and R.

*Most of these ideas are very similar to what existing tools might have already - such as combining iPlots/grid's ability to be able to return, add and remove ids and objects easily, event types from htmlwidgets that we've been looking at (specifically Plotly, crosstalk), and my basic knowledge of attaching simple interactions to SVG/DOM elements.*

OTHER THINGS...
- Would we want to include ui inputs (like sliders, filters, e.t.c) like what Shiny does that automatically links everything together? Or should we make something that focuses on on-plot/linking interactions?
(One way would be to make an HTMLwidget that's compatible with Shiny.)
- An easy approach to customise interactivity, but also achieve complexity (a possible stretch to producing animations on plots)
- Something that can suggest suitable interaction between different plots (might be too complex)??
- Could extend to simple DOM elements other than plots
- SVG with big datasets: would need to aggregate data + create interactions that scale accordingly (zooming)
- Possibility of storing data within the svg element tags to make mapping and attaching interactivity easier(?)
- Could you add and remove interactivity WITHOUT refreshing the entire browser/or need to rerun code to make the entire plot from scratch?

**Boxplots:**
- If the box plot was built in layers: have functions that allow user to - link layers together, add layers, remove layers easily.

- Imaginary pseudo-code:

```

boxplot(x, name.id)
add_dotplot(x, align = l/r, share.axes = TRUE, id = )
add_highlight(box, dot, range = c(boxMin, boxMed), event.type = c("hover", "click"), color = "red")

#possible functions for plot layer control
link_layers(box, dot,...)
remove_layers(layer.name)
add_layers(layer.name)

```

- construct the box plot (already exists), name/id would allow an id group for the entire box plot.  
- Inside the boxplot constructed by 2 boxes (rect/polygon elements which are id as upperBox and lowerBox) and lines (line/polygon elements - minLine, maxLine) - to refer to a certain part: name.upperBox
- plot object would have generated some accessible data such as minimum, maximum, median, LQ and UQ values
- if dotplot() is to be plotted on the same axes (or simply, we could have one function but have argument 'share_axes' to determine linking and plotting) - by default it could be false.
- If existing packages don't have this feature, then we could build a function that allows linking of layers(?)
- alignment based upon the position of the last plotted object (in this case the boxplot)
- layers could be automatically linked as they share the same axes (layers are simply groups of plot objects)
- There would need to be a distinction between removing layers and individual objects (such as points) in a plot. You could remove more than 1 layer at once.
- add_highlight() - box = refers to box layer, dot = dot layer
- if we get more complex with different no. of boxplots: could specify an id of a specific box in relation to its dotplot.
- range = range to be highlighted or marked. Another way would be to specify javascript object (so in this case, lowerBox) ('range' might not be a good word to describe this? interval?)
- event.type = click, hover, double click... etc. You could attach more than one event.


**Trendlines:**
- Want something allows easy adding/removing of trendlines
- Imaginary pseudo-code:

```
scatterplot(x, y, data = , group.id)
add_trendline(modelFit, formula, model.type, id, ...)
remove_trendline(id)

#functions where you could add interactivity:
update_trendline(id, modelFit, formula, model.type,...)
show_labels(trendline.id, label = , event.type = "hover", ...)

```
- the functions scatterplot(), add_trendline(), remove_trendline() mirrors some of that in iPlots/grid where we can easily add/remove objects to a plot  by simply referring to an id that the user has assigned
-  in existing tools: either make a function that does all the modelling for you (too limited at times), or leave it up to the user to define their own model (more generic).
- add_trendline(modelFit, formula, model.type, id, ...) - ... could include graphical parameters such as color, stroke width, e.t.c - this is more of a static plot function
- to update trendlines: update_trendline(id = , modelFit, formula, model.type...)
With this, you could add in interactivity by attaching events and controlling what information is attached to the line (R^2 value, model fit, equation, ...e.t.c)
- to add interactivity: additional arguments could be introduced, such as event.type
- show_labels(trendline.id, label = , event.type = "hover", ...)


**Array of plots:**
```
##somehow construct each plot separately, and then rearrange it in an array.

arrange_plotMatrix(plot1, plot2, plot3..., nrows = , ncols = , group.id = plotMatrix)
link_plotMatrix(groupid = plotMatrix)
view_plot(plotid = plotMatrix)

#Additional functions that could help:
#to detach links from plots in a plot matrix:
detach_link(plotid, groupid)

#remove plots:
remove_plot(plotid, groupid)

#To customise linking between certain plots:
link_plots(plot1, plot2,...)

```
- for static plots, there's the option of either creating separate plots and arranging them into a matrix, or there's a function that constructs facet plots/scatterplot matrix/trellis display for you
- May be able to detach plots in the matrix and their link if interactivity is attached.
- link_plotMatrix(groupid) - a little vague, but does automatic linking between plots.
What could happen is it could render the plots in 'panels', where each panel can
be moved around and viewed separately as well as together.
- view_plot() can be used to view a single plot in its own panel (or be able to zoom into one of the panels), but still has the links between the plot and the plot matrix. To detach the plot, use detach_link().
- The challenge of expressing links between different plots (what would you use for something with a bar plot and a scatterplot? Find a way to aggregate data first before querying??)

#### NOTES:

Extra notes from previous meeting:
- "What is the use of all this??" - all of these tools are great and they do things, but are they of any use to anyone?
- Ideally, if I do get round to making something in the future: aim for something that users would want to use and meets their needs (such as for teaching, or for trying to explain something in more detail)
- Things that got left behind that were good interactive tools: Mondrian, iPlots (Java) - why did they get left behind and Shiny/RStudio's successful?    
  - MODERN USER INTERFACE  
  - Using the web as the playground
  - Installation problem solved
  - accessible and sharable to all (via a web server)
- What do they achieve that these web tools/HTMLwidgets don't (without combining)?
  - Linked brushing
  - Zooming in (general purpose)
  - Able to facilitate and handle LARGE datasets
  - Share the same data on different plots (not just scatter plots only - but histograms, bar plots, box plots...)
  - Query selection (subset points)
- Possible ideas: zooming into hexplots and grid bins  - get to a certain point it becomes scatter points and you can visualise it
- Successful visualisations that have large/big datasets - Google Maps (renders as 'tiles')
- Why do people use interactive visualisations rather than static?
  - Data exploration
  - "It looks cool" (not really a valid reason, but it gets people to look)
  - Educational purposes
- Could you get something like iPlots working in a web browser (with multiple panels - like TrelliscopeJS)

**Challenge summary (Boxplot, Trendlines, Arrays):**
- Shiny is great for anything that requires statistical computation (such as trendlines) as you've got a link back to R, and for building a modernized UI (Bootstrap  + HTML).
- Crosstalk is great for linking plots together, but only present for Plotly and scatterplots. Instead, iPlots has an upperhand with linking capabilities that extend to different kinds of plots.
- Plotly, rbokeh, highcharts, ggvis are good for incorporating 'basic' interactivity within the plot (especially when it comes to just a single plot - gives you basic information about that plot, points, zoom in, selection, basic stats...etc). It's more about making an 'easy' visual rather than using interactivity to find out more information and gaining more insight. (ie A selection done on the plot doesn't give you any information about it - does it have outliers? looking at the selected group as a whole? - couple it with Shiny and you're likely to get a lot further.) iPlots could get you further in terms of being able to return selections of plots.
- It's hard to customise your own on-plot/in-plot interactions in (as found from the boxplot challenge) as most functions have a set event attached to them (or simply: you plug in data (generally in JSON format), and it just gives you a standard plot). These functions were designed to make plotting easy for the user without having to learn web technologies (HTML, CSS, JavaScript). As these JS libraries were originally built for a different program (such as JavaScript, Python, e.t.c), features may be limited (+ possible limitations of the creating an HTMLwidget package, if any).
- Simple javascript solutions work well with on-plot interactions that do not require updating. This becomes a challenge when we try to devise a solution that requires updating of co-ordinates (such as manually changing the shape of a trendline), whereas these are easily achieved with Shiny but requires repeated rendering of the entire plot.
- The approach during these challenges was to: find out which tool does what best, and then find a way to combine them. In some cases it worked well (as seen in the array challenge), other times it was hopeless (boxplot challenge) simply because the tools didn't have the capability or required more expertise and investigation.

*(I do think it's taking me longer to try understand the Plotly API than trying to write my own solution for the boxplot challenge... but will keep it at the back of my mind if I ever do come back to it.)*

**Alternatives to dealing with large datasets to be rendered on the browser:**
- Unfortunately, SVG and DOM cannot handle large datasets well - speed starts to crawl.
- Kruger's [performance](http://tommykrueger.com/projects/d3tests/performance-test.php) test example shows this problem (and it could eventually make your browser crash/freeze)
- Use of canvas instead of SVG
- Aggregate data first, then scale down when it gets finer (hex bins and grid squares to points))

**Learning more about Shiny + JS:**
- can we be in JS directing Shiny and getting prompts from Shiny ??
- Shiny apps are designed for the end user, to share and explore findings in data
- Prompting JavaScript? You can write JavaScript in R into Shiny apps in the UI section. This is because you should view the UI written in Shiny as an HTML page (which it is, as when you run fluidPage(), fluidRow() functions separately, they generate pages of HTML code with <div> tags to separate each component that the user has defined.)
- Some ways to incorporate JS into Shiny are highlighted [here](https://ryouready.wordpress.com/2013/11/20/sending-data-from-client-to-server-and-back-using-shiny/).
*This blog post has been referred to in the Shiny repository.*
- You can send messages/data between Shiny/server and JS/client.
- Functions: Shiny.onInputChange(), Shiny.addCustomMessageHandler()
- session$sendCustomMessage(), observe()
- Use of an observer:
- More complex examples for reference: Chang's demo test apps

**DOM package:** (in progress)
- Paul's DOM package allows communication between R and the web browser.
- Reports [v0.3](https://www.stat.auckland.ac.nz/~paul/Reports/DOM/v0.3/DOM-v0.3.html)
- Alot more low-level and flexible than compared to Shiny

- What is greasemonkey?
 - trivia: an informal word for 'mechanic'
 - a Mozilla Firefox extension that allows you to customise a web page using JS via a user script.
 - [Add-on to Firefox](https://addons.mozilla.org/en-US/firefox/addon/greasemonkey/)

- ADVANTAGES: You can throw things on a page, and remove things on the page without having to rerender/refresh the page...

- DISADVANTAGES: Currently under development, several limitations listed [here](https://www.stat.auckland.ac.nz/~paul/Reports/DOM/Intro/DOM-Intro.html)
  - Installation might not be as straightforward (for standalone HTML, might be fine but for when you want to send things back and forth from R  <-> browser - requires greasemonkey + FireFox)
  - You can only run 1 page at a time.


- COMPARISON to Shiny:
  - Shiny has the advantage of being 'simplistic' to the user without introducing the web technologies behind it (you can actually get a little further with basic knowledge of CSS/HTML/JS), whereas DOM has got the advantage of being more flexible, but requires knowledge in these web technologies.
  - Shiny can get complex in terms of dealing with its 'reactive' nature that appears to do 'magic'. Sometimes this is unwarranted for (especially when it just throws a bunch of errors at you and you have no idea why it runs fine in R, but not in Shiny...). Sometimes you don't want it to be reactive (like the trendline challenge).
  - If you hate the bootstrap look: you can customise how things look in DOM.
  - htmlPage(): Looking a little similar (externally) to what Shiny's doing with rendering UI in its UI component...

  *Questions:
  - Can you link external CSS/JS files in without having to set attributes for each element?
  - Are the only things you can return in the RDom.Rcall() function things related to elt/css from the browser?*

```
Shiny notation for a paragraph:
tags$p('Hello World') ---> <p> "Hello World" </p>
        HTML("<p> Hello World </p>")

DOM package notation:
htmlPage("<p> Hello World </p>")
```


**Trendline Challenge Part II: SVG + Shiny/DOM + JS**
- Managed to render an svg plot in Shiny simply just using the UI component (instead of viewing it as inputs and outputs), however it's only a static svg and is updated as an entire object (same output generated as using renderPlot()).
- There could be a possibility that this might be slower than trying to actually 'redraw' the plot because you're reproducing the svg output every time (might not make much of a difference? Not sure).
- The idea (was) to produce a simple SVG plot using grid and gridSVG, separate the plot into svg components such as points, a trend line, legend (if there is one), axes as separate UI components.
- Problems: trying to separate the components of the svg. There are nesting <g> elements that represent each viewport. Even if you could separate it, it doesn't help as Shiny will need to reproduce all the svg output again (which essentially re-renders the entire plot).
- Instead: send model fitting co-ordinates from R through Shiny to the client(JavaScript) using an observer/handlers, then use exported mappings/functions generated from gridSVG to convert to SVG co-ordinates in JavaScript or in R, then modify.
- Successful! See the lattice plot example under *code >> svg-to-shiny.R*
- Limitations/thoughts: currently works with the plot pre-defined in R, how accurate is gridSVG in translating co-ordinates(?), works best when you've got a plot with a consistent naming scheme (for panels + locating elements)

- DOM version: (in progress)
  - Managed to render plot, dropdowns on the page
  - Still figuring out how to link everything together....


**More about HTMLWidgets:**
- [HTMLWidgets for R](http://www.htmlwidgets.org/)
- [Vignettes - Development Intro](https://cran.r-project.org/web/packages/htmlwidgets/vignettes/develop_intro.html)
- A pretty fun introduction to HTMLWidgets by YiHui Xie, RStudio

- "the 'HTMLWidgets' package provides a framework for creating R bindings to JavaScript libraries" - this is used by developers to make their package
- Varying degree of difficulty (depends how much you would like to do...)
- An HTMLWidget is essentially an R package in itself
- Consists of 3 components - dependencies (JS library/CSS you're depending on), R bindings (functions that end users (R users) call to provide input data in), JS bindings (JS that passes data and options from R binding to JS library)

- ADVANTAGES:
  - Simple and straightforward for R users to easily generate visualisations using specific JavaScript libraries
  - Able to be used in all of RStudio's other works - such as RMarkdown reports, Shiny apps, FlexDashboard
  - Can be saved as standalone web pages, makes sharing easy

- DISADVANTAGES??

*I think I might find this out if I manage to develop one...
What's the limit for translating data from R to JSON and back?*

- Designed to streamline and make the process easier of having to deal with HTML, CSS, JavaScript together in R.
- There could be a potential to make one of these for iNZight rather than using the current process (which involves: export iNZightPlot from R as an SVG using gridSVG, convert data to JSON, find out which elements to attach events to, use xtable to produce an HTML table, write custom javascript/jQuery and CSS, and put it altogether on an HTML page.)

**Mondrian:**
- [Main page](http://www.theusrus.de/Mondrian/)
- A possible reading to look into:  Interactive Graphics for Data Analysis
- Another kind of software that uses JAVA programming
- Looking very similar to iPlots (Mondrian doesn't require coding, but is rather catered for the end user.)
- Supports features such as brushing, linking plots together, querying and visualisation of large datasets
- Possible to import R dataframes for analysis

The interesting part is HOW does Mondrian and iPlots manage to do linking so 'effortlessly', and can that be translated onto the web? - might be too hard to tell from source code (unfortunately, I don't know Java.)
Could we find tools that do similar things?
- Martin Theus' [home page](http://www.theusrus.de/Homepage_of_Martin_Theus.html)
  - His talk on interactive graphics in [2006](http://www.theusrus.de/Talks/Talks/IGfS.pdf)
  - His talk slides on Mondrian in [2008](http://www.theusrus.de/Talks/Talks/Mondrian.pdf)
  - [More talks slides](http://www.theusrus.de/Talks/)
  - Might investigate this more to see if we could make similar in JS/for the web?
- Linking a scatterplot to a bar plot [Demo](http://bl.ocks.org/curran/f4041cac02f19ee460dfe8b709dc24e7)
  - this uses model.js, which is a 'reactive model library used for data visualisation'
  - ^easily achievable in Shiny

**ggplot2 + ggiraph:**
- Quick introduction to [ggiraph](https://davidgohel.github.io/ggiraph/articles/an_introduction.html)
- [Github repository](https://github.com/davidgohel/ggiraph)
- [Main page](http://davidgohel.github.io/ggiraph/)
- [CRAN documentation](https://cran.r-project.org/web/packages/ggiraph/index.html)
- The ggiraph package is designed to make ggplot2 interactive, and is an htmlwidget.
- extends ggplot2 with interactive functions
- has the following features: tooltips (hovers + labels),  onclick (JS function whenever click occurs on an element), data_id (for use with Shiny)
- Simplistic, has 'basic' interactivity covered - similar to the other htmlwidgets we've been looking at
- Plotly has more features with ggplotly() covered
- How it works: you build upon a ggplot by adding interactive functions under ggiraph, and pass it through the ggiraph() function.

```
# a simple ggplot (scatterplot):
g <- ggplot(iris, aes(x = Petal.Width, y = Petal.Length, color = Species)) + geom_point()

# add tooltips:
g_int <- g + geom_point_interactive(aes(tooltip = Species), size = 2)

#render:
ggiraph(code = print(g_int), width = 0.7)

```

- Currently looking at source code to see how they've managed to render the ggplot into SVG. (looks like they used D3 to render the plot + additional JS to pass data through from R -> JS).
- *I had a look at this to see how others have incorporated 'interactivity' on an originally static R plot. ggplot is built upon grid, similarly iNZightPlots is built upon grid.*
- Are there any other packages out there that take a plot package originally for static plotting in R and have made them interactive on the web?

**Other ideas/inspiration...**
- Build a web app which runs on React?
- Grid panels!
- Mike Bostock's introduction to D3.express which uses reactive programming on [Medium](https://medium.com/@mbostock/a-better-way-to-code-2b1d2876a3a0)
- Time series [zoom](https://bl.ocks.org/jroetman/9b4c0599a4996edef0ab) - D3

**On the to-read list:**
- [iPlots eXtreme - Simon Urbanek](https://link.springer.com/article/10.1007/s00180-011-0240-x)
- Interactive Graphics for Data Analysis
- GOLD (Graphics of Large Datasets) - Antony Unwin, Martin Theus, Heike Hofmann

---

## Week 5 & 6 (06/04- 20/04): Challenges

**Q: Do the following challenges.**

*- Attempt to recreate the boxplot challenge using Plotly, ggvis, Shiny/Crosstalk*

*- Recreate the trendline challenge with Plotly, ggvis, Shiny/Crosstalk, iplots*

*- Array of plots challenge*

**Trendline challenge:**
- Easily achievable using Plotly + Shiny (or anything with Shiny) - however you still face the problem of re-rendering the entire plot.
- Plotly itself does not have statistical curves or statistical functions to compute model fitting for trendlines (not designed to).
- An even easier approach is using ggplotly(), which makes it simple using ggplot2 through stat_smooth()/geom_smooth() (ggvis is in a sense trying to achieve this via layer_model_predictions(), where it does everything for you)
- Done with iNZightPlots + Shiny (just some simple trendline fitting - already established in iNZight Lite)
- Not possible with crosstalk due to its limitations.
- Can be done with iPlots (you can easily remove and add trendlines to a plot, done through code, not a UI.)
- Possible Javascript solutions? Could easily add/remove trendlines that are already on the plot (but hidden to the user), however that limits if the user wishes to change the trendline in a way where it will shift (such as a different formula, its shape, degree of polynomial, family distribution).

**Boxplot challenge:**
- This seems 'impossible' with plotly - not a reliable method (selecting over a box by eye).
- It also seems impossible for ggvis  - hard to add/remove layers, and only allows very basic interactions. You could use brushing on it, but that's not reliable either.
- Tried using a filter_slider with this, however you cannot define the points along the slider (so for example, if I wanted a slider that has tick points at it's minimum, maximum, median, LQ and UQ, it's not possible because the argument 'step' only takes in 1 value).
- In terms of using plotly.JS alone, it is possible, but not designed to (the boxplot itself is defined as a single object, drawn by a single SVG path rather than individual lines/rectangles??) - I still haven't found if Plotly has a way of identifying objects easily. (currently still trying to learn what's what in their API.) - using onRender() in R makes it possible to write javascript from R, but the problem I'm facing is identifying which element exactly corresponds to the boxplot + points in order to attach events to them.
- Surprisingly, this was the harder challenge of the 3. Any more ideas on how I could stretch this one??


**Array of plots challenge:**
- A possible solution? Works on Shiny + d3scatter + crosstalk. Use crosstalk to do the linking between plots, and then shiny to facilitate the zooming in by using a modal. The problem is you'd have to specify a modal button for every single plot, and Shiny doesn't have capabilities of 'clicking' on an output plot.
- Works on Shiny + Plotly + crosstalk in the same way, but to link all plots together, use the subplot() function to create the scatterplot matrix.
- Using ggpairs to generate the scatterplot matrix + ggplotly has crosstalk embedded in easily links the matrix together, however because the entire plot is rendered as a single plot, hard to zoom into/ extract out a single plot.
- You could possibly do it with Shiny alone (but you have to co-ordinate links to every single plot)
- Managed to do bits of linking with ggvis + Shiny, running into a little trouble trying to make it visible in a modal (since rendering ggvis is slightly different to the usual 'renderOutput()' functions).
- ggvis plots don't appear to scale to Bootstrap framework.
- When you select a plot to view in the modal, it does not link up to selection if brushing has been done on the scatterplot matrix.
- Can be done with iPlots - draw each individual scatterplot, and they are all automatically linked. If you need to zoom in on a single plot, just increase the size.
- This might be complex to build from scratch for iNZight (especially the linking - probably would start small with linked brushing and then expand).
- Ideas for popping into a new window (could be investigated further if needed) - could be done manually where you construct your own HTML page and nest each plot in a < div > tag, but probably requires a lot more work. It might be hard to link up the plot if it were to be opened in a new page/window (not sure).

**Ideas and problems to investigate:**
- How much 'math/stats' can JavaScript handle and would it be a good idea to make use of it (to create standalone plots), or let R do all the computation (and somehow link the two to drive a change in a trendline - in this case linked and not standalone, like Shiny - but avoid redraws). - get it talking to each other.
- Ways to get R -> Browser + JS, JS -> R (look at the DOM package?)
- A possible idea: Turn iNZightPlots into an HTMLWidget (maybe using previous code + alot of 'restructuring') to facilitate in-plot interactions on iNZight Lite? - a bit of 'backwards logic'. Is the only way to incorporate JavaScript into a Shiny app is to turn something into an HTMLwidget?

**Another possible reason why it may be hard to prevent re-rendering of plots:**
- (Not sure if this can be considered an underlying problem?) In all cases of using plotly, ggvis, or even ggplot2, even though the plots generated are 'layers', it does not appear possible to isolate a single 'layer' and modify it without drawing the entire plot again. (Sometimes when we try to run a single 'layer', it draws an entirely different plot... which is not what we want, or complains an error.)
You can add on layers, but you always have to refer back to the plot (either through %>%, or storing the plot as a variable). Regardless, Shiny will always(?) manage to rerender the entire plot.

**A few minor mistakes + issues addressed (Week 5):**
- event_data("plotly_selected") does indeed return a dataframe, NOT a LIST - output that was printed when trying on other plots was "list()".

- curveNumber can get a little complex when it comes to dealing with more complex facetted plots, but it is a group id for each subset for each plot (verified by a more complex ggplotly example added in Week 4).

- How Plotly interacts with crosstalk: under filtering it redraws the Plotly entire graph, while under selection - it appears to only update 'traces' (styles of points), which may explain why selection appears much faster than compared to filtering.

#### NOTES:
- Summary Tables:  Just to recap what I've learnt so far in the past month.

*UPDATE: These have been moved to a separate file called 'summary-tables.md' found in this repository... they were getting too long.*

**A bit more on ggvis and its interactivity:**
- Been watching Winston Chang's presentation about ggvis from the useR conference in 2014. [Youtube link](https://www.youtube.com/watch?v=wYafq7hYWcg)

Some notes from this presentation are recorded below:
- Interactivity is driven by Shiny: "functional reactive programming,  a reactive can use a  value from another reactive - creating a dependency of reactives which persist. When something changes, everything that's dependent on it changes (recompute)."
- Vega.js is doing the rendering - either as SVG, or HTML canvas, NO R graphics AT ALL.
- ggplot is fundamentally different from ggvis
- Bidirectional links: have to be careful how you setup the reactives carefully.
- Large datasets? - in browser rendering done by JavaScript, can get sluggish when interacting when you've got lots of points. (If you're dealing with large data -> do computation in R first, then scale. They intend to change to using C to do computation as it's alot faster than R. )
- may not work on early version of R due to package dependencies

Other things to note:
- So apparently ggvis does not redraw the entire plot when you update data?
- Link to a [stackoverflow](http://stackoverflow.com/questions/25011544/how-is-data-passed-from-reactive-shiny-expression-to-ggvis-plot/25060999#25060999) comment
- Might look into it just to make sure...  

**Fast search: Crosstalk + Plotly + Shiny**

Here are some working demo examples that use crosstalk, plotly and shiny together (found in the Plotly repository):

- [Basic demo app](https://github.com/ropensci/plotly/blob/51e159ba825b007657c1d7534825ef25afc7e7af/demo/shiny/basic/app.R)
- [Using DT](https://github.com/ropensci/plotly/blob/51e159ba825b007657c1d7534825ef25afc7e7af/demo/shiny/DT/app.R)


A few notes about crosstalk from Joe Cheng's presentation at the useR Conference 2016: [Youtube link](https://www.youtube.com/watch?v=IiRYmAGMtdo)
- Crosstalk is designed to be a solution for co-ordinating multiple views of the same data (something along the lines of GGobi, cranvas - but on the web)
- Achieved by linking originally separate HTML widgets together using a shared dataset
- Specific and has several limitations (summarised in the table above)
- When you need to co-ordinate multiple views with Shiny, it's alot more complex (requires more thought + code in R), crosstalk allows it to be done easily and conveniently
- Why would you use Shiny and crosstalk at the same time? When you need to co-ordinate views with a histogram, or aggregated data (able to read shared objects) - Shiny can be used to remove the limitations that crosstalk currently faces

- Crosstalk acts like a 'messenger' - when the user selects/filters something, crosstalk gets that signal and communicates which objects have been selected (linked together by 'keys') to the javascript library(ies) - then the library decides how to render the selection/filter on the page.


**Investigating crosstalk + Plotly in more detail:**
- Crosstalk only supports filtering and selection
- After digging through and looking for more source code: FINALLY FOUND THIS (though, still making sense of it), which may explain how the filtering and selection works on Plotly with crosstalk:
[plotly.js via HTMLwidgets](https://github.com/ropensci/plotly/blob/08fe476068da4f5925c5cb696cf07c221d2c6942/inst/htmlwidgets/plotly.js)
- At line 476, it suggests that Plotly redraws under filtering
- At line 484 - function TraceManager.prototype.updateSelection suggests that it may be just changing the styling of key objects rather than redrawing the whole plot under selection...?
- This may explain why it's so much faster than Shiny at selection and linked brushing (because you don't have to redraw things EVERY single time - it's just changing styles...)
- Still uncertain if these are really the correct functions that are driving crosstalk-plotly behaviour/interactions.
- Confirmed!
*Plotly.redraw() does indeed rerender the entire plot, but they're working on maybe trying to prevent it via selection logic.*
- Is it possible to customise or add on plot interactions into Plotly graphs, and if so - how can this be achieved?
*It is possible - need to learn Plotly's API + read on how to plug in custom JS for this.*
- Not sure how long this could take, but will give it a go anyway!
- Alot of issues of expanding interactivity for plotly are discussed under their Github repository. Here's all their ideas for [cross-filtering](https://github.com/plotly/plotly.js/issues/1316) that's appearing as a work in progress (might be helpful to know if I'm going to end up building something)

**Plotly's API - PlotlyJS:**
 - Understanding the API and how a Plotly graph is assembled may be beneficial in testing whether we can add custom javascript interactions easily to certain elements.
 - Alot more can be achieved using Plotly.JS straight off (where some features that are not available through R can be done through here - but of course, it's not as straightforward).
 - Plotly for R makes it really easy to make plotly graphs with just from a line of code or two, whereas when we use Plotly.JS directly we need to assemble the data in JSON format (to which plotly in R does seemlessly via htmlwidgets, which converts data into JSON using the jsonlite package.)
 - (Here's an [example](https://moderndata.plot.ly/regression-diagnostic-plots-using-r-and-plotly/) making residual and scale location plots from Plotly and R.)

**iPlots:**
- [iPlots page](http://rosuda.org/software/iPlots/)
- interactive graphs in R using Java (run through JGR)
- features: querying, highlighting, color brushing, changing parameters
- *Does it redraw?*
- Possible to add things to a plot via its API?
- functions for different graphs: imosaic(), ibar(),ipcp() (parallel plots), ibox(), ilines(), ihist()... e.t.c
- It's a little old, but it's pretty great at linking, brushing
- Downsides: uses Java and JGR (installation was a bit of a hiccup), plots look kind of outdated, no way of connecting plots to the web (native solution!)
- Similarity to grid/base plots: use of 'objects', object lists, and you can easily remove and add plot objects
- In comparison to all the other packages we've been looking at - it's not available to view on a web browser.
- Short learning curve (~1 hour or so to learn basic plotting and interactive functions)
- Use of keyboard shortcuts and mouse keys for some interactive features

**rggobi?:**
- Got a bit curious just to see what it was as it was briefly mentioned by Cheng during his *crosstalk presentation*
- 'open source statistical software tool for interactive data visualisation'
- rggobi is the r interface to GGobi
- Fairly old technology, 2008.
- features: linking, brushing, identifying points on multiple graphs
- Native software - might look into it in the future if it's of use.
- Resources:
  - [CRAN documentation](https://cran.r-project.org/web/packages/rggobi/rggobi.pdf)
  - [rggobi Introduction](http://www.ggobi.org/rggobi/introduction.pdf)

**Co-ordinating multiple views using Shiny**
- Most of this [video](https://www.rstudio.com/resources/videos/coordinated-multiple-views-linked-brushing/) by Winston Chang was introducing interactivity that Shiny can do on baseplots and ggplot2 (what we investigated in week 3). Useful to look back to for how to achieve linked brushing using Shiny.

**Trelliscope package and trelliscopeJS:**
- Looked into this as it was mentioned on the *'Navigating Many Views'* section in *Plotly for R*
- Developed by Ryan Hafen, who also developed rbokeh.
- Designed to explore trellis displays/facetting and large data sets in detail.
- Has its own interface (trelliscope = native version, trelliscopeJS allows viewing on the web and sharing as it is an HTMLwidget built upon javascript library called trelliscopejs-lib)
- Alot of complex features! (might take quite a bit of time to grasp how to use it as well...)
- Appears to have capabilities of zooming into a plot, but no linking(?) (may need to confirm this)
- Good example to learn from for if you really want to develop something with trellis graphics in detail for what kind of interactions and things that users might be looking for (It's a bit beyond me to code up an example at the moment...)
- A possible way of visualising lots of data at once
- Resources to look at in more detail:
  - [Trelliscope tutorial](http://deltarho.org/docs-trelliscope/#introduction)
  - [TrelliscopeJStutorial](https://hafen.github.io/trelliscopejs/#facet_trelliscope)
  - [Quickstarts?](http://deltarho.org/quickstart.html)
  - [CRAN documentation for trelliscope](https://cran.r-project.org/web/packages/trelliscope/trelliscope.pdf)
  - [Trelliscope Introduction Video](https://www.youtube.com/watch?v=0u9G7XGUVXI)
- Example demos:
  - [Gapminder with Plotly](http://hafen.github.io/trelliscopejs-demo/gapminder_plotly/)
  - A different use for trelliscope that's not statistical in any way - [Pokedex](http://hafen.github.io/trelliscopejs-demo/pokemon/)

**JavaScript + Shiny:**
- JavaScript tutorial on the Shiny website (this is more of a 'how to make an HTMLwidget' tutorial in order to use Shiny) - [JS Tutorials for making an HTMLWidget to use in Shiny](https://shiny.rstudio.com/tutorial/js-lesson1/)
- RStudio appears to suggest that in order to incorporate JavaScript into Shiny apps, the solution (?) to make your own HTMLWidget. An HTMLWidget takes an existing JavaScript library and makes 'bindings' to R so that people can use that library through the R interface.
- Comparing iNZightPlots to Plotly, rbokeh, ggvis: In all these cases we've been looking at - a JavaScript library is used to render the plot (which includes interactivity), whereas in iNZightPlots, we have R doing all the rendering but we're trying to attach interactions to it. Whether making an HTMLWidget would help? (a possible route would be to do something like what Plotly does with ggplot2: get a ggplot2 graph and then render it as a Plotly graph.)
- In this case, might be possible to prevent redraws through interacting manually with JavaScript.
- A possible idea: Turn previous project code (with alot of cleaning/restructuring... + new add-on functions for interactivity) into an HTMLWidget, to facilitate interactions into Shiny
- Essentially (because they're all made by RStudio) - Shiny complements HTMLWidgets ('wrapping' JavaScript libraries for R users) well.
-  Ways to try 'track progress on Shiny apps, manipulate inputs/outputs'  [Javascript Events in Shiny](https://shiny.rstudio.com/articles/js-events.html)
- Taking a look at [shinyJS](https://github.com/daattali/shinyjs/blob/master/README.md) - might be useful in the future.

#### CHALLENGES

**Boxplot challenge:** *code >> boxplot-challenge.R*
- Easily achievable with iNZight/gridSVG/custom JS (though, a possible future problem is the ease of matching the correct elements to interactions if there are lots of elements on the page)
- Trying to attempt it with Shiny + filter sliders.
- Would be possible for any javascript library as long as you know the elements to manipulate (ie. the boxplot and the points) - but the problem is knowing which elements to manipulate, which may require some background knowledge on the  javascript library itself.
- Not possible in R interfaces of plotly (though: it could be possible if you know the elements to manipulate, you can add javascript code by using the onRender() function)
- May not be possible in ggvis, as you can't appear to 'link' layers together (in a sense, each layers is treated separately, and hard to add/remove layers). Limited to basic interactivity (as stated on their page).
- Shiny does not facilitate in-plot interactions (mostly driven by Javascript)!


**Trendline challenge:** *code >>  trendline-challenge.R or trendline-challenge.Rmd*
- When you're coupling it with Shiny - it seems everything's doable (in an R sense).
- Main advantages of using Shiny becomes much clearer in the sense where you have access to R to do statistical computation (such as computing models, lines, and you could probably go further with of what kind of trendline you want to plot - e.g. formulas, type of model, type of family distribution (GAM), span for loess...e.t.c)
- Downside for using Shiny: recomputation takes time and it's inefficent (and sometimes Shiny lags + or is unstable), + can't do it on large datasets
- Plotly + Shiny: Plotly itself has limited statistical curves. You can achieve the same by linking it up to Shiny. However, if you use ggplot2 + ggplotly - you can go further as ggplot2 has built in functions that help make plotting of smoothers easier.
- ggvis alone: Because ggvis does use Shiny's infrastructure to drive its interactions + ui inputs, you can achieve this via using layer_model_predictions() (limited to 3 different types of models at the moment) and layer_smooths() (loess) function.
- ggvis + Shiny: probably can achieve more models using other R packages that are made for modelling.


**An advanced facetting example/array of plots challenge:** *code >> array-challenge.R or array-challenge.Rmd*
- Taking a simple example of the iris dataset!
- *plotly in R* has managed to make a linked scatterplot matrix using ggpairs() and plotly, which has crosstalk embedded in to facilitate the links between each plot. However, because it's rendered as a single plot object, not sure how you could zoom in/ select a single plot.       -[Example](https://cpsievert.github.io/plotly_book/linking-views-without-shiny.html)
- Using crosstalk + d3scatter + shiny: you can view a single plot through adding a modal, and linking all the plots together easily using crosstalk. UI options and links are provided by Shiny.
- Can be done with plotly + crosstalk + shiny (need to use subplot() to link scatterplot matrix together). Only unidirectional links occur when you plot separately.
- Too hard to do it manually? You could have crosstalk linking everything together, the problem with having it pop out into a new window would be trying to link the plot from that one window to another which may not be possible, as links generally apply to plots on a page.
- Could be possible with Shiny alone, but requires work trying to link all the plots together (and if it's possible with Shiny, then most likely possible with ggvis.)
- Working with ggvis, but (not sure if this may be the problem) because it uses slightly different notation to render its output and bind to Shiny - running into trouble trying to bind it to a modal.
- Other findings: ggvis + shiny can't work seem to work on rmarkdown?, ggvis plots do not scale to Bootstrap in Shiny (somehow overrides widths).

- A d3 [example](http://mbostock.github.io/d3/talk/20111116/iris-splom.html) of linked scatterplot matrix




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

**ggvis** is currently under development (they're still expanding their API). Facetted plots are currently unavailable, but is being developed under a function known as subvis() and appears to work similarly to facetting with Plotly. Unlike ggplot2, there is currently no function that automatically does facetting (such as facet_wrap/facet_grid). It would be interesting to see how much can be achieved using the Vega library.

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

---
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
