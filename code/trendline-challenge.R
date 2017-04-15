## trendline challenge:

## Attempt to either add trendlines on/off or be able to change trendlines on the plot.

## load some data in:
income <- read.csv('datasets/nzincome.csv', header = TRUE)

#ggvis version:

library(ggvis)

ggvis(income, ~weekly_hrs, ~weekly_income, fill = ~sex) %>%
  layer_points() %>%
  layer_smooths(stroke:= "red", span = input_slider(0.5, 1, value = 1, label = "Span of loess smoother" )) %>%
  layer_model_predictions(stroke:="blue", 
                          model = input_select(c("Loess" = "loess", "Linear Model" = "lm", "RLM" = "MASS::rlm"), label = "Select a model"),
                          se = input_checkbox(value = FALSE, label = "Show standard errors"))

#----- another example...
ggvis(income, ~weekly_hrs, ~weekly_income, fill = ~sex) %>%
  layer_points() %>%
  group_by(sex) %>%
  layer_smooths(stroke := "red", span = input_slider(0, 1, value = 1, label = "Span of loess smoother (red)")) %>%
  layer_model_predictions(stroke:="blue", 
                          model = input_select(c("Loess" = "loess", "Linear Model" = "lm", "RLM" = "MASS::rlm"), label = "Select a model"),
                          se = input_checkbox(value = TRUE, label = "Show standard errors"))

#maybe try on a different dataset?
ggvis(cocaine, ~weight, ~price) %>%
  layer_points() %>%
  add_tooltip(function(cocaine) paste0("Weight: <b>", cocaine$weight, "</b><br>", "Price: <b>", cocaine$price, "</b><br>"), "hover") %>%
  layer_smooths(stroke := "red", span = input_slider(0.5, 1, value = 1, label = "Span of loess curve (red)")) %>%
  layer_model_predictions(stroke := "blue", model = input_select(c("Loess" = "loess", "Linear Model" = "lm", "RLM" = "MASS::rlm"), label = "Select a model"),
                          se = TRUE)

## TODO: extending ui options?

#So in this case, you can change where the ui options go (as in sliders, and all. You could also do it individually.)
library(ggvis)
library(shiny)

ui <- fluidPage(
  titlePanel("Trendline challenge: ggvis + Shiny"),
  sidebarLayout(
    sidebarPanel(
      uiOutput("plot_ui")
    ),mainPanel(
      ggvisOutput("plot")
    )
    , position = c("left", "right"),
    fluid = TRUE)
)

server <- function(input, output) {
  ggvis(cocaine, ~weight, ~price) %>%
    layer_points() %>%
    layer_smooths(stroke := "red", span = input_slider(0.5, 1, value = 1, label = "Span of loess curve (red)")) %>%
    layer_model_predictions(stroke := "blue", model = input_select(c("Loess" = "loess", "Linear Model" = "lm", "RLM" = "MASS::rlm"), label = "Select a model"),
                            se = TRUE) %>%
  bind_shiny("plot", "plot_ui")
}

shinyApp(ui, server)

#----------------------------------------------------------------
# plotly + shiny:

library(plotly)
library(shiny)

shinyApp(
    ui = fluidPage(
         titlePanel("Trendline challenge: Plotly + Shiny"),
         sidebarLayout(
            sidebarPanel(
               selectInput("model", "Model", c("Linear" = "lm", "Loess" = "loess", "RLM" = "rlm")),
               numericInput("obs", "Observations:", 3380, min = 0, max = 3380),
               sliderInput("span", "Span for loess", min = 0.5, max = 1, value = 0.75)
               ), 
            mainPanel(
              plotlyOutput("plot")
                ), 
            position = c("left", "right"),
            fluid = TRUE)
       ),
     
       server = function(input, output) {
           
             output$plot <- renderPlotly({
                 
                 if (input$obs == nrow(cocaine)) {
                      cocaine <- cocaine
                     } else {
                       cocaine <- cocaine[1:input$obs, ]
                     }
                 
                   plot <- plot_ly(cocaine, x = ~weight, y = ~price, mode = "markers", type = "scatter")
                   
                    #run condition for model lines:
                     if (input$model == "loess") { #try to get the loess to smoothen. Or use plotly- curves.
                         modelLine <- loess(price ~ weight, data = cocaine, span = 0.75, se = TRUE)
                      } else if (input$model == "MASS::RLM") {
                           modelLine <- mass::rlm(price ~weight, data = cocaine)
                         } else {
                             modelLine <- lm(price ~ weight, data = cocaine)
                           }
                   
                     #add trendline
                    add_lines(plot,y = ~fitted(modelLine), line = list(color = "red"))
                 
                  })
           }
   )

