## JS + Shiny:

## Objectives: 
  #see if you can prompt some javascript into Shiny, and back. 
  #incorporate an SVG, and try manipulate it with some javascript in Shiny
  #'Think of the UI as an HTML page.'

#some basics to incorporating HTML elements into Shiny
library(shiny)

shinyApp(
  ui <- fluidPage(
    tags$div(
      tags$p('hello world'),
      tags$p('hello')
    )),

server <- function(input, output, session) {
}
)


tags$div( #HTMLdiv
  tags$p('This is the first paragraph.'),
  tags$p('This is the second paragraph.')
  )

#output: 
#<div>
 # <p>This is the first paragraph.</p>
 # <p>This is the second paragraph.</p>
# </div>

#Most of these examples to send data to and from come from this blog post:
#https://ryouready.wordpress.com/2013/11/20/sending-data-from-client-to-server-and-back-using-shiny/
#This blog post has been referenced to several times in Shiny's github repository (under issues and also in the forum group).
#It's a good read, and easy to understand too! 

#send data from client to server, process with R and then return - use Shiny.onInputChange

# a simple example (adapted from the blog post):
shinyApp(
  ui <- fluidPage(
    tags$p(id="p1", "Click me!"),
    verbatimTextOutput("results"),
    #send data to shiny server
    tags$script('document.getElementById("p1").onclick = function() {
      var number = Math.random();
      Shiny.onInputChange("mydata", number);
         };'
    ),
    #attempting to send data from server to client: requires a use of a handler function.
    tags$script('
                Shiny.addCustomMessageHandler("colorCall", 
                function(color) {
                document.getElementById("p1").style.backgroundColor = color;
                });')),

server <- function(input, output, session) {
  #render output
  output$results  = renderPrint({
    input$mydata
  })
  
  #to send data to handler function: use of an observer - sending a JS object:
  observe({
    input$mydata
    color = rgb(runif(1), runif(1), runif(1))
    session$sendCustomMessage(type = "colorCall", color)
  })
})


#What would you like to pass??
# You can pass JavaScript objects through, but it's only executed once as they are static. 


#---------------------- incorporating javascript and building with Shiny -------------

# You can also include scripts by using the includeScript function
# Could I combine iNZightPlots + my own custom files (external) and run it.
# need to add SVG plot in.
# TODO:: try incorporate iNZightPlot + JavaScript code.

# render plot:
library(iNZightPlots)
library(gridSVG)
library(grid)

pdf(NULL)
pl <- iNZightPlot(weekly_hrs, weekly_income, colby = ethnicity, data = income100, pch = 19)
plot <- pl$all$all
#get relevant data:
xVal <- plot$x
yVal <- plot$y
tab <- cbind(as.data.frame(xVal), as.data.frame(yVal))
names(tab) <- c(attributes(pl)$varnames$x, attributes(pl)$varnames$y)
#colby variable:
colby <- plot$colby
tab <- cbind(tab, as.data.frame(colby))
names(tab)[ncol(tab)] <- attributes(pl)$varnames$colby

colGroupNo <- nlevels(plot$colby)
namesJSON <- paste0("var names = ", jsonlite::toJSON(names(tab)), ";")
tabJSON <- paste0("var tableData = ", jsonlite::toJSON(tab), ";")
colGroupNo <- paste0("colGroupNo = ", colGroupNo, ";")

#list all data:
JSData <- list(names = namesJSON, tabs = tabJSON, colGroupNo = colGroupNo)
#bind JSON to grid plot:
gridSVG::grid.script(do.call("paste", c(JSData, sep="\n ")), inline = TRUE, name = "linkedJSONdata")
#export as SVG - store in memory:
svgdoc <- gridSVG::grid.export(NULL)$svg
#svg as string:
svg <- paste(capture.output(svgdoc), collapse = "\n")
dev.off()

#Shiny app:
shinyApp(
  ui <- fluidPage(
    mainPanel(
      HTML(svg),
      includeCSS('prev/style.css'),
      includeScript('prev/singleFunctions.js'),
      includeScript('prev/dpsp-nt.js')
    )
  ),
  
  server <- function(input, output, session) {
    #blank
  }
)

# This works, but it's simply static. 
# Would it be possible to connect it to the server side of Shiny??

## looking at more complex examples: Winston Chang's testapp > message-handler-jsfile and inline:
#https://github.com/wch/testapp/tree/master/message-handler-jsfile




