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
  var timeInc = 1 / 240.0;
  var refreshIntervalId;
  var time = 0;

  function draw() {
    d3.timer(function() {
      time += timeInc;
      var pos = ease(time) * -1090;
      context.drawImage(imageObj, pos, 0);
      if (pos <= -1090) {
        return true;
      }
    });
  }

  function startComic() {
    draw();
  }
  // DONE - Nordstrom Comic Image 

  // postMessage() sub-steps
  // example of using postMessage() to send a message to an iframe
  // here, we send the 'start' message to the iframe. 
  // the second argument indicates the origin server of the iframe.
  // a '*' indicates it could be anything - probably our best bet.
  //
  // this functionality requires the iframe to be listening for 
  // messages using addEventListener()
  // derived from: http://viget.com/extend/using-javascript-postmessage-to-talk-to-iframes
  function sendIframe(iframeId, message) {
    iframe = document.getElementById(iframeId);
    iframe.contentWindow.postMessage(message, '*');
  }

  function fillerUp() {
    var el = $('.reveal');
    var width = el.width();
    var height = el.height();
    var angle = 2 * Math.PI;
    $('<canvas>').attr({
      id:'filler_canvas'
    }).css({
      width: width + 'px',
      height: height + 'px'
    }).appendTo(el);

    var canvas = document.getElementById('filler_canvas');
    canvas.width = width;
    canvas.height = height;
    var context = canvas.getContext('2d');
    context.fillStyle = "steelblue";
    context.strokeStyle = "#666";
    context.strokeWidth = 1.5;

    var x = d3.scale.linear()
      .domain([-5, 5])
      .range([0, width]);

    var y = d3.scale.linear()
      .domain([-5, 5])
      .range([0, height]);

    var data = d3.range(500).map(function() {
      return {xloc: 0, yloc: 0, xvel: 0, yvel: 0};
    });

    var time0 = Date.now(),
        time1;

    d3.timer(function() {
      context.clearRect(0, 0, width, height);

      data.forEach(function(d) {
        d.xloc += d.xvel;
        d.yloc += d.yvel;
        d.xvel += 0.04 * (Math.random() - .5) - 0.05 * d.xvel - 0.0005 * d.xloc;
        d.yvel += 0.04 * (Math.random() - .5) - 0.05 * d.yvel - 0.0005 * d.yloc;
        context.beginPath();
        context.arc(x(d.xloc), y(d.yloc), Math.min(1 + 2000 * Math.abs(d.xvel * d.yvel), 40), 0, angle);
        context.fill();
        context.stroke();
      });

      time1 = Date.now();
      time0 = time1;
      if($("#filler_canvas").length == 0) {
        console.log('stopping');
        return true;
      }
    });
  }

  function removeElement(elId) {
    var el = $("#" + elId);
    if(el) {
      el.remove();
    }
  }

  // This event listener gets triggered for each 'fragment' clicked through
  // a fragment is typically used to show another bullet point on the same slide
  // ex: http://lab.hakim.se/reveal-js/#/19
  // however, we can also harness fragments to trigger a 'sub-step' in a slide
  // depending on how many sub-steps we want - this might get messy - so
  Reveal.addEventListener( 'fragmentshown', function(event) {
    fragmentId = $(event.fragment).attr("id")

    if(fragmentId == "nordstrom_comic_start") {
      // start Nordstrom Comic Image animation
      startComic();
    } else if (fragmentId == 'dot_map_start') {
      // start dot map dots
      sendIframe('dotmap_iframe', 'start');
    } else if (fragmentId == 'timeline_start') {
      // start dot map dots
      sendIframe('timeline_iframe', 'start');
    }
  }, false );

  Reveal.addEventListener( 'start_fingerprints', function() {
    sendIframe('fingerprints_iframe', 'start');
  }, false );

  Reveal.addEventListener( 'start_scale', function() {
    fillerUp();
  }, false );

  // I don't know how to find the data-state of the previous
  // slide expect for this. We could certainly abstract this a bit
  // and make it more reusable - by firing events - for example. 
  // 
  // the state of a previous slide is useful to stop an animation
  // or remove an element that is present on the background - 
  // for example
  //
  // also see this code - which does abstract state changes better:
  // https://github.com/dimroc/reveal.js-threejs/blob/gh-pages/js/samples.js
  //
  Reveal.addEventListener( 'slidechanged', function( event ) {
    // event.previousSlide, event.currentSlide, event.indexh, event.indexv
    previousState = $(event.previousSlide).attr("data-state");
    if (previousState == 'start_scale') {
      removeElement('filler_canvas');
    } else if(previousState == 'start_fingerprints') {
      sendIframe('fingerprints_iframe', 'stop');
    }
  });

});
