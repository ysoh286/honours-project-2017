## Other functions that may be useful:

#' @title returnRange
#' @description returns the range of a certain element (box, segment)
#' @param el element to determine range from
#' @export
returnRange <- function(el) {
  # requires validation if a grid object is a segment or something else.
  grob <- grid::grid.get(el)

  if (any(class(grob) == "polygon")) {

    coords <- grid::convertX(grob$x, "native", valueOnly = TRUE)
    max <- max(coords, na.rm = TRUE)
    min <- min(coords, na.rm = TRUE)
    range <- c(min, max)

  } else {

    x <- grid::convertX(grob$x, "native", valueOnly = TRUE)
    y <- grid::convertY(grob$y, "native", valueOnly = TRUE)
    range <- list(x = x, y = y)

  }

  return(range)

}

#' @title convertXY
#' @description convert a set of x and y values to return a set of co-ordinates (svg)
#' @param x x values (native)
#' @param y y values (native)
#' @param panel the panel/viewport that original values lie within
#' @export
convertXY <- function(x, y, panel) {
  #ASSUMES: gridSVG mappings are present (ie draw function must be called first/ runs within RDOM.Rcall)
  #convert coordinates to SVG to draw new polygon:
  svg_x <- gridSVG::viewportConvertX(panel, x, "native")
  svg_y <- gridSVG::viewportConvertY(panel, y, "native")
  # make pt string:
  pt <-  paste(svg_x, svg_y, sep = ",", collapse = " ")
  return(pt)
}

#' @title setPoints
#' @description allows setting attributes/styles of points over a range/index values
#' @param el element/class group to control
#' @param type the type of element (points, bars)
#' @param range either an index or a range (use index for subsetting row observations, range for aggregate data)
#' @param attrs list of attributes and stylings to apply
#' @export
setPoints <- function(el, type, range, attrs) {

# ideally, range could be a 'range' as well, rather than an index value.
if (type == "points") {

  idTags <- paste0(el, ".1.", range)
  #filter attributes to replace names with period to -:
  names(attrs) <- gsub("[.]", "-", names(attrs))

  setStyles <- function(obj) {
    for (names in names(attrs)) { ##TODO: vectorise!
      DOM::setAttribute(pageNo,
                        obj,
                        names,
                        attrs[[names]],
                        async = TRUE)
    }
  }

  #getElements and run the styling:
  sapply(idTags, function(x) {obj <- DOM::getElementById(pageNo,
                                                         x,
                                                        response = DOM::nodePtr(),
                                                        async = TRUE, callback = setStyles) })
      }
}
