// draw points - random simulation - in canvas;

var canvas = document.getElementById('canvas'),
    width = canvas.width,
    height = canvas.height;

//define context;
ctx = canvas.getContext("2d");

for (var i = 0; i < 1000000; i++) {
  ctx.fillRect(Math.random()*600, Math.random()*600, 1, 1);
};