#Maybe use plotly curves? If they have any statistical smoothing functions - they don't?
#When you couple things with R, it actually becomes very advantageous.
#you can't avoid redrawing when using Shiny :(


#----------------------------------------------------------------
#using ggplot2 + shiny + plotly:
#trying out stat_smooth from ggplot2 + additional customisation of trendlines
#ggplot2 has more statistical functions, which could possibly make it easier...?
#parameters available: mapping, data, geom,  method (lm, glm, gam, loess, rlm), formula, se (confidence interval), span 
#You could also use qplot? 

p <- ggplot(cocaine, aes(price, weight)) + geom_point() + stat_smooth()
p <- ggplotly(p)
p

total.obs <- nrow(cocaine)


ui <- fluidPage(
  titlePanel("Trendline challenge: using ggplot2 + ggplotly + Shiny"),
  sidebarLayout(
    sidebarPanel(
      selectInput("model", "Model", c("GAM" = "gam", "Linear" = "lm", "Loess" = "loess", "GLM" = "glm")),
      numericInput("obs", "Observations:", total.obs, min = 0, max = total.obs),
      sliderInput("span", "Span for loess:", min = 0.5, max = 1, value = 0.75), 
      verbatimTextOutput("summary")
      
    ), mainPanel(
      plotlyOutput("plot")
    )
    , position = c("left", "right"),
    fluid = TRUE)
)

server <- function(input, output) {
  
  output$plot <- renderPlotly({
    
    if (input$obs == total.obs) {
      cocaine <- cocaine
    } else {
      cocaine <- cocaine[1:input$obs, ]
    }
    
    #creating the plot:
    p <- ggplot(cocaine, aes(weight, price)) + geom_point() 
    p <- p + stat_smooth(method = input$model, span = input$span, se = TRUE)
    ggplotly(p)
    
  })
    
  output$summary <- renderPrint({
    
    if (input$obs == total.obs) {
      cocaine <- cocaine
    } else {
      cocaine <- cocaine[1:input$obs, ]
    } #might make this reactive to prevent repeats
    
    #compute summary for model:
    if (input$model == "lm") {
      lm(price ~ weight, data = cocaine)
    } else if (input$model == "loess") {
      loess(price ~ weight, data = cocaine)
    } else if (input$model == "glm") {
      glm(price ~ weight, data = cocaine)
    } else {
      mgcv::gam(price ~ weight, data = cocaine)
    }
  })
   
  
}

shinyApp(ui, server)

# What if you could extend it further for each kind of model?? 
#(that is, for glm: specify families, formulae, polynomial degrees... e.t.c)
# You could go further and try do a model comparison. (AIC, BIC, DIC?)
#A clear advantage of using Shiny:: you have access to other R packages and their functions.

#----------------------------------------------------------------
# plotly + crosstalk? - would crosstalk help in any way?
# According to limitations stated, it's not possible.
# It can only filter and select raw data.  

