## DOM.R - Playing with Paul's DOM package :)

#installation:
devtools::install_github('pmur002/DOM')

## going through his intro tutorial;
library(DOM)
page <- htmlPage('<p> Hello World! </p>')

#okay, this works for all browsers - Safari, Firefox, Chrome. But all the rest of the functions don't work.
#Throws an error.

#Switching to LINUX Ubuntu 16.04:

appendChild(page, '<p> Goodbye World! </p>') ## this doesn't work?
removeChild(page, "p") #this doesn't work either... :(


page <- htmlPage('<p> Hello World! </p> <p> Goodbye World! </p>')

closePage(page)

args(appendChild)
args(closePage)
page <- htmlPage(paste("<p> Paragraph", 1:3, "</p>", collapse = ""))

