#' listElements
#'
#' Function tries to list elements drawn (currently derived from grid objects) for further reference to add interactions.
#' @param x a plot that can be stored (x is null for base plots)
#' @keywords list elements
#' @export
#' 
#' 
## Here, we identify what components to combine together, and to 'map'

## list elements function - taking Paul's starting point:
listElements <- function(x = NULL) {
  UseMethod("listElements")
}

## for base: - doesn't work! 
listElements.base <- function(x) {
  gridGraphics::grid.echo()
  grid::grid.ls()
}

## for lattice plots:
listElements.trellis <- function(x) {
  print(x)
  grid::grid.ls()
}

## for ggplot2:
listElements.ggplot <- function(x) {
  print(x)
  grid::grid.force()
  grid::grid.ls()
}

## for iNZight plots:
listElements.inzplotoutput <- function(x) {
  #print(x)
  grid::grid.ls()
}

##other things to try: a javascript graphing library.
