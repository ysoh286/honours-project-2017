#' Interactions
#' A list of interactiosn that can be specified (still testing!)
#' 

#' fill: highlights an element with a color
#' @param element element to target
#' @param color color to highlight
#' @export
fill <- function(element, color) {
  id <- paste0(element, ".1.1")
  f <- paste0("fill('", id, "','", color, "')")
  return(f)
}

#' unfill: returns element to original color (if 'fill' is added)
#' @param element element to target
#' @export
unfill <- function(element) {
  id <- paste0(element, ".1.1")
  f <- paste0("unfill('", id, "')")
  return(f)
}

#' highlightPoints: link an object to highlight certain group of points
#' @param p1 element to target
#' @param p2 group of points to target
#' @export
highlightPoints <- function(p1, p2) {
  p2 <- paste0(p2, ".1")
  p1 <- paste0(p1, ".1.1")
  paste0("highlightPoints('", p1, "','", p2, "')")
}
