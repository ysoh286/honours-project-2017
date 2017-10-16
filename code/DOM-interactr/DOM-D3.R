## trial DOM + D3:

library(DOM)

page <- htmlPage()

# read in D3:
d3lib <- paste(readLines("~/Downloads/d3/d3.min.js"), collapse = "\n")

#throws warning - incomplete final line
appendChild(page,
            child = javascript(d3lib))

#test that it runs d3 code:
appendChild(page,
            child = javascript('console.log(d3);'))

# some other code:




