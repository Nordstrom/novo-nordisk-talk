Reveal.addEventListener( 'ready', function( event ) {
  var w = 960,
  h = 700,
  z = d3.scale.category20c(),
  i = 0;

  // For the Nordstrom Comic Image
  // probably a terrible way to do this.
  // but it works for now.
  // Draw image in a canvas. Use setInterval()
  // to start an animation of the image and pan it
  // uses d3.js for its easing capabilities.
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

  function startComic() {
    refreshIntervalId = setInterval(draw, 30);
  }
  // DONE - Nordstrom Comic Image 

  // This event listener gets triggered for each 'fragment' clicked through
  // a fragment is typically used to show another bullet point on the same slide
  // ex: http://lab.hakim.se/reveal-js/#/19
  // however, we can also harness fragments to trigger a 'sub-step' in a slide
  // depending on how many sub-steps we want - this might get messy - so
  Reveal.addEventListener( 'fragmentshown', function(event) {
    fragmentId = $(event.fragment).attr("id")

    // start Nordstrom Comic Image animation
    if(fragmentId == "nordstrom_comic_start") {
      startComic();
    }
  }, false );

});
