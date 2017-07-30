#' @title listElements
#'
#' @description Function tries to list elements drawn (currently derived from grid objects)
#' for further reference to add interactions.
#' @param x a plot that can be stored
#' @export
listElements <- function(x) {
  UseMethod("listElements")
}

#for recorded plots (ie base)
#' @export
listElements.recordedplot <- function(x) {

  if (!requireNamespace("gridGraphics", quietly = TRUE)) {
    stop(paste("We require the gridGraphics package for this.",
               "Please use install.packages('gridGraphics') to install.",
               sep = "\n"))
  }

  print(x)
  gridGraphics::grid.echo()
  grid::grid.ls()

}

## for lattice plots:
#' @export
listElements.trellis <- function(x) {
  print(x)
  grid::grid.ls()
}

## for ggplot2:
#' @export
listElements.ggplot <- function(x) {
  print(x)
  grid::grid.force()
  grid::grid.ls()
}

## for iNZight plots:
#' @export
listElements.inzplotoutput <- function(x) {
  #print(x)
  grid::grid.ls()
}

##other things to try: a javascript graphing library.
