## Using trelliscope: Just running through this tutorial about it:
#http://deltarho.org/docs-trelliscope/#quickstart
install.packages('trelliscope')

library(trelliscope)

##some examples:
str(iris) #this shows you what's in the iris dataframe.


## set up a visualisation database - directory where info and displays are stored.
## establish a connection?
setwd('~/Desktop')
conn <- vdbConn("vdb", name = "deltarhoTutorial") ## creates a new folder called 'vdb'.

##divide iris by Species
bySpecies <- divide(iris, by = "Species")
bySpecies[[1]]

## Creating a trellis display/facetted plot:
createPanel <- function(x) {
  lattice::xyplot(Sepal.Length ~ Sepal.Width, data = x, auto.key = TRUE)
}

createPanel(bySpecies[[1]]$value) ## this just plots whatever plot you specified...

## okay, so it turns out this is the native version.
## trelliscopeJS makes it all on the web?
