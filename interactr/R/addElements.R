# Be able to add elements to a page (for drawing):
#' @title addPolygon
#' @description add a polygon to the page with certain attributes
#' @param id a name/id for the polygon element
#' @param panel panel/viewport you want to attach this polygon to
#' @param attrs a list of attributes
#' @export
addPolygon <- function(id, panel, attrs) {

  # for this to occur: requires page to exist and graphs to be drawn first.
  panelObj <- DOM::getElementById(pageNo,
                             panel,
                             response = DOM::nodePtr())

  newPolygon <<- DOM::createElementNS(pageNo,
                                "http://www.w3.org/2000/svg",
                                "polygon")

  #assign("newPolygon", newPolygon, p.env)

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

    #newPolygon <- get(newPolygon, p.env)

      DOM::setAttribute(pageNo,
                        newPolygon,
                        nm,
                        attrs[[nm]])

    invisible(NULL)
    })

  invisible(NULL)

}
