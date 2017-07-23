#' convertToSVG
#' Function to convert plots into an svg format, that can be further sent and viewed on a web browser
#' Generally for R plots.
#' @param x plot object (if can be stored)
#' @export
convertToSVG <- function(x = NULL) {
  UseMethod("convertToSVG")
}

# convert plot to svg:
convertToSVG.default <- function(x = NULL) {
  
  svgall <- gridSVG::grid.export(NULL, exportMappings = "inline", exportCoords = "inline")
  svg <- svgall$svg
  mappings <- svgall$mappings
  coords <- svgall$coords
  gridSVG::gridSVGCoords(coords)
  gridSVG::gridSVGMappigns(mappings)
  dev.off()
  
  return(svg)
  
}

convertToSVG.trellis <- function(x) {
  
  ##draw svg: has a certain structure
  pdf(NULL)
  print(x)
  svgall <- gridSVG::grid.export(NULL, exportMappings = "inline", exportCoords = "inline")
  svg <- svgall$svg
  mappings <- svgall$mappings
  coords <- svgall$coords
  gridSVG::gridSVGCoords(coords)
  gridSVG::gridSVGMappigns(mappings)
  dev.off()
  
  return(svg)
  
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

#' Draw: send plot/svg to browser and attach interactions
#' @details Used to send plots to the browser and its interactivity attached.
#'   You can also draw plots with no interactions if you like.
#'  @param pl plot 
#'  @param target plot object to attach interactions to
#'  @param interactions interactions to attach to target
#'  @param new.page specifies drawing on a new web page
#'  @export  
draw <- function(pl, target = NULL, interactions = NULL, new.page = FALSE) {
  
  svg <- convertToSVG(pl)
  
  ##send to browser - initial set up:
  if (new.page == TRUE) {
    pageNo <<- DOM::htmlPage()
    ## append D3 library + javascript: 
    #appendChild(page,
    #            child = htmlNode("<script src = 'https://d3js.org/d3.v4.min.js'> </script>"))
    DOM::appendChild(pageNo,
                    child = DOM::javascript(paste(readLines('functions.js'), collapse = "\n")))
  }
  
  DOM::appendChild(pageNo,
                   child = DOM::svgNode(XML::saveXML(svg)),
                   ns = TRUE)
  
  ## attach interactions:
  if (!is.null(interactions)) {
    addInteractions(target, interactions)
  }
  
}
