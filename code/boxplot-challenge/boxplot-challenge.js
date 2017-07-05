// Boxplot challenge - simple interaction:

var Grob = 'DOTPOINTS.1',
    count = document.getElementById(Grob).childElementCount;

//To get boxes:
//Obtaining the 'polygon' boxes associated with the boxplot:
var polygonBox = document.getElementsByTagName('polygon');
var polygonId = polygonBox[polygonBox.length -1].id;
var idLine = polygonId.substring(0, polygonId.lastIndexOf('.'));

for (i = 1; i <= polygonBox.length; i ++) {
  if (polygonBox[i-1].id.indexOf(idLine) >= 0){
    polygonBox[i-1].setAttribute('class', 'box');
  }
}

//Box Plot interactions:
var box = document.getElementsByClassName('box');
var lowerBox = box[0];
var upperBox = box[1];

//setting interactions and colors for lower box:
  lowerBox.addEventListener('mouseover', fillBox, false);
  lowerBox.addEventListener('mouseout', normalBox, false);
  lowerBox.addEventListener('click', showPoints, false);
  //box[i].addEventListener('click', showBox, false);


function fillBox() {
  lowerBox.setAttribute('fill', 'red');
};

function normalBox() {
  lowerBox.setAttribute('fill', 'transparent');
};

function showPoints() {
  //Get the min and max of x:
  var points = lowerBox.getAttribute('points').split(" ");
  var x1 = points[0].split(",")[0];
  var x2 = points[2].split(",")[0];

  for (i = 1; i <= count; i ++) {
    var dot = document.getElementById(Grob + '.' + i);
    var x = dot.x.baseVal.value;
    //run condition where if x is between the min and max of the box:
    if (x1 <= x && x <= x2) {
      dot.setAttribute('fill', 'red');
      dot.setAttribute('fill-opacity', '1');
    } else {
      dot.setAttribute('fill', 'none');
      dot.setAttribute('fill-opacity', '0');
    }
  }


}
