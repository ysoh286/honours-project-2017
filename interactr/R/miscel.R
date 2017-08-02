## Other functions that may be useful: generally for conversion and point change.

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
#' @param type either an index of points (row observations), or a string of coordinates to plot ("index" or "coords")
#' @param value vector of indices, or a character vector of coordinates
#' @param attrs list of attributes and stylings to apply (optional)
#' @export
setPoints <- function(el, type, value, attrs = NULL) {

# ideally, range could be a 'range' as well, rather than an index value.
  if (type == "index") {

    idTags <- paste0(el, ".1.", value)

    #filter attributes to replace names with period to -:
    names(attrs) <- gsub("[.]", "-", names(attrs))

    setStyles <- function(obj) {

      lapply(names(attrs), function(nm) {
        DOM::setAttribute(pageNo,
                          obj,
                          nm,
                          attrs[[nm]],
                          async = TRUE)

        invisible(NULL)
      })

    }

  #getElements and run the styling:
    sapply(idTags, function(x) {obj <- DOM::getElementById(pageNo,
                                                           x,
                                                          response = DOM::nodePtr(),
                                                          async = TRUE, callback = setStyles) })
  } else if (type == "coords") {

    newRegion <- DOM::getElementById(pageNo,
                                    el,
                                    response = nodePtr(),
                                    async = TRUE,
                                    callback = function(newRegion) {
                                      DOM::setAttribute(pageNo,
                                                        newRegion,
                                                        "points",
                                                        value,
                                                        async = TRUE)
                                    })

  } else {
    stop("Invalid input.type!")
  }

}
