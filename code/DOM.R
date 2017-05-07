## DOM.R - Playing with Paul's DOM package :)

#installation:
devtools::install_github('pmur002/DOM')
library(DOM)

## going through his intro tutorial - look at  version: 0.3. 
## DON'T LOOK AT 0.4! (unless you're playing with CSS)
#this works for all browsers - Safari, Firefox, Chrome (testing on Mac OSX, R version 3.2.4).

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


# Requesting in the browser:



