#' @title Add a linking selection box
#' @description allows user to draw a selection rectangle which captures points within that region
#' Currently only works for (lattice) scatterplots and for a single SVG plot only.
#' @param plotNum the plot number on the page (from left to right, starting from 1)
#' @param el the element id/tag to capture (points only)
#' @export
#'
addSelectionBox <- function(plotNum = 1, el) {

  ##for now, this is only for attaching to a single SVG only.
  #currently only  works with capturing point index.

  pageNo <- p.env$pageNo

  if(is.null(pageNo)) {
    stop("No page to send to! Start a new page using draw().")
  }

  panel <- findPanel(el)

  ## append a selection box:
  addPolygon("selectRect", panel, attrs = list(fill.opacity = "0", class = "selectRect", pointer.events = "none"))

  DOM::appendChild(pageNo,
                   child = DOM::javascript(paste0("var panelId = '", panel, "';" )))

  DOM::appendChild(pageNo,
                  child = DOM::javascript(paste0("var pointId = '", el, ".1';")))

  ## identify svg:
  DOM::appendChild(pageNo,
                  child = DOM::javascript(paste0("var svg = document.getElementsByTagName('svg')[", plotNum-1,"]")))

  ## attach js - TODO: should only run ONCE.
  DOM::appendChild(pageNo,
                   child = DOM::javascript(paste(readLines(system.file("inst/js", "selection-box.js", package="interactr")), collapse = "\n")),
                   response = DOM::nodePtr())

  js <- "svg.addEventListener('mouseup', MouseUp, false);
  svg.addEventListener('mousedown', MouseDown, false);
  svg.addEventListener('mousemove', MouseDrag, false); "

  DOM::appendChild(pageNo,
              child = DOM::javascript(js))

  invisible(NULL)

  # for now this only returns the indexes.
  # could return coordinates.

}
