## Running through ggiraph + ggplot2 and its capabilities;

#installation
install.packages('ggplot2')
install.packages("ggiraph")
devtools::install_github("davidgohel/ggiraph")

#tutorial + resources:
#https://davidgohel.github.io/ggiraph

library(ggiraph)
library(ggplot2)

## load dataset

income <- read.csv('datasets/nzincome.csv', header = TRUE)
census <- read.csv('datasets/census.csv', header = TRUE)

# a simple ggplot:
g <- ggplot(iris, aes(x = Petal.Width, y = Petal.Length, color = Species)) + geom_point()

# add tooltips by building upon this;
g_int <- g + geom_point_interactive(aes(tooltip = Species), size = 2)
ggiraph(code = print(g_int), width = 0.7)
#tooltip adds labels to each point.

#adding petal.legnth and petal.width;
g_int <- g + geom_point_interactive(aes(tooltip = paste("Petal Width:", Petal.Width, "\n Petal Length:", Petal.Length)), size = 3)
ggiraph(code = print(g_int), width = 0.7)

#hover effects?
g_hover <- g + geom_point_interactive(aes(tooltip = Species, data_id = seq.int(nrow(iris))))
ggiraph(code = print(g_hover), width = 0.7, hover_css = "cursor:pointer; fill: red; stroke: red;")
#hover_css only controls what happens when you hover (not the tooltip)
## hover_css styles the hover to red on points -> fill and stroke as read.
## Width: widget width ratio (between 0 and 1)
# is in fact an svg?

#clicking: string column in the dataset contains valid js instructions.
#linking to the Iris dataset - Wikipedia.

## Customisation with tooltips:
g_tooltip <- ggplot(iris, aes(x = Petal.Width, y = Petal.Length, color = Species, tooltip = Species)) + geom_point_interactive(size = 3)
ggiraph(print(g_tooltip), tooltip_offx = 10, tooltip_offy =-10)
#this literally moves the tooltip towards the left/right, up/down relative to the mouse

## add more css to the tooltip (controls how the tooltip is styled):
g_tooltip <- ggplot(iris, aes(x = Petal.Width, y = Petal.Length, color = Species, tooltip = Species)) + geom_point_interactive(size = 4)
ggiraph(print(g_tooltip), tooltip_extra_css = "color: red; text-align: center; padding: 10px; background-color:blue; border-radius:10px ;", tooltip_opacity = 0.5, width = 0.7)
#makes tooltip text red, centerd, padded, rounded rectangle is blue

#graph is rendered as an SVG!

#zooming;
ggiraph(code = print(g_int), zoom_max = 5, width =0.7)


#What about interactivity in other kinds of plots?
# applying to other kinds of plots:

#bar plots:
g_bar <- ggplot(income, aes(x = ethnicity, tooltip = ethnicity)) + geom_bar_interactive()
ggiraph(code = print(g_bar), zoom_max = 1, width = 0.7)

g_bar <- ggplot(income, aes(x = ethnicity, fill = sex, tooltip = paste(ethnicity, "\n", sex))) + geom_bar_interactive()
ggiraph(code = print(g_bar), width = 1)

g_bar <- ggplot(income, aes(x = ethnicity, fill = sex, tooltip = paste(ethnicity, "\n", sex))) + geom_bar_interactive()
ggiraph(code = print(g_bar), width = 1)

#box plots:
g_box <- ggplot(income, aes(ethnicity, weekly_hrs, tooltip = ethnicity, fill = ethnicity)) + geom_boxplot_interactive() + guides(fill = "none") #removes the legend
ggiraph(code = print(g_box), width = 1)

# other supported plots:
# geom_line_interactive()
# geom_path_interactive()

## Compatibility with Shiny:

library(shiny)

shinyApp(
  
  ui <- fluidPage(
    titlePanel("Rendering ggplot2 + ggiraph - boxplot"),
    mainPanel(
      ggiraphOutput("plot")
    )
  ),
  
  server <- function(input, output, session) {
  
      output$plot <- renderggiraph({
      ggiraph(code = print(g_box))
    })
  }
  
)


## selection in Shiny? Not sure what this does... but it seems to be missing something.

shinyApp(
  ui <- fluidPage(
    titlePanel("Rendering ggplot2 + ggiraph - scatterplot selection? "),
    mainPanel(
      ggiraphOutput("plot"),
      verbatimTextOutput("selpoint")
    )
  ),
  
  server <- function(input, output, session) {
     
    # make the dataset reactive:
    react_iris <- reactive ({
      if (is.null(input$plot_selected)) {
        character(0)
      } else {
        input$plot_selected
      }
    })
    
     output$plot <- renderggiraph({
       g <- ggplot(iris, aes(x = Petal.Width, y = Petal.Length, color = Species, tooltip = Species)) + geom_point_interactive(size = 3)
      ggiraph(code = print(g), selection_type = "single")
    })
     
     output$selpoint <- renderText({
       value <- react_iris()
     })
  }
)



## Conclusions:
# ggiraph is an HTMLwidget that provides very basic interactivity via tooltips, hovers, and basic zooming.
# These can be applied to most graphs.
# Can be used with Shiny.
# In comparison to Plotly's ggplotly(), it's much more limited in the sense. Plotly's got an upperhand with 
# all the following capabilities + linked brushing + being able to attach event

# This was briefly investigated to see what kind of interactions can ggiraph achieve with ggplot2.
# Stems as ideas....



