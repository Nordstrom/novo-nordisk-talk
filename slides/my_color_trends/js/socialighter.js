var BanquoClient = (function () {
  $banquoServer = 'http://ec2-54-201-87-66.us-west-2.compute.amazonaws.com:3000'
  $screenshotContainer   = $('#image-container');
  $visSelector = "#vis"

  MYTRENDS = {}
  var me = {};

  function formatBanquoParams(params){
    var params_string_hash = [];
    d3.map(params).forEach(function(key, value){
      params_string_hash.push(key + '=' + value);
    })
    return params_string_hash.join('&');//.replace(/#/g, '%23').replace(/\//g, '__').replace(/,/g, '%2c');
  }

  function sendScreenshotQuery(params){
    var params_string_hash = formatBanquoParams(params);
    var url = $banquoServer + "/" + getScreenShotUrl() + "/" + encodeURIComponent(params_string_hash);
    console.log(url);
  return $.ajax({
    url: url,
         dataType: 'JSONP',
         callback: 'callback'
  })
  }

  function getScreenShotUrl(){
    var host = window.location.host + window.location.pathname;
    // latlng = window.location.hash,
    //     map_latlng = MYTRENDS.map.getCenter().lat + '/' + MYTRENDS.map.getCenter().lng,
    //     map_zoom   = MYTRENDS.map.getZoom();
    // if (latlng){
    //   return host + latlng + '/' + map_latlng + '/' + map_zoom; 
    // }else{
    //   showHideSubmitForm.toggleExpandContainer();
    //   alert("Please click on an area of the map before taking a screenshot.");
    //   return false;
    // }
    return encodeURIComponent(host);

  }

  function assembleBanquoSettings(){
    var opts = {
      mode: 'base64',
      delay: 2000,
      viewport_width: 700,
      selector: $visSelector,
      css_hide: '#vis_comps'
    };
    return opts
  }

  function checkBanquoNew(){
    if (!MYTRENDS.banquo_settings || MYTRENDS.banquo_settings.url != assembleBanquoSettings().url){
      return true
    }else{
      return false
    }
  }

  function beginScreenshotProcess(config){
    // $screenshotContainer.html('Processing screenshot <span class="ajmint-icon-arrows-cw"></span>')
    MYTRENDS.banquo_settings = assembleBanquoSettings();
    MYTRENDS.banquo_settings.key = config.key;
    sendScreenshotQuery(MYTRENDS.banquo_settings)
      .done(function(response){
        console.log('done');
        console.log(response);
        MYTRENDS.screenshot = response.path
        // $latlngGrabber.val(window.location.hash.replace('#',''));
        // $galleryDataInput.val(response.timestamp);
        $screenshotContainer.html('<img src="data:image/png;base64,' + response.image_data + '" />');
        // $submitGalleryBtn.attr('disabled', false)
      })
    .fail(function(err){
      $screenshotContainer.html('Please try again.');
      console.log('problem getting image. sorry');
      // alert('We had trouble saving your map image. Please try again later.');
    })
  }

  me.abortScreenshotRequest = function(){
    if (MYTRENDS.active_screenshot_call){
      MYTRENDS.active_screenshot_call.abort();
    }
  }

  me.getScreenshot = function(config){
    me.abortScreenshotRequest();
    if(checkBanquoNew()){
      beginScreenshotProcess(config);
    }
  }

  me.screenshotUrl = function() {
    return MYTRENDS.screenshot;
  }
  return me;
}());


var Socialighter = (function () {

  var me = {};

  me.sharing = function(data) {
    return $(".share_button").bind("click", function(e) {
      var el = $(this);
      console.log(el);
      var socialType = el.data("button-type");
      var href = window.location.href;
      if(!data.uri) {
        data.uri = href;
      }
      if(!data.origin) {
        data.origin = href;
      }

      var shareWindow = window.open("", "Share_Window", "menubar=0,resizable=1,width=550,height=350,toolbar=0,scrollbars=1,location=0");
      e.preventDefault();
      return $.ajax("/shorten", {
        dataType: "json",
        type: "POST",
        data: {
          long_url: href
        },
        timeout: 200,
        success: function (e) {
          // el.fadeTo(50, 1);
          // var n = e.status_code !== 200 ? s : e.data.url;
          data.img = BanquoClient.screenshotUrl();
          window.Socialighter.send_to_social(data, socialType, shareWindow);
        },
        error: function () {
          // el.fadeTo(50, 1);
          data.img = BanquoClient.screenshotUrl();
          window.Socialighter.send_to_social(data, socialType, shareWindow)
        }
      });
    });
  };

  me.send_to_social = function(data, type, shareWindow) {
    var shareUrl = "";
    switch (type) {
      case "twitter":
        shareUrl = "https://twitter.com/intent/tweet?" + "&text=" + data.title + "&url=" + encodeURIComponent(data.uri) + "&via=" + data.source + "&hashtags=" + "Ncolor";
        break;
      case "facebook":
        // shareUrl = "https://www.facebook.com/sharer.php?&p[url]=" + data.uri + "&p[title]=" + data.title + "&p[images][0]=";
        shareUrl = "https://www.facebook.com/sharer.php?&s=100&p[url]=" + data.uri + "&p[title]=" + data.title + "&p[images][0]=" + data.img;
        break;
      case "linked_in":
        shareUrl = "http://www.linkedin.com/shareArticle?mini=true&url=" + data.uri + "&title=" + data.title + "&summary=" + data.description + "&source=" + data.source;
        break;
      case "gplus":
        shareUrl = "https://plusone.google.com/_/+1/confirm?hl=en&url=" + data.uri;
        break;
      case "pintrest":
        shareUrl = "http://www.pinterest.com/pin/create/button/?url=" + encodeURIComponent(data.uri) + "&media=" + encodeURIComponent(data.img) + "&description=" + data.title;
    }
    shareWindow.location = shareUrl;
    
  };

  return me;
}());
