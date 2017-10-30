library(gridSVG)
library(grid)

grid.circle(x = 0.5, y = 0.5, r = 0.25, name = "circle.A",
            gp = gpar(fill = "yellow"))
grid.garnish('circle.A', onmouseover = "allred()",
            onmouseout = "allyellow()",
            "pointer-events" = "all")
grid.script("allred = function() {
  var circle = document.getElementById('circle.A.1.1');
  circle.setAttribute('fill', 'red');
  }")
grid.script("allyellow = function() {
  var circle = document.getElementById('circle.A.1.1');
  circle.setAttribute('fill', 'yellow');
  }")
grid.export("circle.svg")
