//non d3 version:
fill = function(id, color) {
var plotObj = document.getElementById(id);
plotObj.setAttribute('fill', color);
plotObj.setAttribute('fill-opacity', '1');
}

unfill = function(id) {
var plotObj = document.getElementById(id);
plotObj.setAttribute('fill', 'transparent');
}

highlightPoints = function(obj, plObj) {

var plotObj = document.getElementById(obj);
//Get the min and max of x:
var range = plotObj.getAttribute("points").split(" ");
var min = range[0].split(",")[0];
var max = range[2].split(",")[0];

var count = document.getElementById(plObj).childElementCount;

for (i = 1; i <= count; i ++) {
  var dot = document.getElementById(plObj + "." + i);
  var x = dot.x.baseVal.value;
//run condition where if x is between the min and max of the box:
if (min <= x && x <= max) {
    dot.setAttribute("fill", "red");
    dot.setAttribute("fill-opacity", "1");
  } else {
    dot.setAttribute("fill", "none");
    dot.setAttribute("fill-opacity", "0");
    }
  }
}

filter = function(label, type, range) {
  var panel = document.getElementById(label);

  if (type == "points") {
    var count = label.childElementCount;
    for (var i = 1; i <= count; i ++) {
      var point = document.getElementById(label + '.' + i);
        point.setAttribute('data-pt', tab[i-1].x);
      //run condition where if x is between the min and max of the box:
      if (range.min <= tab[i-1].x && tab[i-1].x <= range.max) {
        point.setAttribute('fill', 'red');
        point.setAttribute('fill-opacity', '1');
      } else {
        point.setAttribute('fill', 'none');
        point.setAttribute('fill-opacity', '0');
        }
      }
    }
  }


highlight = function(label, fillColor, strokeColor, filterOn) {
  var label = document.getElementById(label + '.1.1');
    if (fillColor != null) {
      label.setAttribute('fill', fillColor);
      label.setAttribute('fill-opacity', 1);
    } else {
      label.setAttribute('stroke', strokeColor);
    }

  // for filtering points - relative to other plot:
  if (filterOn == true) {
    filter(panel2, "points", range)
  }

}
