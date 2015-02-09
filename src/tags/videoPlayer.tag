/* global videojs */
var $ = require('jquery');

<video-player>

  <video if={sources.length} id="video" class="video-js vjs-default-skin vjs-big-play-centered"
    controls preload="auto" width="{width}" height="{height}">
    <source each={sources} src={url} type={type}/>
    <track each={tracks} kind="subtitles" src={url} srclang="en" label="Drinks" default/>
  </video>

  var self = this;
  var events = opts.events;
  var videoElement = function(cb){
    var v = $('#video');
    if(v.length) cb(videojs('video'),v.find('video').get(0));
  };

  var updateVideo = function(filename){
    resizeVideo();
    self.update();
    videoElement(function(v){
      v.one('play',function(){
        events.trigger('videoLoaded');
      });
      v.on('timeupdate',function(){
        var time = v.currentTime();
        events.trigger('timeUpdate',time);
      });
      v.play();
    });
  }

  events.on('videoFilename',function(filename,subtitles){
    self.tracks=[{
      url : subtitles
    }];
    self.sources = [{
      url : filename
    }];
    self.update();
    setTimeout(updateVideo,1000);
  });

  events.on('scrub',function(amount){
    // this seems to cause a loader... which sucks but I can't seem to figure out how to do a live scrub.
    videoElement(function(v){
      var isPaused = v.paused();
      v.pause();
      var currentTime = v.currentTime();
      v.currentTime(currentTime + amount);
      if(!isPaused) v.play();
    });
  });

  events.on('seek',function(time){
    videoElement(function(v){
      v.currentTime(time);
    });
  });

  events.on('changePlaybackRate',function(newRate){
    videoElement(function(v){
      v.playbackRate(newRate);
    });
  });

  events.on('resumeVideo',function(){
    videoElement(function(v){
      v.play();
    });
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
      videoElement(function(v){
        v.pause();
        events.trigger('createMarkerAtTimestamp',v.currentTime());
      });
    }
  });

  this.sources = [];
  this.preview = opts.preview;


</video-player>
