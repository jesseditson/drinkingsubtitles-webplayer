var $ = require('jquery');
require('jquery-mousewheel')($);

<controls>

  <div id="controls">
    <div class="file-selector">
      <input id="video-path" type="text" name="video-path" value={defaultValue} placeholder="path to video"/>
      <input id="subtitles-path" type="text" value={defaultSubtitlesValue} placeholder="path to subtitles"/>
      <input type="button" value="load video" onclick={loadVideo}/>
    </div>
    <div class="file-uploader" if={videoLoaded}>
      <input id="subtitles-path" type="file" onchange={loadSubtitles}/>
    </div>
    <div class="rangeslider" if={videoLoaded}>
      <input type="range" id="range" name="speed" min={minSpeed} value={playbackSpeed} max={maxSpeed} step=0.25 oninput={playbackRateChanged} />
      <label for="speed">{playbackSpeedStr}</label>
    </div>
    <div class="buttons" if={videoLoaded}>
      <input type="button" value="export subtitles" onclick={exportSubs}/>
      <!-- TODO: load the subtitles from localStorage -->
      <!-- <input type="button" value="reload subtitles" onclick={reloadSubs}/> -->
    </div>
  </div>

  this.defaultValue = "";
  this.defaultSubtitlesFile = "";
  var minSpeed = this.minSpeed = 0.5;
  var maxSpeed = this.maxSpeed = 4;
  this.playbackSpeed = 1;
  this.videoLoaded = false;
  var self = this;

  var events = opts.events;

  var setPlaybackRate = function(val){
    val = parseFloat(val);
    events.trigger('changePlaybackRate',val);
    self.playbackSpeed = val;
    // round to 2 decimals
    var humanVal = Math.round(val * 100) / 100;
    self.playbackSpeedStr = humanVal + 'x';
    // for some reason riot updates the value, but the range slider doesn't change.
    $('#range').val(val);
    self.update();
  }

  exportSubs(e) {
    events.trigger('export');
  }
  reloadSubs() {
    events.trigger('reloadSubtitles');
  }

  playbackRateChanged(e){
    var val = parseFloat(e.target.value);
    setPlaybackRate(val);
  }

  loadVideo() {
    var filename = $("#video-path").val();
    var subtitles = $("#subtitles-path").val();
    events.trigger('videoFilename',filename,subtitles);
  }

  loadSubtitles(e) {
    if(e.target.files && e.target.files[0]){
      events.trigger('importSubtitles',e.target.files[0]);
    }
  }

  events.on('videoLoaded',function(){
    self.videoLoaded = true;
    self.update();
  });

  var scrubFactor = 0.1;
  var speedFactor = 0.1;

  $(window).on('mousewheel', function(e) {
    var absY = Math.abs(e.deltaY);
    var absX = Math.abs(e.deltaX);
    if(absX > absY) {
      // scrolling horizontally
      var val = e.deltaX * scrubFactor;
      events.trigger('scrub',val);
    } else if(absY > absX) {
      // scrolling vertically
      // invert, as Y axis is top to bottom
      var amount = e.deltaY > 0 ? -0.02 : 0.02;
      // constrain to the max/min
      var val = Math.max(minSpeed,Math.min(maxSpeed,self.playbackSpeed + amount));
      setPlaybackRate(val);
    }
    return false;
  });

</controls>
