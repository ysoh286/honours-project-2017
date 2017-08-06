# Be able to add elements to a page (for drawing):
#' @title addPolygon
#' @description add a polygon to the page with certain attributes
#' @param id a name/id for the polygon element
#' @param panel panel/viewport you want to attach this polygon to
#' @param attrs a list of attributes
#' @export
addPolygon <- function(id, panel, attrs) {

  pageNo <- p.env$pageNo

  # for this to occur: requires page to exist and graphs to be drawn first.
  panelObj <- DOM::getElementById(pageNo,
                             panel,
                             response = DOM::nodePtr())

  newPolygon <- DOM::createElementNS(pageNo,
                                "http://www.w3.org/2000/svg",
                                "polygon")

  DOM::appendChild(pageNo,
                  newPolygon,
                  parent = panelObj,
                  response = DOM::nodePtr())

  DOM::setAttribute(pageNo,
                    newPolygon,
                    "id",
                    id)

  names(attrs) <- gsub("[.]", "-", names(attrs))

  lapply(names(attrs), function(nm) {

      DOM::setAttribute(pageNo,
                        newPolygon,
                        nm,
                        attrs[[nm]])

    invisible(NULL)
    })

  invisible(NULL)

}

#' @title addLine
#' @description add a line/smooth/curve to the page with certain attributes
#' @param id a name/id for the line element
#' @param panelID panel/viewport to attach this line to
#' @param attrs a list of attributes for this line
#' @export
addLine <- function(id, panelID, attrs) {

  pageNo <- p.env$pageNo

  # create a new element + set its attributes:
  newLine <- DOM::createElementNS(pageNo,
                               "http://www.w3.org/2000/svg",
                               "polyline")

  #find panel: DEFINE VIEWPORT TO WHERE YOU'D LIKE TO ATTACH TO.
  panel <- DOM::getElementById(pageNo,
                               panelID,
                              response = DOM::nodePtr())

  DOM::appendChild(pageNo,
                  newLine,
                  parent = panel,
                  response = DOM::nodePtr())

  ## set id:
  ## to do: need validation code to make sure ID has not been taken
  DOM::setAttribute(pageNo, newLine, "id", id)

  ## fix attribute names:
  names(attrs) <- gsub("\\.", "-", names(attrs))

  lapply(names(attrs), function(nm) {

    DOM::setAttribute(pageNo,
                      newLine,
                      nm,
                      attrs[[nm]])

    invisible(NULL)
  })

  invisible(NULL)

}
