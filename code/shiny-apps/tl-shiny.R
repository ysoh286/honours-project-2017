#trendline-shiny-challenge

library(lattice)
library(shiny)
library(gridSVG)

#draw plot:
pdf(NULL)
cols <- c("red", "green", "blue")
pl <- lattice::xyplot(Petal.Length ~ Petal.Width, data = iris, col = cols[iris$Species], pch = 19, type = c("p", "smooth"), col.line = "orange", lwd = 3)
print(pl)
#get svg output
all <- gridSVG::grid.export(NULL, exportCoords = "inline", exportJS = "inline")
coords <- all$coords
dev.off()
svgOutput <- capture.output(all$svg)
#get panel viewport to match co-ordinates correctly:
panel <- "plot_01.toplevel.vp::plot_01.panel.1.1.vp.2"

#load co-ordinates:
gridSVG::gridSVGCoords(coords)

#build shiny app:
shinyApp(
  ui <- fluidPage(
    titlePanel("Change a trendline without redrawing the entire plot:"),
    sidebarLayout(
      sidebarPanel(
        selectInput("color",
                    label = "Select color",
                    choices = c("red", "blue"),
                    selected = "red"),
        selectInput("trendline",
                    label = "Select trendline",
                    choices = c("Loess" = "loess", "Linear" = "linear", "GLM" = "glm"),
                    selected = "loess"),
        
        conditionalPanel(
          condition = "input.trendline == 'glm'",
          selectInput(
            "family",
            label = "Distribution",
            choices = c("Gaussian" = "gaussian", "Binomial" = "binomial", "Poisson" = "poisson", "Gamma" = "gamma"),
            selected = "gaussian")
        ),
        
        conditionalPanel(
          condition = "input.trendline == 'loess'",
          sliderInput(
            "span",
            label = "Degree of smoothing",
            min = 0.5, max = 1, value = 1, step = 0.01)
        )
      ),
      
      mainPanel(
        #render the svg:
        HTML(svgOutput),
        #testing to render text:
        verbatimTextOutput("results")
      )
    ),
    
    #attempting to send data from server to client: requires a use of a handler function.
    tags$script('
                Shiny.addCustomMessageHandler("colorCall",
                function(color) {
                var trendline = document.getElementById("plot_01.loess.lines.panel.1.1.1.1");
                trendline.style.stroke = color;
                });'),
      tags$script('
                  Shiny.addCustomMessageHandler("trendlineCall",
                  function(pt) {
                  var trendline = document.getElementById("plot_01.loess.lines.panel.1.1.1.1");
                  trendline.setAttribute("points", pt);
                  });'),
    tags$script('
                Shiny.addCustomMessageHandler("newSmooth",
                function(newPt) {
                var newSmooth = document.getElementById("newSmooth");
                if (newSmooth == null || undefined) {
                var newSmooth = document.createElementNS("http://www.w3.org/2000/svg", "polyline");
                newSmooth.setAttribute("stroke", "black");
                newSmooth.setAttribute("stroke-width", "5");
                newSmooth.setAttribute("id", "newSmooth");
                var panel = document.getElementById("plot_01.loess.lines.panel.1.1.1");
                panel.appendChild(newSmooth);
                }
                newSmooth.setAttribute("points", newPt);
                });'),

    #include script for brushing:
    includeScript('tl-shiny.js')
    
    ),
  
  server <- function(input, output, session) {
    
    #recalculate new smoother:
    observe({
      if (!is.null(input$selectedPoints) && length(input$selectedPoints) > 10) {
        selected_iris = iris[input$selectedPoints, ]
        #plot loess model instead:
        x <- seq(min(selected_iris$Petal.Width), max(selected_iris$Petal.Width), length = 20)
        lo <- loess(Petal.Length~Petal.Width, data = selected_iris, span = input$span)
        #Note that this is NOT stable when you try setting values close to log(1)/log(2).
        #if we set a span to something lower, it starts to get funny and runs into errors.
        #Loess smoothing starts to break down and return NA/Inf/-Inf prediction values...
        y <- predict(lo, x)
        
        #conversion to SVG pixel co-ordinates:
        svg_x <- viewportConvertX(panel, x, "native")
        svg_y <- viewportConvertY(panel, y, "native")
        
        #create 'points' string:
        newPt <-  paste(svg_x, svg_y, sep = ",", collapse = " ")
      } else {
        newPt <- ""
      }
      session$sendCustomMessage(type = "newSmooth", newPt)
      
    })
    
    #to send data to handler function: use of an observer - sending a JS object:
    observe({
      if (input$color == "red") {
        color = "red"
        session$sendCustomMessage(type = "colorCall", color)
      } else {
        color = "blue"
        session$sendCustomMessage(type = "colorCall", color)
      }
    })
    
    
    observe({
      x <- seq(min(iris$Petal.Width), max(iris$Petal.Width), length = 20)
      
      if (input$trendline == "linear") {
        #linear model:
        linear <- lm(Petal.Length~Petal.Width, data = iris)
        y <- linear$coefficients[1] + linear$coefficients[2]*x
      } else if (input$trendline == "loess") {
        #loess model:
        lo <- loess(Petal.Length~Petal.Width,data = iris, span = input$span)
        y <- predict(lo, x)
      } else {
        #general linear model:
        glm <- glm(Petal.Length~Petal.Width, data = iris, family = "gaussian")
        y <- glm$coefficients[1] + glm$coefficients[2]*x
      }
      
      #conversion to SVG pixel co-ordinates:
      svg_x <- viewportConvertX(panel, x, "native")
      svg_y <- viewportConvertY(panel, y, "native")
      
      #create 'points' string:
      pt <-  paste(svg_x, svg_y, sep = ",", collapse = " ")
      session$sendCustomMessage(type = "trendlineCall", pt)
      
    })
    
  }
)