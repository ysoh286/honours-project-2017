/* JavaScript code for dot plots and scatterplots. */


//create form and select options for variable selection/display.
//createVariableSelectionForm();

/* -------------------------------------------------------
              dotplot and scatterplot interactions
      Code to assign points (and hide certain things),
      create svg labels for each point, boxplot labels,
      drive interaction (hovers, clicks, reset).
      Data is also parsed.
      Select option interaction.
---------------------------------------------------------- */

var svg = document.getElementsByTagName('svg')[0];
//svg.setAttribute('preserveAspectRatio', 'xMinYMin meet');

//set container with no style padding:
//var svgContainer = document.getElementById('svg-container');
//svgContainer.classList.add('contained');

if (boxData != undefined) {
  // for dotplots only...
  var Grob = "DOTPOINTS.1",
      count = document.getElementById(Grob).childElementCount,
      panel = document.getElementsByTagName('g')[0];

  var lastLine = getMinMaxLinesId();
  getBoxes("dotplot");

  boxLabelSet(0, 1, 0,'LQ');
  boxLabelSet(1, 2, 2, 'UQ');
  boxLabelSet(1, 0, 1, 'Median');
  boxLabelSet(1, 0, 3, 'Min');
  boxLabelSet(2, 1, 4, 'Max');

  //Box Plot interactions:
  var box = document.getElementsByClassName('box');
  var boxData = document.getElementsByClassName('boxData');

  //setting interactions and colors for box plot:
  for (i = 0; i < box.length; i++) {
    box[i].addEventListener('mouseover', fillBox, false);
    box[i].addEventListener('mouseout', normalBox, false);
    box[i].addEventListener('click', showBox, false);
  }

} else {
  var Grob = "SCATTERPOINTS.1";
  var count = document.getElementById(Grob).childElementCount;
  var panel = document.getElementsByTagName('g')[0];
}

//POINT LABELS:

//making rectangles and g elements for each point:
for (i = 1; i <= count; i++) {
  gLabel(i);
};

for (i = 1; i <= count; i++) {
  gRect(i);
}

//Create number and value labels:
for (j = 0; j < names.length; j++) {

for (i  = 1; i <= count; i++) {

  var varNo = names.length + 1;
  var point = document.getElementById(Grob + '.' + i);
  var x = Number(point.getAttribute('x'));
  var y = Number(point.getAttribute('y'));

  text = [];
  text[j] = names[j] + ": ";
  label('label' + '.' + (j+1) + '.' , text[j], i, (varNo-j-1)*11);

  var lab = document.getElementById('label' + '.' + (j+1) + '.' + i);
  tLabel('tLabel', tableData[i-1][names[j]], i, lab);
  lab.classList.add((j+1));

// Attach and draw rectangles to labels according to the size of the gLabel (with all labels attached)
  drawRectLabel(i);
  }
};

/// INTERACTION CODE: Hovers, Clicks, Legends
//Hovers, clicks on points to show labels and data from table:

for (i = 1; i <= count; i++) {
  (function(i){
    var point = document.getElementById(Grob + '.' + i);
    point.addEventListener("mouseover",function(){light(i, 'showPoint')},false);
    point.addEventListener("mouseout", function(){normal(i, 'showPoint')}, false);
    point.addEventListener("click", function(){info(i)}, false);
    point.addEventListener("dblclick", function(){deselect(i)}, false);
    }) (i)
  };

//On click:
function info(i) {
  for (j = 1; j <= count; j++) {
    var point = document.getElementById(Grob + "." + j);
    var gLabel = document.getElementById('gLabel' + j);

    var l = point.getAttribute('stroke');
    var lp = l.substring(l.lastIndexOf("("), l.lastIndexOf(")"));

if (point.getAttribute('class') != "point selected") {
    if (i == j) {
      gLabel.classList.remove('invisible');

      point.setAttribute('class', 'point selected');

    } else {
      gLabel.classList.add('invisible');
      point.setAttribute('class', 'point none');

    }
  }
}
  if (boxData != undefined) {
 boxData = document.getElementsByClassName('boxData');
    hideBox();
}
};

//on doubleclick to deselect points
deselect = function(i) {
  for (j = 1; j <= count; j++) {
    var point = document.getElementById(Grob + "." + j);
    var gLabel = document.getElementById('gLabel' + j);

    if (i == j) {
      gLabel.classList.add('invisible');

      point.setAttribute('class', 'point none');
    }
}
};


//LEGEND INTERACTION:

