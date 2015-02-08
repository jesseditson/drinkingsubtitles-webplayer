var storage = require('./storage');

var allSubs;

var esc = function(str){
  return str.replace('<','&lt;').replace('>','&gt;').replace('&','&amp;').replace(/(drink[^\s]+)/i,'<c.drink>$1</c>');
};

var timestamp = function(time){
  var seconds = parseFloat(time);
  var hours = Math.floor(seconds / 3600);
  var minutes = Math.floor((seconds - (hours * 3600)) / 60);
  var secs = Math.floor(seconds - (hours * 3600) - (minutes * 60));
  var ms = Math.round((seconds - (hours * 3600) - (minutes * 60) - secs) * 1000);

  if (hours < 10) hours = "0"+hours;
  if (minutes < 10) minutes = "0"+minutes;
  if (secs < 10) secs = "0"+secs;
  if (ms < 100 && ms > 10) ms = "0"+ms;
  if (ms < 10) ms = "00"+ms;
  var time = hours+':'+minutes+':'+secs+'.'+ms;
  return time;
};

var create = function(text,length){
  length = length || 8;
  var timeBegin = this.currentTime - this.subtitleOffset;
  var timeEnd = timeBegin + parseFloat(length);
  allSubs[timeBegin] = {
    start : timeBegin,
    end : timeEnd,
    text : text
  };
  this.save();
};

var nearest = function(time){
  var keys = Object.keys(allSubs);
  var i=0,len=keys.length;
  var last;
  for(i;i<len;i++){
    var key = keys[i];
    var n = parseFloat(key);
    if(n > time){
      // if we passed the timestamp, it's the previous one.
      break;
    }
    last = key;
  }
  var sub = allSubs[last];
  if(sub && time < sub.end){
    return sub;
  }
};

var update = function(text,length){
  var sub = this.current();
  if(sub){
    var timeEnd = sub.start + parseFloat(length);
    sub.text = text;
    allSubs[sub.start] = sub;
    this.save();
  }
  return sub;
};

var current = function(){
  return this.nearest(this.currentTime);
};

var deleteCurrent = function(){
  var s = this.current();
  delete allSubs[s.start];
  this.save();
};

var serializeWebVTT = function(formatStr){
  var out = "WEBVTT";
  formatStr = formatStr ? " " + formatStr : "";
  Object.keys(allSubs).forEach(function(key,index){
    var s = allSubs[key];
    out += "\n\n" + (index+1) + "\n";
    out += timestamp(s.start) + " --> " + timestamp(s.end) + (formatStr) + "\n";
    out += esc(s.text);
  });
  return out;
};

var save = function(){
  storage.set(this.storageKey,allSubs);
};

module.exports = function(config){
  if(!config || !config.events || !config.file){
    throw new Error('config object passed to subtitles constructor *must* have an events object and file key');
  }
  this.subtitleOffset = config.offset || 1;
  var events = config.events;
  this.filename = config.file;
  var self = this;

  this.storageKey = this.filename + '_subtitles_hash';

  allSubs = storage.get(this.storageKey) || {};

  events.on('timeUpdate',function(time){
    self.currentTime = parseFloat(time);
  });

  // puts the subtitles at the top right
  var defaultWebVTTFormat = "line:0 align:end";

  this.nearest = nearest.bind(this);
  this.create = create.bind(this);
  this.current = current.bind(this);
  this.deleteCurrent = deleteCurrent.bind(this);
  this.serializeWebVTT = serializeWebVTT.bind(this);
  this.save = save.bind(this);
}
