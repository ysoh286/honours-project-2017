// creating a linked brush for lattice plots:
var panelId = 'graphics-plot-1-box-1.1';
//var num = document.getElementById(panelId).childElementCount;

// obtaining svg region:
var svg = document.getElementsByTagName('svg')[0];

//putting selection rectangle in a group element:
var g = document.createElementNS('http://www.w3.org/2000/svg', 'g');
  g.setAttributeNS(null, 'id', 'selectionBox');
  var panel = document.getElementById(panelId);
  panel.appendChild(g);

//Mouse events:
svg.setAttribute('onmouseup', 'MouseUp(evt)');
svg.setAttribute('onmousemove', 'MouseDrag(evt)');
svg.setAttribute('onmousedown', 'MouseDown(evt)');

  var selectRect = document.createElementNS('http://www.w3.org/2000/svg', 'polygon');
  selectRect.setAttributeNS(null, 'id', 'selectRect');
  selectRect.setAttributeNS(null, 'class', 'selectRect');
  selectRect.setAttributeNS(null, 'fill-opacity', '0');
  g.appendChild(selectRect);

var zoomBox = {};

MouseDown = function(evt) {
    zoomBox["startX"] = evt.pageX;
    zoomBox["startY"] = evt.pageY - 40;
    zoomBox["isDrawing"] = true;
   selectRect.setAttribute('points',  zoomBox["startX"] + ',' + zoomBox["startY"]);
};


MouseUp = function(evt) {
  svg.style.cursor = "default";
      zoomBox["endX"] = evt.pageX;
      zoomBox["endY"] = evt.pageY - 40;
      zoomBox["isDrawing"] = false;

  };

MouseDrag = function(evt) {
    if(zoomBox["isDrawing"]) {
        svg.style.cursor = "crosshair";
        zoomBox["endX"] = evt.pageX;
        zoomBox["endY"] = evt.pageY - 40;

        //Because the y-axis is inverted in the plot - need to invert the scale
        var tVal = document.getElementsByTagName('g')[0].getAttribute('transform').substring(13, 16);
        var selectRect = document.getElementById('selectRect');

         // for rectangles with positive height, positive width
        if(zoomBox["startX"] < zoomBox["endX"]) {
        var x1 = zoomBox["startX"];
        var x2 = zoomBox["endX"];
      } else {
        var x1 = zoomBox["endX"];
        var x2 = zoomBox["startX"];
      }

      // for rectangles with opposite directions ('negative' widths, heights)
      if (zoomBox["startY"] < zoomBox["endY"]) {
        var y1 = tVal - zoomBox["startY"] - (zoomBox["endY"]-zoomBox["startY"]);
        var y2 = y1 + (zoomBox["endY"]-zoomBox["startY"]);
      } else {
        var y1 = tVal - zoomBox["endY"] - (zoomBox["startY"]-zoomBox["endY"]);
        var y2 = y1 + (zoomBox["startY"]-zoomBox["endY"]);
      }

        selectRect.setAttribute('points', x1 + ',' + y1 + " " + x1 + ',' + y2 + ' '
                                  + x2 + ',' + y2 + ' ' + x2 + ',' + y1);

          var selected = [];
          selected.push(x1, y1 - 60, x2, y2 - 60);
        //return selected rows to Shiny?
        Shiny.onInputChange("selectedPoints", selected);

        }
};
