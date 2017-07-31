# A list of specific/ simple interactions that can be used:

#' @title styleHover
#' @description allows user to style a hover interaction
#' @param attrs styling options/attributes (currently fill and fill.opacity)
#' @export
styleHover <- function(attrs) {

  if (!is.list(attrs)) {
    stop("Attributes should be in a list!")
  }

  #generateCSS- should be for all list in attr:
  fill <- paste0("fill:", attrs$fill, "; ")
  fillop <- paste0("fill-opacity:", attrs$fill.opacity, "; ")
  #can expand further to other attributes available in css
  # TODO: vectorise!

  #temp fix:
  cssRule <- paste0(".hover:hover {", fill, fillop, "}")
  return(cssRule)

  ## the other alternative: use HTMLnodes instead...

}
