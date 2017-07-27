#' @title Draw plots and add interactions
#' 
#' @description Used to send plots to the browser and its interactivity attached.
#'   You can also draw plots with no interactions if you like.
#'   
#' @param pl plot
#' @param target element to attach interactions to
#' @param interactions interactions to attach to target
#' @param new.page specifies drawing on a new web page
#'  
#' @export

draw <- function(pl, target = NULL, interactions = NULL, new.page = FALSE) {

  svg <- convertToSVG(pl)

  ##send to browser - initial set up:
  if (new.page == TRUE) {
    pageNo <<- DOM::htmlPage()

    js <- paste(readLines(system.file('js/functions.js', package = "interactr")), collapse = "\n")

    DOM::appendChild(pageNo,
                     child = DOM::javascript(js))
  }

  DOM::appendChild(pageNo,
                   child = DOM::svgNode(XML::saveXML(svg)),
                   ns = TRUE)

  ## attach interactions:
  if (!is.null(interactions)) {
    addInteractions(target, interactions)
  }

}

#' addInteractions
#' Function to attach interactions to a single plot object existing on a web page
#' @param target plot object to target
#' @param interactions list of interactions to attach to target
#' @export
addInteractions <- function(target, interactions) {

  if (is.null(target)) {
    stop("You need to specify an object to target.")
  }

  ##find element:
  plotObj <- DOM::getElementById(pageNo,
                                 paste0(target,".1.1"),
                                 response = DOM::nodePtr())

  ## might need some code to stop running if it cannot find the object.

  ## attach interactions
  for (event in names(interactions)) {
    DOM::setAttribute(pageNo,
                      plotObj,
                      event,
                      interactions[[event]])
  }
}


# Backend functions:
# convert to SVG: converts svg using gridSVG (for R plots)
convertToSVG <- function(x = NULL) {
  UseMethod("convertToSVG")
}

# convert plot to svg:
convertToSVG.default <- function(x = NULL) {

  #do not print - because tags changes from reprinting  - user should call listElements first
  svgall <- gridSVG::grid.export(NULL, exportMappings = "inline", exportCoords = "inline")
  svg <- svgall$svg
  mappings <- svgall$mappings
  coords <- svgall$coords
  gridSVG::gridSVGCoords(coords)
  gridSVG::gridSVGMappings(mappings)
  dev.off()

  return(svg)

}

convertToSVG.trellis <- function(x) {

  pdf(NULL)
  print(x)
  svgall <- gridSVG::grid.export(NULL, exportMappings = "inline", exportCoords = "inline")
  svg <- svgall$svg
  mappings <- svgall$mappings
  coords <- svgall$coords
  gridSVG::gridSVGCoords(coords)
  gridSVG::gridSVGMappings(mappings)
  dev.off()

  return(svg)

}
