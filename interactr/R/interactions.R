# A list of specific/ simple interactions that can be used:

#' @title styleHover
#' @description allows user to style a hover interaction
#' @param el element to target
#' @param attrs styling options/attributes (currently fill and fill.opacity)
#' @export
styleHover <- function(el, attrs) {

  if (!is.list(attrs)) {
    stop("Attributes should be in a list!")
  }
  ## future: namecheck css + possible values for each:

  gridObj <- grid::grid.get(el)
  classObj <- class(gridObj)[1]
  #for ids: need to add backslash on periods - doesn't work!
  # TODO: a possible work around is to use gridSVG's css selectors??
  #cssEl <- gsub("[\\.]", "\\\\(\\.)", el)

  #generateCSS- should be for all list in attr:
  fill <- paste0("fill:", attrs$fill, "; ")
  fillop <- paste0("fill-opacity:", attrs$fill.opacity, "; ")
  #can expand further to other attributes available in css
  # TODO: vectorise!

  #temp fix:
  cssRule <- paste0(classObj, ":hover {", fill, fillop, "}")
  return(cssRule)

  ## the other alternative: use HTMLnodes instead...

}
