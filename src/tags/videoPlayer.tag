/* global videojs */
var $ = require('jquery');

<video-player>
  <!-- html5 shiv for video tags -->
  <script type="text/javascript">
  document.createElement('video');
  document.createElement('audio');
  document.createElement('track');
  </script>

  <video if={sources.length} id="video" preload="auto" width="{width}" height="{height}" crossorigin="anonymous" controls>
    <source each={sources} type={type} src={url}/>
    <track each={tracks} kind="captions" src={url} srclang="en" label="Drinks" default/>
  </video>

  var self = this;
  var events = opts.events;

  var videoElement = function(){
    return $('#video').get(0);
  };

  var updateVideo = function(filename){
    resizeVideo();
    self.update();
    var v = videoElement()
    var loaded = function(){
      events.trigger('videoLoaded');
      v.removeEventListener('play',loaded,false);
    };
    v.addEventListener('play',loaded,false);
    v.addEventListener('timeupdate',function(){
      var time = v.currentTime;
      events.trigger('timeUpdate',time);
    },false);
    v.play();
  }

  events.on('videoFilename',function(filename,subtitles){
    // loading local files will not work in chrome - however, it will work if you start with:
    // /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --allow-file-access-from-files
    self.tracks=[{
      url : subtitles
    }];
    self.sources=[{
      url : filename
    }];
    updateVideo();
  });

  events.on('scrub',function(amount){
    // this seems to cause a loader... which sucks but I can't seem to figure out how to do a live scrub.
    var v = videoElement();
    var isPaused = v.paused;
    v.pause();
    var currentTime = v.currentTime;
    v.currentTime = currentTime + amount;
    if(!isPaused) v.play();
  });

  events.on('seek',function(time){
    videoElement().currentTime = time;
  });

  events.on('changePlaybackRate',function(newRate){
    videoElement().playbackRate = newRate;
  });

  events.on('resumeVideo',function(){
    videoElement().play();
  });

  var resizeVideo = function(){
    var aspect = 9/16;
    self.width = $(window).width();
    self.height = self.width * aspect;
  };

  $(window).resize(function(){
    resizeVideo();
    self.update();
  });

  $(document).keydown(function(e){
    if(e.keyCode == 32){
      // space bar pressed, pause and fire an event
      var v = videoElement();
      v.pause();
      events.trigger('createMarkerAtTimestamp',v.currentTime);
    }
  });

  this.sources = [];
  this.preview = opts.preview;


</video-player>
