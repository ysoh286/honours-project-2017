// draw points - random simulation
// code is adapted from: https://www.tutorialspoint.com/webgl/webgl_drawing_points.htm

// a more simpler example of rendering the webgl context:
var canvas = document.querySelector("canvas");
canvas.width = canvas.clientWidth;
canvas.height = canvas.clientHeight;
var gl = canvas.getContext("webgl") || canvas.getContext('experimental-webgl');
if (!gl) {
  alert("Your browser isn't supported!");
}

// defining points:

var vertices = [];

for (var i=0; i < 3000000; i++) {
  if ((i+1)%3 == 0) {
    vertices[i] = 0;
  } else if (i%2 == 0) {
    vertices[i] = Math.random() - 0.5;
  } else {
    vertices[i] = Math.random()
  }
}

//create empty buffer to store vertex buffer;
var vertex_buffer = gl.createBuffer();

//bind appropriate array buffer;
gl.bindBuffer(gl.ARRAY_BUFFER, vertex_buffer);

//pass vertex data;
gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);

// unbind buffer;
gl.bindBuffer(gl.ARRAY_BUFFER, null);

// SHADERS!

//vertex shader:
var vertCode =
            'attribute vec3 coordinates;' +

            'void main(void) {' +
               ' gl_Position = vec4(coordinates, 1);' +
               'gl_PointSize = 1.0;'+
            '}';

// Create a vertex shader object
var vertShader = gl.createShader(gl.VERTEX_SHADER);

// Attach vertex shader source code
 gl.shaderSource(vertShader, vertCode);

// Compile the vertex shader
  gl.compileShader(vertShader);

  // fragment shader source code
    var fragCode =
            'void main(void) {' +
               ' gl_FragColor = vec4(1.0, 1.0, 1.0, 0.0);' +
            '}';

   // Create fragment shader object
   var fragShader = gl.createShader(gl.FRAGMENT_SHADER);

  // Attach fragment shader source code
  gl.shaderSource(fragShader, fragCode);

  // Compile the fragmentt shader
  gl.compileShader(fragShader);

// Create a shader program object to store
  // the combined shader program
var shaderProgram = gl.createProgram();

// Attach vertex shader
 gl.attachShader(shaderProgram, vertShader);

// Attach fragment shader
  gl.attachShader(shaderProgram, fragShader);

// Link both programs
  gl.linkProgram(shaderProgram);

// Use the combined shader program object
  gl.useProgram(shaderProgram);

  /*======== Associating shaders to buffer objects ========*/

  // Bind vertex buffer object
    gl.bindBuffer(gl.ARRAY_BUFFER, vertex_buffer);

    // Get the attribute location
     var coord = gl.getAttribLocation(shaderProgram, "coordinates");

    // Point an attribute to the currently bound VBO
    gl.vertexAttribPointer(coord, 3, gl.FLOAT, false, 0, 0);

    // Enable the attribute
    gl.enableVertexAttribArray(coord);

    // DRAW:
    //clear canvas;
    gl.clearColor(0.0, 0.0, 0.0 ,1.0);

    //enable depth test;
    gl.enable(gl.DEPTH_TEST);

    //clear color:
    gl.clear(gl.COLOR_BUFFER_BIT);

    // set viewport:
    gl.viewport(0,0, canvas.width, canvas.height);

    //draw triangle;
    gl.drawArrays(gl.POINTS, 0, 1000000);
