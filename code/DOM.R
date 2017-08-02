## DOM.R - Playing with Paul's DOM package :)

#installation:
devtools::install_github('pmur002/DOM')
library(DOM)

## going through his intro tutorial - look at  version: 0.3.
#https://www.stat.auckland.ac.nz/~paul/Reports/DOM/v0.3/DOM-v0.3.html
## DON'T LOOK AT 0.4! (unless you're playing with CSS)
#this works on Firefox (testing on Mac OSX, R version 3.2.4).

page <- htmlPage('<p> Hello World! </p>')

page <- htmlPage()
appendChild(page, child = htmlNode("<p> Hello World! </p>"))
# this returns object of class.

# adding a span:
appendChild(page,
            child = htmlNode('<span style = "font-style: italic"> hello italics </span>'))


# to return the css selector instead:
appendChild(page,
            child = htmlNode("<p> hello </p>"),
            response = css())

#return the xpath:
appendChild(page,
            child =xpath("//p[1]"))
#this moves the 1st element (technically the 2nd) down to the end of the page.
#response = what it returns in R.
appendChild(page,
            child = htmlNode("<p> Paragraph 3 </p>"),
            response = xpath())

# adding some JS to the webpage:
appendChild(page,
            child = javascript("document.getElementsByTagName('p')[0].setAttribute('style', 'color:red')"))

## rendering an svg:

#draw a plot:
pdf(NULL)
iNZightPlots::iNZightPlot(1:10)
#export as svg and store in memory
svg <- gridSVG::grid.export(NULL)$svg
dev.off()
#convert to string:
svgString <- paste(capture.output(svg), collapse = "\n")

#render page:
page <- htmlPage()
appendChild(page,
            child = svgNode(svgString),
            ns = TRUE,
            response = svgNode())
appendChild(page,
            child = htmlNode('<span> hello iNZight! </span>'))

#could I render other HTML elements?

#rendering a dropdown menu:
appendChild(page,
            child = htmlNode('<select name="Variables">
                             <option value = "weekly_hrs"> weekly_hrs </option>
                              <option value = "weekly_income"> weekly_income </option>
                             </select>'),
            response = htmlNode())

# a slider?
appendChild( page,
             child = htmlNode('<input name="sl" id="slider" type="range" min = "0" max = "100" step = "10" value = "50" />'),
             response = htmlNode())

appendChild(page,
            child = htmlNode('<output name = "slOut" id="sliderVal"></output>'))
#doesn't show the steps though...

# a search box?
appendChild(page,
            child = htmlNode('<input id="search" type="search" />'))


#removing!:
# note that for removal, you specify css tags rather than htmlNode()
#removes the last item that was originally appended.
removeChild(page,
            child=css('p'))

removeChild(page,
            child=css('input'))
#replacing:

appendChild(page,
            child = htmlNode('<p> Hello </p>'),
            response = css())

replaceChild(page,
             newChild = htmlNode("<p> This has been replaced! </p>"),
             oldChild = css('p'))

#replace something that's already existing on the page - this is good for moving things around:
appendChild(page,
            child = htmlNode('<p> Hello </p>'))

appendChild(page,
            child = htmlNode('<p> Goodbye </p>'))

replaceChild(page,
             newChild = css('select'),
             oldChild = css('p'))

replaceChild(page,
             newChild = css('input'),
             oldChild = css('p'))

#TODO:: Could you add external links? hmm. Doesn't work well with the function...
# Not so simple.


#----------- Making requests from browser -> R:--------------


echo <- function(elt, css) {
  cat("HTML:", elt, "\n")
}
page <- htmlPage()
appendChild(page,
            child = htmlNode("<p> <span>Click on me to change!</span> </p>"))
#add some js:
appendChild(page,
            child = javascript('document.getElementsByTagName("p")[0].style.color = "blue";'))

setAttribute(page, elt = css("span"), attrName = "onclick",
            attrValue = 'RDOM.Rcall("echo", this, [ "HTML" ],null)')

## let's try something different...

js <- 'highlight = function() {
       var spanText = document.getElementsByTagName("p")[0]
        spanText.style.color = "red";
};

normal = function() {
 var spanText = document.getElementsByTagName("p")[0]
  spanText.style.color = "blue";
}'

#set up page:
page <- htmlPage()
appendChild(page,
            child = htmlNode("<p> <span>Click on me to change!</span> </p>"))

#using setAttribute instead + JS:
appendChild(page,
            child = javascript(js))
setAttribute(page,
             elt = css("span"),
             attrName = "onmouseover",
             attrValue = 'highlight()')
setAttribute(page,
             elt = css("span"),
             attrName = "onmouseout",
             attrValue = "normal()")

#TODO: could you return something that's not elt/css?

# CONTROLLING CSS:
page <- htmlPage()
appendChild(page,
            child = htmlNode("<p> Hi! </p>"))

#requires a style sheet!
appendChild(page,
            htmlNode('<style type="text/css"></style>'),
            parent=css("head"))
sheets <- styleSheets(page)
insertRule(page, sheets[1], "p:hover { color: red; }", 0)

# use getProperty instead...?
style <- getProperty(page, css('p'), "style")
setProperty(page, style, "font-size", "10")
setProperty(page, style, "font-family", "Arial")
