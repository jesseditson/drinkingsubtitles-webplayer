var riot = require('riot');
var $ = require('jquery');
var storage = require('./storage');
var Subtitles = require('./subtitles');

// include our tags
require('../tags/videoPlayer.tag');
require('../tags/controls.tag');
require('../tags/subtitleBox.tag');

var eventBus = riot.observable();

var needsInit = true;

var currentVideo;
var subtitles;

eventBus.on('videoFilename',function(f){
  currentVideo = f;
  if(needsInit) {
    var hasStorage = storage.hasStorage();
    if(!hasStorage) return alert('Your browser doesn\'t support html5 storage, so we can\'t create subtitles.');
    needsInit = false;
    $('.video-holder').empty().html('<video-player>');
    riot.mount('video-player',{events : eventBus});
    eventBus.trigger('videoFilename',f);
    needsInit = true;
    subtitles = new Subtitles({
      file : f,
      events : eventBus
    });
  }
});

eventBus.on('videoLoaded',function(){
  var time = storage.get(currentVideo + '_time');
  if(time){
    eventBus.trigger('timeUpdate',time);
    eventBus.trigger('seek',time-5);
  }
});

var currentSub;

eventBus.on('timeUpdate',function(time){
  storage.set(currentVideo + '_time',time);
  var cs = subtitles.current();
  if(cs && (!currentSub || cs.start != currentSub.start)){
    currentSub = cs;
  } else if(!cs) {
    currentSub = null;
  }
});

eventBus.on('createSubtitle',function(subtitle){
  subtitles.create(subtitle.text, subtitle.length);
});

eventBus.on('export',function(){
  // create a download of the subtitles file
  var text = subtitles.serializeWebVTT();
  var pom = document.createElement('a');
  pom.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
  pom.setAttribute('download', 'drinking-subtitles.vtt');
  pom.click();
});

eventBus.on('importSubtitles',function(file){
  subtitles.loadFromFile(file);
});

riot.mount('controls,subtitle-box',{events : eventBus});
