//learning webGL:

// these examples are from MDN tutorials:

var gl;

// this function is used to prepare webgl context:
function start() {
  var canvas = document.getElementById('glCanvas');

  gl = initWebGL(canvas);

  if (!gl) {
    return;
  }

  // set color to green;
  gl.clearColor(0.0, 0.5, 0.0, 1.0);
  // this draws a rectangle bar;
  gl.enable(gl.SCISSOR_TEST);
  gl.scissor(40, 20, 60, 130);
  //depth testing:
  gl.enable(gl.DEPTH_TEST);
  gl.depthFunc(gl.LEQUAL);
  //clear colors and depth buffer;
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  // to resize:
  gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);
}

//create a webgl context (initializing:

function initWebGL(canvas) {
  gl = null;

  //grab standard context:
  gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');

  if (!gl) {
    alert("Unable to initialize webGL. Browser unsupported.");
  }

  return(gl);
}

//add an event listener: simple color switch when canvas is selected:
function switchColor () {
  if (!gl) {
    gl = canvas.getContext("webgl") || canvas.getContext("experimental-webgl");
  if (!gl) {
    alert("Browser unsupported!");
    return;
  }

  gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);

}
  //get a random color
  var color = getRandomColor();

  gl.clearColor(color[0], color[1], color[2], 1.0);

  gl.clear(gl.COLOR_BUFFER_BIT);

}

function getRandomColor() {
  return [Math.random(), Math.random(), Math.random()];
}


start();
var canvas = document.getElementById("glCanvas");
canvas.addEventListener("click", switchColor, false);

//clearing colors: make it render green!

// a more simpler example of rendering the webgl context:
function getRenderingContext() {
  var canvas = document.querySelector("canvas");
  canvas.width = canvas.clientWidth;
  canvas.height = canvas.clientHeight;
  var gl = canvas.getContext("webgl") || canvas.getContext('experimental-webgl');
  if (!gl) {
    alert("Your browser isn't supported!");
    return null;
  }
  gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);
  gl.clearColor(0.0, 0.0, 0.0, 1.0);
  gl.clear(gl.COLOR_BUFFER_BIT);
  return gl;
};