if (colGroupNo != (0 || undefined)) { // if there is a legend, colGroupNo should be a value
//grabbing keys and text from the legend:
var keys = document.getElementsByTagName('use');
var text = document.getElementsByTagName('text');

//assigning mouse events:
for (i = 1; i <= colGroupNo; i ++) { //colGroupNo -> colby levels from R (nlevels)
  var key = document.getElementById(keys[i-1].id),
      keyText = document.getElementById(text[i+3].id);
    if (Grob == "DOTPOINTS.1") { // for dot plots - legend text differs
            var keyText = document.getElementById(text[i+2].id);
      }
  (function(i){
  key.addEventListener("mouseover", function(){show(i)}, false);
  key.addEventListener("mouseout", function(){out(i)}, false);
  key.addEventListener("click", function(){subset(i)}, false);

  keyText.addEventListener("mouseover", function(){show(i)}, false);
  keyText.addEventListener("mouseout", function(){out(i)}, false);
  keyText.addEventListener("click", function(){subset(i)}, false);
}) (i)
};

//on click, subsetting occurs:
subset = function(i) {
  for (j = 1; j <= count; j++) {
    var point = document.getElementById(Grob + '.' + j);
    var key = document.getElementById(keys[i-1].id);
    var gLabel = document.getElementById('gLabel' + j);
    var dataRow = document.getElementById('tr' + j);

if (key.getAttribute('fill') == point.getAttribute('stroke')) {
  point.setAttribute('class', 'point selected');
} else {
  point.setAttribute('class', 'point none');
      }
    }
  }
};

/* Link to interactive table + labels - "Variables to display" select/option box:
- Requires revision due to browser incompatibility. */

selected = function() {
sOpt = selectVar.selectedOptions;
// this does not work on IE, and not fully supported. May need to replace this.
s = [];
for (i =0; i < sOpt.length; i++) {
  s.push(sOpt[i].value);
};

var svg = document.getElementsByTagName('svg')[0];

for (i =1; i <= ncol; i++) {
  var labels = svg.getElementsByClassName(i);

  for(j = 1; j <= labels.length; j++) {
    if (s.indexOf('0') >= 0) {

        labels[j-1].style.display = "inherit";
        detachRectLabel(j);
        gRect(j);
        drawRectLabel(j);
    } else {
      labels[j-1].style.display = "none";
    }
  }
};

for (i=0; i <= s.length; i++) {
  if (s[i] != undefined) {
    labels = svg.getElementsByClassName(s[i]);
    for (j = 1; j <= labels.length; j++) {

     labels[j-1].style.display = "inherit";
     labels[j-1].visibility = "inherit";
     //redraw rectangles according to new label size:
     detachRectLabel(j);
     gRect(j);
     drawRectLabel(j);
      }
    }
  }
};

/* --------------------------------------------------------------
Code to select over a group of points via mouse drag.
//Need to test on IE.
----------------------------------------------------------------- */

//obtaining svg region:
var svg = document.getElementsByTagName('svg')[0];
svg.setAttribute('draggable', 'false');

//create 'invisible' selection box for users:
  createSelectionBox(Grob);

var evt = window.event;
var zoomBox = {};

//Attach mouse events:
svg.setAttribute('onmouseup', 'MouseUp(evt)');
svg.setAttribute('onmousemove', 'MouseDrag(evt)');
svg.setAttribute('onmousedown', 'MouseDown(evt)');

MouseDrag = function(evt) {
    if(zoomBox["isDrawing"]) {
        svg.style.cursor = "crosshair";
        zoomBox["endX"] = evt.pageX - 20;
        zoomBox["endY"] = evt.pageY - 20;

        //Because the y-axis is inverted in the plot - need to invert the scale
         tVal = document.getElementsByTagName('g')[0].getAttribute('transform').substring(13, 16);
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

        for (i =1; i <= count; i++) {
        var point = document.getElementById(Grob + '.' + i);

          var x = point.x.baseVal.value;
          var y = point.y.baseVal.value;

              //points that lie within the  boundary box drawn:
          if((x1 <= x && x <= x2) && (y1 <= y && y <= y2)) {
            point.setAttribute('class', ' point selected');
            l = point.getAttribute('stroke');
            lp = l.substring(l.lastIndexOf("("), l.lastIndexOf(")"));


           } else {
             point.setAttribute('class', 'point none');

          }
       }
    }
};


/* -------------------------------------------------
      Reset button - attempts to return to original state
-------------------------------------------------- */
//Reset Button:
  reset = function() {
    for (i = 1; i <= count; i++) {
    var point = document.getElementById(Grob + "." + i);
      point.setAttribute('class', 'point');

    var gLabel = document.getElementById('gLabel' + i);
    gLabel.classList.add('invisible');

    var gRect = document.getElementById('gRect' + i);
    gRect.classList.remove('hidden');

    }
    // reset selection rectangle
    var selectRect = document.getElementById('selectRect');
    if (selectRect != undefined) {
      selectRect.setAttribute('points', '0,0');
  }

};

// deselection/reset using plotregion double-click:
var plotRegion = document.getElementsByTagName('rect')[1];
plotRegion.addEventListener("dblclick", reset, false);
