# DOM - simple circle (Figure 3.7)
# requires DOM, grid, gridSVG, XML

#draw circle in grid
pdf(NULL)
grid::grid.circle(x = 0.5, y = 0.5, r = 0.25,
                 name = "circle.A", gp = grid::gpar(fill = "yellow"))
#export SVG
svg <- gridSVG::grid.export(NULL)$svg
dev.off()

#set up new page and add circle:
library(DOM)
page <- htmlPage()
appendChild(page,
            child = svgNode(XML::saveXML(svg)),
            ns = TRUE,
            response = svgNode())

circle <- getElementById(page, "circle.A.1.1", response = nodePtr())
# hover effects:
turnRed <- function(ptr) {
  setAttribute(page,
              circle,
              "fill",
              "red",
              async = TRUE)
}

turnYellow <- function(ptr) {
  setAttribute(page,
              circle,
              "fill",
              "yellow",
              async = TRUE)
}

setAttribute(page,
             circle,
             "onmouseover",
             "RDOM.Rcall('turnRed', this, ['ptr'], null)")

setAttribute(page,
             circle,
             "onmouseout",
             "RDOM.Rcall('turnYellow', this, ['ptr'], null)")

# add instructions to the page:
appendChild(page,
            htmlNode('<p id="man" style = "font-weight: bold;">
            Hover over the circle and it will turn red! </p>'))
