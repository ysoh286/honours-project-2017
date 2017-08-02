#' @title Add an HTML slider
#'
#' @description Add an HTML slider to the page
#'
#' @param name element id of slider
#' @param min minimum value of slider
#' @param max maximum value of slider
#' @param step increment for the slider
#' @param control.on an element (id) to control (optional)
#'
#' @export

addSlider <- function(name = "slider", min = 0, max = 10, step = 1, control.on = NULL) {

  htmlTag <- paste0('<input id ="', name,
                    '" type = "range"',
                    'min = "', min,
                    '" max = "', max,
                    '" step = "', step,
                    '" />')
  #append to page
  DOM::appendChild(pageNo,
                   child = DOM::htmlNode(htmlTag),
                   response = DOM::nodePtr())

  if (!is.null(control.on)) {
    plotObj <<- DOM::getElementById(pageNo,
                               paste0(control.on, '.1.1'),
                               response = DOM::nodePtr())
    #assign("plotObj", plotObj, p.env)
  }

  # append invisible paragraph to record values:
  DOM::appendChild(pageNo,
                   DOM::htmlNode('<p id="para"></p>'),
                   response = NULL)

}

## back functions to return slider value to R:
## this is maintained as a back function, but requires 'callback' to change accordingly.
# how can you change callback according to what the user has written?
sliderValue <- function(ptr) {
  value <- DOM::getProperty(pageNo, ptr, "value", async = TRUE, callback = defaultPrint)
}

defaultPrint <- function(value) {

  newPara <- DOM::htmlNode(paste('<p id="para">', value, '</p>'))
  DOM::replaceChild(pageNo, newPara, DOM::css("#para"), async=TRUE)

  # TODO: be able to insert a function that the user has defined (ie controlTrendline)??
  value <- as.numeric(value)
  controlTrendline(value)

}
