## DOM.R - Playing with Paul's DOM package :)

#installation:
devtools::install_github('pmur002/DOM')

## going through his intro tutorial - look at  version: 0.3 
library(DOM)
page <- htmlPage('<p> Hello World! </p>') 

#okay, this works for all browsers - Safari, Firefox, Chrome. But all the rest of the functions don't work.
#Throws an error.


appendChild(page, child=htmlNode("<p> Goodbye World! </p>")) 
removeChild(page, "p") 

page <- htmlPage('<p> Hello World! </p> <p> Goodbye World! </p>')

closePage(page)

args(appendChild)
args(closePage)
page <- htmlPage(paste("<p> Paragraph", 1:3, "</p>", collapse = ""))

