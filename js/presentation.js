Reveal.addEventListener( 'ready', function( event ) {
  var w = 960,
  h = 700,
  z = d3.scale.category20c(),
  i = 0;

  // For the Nordstrom Comic Image
  var canvas = document.getElementById('nord_hist');
  var context = canvas.getContext('2d');
  var imageObj = new Image();
  imageObj.onload = function() {
    context.drawImage(imageObj, 0, 0);
  };
  imageObj.src = 'images/comic_small.jpg'

  var x = 0;
  var y = 0;
  var ease = d3.ease("cubic-in-out");
  var timeInc = 1 / 120.0;
  var refreshIntervalId;
  var time = 0;
  function draw() {
    time += timeInc;
    var pos = ease(time) * -1090;
    context.drawImage(imageObj, pos, 0);
    if (pos <= -1090) {
      clearInterval(refreshIntervalId);
    }
  }

  $('#nord_hist').on("click", function() { 
    refreshIntervalId = setInterval(draw, 30);
  });
  Reveal.addEventListener( 'fragmentshown', function(event) {
    fragmentId = $(event.fragment).attr("id")
    if(fragmentId == "nordstrom_comic_start") {
      refreshIntervalId = setInterval(draw, 30);
    }
  }, false );
  // DONE - Nordstrom Comic Image 

});