#----------------------------------------------------------------
## iNZightPlots + Shiny trial:
shinyApp (
  ui = fluidPage(
    titlePanel("Trendline challenge: iNZightPlots + Shiny"),
    sidebarLayout(
      sidebarPanel( #things on the side...
        selectInput("trend", "Trend", c("Linear" = "linear", "Quadratic" = "quadratic", "Cubic" = "cubic")),
        numericInput("obs", "Observations:", total.obs, min = 0, max = total.obs),
        sliderInput("smooth", "Smoothness", min = 0.5, max = 1, value = 0.75), 
        sliderInput("lwd", "Line width", min = 0.1, max = 5, value = 1)
        
      ), mainPanel(
        plotOutput("plot"),
        verbatimTextOutput("summary")
      )
      , position = c("left", "right"),
      fluid = TRUE)
  ),
  
  server = function(input, output) {
    
    output$plot <- renderPlot({
      
      if (input$obs == total.obs) {
        cocaine <- cocaine
      } else {
        cocaine <- cocaine[1:input$obs, ]
      }
      
      #creating the iNZightPlot:
      iNZightPlots::iNZightPlot(weight, price, data = cocaine, trend = input$trend, smooth = input$smooth, lwd = input$lwd)
      
    })
    
    output$summary <- renderPrint({
      
      if (input$obs == total.obs) {
        cocaine <- cocaine
      } else {
        cocaine <- cocaine[1:input$obs, ]
      } #might make this reactive to prevent repeats
      
      #compute summary for model:
      iNZightPlots::getPlotSummary(weight, price, data = cocaine, trend = input$trend, smooth = input$smooth, lwd = input$lwd, summary.type = "inference")
      
    })
  }
)


# in all cases, there's always redrawing of plots.
# Can Plotly just change that one line (or even just remove the line)? or is it really not possible at all?
# May need to look into the PlotlyJS to see if I could possibly change/customise JS interactions
#further.

##---------------------------------------------------------------------
## trying a base plot example:

plot.new()
## different modelLines:
plot(cocaine$weight, cocaine$price)
modelLine <- loess.smooth(cocaine$weight, cocaine$price, span = 0.75, degree = 2)
lines(modelLine$x, modelLine$y, col = "red")
##lm
abline(lm(cocaine$price ~ cocaine$weight), col = "blue")
##glm:
abline(glm(cocaine$price ~ cocaine$weight), col = "green")

## baseplot + shiny? 
library(shiny)
shinyApp(
  ui = fluidPage(
  titlePanel("Trendline challenge: Base Plots + Shiny"),
  sidebarLayout(
    sidebarPanel( #things on the side...
      selectInput("model", "Model", c("Linear" = "lm", "GLM" = "glm", "Loess" = "loess")),
      numericInput("obs", "Observations:", nrow(cocaine), min = 0, max = nrow(cocaine)),
      sliderInput("span", "Smoothness", min = 0.5, max = 1, value = 0.75), 
      sliderInput("lwd", "Line width", min = 0.1, max = 5, value = 1),
      numericInput("degree", "Degree", min = 1, max = 2, value = 1)
      
    ), mainPanel(
      plotOutput("plot"),
      verbatimTextOutput("summary")
    )
    , position = c("left", "right"),
    fluid = TRUE)
    
  ),
  
  server = function(input, output) {
    
    output$plot <- renderPlot({
      plot(cocaine$weight, cocaine$price)
      
      if(input$model == "loess") {
        modelLine <- loess.smooth(cocaine$weight, cocaine$price, span = input$span, degree = input$degree)
        lines(modelLine$x, modelLine$y, col = "red", lwd = input$lwd)
      } else if (input$model == "glm") {
        abline(glm(cocaine$price ~ cocaine$weight), col = "green", lwd = input$lwd)
      } else {
        abline(lm(cocaine$price ~ cocaine$weight), col = "blue", lwd = input$lwd)
      }
      
    })
    
  }

)

# Even if you can add on to a plot separately - the main problem with using Shiny is the
# renderPlot() function that encapsulates the entire plot. Would isolate() help in any way?


## ------------------ JAVASCRIPT SOLUTIONS?? -------------------------

